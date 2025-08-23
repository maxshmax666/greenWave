import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManualStopwatchScreen extends StatefulWidget {
  final int lightId;
  final String dir;
  const ManualStopwatchScreen({super.key, required this.lightId, required this.dir});

  @override
  State<ManualStopwatchScreen> createState() => _ManualStopwatchScreenState();
}

class _ManualStopwatchScreenState extends State<ManualStopwatchScreen> {
  final _supa = Supabase.instance.client;
  bool _running = false;
  String? _curPhase;
  DateTime? _curStart;
  final List<Map<String, dynamic>> _segments = [];

  void _start() {
    _segments.clear();
    _curPhase = null;
    _curStart = DateTime.now();
    _running = true;
    setState(() {});
  }

  void _mark(String phase) {
    if (!_running) return;
    final now = DateTime.now();
    if (_curPhase != null && _curStart != null) {
      _segments.add({'phase': _curPhase, 'start': _curStart, 'end': now});
    }
    _curPhase = phase;
    _curStart = now;
    setState(() {});
  }

  void _stop() {
    if (!_running) return;
    final now = DateTime.now();
    if (_curPhase != null && _curStart != null) {
      _segments.add({'phase': _curPhase, 'start': _curStart, 'end': now});
    }
    _curPhase = null;
    _curStart = null;
    _running = false;
    setState(() {});
  }

  Future<void> _save() async {
    final uid = _supa.auth.currentUser?.id;
    if (uid == null || _segments.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nothing to save')));
      }
      return;
    }
    final rows = _segments
        .map((s) => {
              'light_id': widget.lightId,
              'phase': s['phase'],
              'dir': widget.dir,
              'start_ts': (s['start'] as DateTime).toUtc().toIso8601String(),
              'end_ts': (s['end'] as DateTime).toUtc().toIso8601String(),
              'source': 'manual',
              'inserted_via': 'manual',
              'confidence': 1.0,
              'created_by': uid,
            })
        .toList();
    await _supa.from('light_cycles').insert(rows);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved')));
      setState(() {
        _segments.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Light ${widget.lightId}, dir ${widget.dir}'),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: _start,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 60)),
                  child: const Text('Start')),
              ElevatedButton(
                  onPressed: () => _mark('green'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 60)),
                  child: const Text('Green')),
              ElevatedButton(
                  onPressed: () => _mark('yellow'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 60)),
                  child: const Text('Yellow')),
              ElevatedButton(
                  onPressed: () => _mark('red'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 60)),
                  child: const Text('Red')),
              ElevatedButton(
                  onPressed: _stop,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 60)),
                  child: const Text('Stop')),
              ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 60)),
                  child: const Text('Save')),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _segments.length,
              itemBuilder: (c, i) {
                final s = _segments[i];
                return ListTile(
                  title: Text('${s['phase']}'),
                  subtitle: Text(
                      '${(s['start'] as DateTime).toLocal()} -> ${(s['end'] as DateTime).toLocal()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

