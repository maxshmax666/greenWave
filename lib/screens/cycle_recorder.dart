import "dart:async";
import "dart:math";
import "package:flutter/material.dart";
import "package:camera/camera.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:permission_handler/permission_handler.dart";
import "package:geolocator/geolocator.dart";

import '../glowing_button.dart';

final supa = Supabase.instance.client;

class CycleRecorderScreen extends StatefulWidget {
  const CycleRecorderScreen({super.key});
  @override
  State<CycleRecorderScreen> createState() => _CycleRecorderScreenState();
}

class _CycleRecorderScreenState extends State<CycleRecorderScreen> {
  CameraController? _cam;
  List<CameraDescription> _cams = [];
  bool _camReady = false;
  bool _autoDetect = false;
  int _stableCount = 0;
  String? _lastAuto;

  List<Map<String, dynamic>> _lights = [];
  int? _selectedLightId;

  String? _curPhase;
  DateTime? _curStart;
  final List<Map<String, dynamic>> _segments = [];

  @override
  void initState() {
    super.initState();
    _loadLights();
    _initCamera();
  }

  Future<void> _loadLights() async {
    final res = await supa.from("lights").select("id,name").order("id");
    setState(() => _lights = List<Map<String, dynamic>>.from(res));
  }

  Future<void> _initCamera() async {
    final perm = await Permission.camera.request();
    if (!perm.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
      }
      return;
    }
    try {
      _cams = await availableCameras();
      final cam = _cams.first;
      _cam = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _cam!.initialize();
      if (mounted) setState(() => _camReady = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Camera error: $e")));
    }
  }

  void _markPhase(String phase) {
    final now = DateTime.now();
    if (_curPhase != null && _curStart != null) {
      _segments.add({"phase": _curPhase, "start": _curStart, "end": now});
    }
    _curPhase = phase;
    _curStart = now;
    setState(() {});
  }

  Future<void> _stopAndUpload() async {
    if (_curPhase != null && _curStart != null) {
      _segments.add({"phase": _curPhase, "start": _curStart, "end": DateTime.now()});
      _curPhase = null;
      _curStart = null;
    }
    if (_segments.isEmpty || _selectedLightId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No segments or light not selected")));
      return;
    }
    final u = supa.auth.currentUser;
    if (u == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sign in required")));
      return;
    }
    final rows = _segments.map((s)=> {
      "light_id": _selectedLightId,
      "phase": s["phase"],
      "start_ts": (s["start"] as DateTime).toIso8601String(),
      "end_ts": (s["end"] as DateTime).toIso8601String(),
      "source": "camera",
      "created_by": u.id,
    }).toList();
    await supa.from("light_cycles").insert(rows);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploaded")));
    setState(() => _segments.clear());
  }

  Future<void> _markHere() async {
    final loc = await Permission.locationWhenInUse.request();
    if (!loc.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission denied")));
      }
      return;
    }
    final p = await Geolocator.getCurrentPosition();
    final u = supa.auth.currentUser;
    if (u == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sign in required")));
      return;
    }
    await supa.from("record_marks").insert({
      "lat": p.latitude, "lon": p.longitude, "note": "record mark", "created_by": u.id,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marked on map")));
    }
  }

  void _toggleAuto() async {
    if (!_camReady || _cam == null) return;
    if (!_autoDetect) {
      try {
        await _cam!.startImageStream(_onImage);
        _autoDetect = true;
        _stableCount = 0;
        _lastAuto = null;
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Stream error: $e")));
      }
    } else {
      try { await _cam!.stopImageStream(); } catch (_) {}
      _autoDetect = false;
    }
    setState(() {});
  }

  int _w = 0, _h = 0;
  DateTime _lastDecision = DateTime.fromMillisecondsSinceEpoch(0);

  void _onImage(CameraImage img) {
    _w = img.width; _h = img.height;
    if (img.format.group != ImageFormatGroup.yuv420) return;

    final planeY = img.planes[0];
    final planeU = img.planes[1];
    final planeV = img.planes[2];

    final cx = _w ~/ 2;
    final cy = _h ~/ 3;
    int rC=0, gC=0, yC=0, total=0;

    for (int dy=-20; dy<=20; dy+=4) {
      final y0 = cy+dy;
      if (y0<0 || y0>=_h) continue;
      for (int dx=-20; dx<=20; dx+=4) {
        final x0 = cx+dx;
        if (x0<0 || x0>=_w) continue;

        final Y = planeY.bytes[y0*planeY.bytesPerRow + x0] & 0xFF;
        final uvx = (x0/2).floor();
        final uvy = (y0/2).floor();
        final uIndex = uvy*planeU.bytesPerRow + uvx*planeU.bytesPerPixel!;
        final vIndex = uvy*planeV.bytesPerRow + uvx*planeV.bytesPerPixel!;
        int U = planeU.bytes[uIndex] & 0xFF;
        int V = planeV.bytes[vIndex] & 0xFF;

        double C = Y - 16;
        double D = U - 128;
        double E = V - 128;
        double R = (1.164*C + 1.596*E);
        double G = (1.164*C - 0.392*D - 0.813*E);
        double B = (1.164*C + 2.017*D);

        R = R.clamp(0,255);
        G = G.clamp(0,255);
        B = B.clamp(0,255);

        if (R>150 && G<130) rC++;
        else if (G>150 && R<140) gC++;
        else if (R>150 && G>150) yC++;

        total++;
      }
    }

    String? guess;
    final th = max(8, (total*0.08).floor());
    if (rC>gC && rC>yC && rC>th) guess="red";
    else if (gC>rC && gC>yC && gC>th) guess="green";
    else if (yC>rC && yC>gC && yC>th) guess="yellow";

    if (guess!=null) {
      if (_lastAuto==guess) _stableCount++; else { _stableCount=1; _lastAuto=guess; }
      final now = DateTime.now();
      if (_stableCount>=6 && now.difference(_lastDecision).inMilliseconds>400) {
        _lastDecision = now;
        if (mounted) {
          _markPhase(guess);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Auto: $guess")));
        }
      }
    }
  }

  @override
  void dispose() {
    try { _cam?.stopImageStream(); } catch (_) {}
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final btnStyle =
        disableAnimations ? ElevatedButton.styleFrom(elevation: 0) : null;
    final ratio = _cam != null && _camReady ? _cam!.value.aspectRatio : 16 / 9;
    return Scaffold(
      appBar: AppBar(title: const Text("Cycle Recorder")),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: ratio,
            child: _cam!=null && _camReady ? CameraPreview(_cam!) : const ColoredBox(color: Colors.black12),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<int>(
              value: _selectedLightId,
              items: _lights.map((l)=>DropdownMenuItem<int>(
                value: l["id"] as int,
                child: Text("${l["id"]}: ${l["name"] ?? "light"}"),
              )).toList(),
              onChanged: (v)=>setState(()=>_selectedLightId=v),
              decoration: const InputDecoration(labelText: "Traffic light"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Wrap(spacing: 8, children: [
 
              ElevatedButton(
                  onPressed: () => _markPhase("red"),
                  style: btnStyle,
                  child: const Text("Red")),
              ElevatedButton(
                  onPressed: () => _markPhase("yellow"),
                  style: btnStyle,
                  child: const Text("Yellow")),
              ElevatedButton(
                  onPressed: () => _markPhase("green"),
                  style: btnStyle,
                  child: const Text("Green")),
              OutlinedButton(
                  onPressed: _stopAndUpload,
                  child: const Text("Stop & Upload")),
              OutlinedButton(
                  onPressed: _markHere, child: const Text("Mark here")),
              ElevatedButton(
                  onPressed: _toggleAuto,
                  style: btnStyle,
                  child: Text(
                      _autoDetect ? "Auto Detect: ON" : "Auto Detect: OFF")),

              GlowingButton(
                  onPressed: () => _markPhase("red"),
                  text: "Red",
                  tone: GlowingButtonTone.secondary),
              GlowingButton(
                  onPressed: () => _markPhase("yellow"),
                  text: "Yellow",
                  tone: GlowingButtonTone.secondary),
              GlowingButton(
                  onPressed: () => _markPhase("green"),
                  text: "Green",
                  tone: GlowingButtonTone.secondary),
              GlowingButton(
                  onPressed: _stopAndUpload,
                  text: "Stop & Upload",
                  tone: GlowingButtonTone.ghost),
              GlowingButton(
                  onPressed: _markHere,
                  text: "Mark here",
                  tone: GlowingButtonTone.ghost),
              GlowingButton(
                  onPressed: _toggleAuto,
                  text: _autoDetect ? "Auto Detect: ON" : "Auto Detect: OFF"),
 
            ]),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _segments.length,
              itemBuilder: (c, i) {
                final s = _segments[i];
                return ListTile(
                  dense: true,
                  title: Text("${s["phase"]}"),
                  subtitle: Text("${s["start"]} -> ${s["end"]}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
