# green_wave_auto_final.py
# Автозапись (VLC) или готовое видео → авто-детект светофоров (YOLOv8, multi-frame)
# → робастная классификация фаз → дебаунс/склейка → CSV/PNG/Report с циклами

import os, sys, csv, math, shutil, subprocess, datetime
from dataclasses import dataclass
from pathlib import Path
from typing import List, Dict, Tuple, Optional

import cv2
import numpy as np
import matplotlib.pyplot as plt
from ultralytics import YOLO

# ====== ПАРАМЕТРЫ ======
VLC_EXE_DEFAULT = r"C:\Program Files\VideoLAN\VLC\vlc.exe"

# Вход: либо URL .m3u8, либо локальный файл .ts/.mp4 и т.п.
DEFAULT_RECORD_SEC = 300
DEFAULT_INTERVAL_SEC = 1.0

# YOLO — сперва точнее (s), потом легче (n)
YOLO_WEIGHTS_TRY = ["yolov8s.pt", "yolov8n.pt"]
CLASS_TRAFFIC_LIGHT = 9        # COCO id "traffic light"
CONF_THRES = 0.15              # понижен для слабых объектов
IOU_THRES  = 0.45
YOLO_IMGSZ = 1280              # увеличенный вход
UPSCALE_DET_FACTOR = 1.8       # апскейл кадра перед детекцией

# Поиск по множеству кадров от начала записи
DETECT_SCAN_SECONDS = 12
DETECT_MAX_FRAMES   = 60
NMS_MERGE_IOU       = 0.50
MIN_BOX_W, MIN_BOX_H = 12, 20  # отсечь мусор (пиксели)

# Робастная классификация секций (работает и ночью)
MIN_FILL   = 0.03    # доля пикселей цвета в секции (3%)
MIN_BRIGHT = 0.45    # средняя яркость V внутри маски (0..1)
MARGIN_RATIO = 1.15  # лидер должен быть на 15% выше второго

# Дебаунс: минимальное «удержание» нового состояния до фиксации
MIN_HOLD_SEC = 3.0
# Слитие коротких «шипов» после анализа
MERGE_SPIKE_SEC = 2.5

MAX_LIGHTS_TO_DRAW = 12

# ====== УТИЛИТЫ ======
def ask(prompt: str, cast=str, default=None):
    s = input(f"{prompt}" + (f" [{default}]" if default is not None else "") + ": ").strip()
    if not s and default is not None: return default
    try: return cast(s)
    except: print("Неверный ввод."); return ask(prompt, cast, default)

def is_url(s: str) -> bool:
    return s.lower().startswith(("http://", "https://"))

def vlc_cmd(vlc_path: Optional[str]) -> str:
    return vlc_path if (vlc_path and os.path.exists(vlc_path)) else VLC_EXE_DEFAULT

def record_via_vlc(url: str, secs: int, out_path: Path, vlc_path: Optional[str]):
    cmd = [
        vlc_cmd(vlc_path), "-I","dummy", url,
        ":http-user-agent=Mozilla/5.0",
        ":http-referrer=https://setitagila.ru/",
        ":http-reconnect=true",
        "--sout", f"#std{{access=file,mux=ts,dst={out_path.as_posix()}}}",
        "--run-time", str(secs),
        "vlc://quit"
    ]
    print(f"[VLC] запись → {out_path}")
    subprocess.run(cmd, check=False)
    if not out_path.exists() or out_path.stat().st_size < 1000:
        raise RuntimeError("VLC не создал файл или он слишком мал.")

# ====== ДЕТЕКЦИЯ ======
@dataclass
class BandROI:
    x:int; y:int; w:int; h:int
    label:str

@dataclass
class LightBox:
    id:int
    x1:int; y1:int; x2:int; y2:int
    bands:List[BandROI]

def load_yolo_model() -> YOLO:
    last_err=None
    for w in YOLO_WEIGHTS_TRY:
        try:
            return YOLO(w)
        except Exception as e:
            last_err=e
    raise last_err if last_err else RuntimeError("Не удалось загрузить YOLO-веса")

def split_box_auto(x1:int,y1:int,x2:int,y2:int) -> List[BandROI]:
    """Делим бокс на 3 секции: вертикальный → горизонтальные полосы; горизонтальный → вертикальные."""
    w = max(1, x2-x1); h = max(1, y2-y1)
    if w >= h*1.4:  # горизонтальный светофор
        bw = w//3
        return [
            BandROI(x1, y1, bw, h, "RED"),
            BandROI(x1+bw, y1, bw, h, "YELLOW"),
            BandROI(x1+2*bw, y1, w-2*bw, h, "GREEN"),
        ]
    else:           # вертикальный (обычный)
        bh = h//3
        return [
            BandROI(x1, y1, w, bh, "RED"),
            BandROI(x1, y1+bh, w, bh, "YELLOW"),
            BandROI(x1, y1+2*bh, w, h-2*bh, "GREEN"),
        ]

def iou(a, b):
    ax1,ay1,ax2,ay2=a; bx1,by1,bx2,by2=b
    x1,y1=max(ax1,bx1),max(ay1,by1)
    x2,y2=min(ax2,bx2),min(ay2,by2)
    inter=max(0,x2-x1)*max(0,y2-y1)
    A=(ax2-ax1)*(ay2-ay1); B=(bx2-bx1)*(by2-by1)
    union=A+B-inter if A+B-inter>0 else 1
    return inter/union

def nms_merge(boxes, iou_thr=0.5):
    # boxes: (x1,y1,x2,y2,score)
    boxes=sorted(boxes,key=lambda x:x[4],reverse=True)
    kept=[]
    while boxes:
        cur=boxes.pop(0)
        kept.append(cur)
        boxes=[b for b in boxes if iou(b[:4], cur[:4])<iou_thr]
    return kept

def detect_lights_multi_frames(video_path: Path):
    cap=cv2.VideoCapture(str(video_path))
    if not cap.isOpened(): raise RuntimeError("Не открыть видео для детекции.")
    fps=float(cap.get(cv2.CAP_PROP_FPS) or 25.0)
    total=int(cap.get(cv2.CAP_PROP_FRAME_COUNT) or 0)
    ok, first=cap.read()
    if not ok or first is None:
        cap.release(); raise RuntimeError("Не прочитать первый кадр.")
    H,W=first.shape[:2]

    scan_frames=min(total, int(DETECT_SCAN_SECONDS*fps))
    if scan_frames<=0: scan_frames=min(total,120)
    idx_list=np.linspace(0,max(0,scan_frames-1), num=min(DETECT_MAX_FRAMES,max(1,scan_frames))).astype(int).tolist()

    model=load_yolo_model()
    det_boxes=[]  # (x1,y1,x2,y2,score)

    for idx in idx_list:
        cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
        ok, frame = cap.read()
        if not ok or frame is None: continue
        frame_in = cv2.resize(frame, None, fx=UPSCALE_DET_FACTOR, fy=UPSCALE_DET_FACTOR, interpolation=cv2.INTER_CUBIC) \
                   if UPSCALE_DET_FACTOR!=1.0 else frame
        res = model.predict(frame_in, conf=CONF_THRES, iou=IOU_THRES, classes=[CLASS_TRAFFIC_LIGHT],
                            imgsz=YOLO_IMGSZ, verbose=False)
        for r in res:
            if r.boxes is None: continue
            for b in r.boxes:
                x1,y1,x2,y2=[int(v) for v in b.xyxy[0].tolist()]
                score=float(b.conf[0].item()) if hasattr(b,"conf") else 1.0
                sc=UPSCALE_DET_FACTOR
                x1=int(round(x1/sc)); y1=int(round(y1/sc))
                x2=int(round(x2/sc)); y2=int(round(y2/sc))
                x1,y1=max(0,x1),max(0,y1); x2,y2=min(W-1,x2),min(H-1,y2)
                if (x2-x1)>=MIN_BOX_W and (y2-y1)>=MIN_BOX_H:
                    det_boxes.append((x1,y1,x2,y2,score))
    cap.release()

    if not det_boxes:
        return [], first, fps, total

    merged=nms_merge(det_boxes, iou_thr=NMS_MERGE_IOU)
    boxes=[]
    for i,(x1,y1,x2,y2,score) in enumerate(merged):
        bands=split_box_auto(x1,y1,x2,y2)
        boxes.append(LightBox(id=i, x1=x1,y1=y1,x2=x2,y2=y2, bands=bands))

    # debug
    dbg=first.copy()
    for lb in boxes[:MAX_LIGHTS_TO_DRAW]:
        cv2.rectangle(dbg,(lb.x1,lb.y1),(lb.x2,lb.y2),(255,255,255),2)
        cv2.putText(dbg,f"L{lb.id}",(lb.x1,lb.y1-6),cv2.FONT_HERSHEY_SIMPLEX,0.6,(255,255,255),2)
    cv2.imwrite(str(video_path.with_suffix(".det_debug.png")), dbg)

    return boxes, first, fps, total

# ====== КЛАССИФИКАЦИЯ СЕКЦИЙ ======
def _mask_fill_and_brightness(bgr, low, high):
    hsv=cv2.cvtColor(bgr, cv2.COLOR_BGR2HSV)
    mask=cv2.inRange(hsv, np.array(low,np.uint8), np.array(high,np.uint8))
    mask=cv2.morphologyEx(mask, cv2.MORPH_OPEN, np.ones((3,3),np.uint8))
    fill=mask.mean()/255.0
    if fill<=1e-6: return 0.0,0.0
    v=hsv[:,:,2]
    bright=v[mask>0].mean()/255.0
    return float(fill), float(bright)

def _band_color_scores(bgr):
    # RED — две дуги
    f1,b1 = _mask_fill_and_brightness(bgr, (0, 90, 80), (10,255,255))
    f2,b2 = _mask_fill_and_brightness(bgr, (160,90, 80), (179,255,255))
    red_fill  = f1+f2;  red_brt = max(b1,b2)
    # YELLOW
    fy,by = _mask_fill_and_brightness(bgr, (16, 80, 80), (55,255,255))
    # GREEN
    fg,bg = _mask_fill_and_brightness(bgr, (56, 60, 70), (110,255,255))
    score = {
        "RED":    red_fill  * (0.5 + 0.5*red_brt),
        "YELLOW": fy        * (0.5 + 0.5*by),
        "GREEN":  fg        * (0.5 + 0.5*bg),
    }
    raw = {"RED":(red_fill,red_brt), "YELLOW":(fy,by), "GREEN":(fg,bg)}
    return score, raw

def classify_state_from_bands(frame, bands: List[BandROI]):
    per={}
    raw={}
    for b in bands:
        crop = frame[b.y:b.y+b.h, b.x:b.x+b.w]
        s, r = _band_color_scores(crop)
        per[b.label]=s[b.label]
        raw[b.label]=r[b.label]
    # лидер / второй
    leader=max(per, key=per.get)
    top=per[leader]
    second=sorted(per.values(), reverse=True)[1]
    # условия уверенности (заливка + яркость проверили внутри score)
    # дополнительное условие «зазор к 2-му месту»
    if top < MIN_FILL or (top / max(1e-6,second)) < MARGIN_RATIO:
        return "UNKNOWN", per, raw
    return leader, per, raw

# ====== СЕГМЕНТЫ / ЦИКЛЫ ======
@dataclass
class Segment:
    state:str
    t_start:float
    t_end:float

def merge_short_segments(segs: List[Segment], min_dur: float) -> List[Segment]:
    if not segs: return segs
    # 1) слепим A X A, где X короткий
    merged=[segs[0]]
    for s in segs[1:]:
        last=merged[-1]
        if s.state==last.state:
            merged[-1]=Segment(last.state,last.t_start,s.t_end)
        else:
            merged.append(s)
    i=1
    while i<len(merged)-1:
        a, x, b = merged[i-1], merged[i], merged[i+1]
        if (x.t_end-x.t_start)<min_dur and a.state==b.state and x.state!=a.state:
            merged[i-1]=Segment(a.state, a.t_start, b.t_end)
            del merged[i:i+2]
        else:
            i+=1
    return merged

def segments_to_cycles(segs: List[Segment]) -> List[Tuple[float,float,float,float,float]]:
    seq=[s for s in segs if s.state in ("RED","GREEN","YELLOW")]
    cycles=[]; k=0; m=len(seq)
    while k<m:
        while k<m and seq[k].state!="RED": k+=1
        if k>=m-1: break
        t0=seq[k].t_start; red=seq[k].t_end-seq[k].t_start; k+=1
        green=0.0
        while k<m and seq[k].state=="GREEN":
            green+=seq[k].t_end-seq[k].t_start; k+=1
        yellow=0.0
        while k<m and seq[k].state=="YELLOW":
            yellow+=seq[k].t_end-seq[k].t_start; k+=1
        t1=seq[k].t_start if (k<m and seq[k].state=="RED") else (seq[k-1].t_end if k>0 else t0)
        if red+green+yellow>0:
            cycles.append((t0,red,green,yellow,t1))
    return cycles

# ====== АНАЛИЗ ======
def analyze_video(video_path: Path, boxes: List[LightBox], fps: float, total_frames: int,
                  interval_sec: float, out_dir: Path):
    cap=cv2.VideoCapture(str(video_path))
    if not cap.isOpened(): raise RuntimeError("Не открыть видео для анализа.")
    step=max(1,int(round(interval_sec*fps)))
    hold_needed=max(1, int(round(MIN_HOLD_SEC/max(1e-6,interval_sec))))
    idx=0

    last_state={lb.id:None for lb in boxes}
    last_t    ={lb.id:0.0  for lb in boxes}
    cand      ={lb.id:None for lb in boxes}
    hold      ={lb.id:0    for lb in boxes}
    segments  ={lb.id:[]   for lb in boxes}

    dbg_saved=False
    dbg_path = out_dir / f"{video_path.stem}.debug_auto.png"

    while True:
        ok, frame = cap.read()
        if not ok or frame is None:
            t=(idx-1)/fps if idx>0 else 0.0
            for lb in boxes:
                if last_state[lb.id] is not None:
                    segments[lb.id].append(Segment(last_state[lb.id], last_t[lb.id], t))
            break

        if idx % step == 0:
            t = idx / fps
            for lb in boxes:
                st, per, raw = classify_state_from_bands(frame, lb.bands)
                pred = st
                if last_state[lb.id] is None:
                    last_state[lb.id]=pred; last_t[lb.id]=t
                    cand[lb.id]=pred; hold[lb.id]=1
                else:
                    if pred == last_state[lb.id]:
                        cand[lb.id]=pred; hold[lb.id]=0
                    else:
                        if cand[lb.id]==pred:
                            hold[lb.id]+=1
                        else:
                            cand[lb.id]=pred; hold[lb.id]=1
                        if hold[lb.id]>=hold_needed:
                            segments[lb.id].append(Segment(last_state[lb.id], last_t[lb.id], t))
                            last_state[lb.id]=pred; last_t[lb.id]=t
                            hold[lb.id]=0

            if not dbg_saved:
                dbg=frame.copy()
                for lb in boxes[:MAX_LIGHTS_TO_DRAW]:
                    cv2.rectangle(dbg,(lb.x1,lb.y1),(lb.x2,lb.y2),(255,255,255),2)
                    for b in lb.bands:
                        color=(0,0,255) if b.label=="RED" else (0,255,255) if b.label=="YELLOW" else (0,255,0)
                        cv2.rectangle(dbg,(b.x,b.y),(b.x+b.w,b.y+b.h),color,2)
                        cv2.putText(dbg,b.label,(b.x,b.y-4),cv2.FONT_HERSHEY_SIMPLEX,0.5,color,1)
                cv2.imwrite(str(dbg_path), dbg); dbg_saved=True
        idx+=1
    cap.release()

    # Склейка коротких шипов
    for lb in boxes:
        segments[lb.id] = merge_short_segments(segments[lb.id], MERGE_SPIKE_SEC)

    # Экспорт CSV по каждому светофору (сегменты)
    for lb in boxes:
        csv_l = out_dir / f"{video_path.stem}_L{lb.id}.csv"
        with open(csv_l, "w", newline="", encoding="utf-8") as f:
            w=csv.writer(f); w.writerow(["state","t_start","t_end","duration"])
            for s in segments[lb.id]:
                w.writerow([s.state, f"{s.t_start:.2f}", f"{s.t_end:.2f}", f"{(s.t_end-s.t_start):.2f}"])
        print(f"[✓] CSV L{lb.id}: {csv_l}")

    # Таймлайн
    plot_timeline(video_path, boxes, segments, out_dir)
    # Отчёт с циклами
    report_path = out_dir / f"{video_path.stem}_report_auto.txt"
    write_cycle_report(report_path, boxes, segments)
    print(f"[✓] Отчёт: {report_path}")

def plot_timeline(video_path: Path, boxes: List[LightBox], segments: Dict[int,List[Segment]], out_dir: Path):
    level={"UNKNOWN":0,"GREEN":1,"YELLOW":2,"RED":3}
    rows=min(len(boxes),10)
    fig_h=max(3,int(0.9*rows))
    fig,axs=plt.subplots(rows,1,figsize=(12,fig_h),sharex=True)
    if rows==1: axs=[axs]
    for i,lb in enumerate(boxes[:rows]):
        ax=axs[i]
        for s in segments[lb.id]:
            y=level.get(s.state,0)
            ax.plot([s.t_start,s.t_end],[y,y],linewidth=8)
            ax.text((s.t_start+s.t_end)/2,y+0.1,s.state,ha='center',va='bottom',fontsize=8)
        ax.set_yticks([0,1,2,3]); ax.set_yticklabels(["UNK","GRN","YLW","RED"])
        ax.set_title(f"L{lb.id} box=({lb.x1},{lb.y1})-({lb.x2},{lb.y2})")
        ax.grid(True,axis='x',linestyle='--',alpha=.4)
    axs[-1].set_xlabel("Время, сек")
    fig.tight_layout()
    png = out_dir / f"{video_path.stem}_timeline_auto.png"
    fig.savefig(png, dpi=150); plt.close(fig)
    print(f"[✓] Таймлайн: {png}")

def write_cycle_report(out_path: Path, boxes: List[LightBox], segments: Dict[int,List[Segment]]):
    with open(out_path,"w",encoding="utf-8") as f:
        f.write("=== Traffic Light Auto Report ===\n\n")
        for lb in boxes:
            f.write(f"[L{lb.id}] box=({lb.x1},{lb.y1})-({lb.x2},{lb.y2})\n")
            cyc=segments_to_cycles(segments[lb.id])
            if not cyc:
                f.write("  cycles: not enough data\n\n"); continue
            reds=[c[1] for c in cyc]; greens=[c[2] for c in cyc]; yels=[c[3] for c in cyc]
            fulls=[c[4]-c[0] for c in cyc]
            for i,c in enumerate(cyc,1):
                f.write(f"  Cycle {i}: start={c[0]:.2f}s  RED={c[1]:.2f}s  GREEN={c[2]:.2f}s  YELLOW={c[3]:.2f}s  FULL={c[4]-c[0]:.2f}s\n")
            f.write("  Averages:\n")
            f.write(f"    RED={float(np.mean(reds)):.2f}s  GREEN={float(np.mean(greens)):.2f}s  YELLOW={float(np.mean(yels)):.2f}s  FULL={float(np.mean(fulls)):.2f}s\n\n")

# ====== MAIN ======
def main():
    print("=== Green Wave AUTO (final) ===")
    vlc_path=None
    if "--vlc" in sys.argv:
        try:
            i=sys.argv.index("--vlc"); vlc_path=sys.argv[i+1]; del sys.argv[i:i+2]
        except: pass

    source = ask("Введи .m3u8 URL или путь к видео", str)
    interval = ask("Интервал анализа, сек", float, DEFAULT_INTERVAL_SEC)
    outdir = Path(ask("Папка для сохранения", str, str(Path.home()/ "Videos")))
    outdir.mkdir(parents=True, exist_ok=True)

    if is_url(source):
        secs = ask("Сколько секунд записывать", int, DEFAULT_RECORD_SEC)
        video_path = outdir / f"capture_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.ts"
        record_via_vlc(source, secs, video_path, vlc_path)
    else:
        video_path = Path(source)
        if not video_path.exists():
            print("[!] Файл не найден."); sys.exit(1)

    # детекция по многим кадрам
    boxes, first, fps, total = detect_lights_multi_frames(video_path)
    if not boxes:
        cv2.imwrite(str(video_path.with_suffix(".firstframe.png")), first)
        print("[!] Авто-детект не нашёл светофоры. Попробуй поднять UPSCALE_DET_FACTOR или YOLO_IMGSZ, понизить CONF_THRES.")
        sys.exit(2)
    print(f"[i] Найдено светофоров: {len(boxes)}")

    # анализ
    analyze_video(video_path, boxes, fps, total, interval, outdir)

if __name__ == "__main__":
    import numpy as np
    main()
