import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../glowing_button.dart';

final supa = Supabase.instance.client;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _map = MapController();
  LatLng? _me;
  StreamSubscription<Position>? _posSub;

  List<Light> _lights = [];
  List<Map<String, dynamic>> _marks = [];
  RealtimeChannel? _marksChannel;
  RealtimeChannel? _lightsChannel;

  Timer? _ticker; // ежесекундный тик для смены цвета

  @override
  void initState() {
    super.initState();
    _ensureSession();
    _initLocation();
    _loadLights();
    _loadMarks();
    _subscribeMarks();
    _subscribeLights();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  // ---------- AUTH ----------
  Future<void> _ensureSession() async {
    try {
      if (supa.auth.currentSession == null) {
        await supa.auth.signInAnonymously();
      }
    } catch (e) {
      _toast('Auth error: $e');
    }
  }

  // ---------- LOCATION ----------
  Future<void> _initLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      _toast('Разрешение на геопозицию не выдано');
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _me = LatLng(pos.latitude, pos.longitude));
      _map.move(_me!, 16);
      _posSub = Geolocator.getPositionStream().listen((p) {
        setState(() => _me = LatLng(p.latitude, p.longitude));
      });
    } catch (e) {
      _toast('Ошибка геопозиции: $e');
    }
  }

  // ---------- SUPABASE LOAD/SUBSCRIBE ----------
  Future<void> _loadLights() async {
    try {
      final res = await supa
          .from('lights')
          .select(
              'id,name,lat,lon,green_sec,yellow_sec,red_sec,offset_sec,cycle_start_at')
          .order('id');
      setState(() {
        _lights = List<Map<String, dynamic>>.from(res)
            .map((m) => Light.fromMap(m))
            .toList();
      });
    } catch (e) {
      _toast('Не загрузили светофоры: $e');
    }
  }

  Future<void> _loadMarks() async {
    try {
      final res = await supa
          .from('record_marks')
          .select('id,lat,lon,note,ts,created_by')
          .order('ts', ascending: false);
      setState(() => _marks = List<Map<String, dynamic>>.from(res));
    } catch (e) {
      _toast('Не загрузили метки: $e');
    }
  }

  void _subscribeMarks() {
    _marksChannel = supa
        .channel('public:record_marks')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'record_marks',
          callback: (payload) {
            final rec = Map<String, dynamic>.from(payload.newRecord);
            setState(() => _marks.insert(0, rec));
          },
        )
        .subscribe();
  }

  void _subscribeLights() {
    _lightsChannel = supa
        .channel('public:lights')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'lights',
          callback: (_) => _loadLights(),
        )
        .subscribe();
  }

  // ---------- ACTIONS ----------
  Future<void> _addLight(LatLng p) async {
    final ctrlName = TextEditingController(
      text:
          'light_${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}',
    );
    final ctrlGreen = TextEditingController(text: '30');
    final ctrlYellow = TextEditingController(text: '3');
    final ctrlRed = TextEditingController(text: '30');
    final ctrlOffset = TextEditingController(text: '0');

    DateTime startRed = DateTime.now(); // начало красного (якорь цикла)

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) {
        return AlertDialog(
          title: const Text('Добавить светофор'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrlName,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctrlGreen,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Зелёный, сек'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: ctrlYellow,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Жёлтый, сек'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctrlRed,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Красный, сек'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: ctrlOffset,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Смещение, сек'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Старт КРАСНОГО: ${_fmt(startRed)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          setLocal(() => startRed = DateTime.now()),
                      child: const Text('= сейчас'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена'),
            ),
            GlowingButton(
              onPressed: () => Navigator.pop(ctx, true),
              text: 'Сохранить',
            ),
          ],
        );
      }),
    );
    if (ok != true) return;

    final u = supa.auth.currentUser;
    if (u == null) {
      _toast('Нужна авторизация');
      return;
    }

    final green = int.tryParse(ctrlGreen.text.trim()) ?? 30;
    final yellow = int.tryParse(ctrlYellow.text.trim()) ?? 3;
    final red = int.tryParse(ctrlRed.text.trim()) ?? 30;
    final offset = int.tryParse(ctrlOffset.text.trim()) ?? 0;

    try {
      await supa.from('lights').insert({
        'name': ctrlName.text.trim(),
        'lat': p.latitude,
        'lon': p.longitude,
        'created_by': u.id,
        'green_sec': green,
        'yellow_sec': yellow,
        'red_sec': red,
        'offset_sec': offset,
        'cycle_start_at': startRed.toIso8601String(),
      });
      await _loadLights();
      _toast('Светофор добавлен');
    } catch (e) {
      _toast('Ошибка добавления светофора: $e');
    }
  }

  Future<void> _editLight(Light l) async {
    final ctrlName = TextEditingController(text: l.name ?? '');
    final ctrlGreen = TextEditingController(text: '${l.greenSec}');
    final ctrlYellow = TextEditingController(text: '${l.yellowSec}');
    final ctrlRed = TextEditingController(text: '${l.redSec}');
    final ctrlOffset = TextEditingController(text: '${l.offsetSec}');
    DateTime startRed = l.cycleStartAt;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) {
        return AlertDialog(
          title: const Text('Настроить интервалы'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrlName,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctrlGreen,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Зелёный, сек'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: ctrlYellow,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Жёлтый, сек'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctrlRed,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Красный, сек'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: ctrlOffset,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Смещение, сек'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Старт КРАСНОГО: ${_fmt(startRed)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          setLocal(() => startRed = DateTime.now()),
                      child: const Text('= сейчас'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена'),
            ),
            GlowingButton(
              onPressed: () => Navigator.pop(ctx, true),
              text: 'Сохранить',
            ),
          ],
        );
      }),
    );
    if (ok != true) return;

    final green = int.tryParse(ctrlGreen.text.trim()) ?? l.greenSec;
    final yellow = int.tryParse(ctrlYellow.text.trim()) ?? l.yellowSec;
    final red = int.tryParse(ctrlRed.text.trim()) ?? l.redSec;
    final offset = int.tryParse(ctrlOffset.text.trim()) ?? l.offsetSec;

    try {
      await supa.from('lights').update({
        'name': ctrlName.text.trim(),
        'green_sec': green,
        'yellow_sec': yellow,
        'red_sec': red,
        'offset_sec': offset,
        'cycle_start_at': startRed.toIso8601String(),
      }).eq('id', l.id);
      await _loadLights();
      _toast('Интервалы обновлены');
    } catch (e) {
      _toast('Ошибка обновления: $e');
    }
  }

  Future<void> _addMarkHere() async {
    final loc = await Permission.locationWhenInUse.request();
    if (!loc.isGranted) {
      _toast('Нет доступа к геопозиции');
      return;
    }
    Position p;
    try {
      p = await Geolocator.getCurrentPosition();
    } catch (e) {
      _toast('Не удалось получить позицию: $e');
      return;
    }
    await _ensureSession();
    final u = supa.auth.currentUser;
    if (u == null) {
      _toast('Нет сессии, авторизуйтесь');
      return;
    }

    final local = {
      'id': DateTime.now().microsecondsSinceEpoch,
      'lat': p.latitude,
      'lon': p.longitude,
      'note': 'mark_from_map',
      'ts': DateTime.now().toIso8601String(),
      'created_by': u.id,
    };
    setState(() => _marks.insert(0, local));

    try {
      final row = await supa
          .from('record_marks')
          .insert({
            'lat': p.latitude,
            'lon': p.longitude,
            'note': 'mark_from_map',
            'created_by': u.id,
          })
          .select()
          .single();
      final idx = _marks.indexWhere((m) => m['id'] == local['id']);
      if (idx != -1) {
        setState(() => _marks[idx] = Map<String, dynamic>.from(row));
      }
      _toast('Метка добавлена');
    } catch (e) {
      _toast('Ошибка добавления метки: $e');
    }
  }

  // ---------- MISC ----------
  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _posSub?.cancel();
    if (_marksChannel != null) supa.removeChannel(_marksChannel!);
    if (_lightsChannel != null) supa.removeChannel(_lightsChannel!);
    _ticker?.cancel();
    super.dispose();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final center = _me ?? const LatLng(55.751244, 37.618423);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map & Lights'),
        actions: [
          IconButton(
            onPressed: _loadLights,
            tooltip: 'Обновить светофоры',
            icon: const Icon(Icons.traffic),
          ),
          IconButton(
            onPressed: _loadMarks,
            tooltip: 'Обновить метки',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _addMarkHere,
            tooltip: 'Поставить метку здесь',
            icon: const Icon(Icons.flag),
          ),
          IconButton(
            onPressed: () {
              if (_me != null) _map.move(_me!, 16);
            },
            tooltip: 'Моё местоположение',
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _map,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 14,
          onLongPress: (tapPos, latlng) => _addLight(latlng),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.green_wave_app',
          ),

          // Метки (оранжевые флажки)
          MarkerLayer(
            markers: _marks.map((m) {
              final p = LatLng(
                (m['lat'] as num).toDouble(),
                (m['lon'] as num).toDouble(),
              );
              final note = (m['note'] ?? '').toString();
              final ts = (m['ts'] ?? '').toString();
              final msg = note.isEmpty ? ts : '$note\n$ts';
              return Marker(
                point: p,
                width: 36,
                height: 36,
                child: Tooltip(
                  message: msg,
                  child: const Icon(Icons.flag, color: Colors.orange, size: 28),
                ),
              );
            }).toList(),
          ),

          // Светофоры (меняют цвет: red/green/yellow)
          MarkerLayer(
            markers: _lights.map((l) {
              final p = LatLng(l.lat, l.lon);
              final phase = l.phaseAt(now);
              final color = switch (phase) {
                LightPhase.green => Colors.green,
                LightPhase.yellow => Colors.amber,
                LightPhase.red => Colors.red,
              };

              return Marker(
                point: p,
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => _editLight(l),
                  child: Tooltip(
                    message:
                        '${l.name ?? 'light'}\nG:${l.greenSec}s Y:${l.yellowSec}s R:${l.redSec}s\nСтарт RED: ${_fmt(l.cycleStartAt)}',
                    child: Icon(Icons.traffic, color: color, size: 32),
                  ),
                ),
              );
            }).toList(),
          ),

          // Я (синий)
          if (_me != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _me!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.my_location,
                      color: Colors.blue, size: 32),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ====== Вспомогательные вещи ======
String _fmt(DateTime t) {
  // простой человекочитаемый формат
  return '${t.year.toString().padLeft(4, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}';
}

// ====== Модель светофора ======
enum LightPhase { red, green, yellow }

class Light {
  final int id;
  final String? name;
  final double lat;
  final double lon;
  final int greenSec;
  final int yellowSec;
  final int redSec;
  final int offsetSec; // оставили для совместимости
  final DateTime cycleStartAt; // якорь: начало КРАСНОГО

  Light({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.greenSec,
    required this.yellowSec,
    required this.redSec,
    required this.offsetSec,
    required this.cycleStartAt,
  });

  factory Light.fromMap(Map<String, dynamic> m) => Light(
        id: m['id'] as int,
        name: (m['name'] as String?),
        lat: (m['lat'] as num).toDouble(),
        lon: (m['lon'] as num).toDouble(),
        greenSec: (m['green_sec'] ?? 30) as int,
        yellowSec: (m['yellow_sec'] ?? 3) as int,
        redSec: (m['red_sec'] ?? 30) as int,
        offsetSec: (m['offset_sec'] ?? 0) as int,
        cycleStartAt: DateTime.parse(
          (m['cycle_start_at'] ?? DateTime.now().toIso8601String()) as String,
        ),
      );

  /// Фаза в момент [t]. Начало цикла — RED (cycle_start_at).
  LightPhase phaseAt(DateTime t) {
    final total = greenSec + yellowSec + redSec;
    if (total <= 0) return LightPhase.green;

    // добавим offsetSec как дополнительный сдвиг (если ещё используешь)
    final elapsed = t.difference(cycleStartAt).inSeconds + offsetSec;

    // корректный модуль для отрицательных
    int mod(int a, int b) => ((a % b) + b) % b;
    final x = mod(elapsed, total);

    if (x < redSec) return LightPhase.red;
    if (x < redSec + greenSec) return LightPhase.green;
    return LightPhase.yellow;
  }

  bool isGreenAt(DateTime t) => phaseAt(t) == LightPhase.green;
}
