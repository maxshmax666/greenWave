import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CyclesScreen extends StatefulWidget {
  const CyclesScreen({super.key});
  @override
  State<CyclesScreen> createState() => _CyclesScreenState();
}

class _CyclesScreenState extends State<CyclesScreen>
    with SingleTickerProviderStateMixin {
  final _supa = Supabase.instance.client;
  List<Map<String, dynamic>> _lights = [];
  int? _lightId;
  late TabController _tabController;
  final _dirs = ['main', 'secondary', 'ped'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLights();
  }

  Future<void> _loadLights() async {
    final res = await _supa.from('lights').select('id,name').order('id');
    setState(() => _lights = List<Map<String, dynamic>>.from(res));
  }

  Future<double> _avgDuration(String dir, String phase) async {
    final from =
        DateTime.now().toUtc().subtract(const Duration(days: 1)).toIso8601String();
    final rows = await _supa
        .from('light_cycles')
        .select('start_ts,end_ts')
        .eq('light_id', _lightId)
        .eq('dir', dir)
        .eq('phase', phase)
        .gte('start_ts', from);
    final list = List<Map<String, dynamic>>.from(rows);
    if (list.isEmpty) return phase == 'yellow' ? 4.0 : 30.0;
    double sum = 0;
    for (final r in list) {
      final s = DateTime.parse(r['start_ts']).toUtc();
      final e = DateTime.parse(r['end_ts']).toUtc();
      sum += e.difference(s).inSeconds.toDouble();
    }
    return sum / list.length;
  }

  Future<void> _addEvent(String dir) async {
    String phase = 'green';
    final timeCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final durCtrl = TextEditingController();
    String note = '';
    double conf = 1.0;
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Добавить событие'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: phase,
                    items: const [
                      DropdownMenuItem(value: 'green', child: Text('Green')),
                      DropdownMenuItem(value: 'yellow', child: Text('Yellow')),
                      DropdownMenuItem(value: 'red', child: Text('Red')),
                    ],
                    onChanged: (v) => phase = v ?? 'green',
                    decoration: const InputDecoration(labelText: 'Фаза'),
                  ),
                  TextField(
                    controller: timeCtrl,
                    decoration: const InputDecoration(labelText: 'ЧЧ:ММ'),
                  ),
                  TextField(
                    controller: dateCtrl,
                    decoration: const InputDecoration(labelText: 'ГГГГ-ММ-ДД (опц)'),
                  ),
                  TextField(
                    controller: durCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Длительность сек'),
                  ),
                  TextField(
                    onChanged: (v) => note = v,
                    decoration: const InputDecoration(labelText: 'Примечание'),
                  ),
                  Slider(
                    value: conf,
                    min: 0.5,
                    max: 1.0,
                    divisions: 5,
                    label: conf.toStringAsFixed(2),
                    onChanged: (v) => setState(() => conf = v),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Отмена')),
              ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final parts = timeCtrl.text.split(':');
                    if (parts.length < 2) return;
                    final hour = int.tryParse(parts[0]) ?? now.hour;
                    final minute = int.tryParse(parts[1]) ?? now.minute;
                    DateTime start;
                    if (dateCtrl.text.isEmpty) {
                      start = DateTime(now.year, now.month, now.day, hour, minute);
                    } else {
                      final d = DateTime.tryParse(dateCtrl.text);
                      if (d == null) return;
                      start = DateTime(d.year, d.month, d.day, hour, minute);
                    }
                    double dur =
                        double.tryParse(durCtrl.text) ?? await _avgDuration(dir, phase);
                    final end = start.add(Duration(seconds: dur.round()));
                    final uid = _supa.auth.currentUser?.id;
                    if (uid == null) return;
                    await _supa.from('light_cycles').insert({
                      'light_id': _lightId,
                      'phase': phase,
                      'dir': dir,
                      'start_ts': start.toUtc().toIso8601String(),
                      'end_ts': end.toUtc().toIso8601String(),
                      'source': 'manual',
                      'inserted_via': 'manual',
                      'confidence': conf,
                      'note': note,
                      'created_by': uid,
                    });
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Сохранено')));
                    }
                  },
                  child: const Text('Сохранить')),
            ],
          );
        });
  }

  Future<void> _whatIf(String dir) async {
    String phase = 'red';
    final timeCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Что-если'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: phase,
                  items: const [
                    DropdownMenuItem(value: 'green', child: Text('Green')),
                    DropdownMenuItem(value: 'yellow', child: Text('Yellow')),
                    DropdownMenuItem(value: 'red', child: Text('Red')),
                  ],
                  onChanged: (v) => phase = v ?? 'red',
                  decoration: const InputDecoration(labelText: 'Фаза'),
                ),
                TextField(
                  controller: timeCtrl,
                  decoration: const InputDecoration(labelText: 'ЧЧ:ММ'),
                ),
                TextField(
                  controller: dateCtrl,
                  decoration: const InputDecoration(labelText: 'ГГГГ-ММ-ДД (опц)'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Отмена')),
              ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final parts = timeCtrl.text.split(':');
                    if (parts.length < 2) return;
                    final hour = int.tryParse(parts[0]) ?? now.hour;
                    final minute = int.tryParse(parts[1]) ?? now.minute;
                    DateTime start;
                    if (dateCtrl.text.isEmpty) {
                      start = DateTime(now.year, now.month, now.day, hour, minute);
                    } else {
                      final d = DateTime.tryParse(dateCtrl.text);
                      if (d == null) return;
                      start = DateTime(d.year, d.month, d.day, hour, minute);
                    }
                    final avgR = await _avgDuration(dir, 'red');
                    final avgG = await _avgDuration(dir, 'green');
                    final avgY = await _avgDuration(dir, 'yellow');
                    final mapDur = {'red': avgR, 'green': avgG, 'yellow': avgY};
                    final order = {'red': 'green', 'green': 'yellow', 'yellow': 'red'};
                    DateTime t = start;
                    String ph = phase;
                    final greens = <String>[];
                    for (int i = 0; i < 6 && greens.length < 3; i++) {
                      final dur = mapDur[ph]!;
                      final end = t.add(Duration(seconds: dur.round()));
                      if (ph == 'green') {
                        greens.add(
                            '${t.toLocal().toIso8601String()} - ${end.toLocal().toIso8601String()}');
                      }
                      t = end;
                      ph = order[ph]!;
                    }
                    if (mounted) {
                      Navigator.pop(ctx);
                      final txt =
                          greens.isEmpty ? 'Нет зеленых окон' : greens.join('\n');
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(txt)));
                    }
                  },
                  child: const Text('Посчитать')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Циклы'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Главная'),
            Tab(text: 'Второстепенная'),
            Tab(text: 'Пешеход'),
          ],
        ),
      ),
      body: Column(
        children: [
          DropdownButton<int>(
            value: _lightId,
            hint: const Text('Выберите светофор'),
            items: _lights
                .map((l) => DropdownMenuItem<int>(
                      value: l['id'] as int,
                      child: Text(l['name'] as String),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _lightId = v),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                3,
                (i) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: _lightId == null
                              ? null
                              : () => _addEvent(_dirs[i]),
                          child: const Text('Добавить событие')),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _lightId == null
                              ? null
                              : () => _whatIf(_dirs[i]),
                          child: const Text('Что-если')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

