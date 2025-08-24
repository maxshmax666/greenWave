import 'package:flutter/material.dart';
import '../data/db.dart';
import 'speed_advisor.dart';
import 'package:green_wave_app/l10n/generated/app_localizations.dart';

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
  Widget build(BuildContext c) {
    final l10n = AppLocalizations.of(c)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adviceTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _m == null
            ? Text(l10n.notEnoughData)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cycleInfo(
                      _m!.tCycle.toStringAsFixed(1),
                      _m!.tRed.toStringAsFixed(1),
                      _m!.tYellow.toStringAsFixed(1),
                      _m!.tGreen.toStringAsFixed(1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_adv != null) ...[
                    Text(
                      _adv!.message,
                      style: Theme.of(c).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_adv!.vLow != null && _adv!.vHigh != null)
                      Text(
                        l10n.holdSpeed(
                          (_adv!.vLow! * 3.6).toStringAsFixed(0),
                          (_adv!.vHigh! * 3.6).toStringAsFixed(0),
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}
