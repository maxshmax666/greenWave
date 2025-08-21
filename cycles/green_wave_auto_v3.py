# green_wave_auto_v3.py
# VLC запись → авто-детект светофоров (multi-frame YOLO, upscaling, imgsz) → ФОЛБЭК по координатам → анализ → циклы

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

# YOLO: сперва пробуем s-модель (точнее), если нет — n-модель
YOLO_WEIGHTS_TRY = ["yolov8s.pt", "yolov8n.pt"]
CONF_THRES = 0.15       # ниже — ловим слабые объекты
IOU_THRES  = 0.45
CLASS_TRAFFIC_LIGHT = 9 # COCO id 'traffic light'
YOLO_IMGSZ = 1280       # повысим размер входа для мелких объектов

# Анализ
SAMPLE_INTERVAL_SEC = 1.0
ALPHA = 0.7
THRESHOLD = 0.28
MIN_BOX_W, MIN_BOX_H = 12, 20     # минимальный размер бокса
MAX_LIGHTS_TO_DRAW = 12

# Мультикадровая детекция
DETECT_SCAN_SECONDS = 12
DETECT_MAX_FRAMES   = 60
UPSCALE_DET_FACTOR  = 1.8   # сильнее апскейлим картинку для YOLO
NMS_MERGE_IOU       = 0.50

# Фолбэк по известным координатам (отн. 1920x1080)
REF_W, REF_H = 1920, 1080
SEED_POINTS = [  # центры
    (376, 521),   # светофор 1
    (775, 365),   # светофор 2
    (1300, 778),  # светофор 3
]
SEED_BOX_W, SEED_BOX_H = 60, 150  # примерный вертикальный светофор

# ====== СТРУКТУРЫ ======
@dataclass
class BandROI:
    x:int; y:int; w:int; h:int
    label:str

@dataclass
class LightBox:
    id:int
    x1:int; y1:int; x2:int; y2:int
    bands:List[BandROI]

@dataclass
class Segment:
    state:str
    t_start:float
    t_end:float

# ====== УТИЛИТЫ ======
def ask(prompt: str, cast=str, default=None):
    s = input(f"{prompt}" + (f" [{default}]" if default is not None else "") + ": ").strip()
    if not s and default is not None: return default
    try: return cast(s)
    except: print("Неверный ввод."); return ask(prompt, cast, default)

def vlc_cmd(vlc_path: Optional[str]) -> str:
    return vlc_path if (vlc_path and os.path.exists(vlc_path)) else VLC_EXE_DEFAULT

def record_vlc(url: str, secs: int, out_path: Path, vlc_path: Optional[str]):
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

def mean_hsv_score(bgr: np.ndarray) -> Tuple[float,float,float,float]:
    if bgr.size == 0: return 0.0,0.0,0.0,0.0
    hsv = cv2.cvtColor(bgr, cv2.COLOR_BGR2HSV)
    h = hsv[:,:,0].astype(np.float32)
    s = hsv[:,:,1].astype(np.float32)
    v = hsv[:,:,2].astype(np.float32)
    v = cv2.equalizeHist(v.astype(np.uint8)).astype(np.float32)
    h_mean = float(np.mean(h))
    s_mean = float(np.mean(s))/255.0
    v_mean = float(np.mean(v))/255.0
    score  = ALPHA*v_mean + (1-ALPHA)*s_mean
    return h_mean, s_mean, v_mean, score

def split_box_into_bands(x1:int,y1:int,x2:int,y2:int) -> List[BandROI]:
    w = max(1, x2-x1); h = max(1, y2-y1); bh = h//3
    return [
        BandROI(x1,y1,w,bh,"RED"),
        BandROI(x1,y1+bh,w,bh,"YELLOW"),
        BandROI(x1,y1+2*bh,w,h-2*bh,"GREEN")
    ]

def iou(boxA, boxB):
    ax1,ay1,ax2,ay2 = boxA
    bx1,by1,bx2,by2 = boxB
    x1,y1 = max(ax1,bx1), max(ay1,by1)
    x2,y2 = min(ax2,bx2), min(ay2,by2)
    inter = max(0,x2-x1)*max(0,y2-y1)
    a = (ax2-ax1)*(ay2-ay1); b = (bx2-bx1)*(by2-by1)
    union = a+b-inter if a+b-inter>0 else 1
    return inter/union

def nms_merge(boxes: List[Tuple[int,int,int,int,float]], iou_thr=0.5) -> List[Tuple[int,int,int,int,float]]:
    # boxes: (x1,y1,x2,y2,score)
    boxes = sorted(boxes, key=lambda x: x[4], reverse=True)
    kept=[]
    while boxes:
        cur = boxes.pop(0)
        kept.append(cur)
        boxes = [b for b in boxes if iou(b[:4], cur[:4]) < iou_thr]
    return kept

# ====== ДЕТЕКЦИЯ ======
def load_yolo_model() -> YOLO:
    # пробуем s, затем n
    last_err=None
    for w in YOLO_WEIGHTS_TRY:
        try:
            return YOLO(w)
        except Exception as e:
            last_err=e
    raise last_err if last_err else RuntimeError("Не удалось загрузить YOLO-веса")

def detect_lights_multi_frames(video_path: Path) -> Tuple[List[LightBox], np.ndarray, float, int]:
    cap = cv2.VideoCapture(str(video_path))
    if not cap.isOpened(): raise RuntimeError("Не открыть видео для детекции.")
    fps = float(cap.get(cv2.CAP_PROP_FPS) or 25.0)
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT) or 0)
    ok, first = cap.read()
    if not ok or first is None:
        cap.release(); raise RuntimeError("Не прочитать первый кадр.")
    H,W = first.shape[:2]

    scan_frames = min(total, int(DETECT_SCAN_SECONDS*fps))
    if scan_frames <= 0: scan_frames = min(total, 120)
    idx_list = np.linspace(0, max(0, scan_frames-1), num=min(DETECT_MAX_FRAMES, max(1,scan_frames))).astype(int).tolist()

    model = load_yolo_model()
    det_boxes = []  # (x1,y1,x2,y2,score)

    for i, idx in enumerate(idx_list):
        cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
        ok, frame = cap.read()
        if not ok or frame is None: continue

        # апскейл для мелких объектов
        if UPSCALE_DET_FACTOR != 1.0:
            frame_in = cv2.resize(frame, None, fx=UPSCALE_DET_FACTOR, fy=UPSCALE_DET_FACTOR, interpolation=cv2.INTER_CUBIC)
        else:
            frame_in = frame

        res = model.predict(
            frame_in,
            conf=CONF_THRES, iou=IOU_THRES,
            classes=[CLASS_TRAFFIC_LIGHT],
            imgsz=YOLO_IMGSZ,
            verbose=False
        )
        for r in res:
            if r.boxes is None: continue
            for b in r.boxes:
                x1,y1,x2,y2 = [int(v) for v in b.xyxy[0].tolist()]
                score = float(b.conf[0].item()) if hasattr(b, "conf") else 1.0
                # назад в оригинальный масштаб
                scale = UPSCALE_DET_FACTOR
                x1 = int(round(x1/scale)); y1 = int(round(y1/scale))
                x2 = int(round(x2/scale)); y2 = int(round(y2/scale))
                x1,y1 = max(0,x1), max(0,y1)
                x2,y2 = min(W-1,x2), min(H-1,y2)
                if (x2-x1) >= MIN_BOX_W and (y2-y1) >= MIN_BOX_H:
                    det_boxes.append((x1,y1,x2,y2,score))

    cap.release()

    if not det_boxes:
        return [], first, fps, total

    merged = nms_merge(det_boxes, iou_thr=NMS_MERGE_IOU)
    boxes=[]
    for i,(x1,y1,x2,y2,score) in enumerate(merged):
        bands = split_box_into_bands(x1,y1,x2,y2)
        boxes.append(LightBox(id=i, x1=x1,y1=y1,x2=x2,y2=y2, bands=bands))

    # debug
    dbg = first.copy()
    for lb in boxes[:MAX_LIGHTS_TO_DRAW]:
        cv2.rectangle(dbg,(lb.x1,lb.y1),(lb.x2,lb.y2),(255,255,255),2)
        cv2.putText(dbg,f"L{lb.id}",(lb.x1,lb.y1-6),cv2.FONT_HERSHEY_SIMPLEX,0.6,(255,255,255),2)
    cv2.imwrite(str(video_path.with_suffix(".det_debug.png")), dbg)

    return boxes, first, fps, total

# ====== ФОЛБЭК ПО КООРДИНАТАМ ======
def build_seed_boxes(first_frame: np.ndarray) -> List[LightBox]:
    H, W = first_frame.shape[:2]
    boxes=[]
    for i,(cx_ref, cy_ref) in enumerate(SEED_POINTS):
        cx = int(round(cx_ref * W / REF_W))
        cy = int(round(cy_ref * H / REF_H))
        bw = int(round(SEED_BOX_W * W / REF_W))
        bh = int(round(SEED_BOX_H * H / REF_H))
        x1 = max(0, cx - bw//2); y1 = max(0, cy - bh//2)
        x2 = min(W-1, x1 + bw);  y2 = min(H-1, y1 + bh)
        bands = split_box_into_bands(x1,y1,x2,y2)
        boxes.append(LightBox(id=i, x1=x1,y1=y1,x2=x2,y2=y2, bands=bands))
    # debug
    dbg = first_frame.copy()
    for lb in boxes[:MAX_LIGHTS_TO_DRAW]:
        cv2.rectangle(dbg,(lb.x1,lb.y1),(lb.x2,lb.y2),(0,255,255),2)
        cv2.putText(dbg,f"SEED L{lb.id}",(lb.x1,lb.y1-6),cv2.FONT_HERSHEY_SIMPLEX,0.6,(0,255,255),2)
    return boxes, dbg

# ====== КЛАССИФИКАЦИЯ И АНАЛИЗ ======
def classify_state_from_bands(frame: np.ndarray, bands: List[BandROI]) -> Tuple[str, Dict[str,float]]:
    per={}
    for b in bands:
        crop = frame[b.y:b.y+b.h, b.x:b.x+b.w]
        _,_,_,sc = mean_hsv_score(crop)
        per[b.label]=sc
    best = max(per, key=per.get)
    if per[best] < THRESHOLD: return "UNKNOWN", per
    return best, per

@dataclass
class SampleRow:
    t_sec: float
    per_light: Dict[int, Dict[str, float]]  # {lid: {"RED":..., "YELLOW":..., "GREEN":..., "state":...}}

def analyze_video(video_path: Path, boxes: List[LightBox], fps: float, total_frames: int,
                  interval_sec: float, out_dir: Path):
    cap = cv2.VideoCapture(str(video_path))
    if not cap.isOpened(): raise RuntimeError("Не открыть видео для анализа.")
    step = max(1, int(round(interval_sec * fps)))
    idx=0

    last_state={lb.id:None for lb in boxes}
    last_t={lb.id:0.0 for lb in boxes}
    segments={lb.id:[] for lb in boxes}
    samples: List[SampleRow]=[]

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
            row = SampleRow(t_sec=t, per_light={})
            for lb in boxes:
                st, per = classify_state_from_bands(frame, lb.bands)
                row.per_light[lb.id] = {"RED":per.get("RED",0.0), "YELLOW":per.get("YELLOW",0.0), "GREEN":per.get("GREEN",0.0), "state":st}
                if last_state[lb.id] is None:
                    last_state[lb.id]=st; last_t[lb.id]=t
                elif st != last_state[lb.id]:
                    segments[lb.id].append(Segment(last_state[lb.id], last_t[lb.id], t))
                    last_state[lb.id]=st; last_t[lb.id]=t
            samples.append(row)

            if not dbg_saved:
                dbg=frame.copy()
                for lb in boxes[:MAX_LIGHTS_TO_DRAW]:
                    cv2.rectangle(dbg,(lb.x1,lb.y1),(lb.x2,lb.y2),(255,255,255),2)
                    for b in lb.bands:
                        color=(0,0,255) if b.label=="RED" else (0,255,255) if b.label=="YELLOW" else (0,255,0)
                        cv2.rectangle(dbg,(b.x,b.y),(b.x+b.w,b.y+b.h),color,2)
                        cv2.putText(dbg,b.label,(b.x,b.y-4),cv2.FONT_HERSHEY_SIMPLEX,0.5,color,1)
                cv2.imwrite(str(dbg_path), dbg)
                dbg_saved=True

        idx+=1

    cap.release()

    # общий CSV
    all_csv = out_dir / f"{video_path.stem}_ALL_auto.csv"
    headers = ["t_sec"]
    for lb in boxes:
        headers += [f"L{lb.id}_state", f"L{lb.id}_RED", f"L{lb.id}_YELLOW", f"L{lb.id}_GREEN"]
    with open(all_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(headers)
        for row in samples:
            r=[f"{row.t_sec:.2f}"]
            for lb in boxes:
                pl = row.per_light[lb.id]
                r += [pl["state"], f"{pl['RED']:.3f}", f"{pl['YELLOW']:.3f}", f"{pl['GREEN']:.3f}"]
            w.writerow(r)
    print(f"[✓] CSV общий: {all_csv}")

    # по каждому светофору
    for lb in boxes:
        csv_l = out_dir / f"{video_path.stem}_L{lb.id}.csv"
        with open(csv_l, "w", newline="", encoding="utf-8") as f:
            w=csv.writer(f); w.writerow(["t_sec","state","RED","YELLOW","GREEN"])
            for row in samples:
                pl=row.per_light[lb.id]
                w.writerow([f"{row.t_sec:.2f}", pl["state"], f"{pl['RED']:.3f}", f"{pl['YELLOW']:.3f}", f"{pl['GREEN']:.3f}"])
        print(f"[✓] CSV L{lb.id}: {csv_l}")

    # график и отчёт
    plot_timeline(video_path, boxes, segments, out_dir)
    report_path = out_dir / f"{video_path.stem}_report_auto.txt"
    write_cycle_report(report_path, boxes, segments)
    print(f"[✓] Отчёт: {report_path}")

def plot_timeline(video_path: Path, boxes: List[LightBox], segments: Dict[int,List[Segment]], out_dir: Path):
    level={"UNKNOWN":0,"GREEN":1,"YELLOW":2,"RED":3}
    rows=min(len(boxes),8)
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
        ax.set_title(f"L{lb.id} box=({lb.x1},{lb.y1})-({lb.x2,lb.y2})")
        ax.grid(True,axis='x',linestyle='--',alpha=.4)
    axs[-1].set_xlabel("Время, сек")
    fig.tight_layout()
    png = out_dir / f"{video_path.stem}_timeline_auto.png"
    fig.savefig(png, dpi=150); plt.close(fig)
    print(f"[✓] Таймлайн: {png}")

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
        t1 = seq[k].t_start if (k<m and seq[k].state=="RED") else (seq[k-1].t_end if k>0 else t0)
        if (red+green+yellow)>0: cycles.append((t0,red,green,yellow,t1))
    return cycles

def write_cycle_report(out_path: Path, boxes: List[LightBox], segments: Dict[int,List[Segment]]):
    with open(out_path,"w",encoding="utf-8") as f:
        f.write("=== Traffic Light Auto Report (v3: YOLO + Seed Fallback) ===\n\n")
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

def main():
    print("=== Green Wave AUTO v3 (YOLO multi-frame + Seed Fallback) ===")
    vlc_path=None
    if "--vlc" in sys.argv:
        try:
            i=sys.argv.index("--vlc"); vlc_path=sys.argv[i+1]; del sys.argv[i:i+2]
        except: pass

    url = ask("URL (.m3u8)", str)
    secs = ask("Сколько секунд писать", int, 300)
    interval = ask("Интервал анализа (сек)", float, SAMPLE_INTERVAL_SEC)
    outdir = Path(ask("Папка для сохранения", str, str(Path.home()/ "Videos"))); outdir.mkdir(parents=True, exist_ok=True)
    video_path = outdir / f"capture_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.ts"

    # запись
    record_vlc(url, secs, video_path, vlc_path)

    # детекция по многим кадрам
    boxes, first, fps, total = detect_lights_multi_frames(video_path)

    if not boxes:
        print("[!] YOLO не нашёл светофоры — включаю фолбэк по известным координатам.")
        boxes, seed_dbg = build_seed_boxes(first)
        cv2.imwrite(str(video_path.with_suffix(".seed_debug.png")), seed_dbg)

    print(f"[i] К анализу светофоров: {len(boxes)}")
    analyze_video(video_path, boxes, fps, total, interval, outdir)

if __name__ == "__main__":
    import numpy as np
    main()
