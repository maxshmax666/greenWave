import 'package:flutter/material.dart';

import '../../domain/models/light.dart';
import '../../domain/models/light_cycle.dart';

/// Card displaying information about the next traffic light on the route.
class NextLightCard extends StatelessWidget {
  final Light light;
  final LightCycle cycle;
  final double? recommendedSpeed;

  const NextLightCard({
    super.key,
    required this.light,
    required this.cycle,
    this.recommendedSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final seconds = cycle.endTs.difference(DateTime.now()).inSeconds;
    String phaseLabel;
    Color phaseColor;
    switch (cycle.phase) {
      case 'green':
        phaseLabel = '🟢 зелёный';
        phaseColor = Colors.green;
        break;
      case 'yellow':
        phaseLabel = '🟡 жёлтый';
        phaseColor = Colors.amber;
        break;
      default:
        phaseLabel = '🔴 красный';
        phaseColor = Colors.red;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Следующий светофор — №${light.id} (${light.name})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Фаза: $phaseLabel', style: TextStyle(color: phaseColor)),
            Text('Таймер: ⏱ ${seconds.clamp(0, 999)} c'),
            if (recommendedSpeed != null)
              Text('Реком. скорость: 🚗 ${recommendedSpeed!.toStringAsFixed(0)} км/ч'),
          ],
        ),
      ),
    );
  }
}
