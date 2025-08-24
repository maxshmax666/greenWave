import 'package:flutter/material.dart';

/// Card showing the upcoming maneuver in the route.
class TurnCard extends StatelessWidget {
  const TurnCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.turn_left, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Через 390 м — налево',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'ул. Ленина',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
