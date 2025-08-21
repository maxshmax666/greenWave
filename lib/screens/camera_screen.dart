import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/db.dart';
import '../data/models.dart';
import '../data/sync.dart';
import '../vision/color_detector.dart';

class CameraScreen extends StatefulWidget {
  final int lightId;
  const CameraScreen({super.key, required this.lightId});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _c;
  final _db = AppDb();
  Roi _roi = const Roi(cx: 0.5, cy: 0.33, size: 0.22);
  final _buf = <LightColor>[];
  LightColor _stable = LightColor.unknown, _lastLogged = LightColor.unknown;
  Timer? _uiTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cam = await Permission.camera.request();
      if (!cam.isGranted) {
        setState(() => _error = 'Нет доступа к камере. Разреши в настройках.');
        return;
      }

      final cams = await availableCameras();
      if (cams.isEmpty) {
        setState(() => _error = 'Камера не найдена на устройстве.');
        return;
      }
      final back = cams.firstWhere(
        (x) => x.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );

      _c = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _c!.initialize();
      await _c!.startImageStream(_onFrame);

      _uiTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
        if (mounted) setState(() {});
      });
      setState(() {});
    } catch (e) {
      setState(() => _error = 'Ошибка камеры: $e');
    }
  }

  void _onFrame(CameraImage img) async {
    final (c, conf) = ColorDetector.detect(img, _roi);
    _buf.add(c);
    if (_buf.length > 6) _buf.removeAt(0);
    final st = _mode(_buf);
    if (st != _stable) {
      _stable = st;
      if (_stable != LightColor.unknown && _stable != _lastLogged) {
        final ps = Phase.values[_stable.index];
        final sample = PhaseSample(
            lightId: widget.lightId,
            phase: ps,
            ts: DateTime.now(),
            confidence: conf);
        await _db.addSample(sample);
        try {
          SyncService.pushSamples([sample]); // fire-and-forget
        } catch (_) {}
        _lastLogged = _stable;
      }
    }
  }

  LightColor _mode(List<LightColor> xs) {
    final m = <LightColor, int>{};
    for (final v in xs) {
      m[v] = (m[v] ?? 0) + 1;
    }
    var best = LightColor.unknown;
    var score = -1;
    m.forEach((k, v) {
      if (v > score) {
        score = v;
        best = k;
      }
    });
    return best;
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _c?.dispose();
    super.dispose();
  }

  void _tapToSetRoi(TapDownDetails d, BuildContext ctx) {
    final size = MediaQuery.of(ctx).size;
    final dx = d.localPosition.dx / size.width;
    final dy = d.localPosition.dy / size.height;
    setState(() => _roi = Roi(cx: dx, cy: dy, size: _roi.size));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Камера — авто лог')),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, textAlign: TextAlign.center))),
      );
    }

    if (_c == null || !_c!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Камера — авто лог')),
      body: GestureDetector(
        onTapDown: (e) => _tapToSetRoi(e, context),
        child: Stack(children: [
          CameraPreview(_c!),
          Positioned.fill(child: CustomPaint(painter: _RoiPainter(_roi))),
          Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: Text('ROI: tap по огню • Цвет: $_stable',
                    style: const TextStyle(color: Colors.white)),
              )),
        ]),
      ),
    );
  }
}

class _RoiPainter extends CustomPainter {
  final Roi roi;
  const _RoiPainter(this.roi);
  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromCenter(
      center: Offset(roi.cx * size.width, roi.cy * size.height),
      width: roi.size * size.shortestSide,
      height: roi.size * size.shortestSide,
    );
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(r, p);
  }

  @override
  bool shouldRepaint(c) => true;
}
