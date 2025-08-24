import 'package:flutter/material.dart';

/// Bottom panel displaying basic route information.
class RouteBottomPanel extends StatelessWidget {
  final String eta;
  final String duration;
  final String distance;
  final double progress; // 0..1

  const RouteBottomPanel({
    super.key,
    this.eta = '--:--',
    this.duration = '0 мин',
    this.distance = '0 км',
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: kElevationToShadow[1],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ETA: $eta'),
              Text('в пути: $duration'),
              Text('дистанция: $distance'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
        ],
      ),
    );
  }
}
