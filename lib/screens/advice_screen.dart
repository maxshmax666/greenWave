import 'package:flutter/material.dart';
import '../data/db.dart';
import 'speed_advisor.dart';

class AdviceScreen extends StatefulWidget {
  final int lightId;
  final double distanceMeters, speedLimitKmh, tSinceCycleStart;

  const AdviceScreen({
    super.key,
    required this.lightId,
    required this.distanceMeters,
    required this.speedLimitKmh,
    required this.tSinceCycleStart,
  });

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  final _db = AppDb();
  PhaseModel? _m;
  SpeedAdvice? _adv;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final s = await _db.samplesByLight(widget.lightId);
    final m = PhaseEstimator.estimate(s);
    setState(() => _m = m);
    if (m != null) {
      final a = Advisor.advise(
        m: m,
        dMeters: widget.distanceMeters,
        vLimit: widget.speedLimitKmh / 3.6,
        tSinceCycleStart: widget.tSinceCycleStart,
      );
      setState(() => _adv = a);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Подсказка скорости')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _m == null
              ? const Text('Недостаточно данных. Прокатись с автологом камеры.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Цикл ${_m!.tCycle.toStringAsFixed(1)}с (R ${_m!.tRed.toStringAsFixed(1)} / '
                      'Y ${_m!.tYellow.toStringAsFixed(1)} / G ${_m!.tGreen.toStringAsFixed(1)})',
                    ),
                    const SizedBox(height: 8),
                    if (_adv != null) ...[
                      Text(
                        _adv!.message,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_adv!.vLow != null && _adv!.vHigh != null)
                        Text(
                          'Держите ~ ${(_adv!.vLow! * 3.6).toStringAsFixed(0)}–'
                          '${(_adv!.vHigh! * 3.6).toStringAsFixed(0)} км/ч',
                        ),
                    ],
                  ],
                ),
        ),
      );
}
