import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';

import '../services/route_service.dart';
import '../services/snap_utils.dart';
import '../services/speed_advisor.dart';

final supa = Supabase.instance.client;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _map = MapController();

  static const _defaultCenter = LatLng(57.90502, 60.08683);
  final List<Map<String, dynamic>> _lights = [];
  Timer? _ticker;
  List<LatLng> _route = [];
  List<SnappedLight> _snapped = [];
  int? _advised;
  LatLng? _myPos;
  int? _nearestId;
  final _dist = Distance();
  String _profile = 'driving-car';

  @override
  void initState() {
    super.initState();
    _loadLights();
    _updateNearest();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      int? sp;
      if (_route.isNotEmpty) {
        sp = SpeedAdvisor.advise(_snapped);
      }
      _updateNearest();
      setState(() => _advised = sp);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadLights() async {
    try {
      final res = await supa
          .from('lights')
          .select(
              'id,name,lat,lon,main_duration,side_duration,ped_duration,cycle_total,cycle_start_at')
          .order('id');
      setState(() {
        _lights
          ..clear()
          ..addAll(List<Map<String, dynamic>>.from(res));
      });
      _updateNearest();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить lights: $e')),
      );
    }
  }

  Future<void> _updateNearest() async {
    try {
      final pos = await _currentPos();
      _myPos = pos;
      double best = double.infinity;
      int? bestId;
      for (final l in _lights) {
        final lat = (l['lat'] as num?)?.toDouble();
        final lon = (l['lon'] as num?)?.toDouble();
        if (lat == null || lon == null) continue;
        final d = _dist.as(LengthUnit.Meter, pos, LatLng(lat, lon));
        if (d < best) {
          best = d;
          bestId = l['id'] as int?;
        }
      }
      if (mounted) setState(() => _nearestId = bestId);
    } catch (_) {}
  }

  Future<LatLng> _currentPos() async {
    try {
      final p = await Geolocator.getCurrentPosition();
      return LatLng(p.latitude, p.longitude);
    } catch (_) {
      return _map.center;
    }
  }

  Future<void> _setDest(LatLng dest) async {
    try {
      final start = await _currentPos();
      final pts = await RouteService.getRoute(start, dest, profile: _profile);
      setState(() {
        _route = pts;
        _snapped = SnapUtils.snapLights(_lights, _route);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Route error: $e')));
    }
  }

  Future<void> _centerOnMe() async {
    final pos = await _currentPos();
    _map.move(pos, 16);
  }

  Future<void> _addLight() async {
    try {
      final pos = await _currentPos();
      await supa.from('lights').insert({'lat': pos.latitude, 'lon': pos.longitude});
      await _loadLights();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Светофор добавлен')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка добавления: $e')));
    }
  }

  void _openExplorer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) => const ExplorerSheet(),
    );
  }

  (Color, int) _phaseColorAndLeft(Map<String, dynamic> l) {
    final total = (l['cycle_total'] as int?) ??
        ((l['main_duration'] as int? ?? 0) +
            (l['side_duration'] as int? ?? 0) +
            (l['ped_duration'] as int? ?? 0));
    final startStr = l['cycle_start_at'] as String?;
    if (total == 0 || startStr == null) return (Colors.grey, 0);

    final mainDur = l['main_duration'] as int? ?? 0;
    final sideDur = l['side_duration'] as int? ?? 0;
    final pedDur = l['ped_duration'] as int? ?? 0;

    int mod(int a, int b) => ((a % b) + b) % b;
    final now = DateTime.now().toUtc();
    final start = DateTime.parse(startStr).toUtc();
    final s = mod(now.difference(start).inSeconds, total);

    if (s < mainDur) return (Colors.green, mainDur - s);
    if (s < mainDur + sideDur) return (Colors.red, mainDur + sideDur - s);
    return (Colors.blue, total - s);
  }

  List<Marker> _lightMarkers(bool disableAnimations) {
    return _lights
        .map((m) {
          final lat = (m['lat'] as num?)?.toDouble();
          final lon = (m['lon'] as num?)?.toDouble();
          if (lat == null || lon == null) return null;
          final (color, left) = _phaseColorAndLeft(m);
          final lamp = _TrafficLamp(color: color, leftSec: left);
          Widget child = lamp;
          if (_nearestId == m['id'] && !disableAnimations) {
            child = Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 4)
              ]),
              child: lamp,
            );
          }
          return Marker(
            point: LatLng(lat, lon),
            width: 46,
            height: 60,
            child: child,
          );
        })
        .whereType<Marker>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final markers = _lightMarkers(disableAnimations);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _openExplorer,
          tooltip: 'Explorer',
          icon: const Icon(Icons.explore),
        ),
        title: const Text('Карта'),
        actions: [
          IconButton(
            onPressed: _loadLights,
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.directions),
            initialValue: _profile,
            onSelected: (v) => setState(() => _profile = v),
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'driving-car', child: Text('Авто')),
              PopupMenuItem(
                  value: 'foot-walking', child: Text('Пешком')),
              PopupMenuItem(
                  value: 'cycling-regular', child: Text('Вело')),
            ],
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _map,
        options: MapOptions(
          initialCenter: _defaultCenter,
          initialZoom: 15,
          onLongPress: (tap, latlng) => _setDest(latlng),
          interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.green_wave_app',
            maxNativeZoom: 19,
            maxZoom: 19,
            backgroundColor: Colors.white,
            // ВАЖНО: сигнатура из 3х аргументов
            errorTileCallback: (tile, error, stackTrace) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка загрузки тайла: $error')),
              );
            },
          ),
          MarkerLayer(markers: markers),
          if (_route.isNotEmpty)
            PolylineLayer(polylines: [
              Polyline(points: _route, strokeWidth: 4, color: Colors.blue)
            ]),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_route.isNotEmpty)
                    Text(_advised != null
                        ? 'Go ~$_advised km/h'
                        : 'No lights on route'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _LegendDot(color: Colors.red, label: 'Второстепенная'),
                      SizedBox(width: 12),
                      _LegendDot(color: Colors.green, label: 'Главная'),
                      SizedBox(width: 12),
                      _LegendDot(color: Colors.blue, label: 'Пешеходы'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_route.isNotEmpty) ...[
            FloatingActionButton(
              heroTag: 'clear',
              elevation: disableAnimations ? 0 : null,
              onPressed: () => setState(() {
                    _route.clear();
                    _snapped = [];
                    _advised = null;
                  }),
              tooltip: 'Очистить маршрут',
              child: const Icon(Icons.clear),
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            heroTag: 'loc',
            elevation: disableAnimations ? 0 : null,
            onPressed: _centerOnMe,
            tooltip: 'Моё местоположение',
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add',
            elevation: disableAnimations ? 0 : null,
            onPressed: _addLight,
            tooltip: 'Добавить светофор',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _TrafficLamp extends StatelessWidget {
  final Color color;
  final int leftSec;
  const _TrafficLamp({required this.color, required this.leftSec});

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final isRed = color == Colors.red;
    final isGreen = color == Colors.green;
    final isBlue = color == Colors.blue;

    Widget lamp(Color on, bool active) => Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: active ? on : Colors.black26,
            shape: BoxShape.circle,
            boxShadow: active && !disableAnimations
                ? [BoxShadow(color: on.withOpacity(0.5), blurRadius: 8)]
                : null,
          ),
        );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 28,
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              lamp(Colors.red, isRed),
              lamp(Colors.green, isGreen),
              lamp(Colors.blue, isBlue),
            ],
          ),
        ),
        Positioned(
          right: -14,
          top: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: disableAnimations
                    ? null
                    : const [
                        BoxShadow(blurRadius: 4, color: Colors.black26)
                      ],
              ),
            child: Text(
              '$leftSec',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class ExplorerSheet extends StatefulWidget {
  const ExplorerSheet({super.key});
  @override
  State<ExplorerSheet> createState() => _ExplorerSheetState();
}

class _ExplorerSheetState extends State<ExplorerSheet> {
  CameraController? _controller;
  bool _rec = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cams = await availableCameras();
    if (cams.isEmpty) return;
    _controller = CameraController(cams.first, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _toggleRec() async {
    if (_controller == null) return;
    if (_rec) {
      final file = await _controller!.stopVideoRecording();
      // upload file.path to server
      setState(() => _rec = false);
    } else {
      await _controller!.startVideoRecording();
      setState(() => _rec = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(child: CameraPreview(_controller!)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.flash_on),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(_rec ? Icons.stop : Icons.fiber_manual_record),
                color: _rec ? Colors.red : null,
                onPressed: _toggleRec,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ],
      ),
    );
  }
}
