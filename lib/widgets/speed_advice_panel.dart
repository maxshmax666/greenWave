import 'package:flutter/material.dart';

import '../domain/speed_advisor.dart';

/// Simple UI panel that displays recommended speed and upcoming windows.
class SpeedAdvicePanel extends StatelessWidget {
  const SpeedAdvicePanel({
    super.key,
    required this.distanceM,
    required this.currentKmh,
    required this.windows,
    this.limitKmh = 70,
  });

  final double distanceM;
  final double currentKmh;
  final List<({double tStart, double tEnd})> windows;
  final double limitKmh;

  @override
  Widget build(BuildContext context) {
    final rec = adviseSpeedKmh(
      distanceM: distanceM,
      currentKmh: currentKmh,
      windows: windows,
      limitKmh: limitKmh,
    );

    // crude progress estimation to stop line (0..1)
    final progress = (1 - distanceM / 200).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Рекомендуем: ${rec.toStringAsFixed(0)} км/ч',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 4,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: windows.map(_buildWindowChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWindowChip(({double tStart, double tEnd}) w) {
    final reachable = _windowReachable(w);
    final text = 'через ${w.tStart.round()}с → ${(w.tEnd - w.tStart).round()}с зелёный';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: reachable
            ? const LinearGradient(colors: [Colors.green, Colors.lightGreen])
            : null,
        color: reachable ? null : Colors.grey.shade600,
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  bool _windowReachable(({double tStart, double tEnd}) w) {
    final vMin = distanceM / w.tEnd * 3.6;
    final vMax = distanceM / w.tStart * 3.6;
    return vMin <= limitKmh && vMax >= 25;
  }
}
