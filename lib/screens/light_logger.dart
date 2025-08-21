import 'package:flutter/material.dart';
import '../data/db.dart';

class LightLogger extends StatefulWidget {
  final int lightId;
  const LightLogger({super.key, required this.lightId});
  @override
  State<LightLogger> createState() => _LightLoggerState();
}

class _LightLoggerState extends State<LightLogger> {
  final _db = AppDb();
  var _items = <dynamic>[];
  Future<void> _load() async {
    final s = await _db.samplesByLight(widget.lightId);
    setState(() => _items = s);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
      appBar: AppBar(title: const Text('Лог фаз')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (ctx, i) {
              final s = _items[i];
              return ListTile(
                  title: Text('${s.ts.toLocal()} — ${s.phase.name}'),
                  subtitle: s.confidence != null
                      ? Text('conf=${s.confidence.toStringAsFixed(2)}')
                      : null);
            }),
      ));
}
