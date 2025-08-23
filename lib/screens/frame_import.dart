import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FrameImportScreen extends StatefulWidget {
  final int lightId;
  final String dir;
  const FrameImportScreen({super.key, required this.lightId, required this.dir});

  @override
  State<FrameImportScreen> createState() => _FrameImportScreenState();
}

class _FrameImportScreenState extends State<FrameImportScreen> {
  final _supa = Supabase.instance.client;
  final _frames = <_FrameItem>[];
  double _offset = 0;
  double _confidence = 0.9;

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (res == null) return;
    for (final f in res.files) {
      final path = f.path;
      if (path == null) continue;
      final name = path.split(RegExp(r'[\\/]')).last;
      final parsed = _parseName(name);
      if (parsed.ts == null) continue;
      String? phase = parsed.phase;
      if (phase == null) {
        phase = await _askPhase(name);
        if (phase == null) continue;
      }
      _frames.add(_FrameItem(ts: parsed.ts!, phase: phase));
    }
    _frames.sort((a, b) => a.ts.compareTo(b.ts));
    setState(() {});
  }

  Future<String?> _askPhase(String name) async {
    String ph = 'green';
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Phase for $name'),
        content: DropdownButton<String>(
          value: ph,
          items: const [
            DropdownMenuItem(value: 'green', child: Text('Green')),
            DropdownMenuItem(value: 'yellow', child: Text('Yellow')),
            DropdownMenuItem(value: 'red', child: Text('Red')),
          ],
          onChanged: (v) => ph = v ?? 'green',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, ph), child: const Text('OK')),
        ],
      ),
    );
  }

  _ParsedName _parseName(String name) {
    final lower = name.toLowerCase();
    DateTime? ts;
    String? phase;
    final rx1 = RegExp(r'(\d{8})[_-](\d{6})(?:_\d+)?(?:_([a-z]+))?(?:_([a-z]+))?');
    final m1 = rx1.firstMatch(lower);
    if (m1 != null) {
      final date = m1.group(1)!;
      final time = m1.group(2)!;
      ts = DateTime(
        int.parse(date.substring(0, 4)),
        int.parse(date.substring(4, 6)),
        int.parse(date.substring(6, 8)),
        int.parse(time.substring(0, 2)),
        int.parse(time.substring(2, 4)),
        int.parse(time.substring(4, 6)),
      );
      phase = _extractPhase([m1.group(3), m1.group(4)]);
    } else {
      final rx2 = RegExp(r'(\d{2})-(\d{2})-(\d{2})');
      final m2 = rx2.firstMatch(lower);
      if (m2 != null) {
        final now = DateTime.now();
        ts = DateTime(now.year, now.month, now.day,
            int.parse(m2.group(1)!), int.parse(m2.group(2)!), int.parse(m2.group(3)!));
      }
      phase = _extractPhase([null]);
    }
    return _ParsedName(ts: ts, phase: phase);
  }

  String? _extractPhase(List<String?> parts) {
    for (final p in parts) {
      if (p == 'red' || p == 'green' || p == 'yellow') return p;
    }
    final phMatch = RegExp(r'_(red|green|yellow)').firstMatch(parts.first ?? '');
    return phMatch?.group(1);
  }

  Future<void> _save() async {
    if (_frames.isEmpty) return;
    final uid = _supa.auth.currentUser?.id;
    if (uid == null) return;
    final rows = <Map<String, dynamic>>[];
    final offsetDur = Duration(seconds: _offset.round());
    for (int i = 0; i < _frames.length; i++) {
      final start = _frames[i].ts.add(offsetDur);
      final end = (i + 1 < _frames.length
              ? _frames[i + 1].ts
              : _frames[i].ts.add(const Duration(seconds: 1)))
          .add(offsetDur);
      rows.add({
        'light_id': widget.lightId,
        'dir': widget.dir,
        'phase': _frames[i].phase,
        'start_ts': start.toUtc().toIso8601String(),
        'end_ts': end.toUtc().toIso8601String(),
        'source': 'import',
        'inserted_via': 'import',
        'confidence': _confidence,
        'created_by': uid,
      });
    }
    await _supa.from('light_cycles').insert(rows);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Imported')));
      setState(() => _frames.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Frames')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Camera offset (sec)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _offset = double.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _pick, child: const Text('Import')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Confidence'),
                Expanded(
                  child: Slider(
                    value: _confidence,
                    min: 0.5,
                    max: 1.0,
                    divisions: 5,
                    label: _confidence.toStringAsFixed(2),
                    onChanged: (v) => setState(() => _confidence = v),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _frames.length,
              itemBuilder: (c, i) {
                final f = _frames[i];
                return ListTile(
                  title: DropdownButton<String>(
                    value: f.phase,
                    items: const [
                      DropdownMenuItem(value: 'green', child: Text('Green')),
                      DropdownMenuItem(value: 'yellow', child: Text('Yellow')),
                      DropdownMenuItem(value: 'red', child: Text('Red')),
                    ],
                    onChanged: (v) => setState(() => f.phase = v ?? f.phase),
                  ),
                  subtitle: Text(f.ts.toLocal().toString()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(onPressed: _save, child: const Text('Save')),
          ),
        ],
      ),
    );
  }
}

class _FrameItem {
  DateTime ts;
  String phase;
  _FrameItem({required this.ts, required this.phase});
}

class _ParsedName {
  final DateTime? ts;
  final String? phase;
  _ParsedName({this.ts, this.phase});
}

