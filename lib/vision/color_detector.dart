import 'dart:math';
import 'package:camera/camera.dart';

enum LightColor { red, yellow, green, unknown }

class Roi {
  final double cx, cy, size;
  const Roi({required this.cx, required this.cy, required this.size});
  Roi clamp()=>Roi(cx: cx.clamp(0.05,0.95), cy: cy.clamp(0.05,0.95), size: size.clamp(0.08,0.5));
}

class ColorDetector {
  static (LightColor,double) detect(CameraImage img, Roi roi){
    if (img.format.group != ImageFormatGroup.yuv420) return (LightColor.unknown, 0);
    final w=img.width, h=img.height;
    final yPlane=img.planes[0].bytes, uPlane=img.planes[1].bytes, vPlane=img.planes[2].bytes;
    final yRowStride=img.planes[0].bytesPerRow, uvRowStride=img.planes[1].bytesPerRow, uvPixelStride=img.planes[1].bytesPerPixel ?? 2;

    final sizePx=(roi.size*min(w,h)).round();
    final cx=(roi.cx*w).round(), cy=(roi.cy*h).round();
    final x0=max(0,cx-sizePx~/2), x1=min(w-1,cx+sizePx~/2);
    final y0=max(0,cy-sizePx~/2), y1=min(h-1,cy+sizePx~/2);

    int red=0,yel=0,grn=0,total=0; const step=3;

    for(int yy=y0; yy<y1; yy+=step){
      final uvRow=(yy~/2)*uvRowStride, yRow=yy*yRowStride;
      for(int xx=x0; xx<x1; xx+=step){
        final yIndex=yRow+xx, uvIndex=uvRow+(xx~/2)*uvPixelStride;
        final Y=yPlane[yIndex].toDouble(), U=uPlane[uvIndex].toDouble(), V=vPlane[uvIndex].toDouble();
        double r=Y+1.402*(V-128), g=Y-0.344136*(U-128)-0.714136*(V-128), b=Y+1.772*(U-128);
        r=r.clamp(0,255)/255.0; g=g.clamp(0,255)/255.0; b=b.clamp(0,255)/255.0;

        final mx=max(r,max(g,b)), mn=min(r,min(g,b)), d=mx-mn;
        double hDeg;
        if(d==0) hDeg=0;
        else if(mx==r) hDeg=(60*((g-b)/d)+360)%360;
        else if(mx==g) hDeg=(60*((b-r)/d)+120)%360;
        else hDeg=(60*((r-g)/d)+240)%360;
        final s=mx==0?0:d/mx; final v=mx;

        total++;
        if(s>0.35 && v>0.35){
          if(hDeg<20||hDeg>340) red++;
          else if(hDeg>30&&hDeg<65) yel++;
          else if(hDeg>80&&hDeg<160) grn++;
        }
      }
    }
    if(total==0) return (LightColor.unknown,0);
    final fr=red/total, fy=yel/total, fg=grn/total;
    final maxv=[fr,fy,fg].reduce(max);
    if(maxv<0.10) return (LightColor.unknown,maxv);
    if(maxv==fr) return (LightColor.red,fr);
    if(maxv==fy) return (LightColor.yellow,fy);
    return (LightColor.green,fg);
  }
}
