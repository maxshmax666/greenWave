import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  LatLng? _myPos;
  List<LatLng>? _route;
  bool _followMe = true;
  String _advice = 'Long-press to set destination';

  @override
  void initState() {
    super.initState();
    _loadLights();
    _initLocation();
    _ticker =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateAdvice());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) return;
    Geolocator.getPositionStream()
        .listen((p) {
      final pos = LatLng(p.latitude, p.longitude);
      if (!mounted) return;
      setState(() {
        _myPos = pos;
        if (_followMe) {
          _map.move(pos, _map.camera.zoom);
        }
      });
    });
  }

  void _updateAdvice() {
    if (!mounted) return;
    if (_myPos == null || _route == null) {
      setState(() => _advice = 'Long-press to set destination');
      return;
    }
    final adv =
        SpeedAdvisor.advise(pos: _myPos!, route: _route!, lights: _lights);
    setState(() {
      if (!adv.hasLights) {
        _advice = 'No lights on route';
      } else {
        _advice =
            'Go ~${adv.speedKmh!.round()} km/h, next green in ${adv.etaSec} s';
      }
    });
  }

  Future<void> _loadLights() async {
    try {
      final res = await supa
          .from('lights')
          .select('id,name,lat,lon,green_sec,yellow_sec,red_sec,cycle_start_at')
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

  (Color, int) _phaseColorAndLeft(Map<String, dynamic> l) {
    final green = l['green_sec'] as int? ?? 0;
    final yellow = l['yellow_sec'] as int? ?? 0;
    final red = l['red_sec'] as int? ?? 0;
    final total = green + yellow + red;
    final startStr = l['cycle_start_at'] as String?;
    if (total == 0 || startStr == null) return (Colors.grey, 0);
    int mod(int a, int b) => ((a % b) + b) % b;
    final now = DateTime.now().toUtc();
    final start = DateTime.parse(startStr).toUtc();
    final s = mod(now.difference(start).inSeconds, total);
    if (s < red) return (Colors.red, red - s);
    if (s < red + green) return (Colors.green, red + green - s);
    return (Colors.yellow, total - s);
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

  Future<void> _setDestination(LatLng dest) async {
    if (_myPos == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет данных GPS')));
      return;
    }
    try {
      final r = await RouteService.getRoute(_myPos!, dest);
      setState(() {
        _route = r;
        _followMe = true;
      });
      _updateAdvice();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('OSRM error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = _lightMarkers();
    final allMarkers = List<Marker>.from(markers);
    if (_myPos != null) {
      allMarkers.add(Marker(
          point: _myPos!,
          width: 20,
          height: 20,
          child: const Icon(Icons.my_location, color: Colors.blue)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map & Lights'),
        actions: [
          IconButton(
            onPressed: _loadLights,
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
          ),
          if (_route != null)
            IconButton(
              onPressed: () => setState(() {
                _route = null;
                _advice = 'Long-press to set destination';
              }),
              tooltip: 'Очистить маршрут',
              icon: const Icon(Icons.clear),
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
          interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          onPositionChanged: (pos, hasGesture) {
            if (hasGesture) setState(() => _followMe = false);
          },
          onLongPress: (tapPos, latlng) => _setDestination(latlng),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.green_wave_app',
            maxNativeZoom: 19,
            maxZoom: 19,
            backgroundColor: Colors.white,
            errorTileCallback: (tile, error, stackTrace) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка загрузки тайла: $error')),
              );
            },
          ),
          if (_route != null)
            PolylineLayer(polylines: [
              Polyline(points: _route!, color: Colors.purple, strokeWidth: 4)
            ]),
          MarkerLayer(markers: allMarkers),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_advice),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _LegendDot(color: Colors.red, label: 'Красный'),
                      SizedBox(width: 12),
                      _LegendDot(color: Colors.yellow, label: 'Жёлтый'),
                      SizedBox(width: 12),
                      _LegendDot(color: Colors.green, label: 'Зелёный'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _followMe
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (_myPos != null) {
                  _map.move(_myPos!, _map.camera.zoom);
                  setState(() => _followMe = true);
                }
              },
              child: const Icon(Icons.my_location),
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
    final isRed = color == Colors.red;
    final isYellow = color == Colors.yellow;
    final isGreen = color == Colors.green;

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
              lamp(Colors.yellow, isYellow),
              lamp(Colors.green, isGreen),
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
