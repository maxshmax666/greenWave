import 'package:flutter/material.dart';

/// A reusable panel with an animated gradient background.
///
/// Uses [AnimatedContainer] to keep animation isolated from parents.
class GradientPanel extends StatelessWidget {
  const GradientPanel({
    super.key,
    required this.child,
    this.gradient,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final Gradient? gradient;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
      ),
      child: child,
    );
  }
}
