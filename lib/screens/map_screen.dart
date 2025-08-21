import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void initState() {
    super.initState();
    _loadLights();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      int? sp;
      if (_route.isNotEmpty) {
        sp = SpeedAdvisor.advise(_snapped);
      }
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить lights: $e')),
      );
    }
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
      final pts = await RouteService.getRoute(start, dest);
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

  List<Marker> _lightMarkers() {
    return _lights
        .map((m) {
          final lat = (m['lat'] as num?)?.toDouble();
          final lon = (m['lon'] as num?)?.toDouble();
          if (lat == null || lon == null) return null;
          final (color, left) = _phaseColorAndLeft(m);
          return Marker(
            point: LatLng(lat, lon),
            width: 46,
            height: 60,
            child: _TrafficLamp(color: color, leftSec: left),
          );
        })
        .whereType<Marker>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final markers = _lightMarkers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map & Lights'),
        actions: [
          IconButton(
            onPressed: _loadLights,
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => _map.move(_defaultCenter, 16),
            tooltip: 'К моему району',
            icon: const Icon(Icons.my_location),
          ),
          IconButton(
            onPressed: () {},
            tooltip: 'Настройки',
            icon: const Icon(Icons.settings),
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
      floatingActionButton: _route.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => setState(() {
                    _route.clear();
                    _snapped = [];
                    _advised = null;
                  }),
              tooltip: 'Clear route',
              child: const Icon(Icons.clear),
            )
          : null,
    );
  }
}

class _TrafficLamp extends StatelessWidget {
  final Color color;
  final int leftSec;
  const _TrafficLamp({required this.color, required this.leftSec});

  @override
  Widget build(BuildContext context) {
    final isRed = color == Colors.red;
    final isGreen = color == Colors.green;
    final isBlue = color == Colors.blue;

    Widget lamp(Color on, bool active) => Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: active ? on : Colors.black26,
            shape: BoxShape.circle,
            boxShadow: active
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
              boxShadow: const [
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
