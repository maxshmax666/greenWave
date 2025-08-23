import 'dart:math';

import 'package:flutter/material.dart';

/// A panel with animated gradients.
///
/// [GradientPanel] cycles through four preset [LinearGradient] palettes using a
/// [TweenSequence]. Each gradient transition lasts between 8–12 seconds. An
/// optional atmosphere of moving 🚦 icons can be displayed by setting
/// [showAtmosphere] to `true`.
class GradientPanel extends StatefulWidget {
  const GradientPanel({super.key, this.showAtmosphere = false});

  /// When true, shows slowly moving decorative elements above the gradient.
  final bool showAtmosphere;

  @override
  State<GradientPanel> createState() => _GradientPanelState();
}

class _GradientPanelState extends State<GradientPanel>
    with TickerProviderStateMixin {
  late final AnimationController _gradientController;
  late final Animation<LinearGradient> _gradientAnimation;

  AnimationController? _atmosphereController;

  @override
  void initState() {
    super.initState();

    // Define four gradient palettes.
    final gradients = <LinearGradient>[
      const LinearGradient(colors: [Colors.green, Colors.blue]),
      const LinearGradient(colors: [Colors.blue, Colors.purple]),
      const LinearGradient(colors: [Colors.purple, Colors.red]),
      const LinearGradient(colors: [Colors.red, Colors.orange]),
    ];

    // Durations (in seconds) for each gradient transition.
    const durations = <double>[8, 10, 12, 9];
    final total = durations.reduce((a, b) => a + b);

    _gradientController =
        AnimationController(vsync: this, duration: Duration(seconds: total.toInt()))
          ..repeat();

    final items = <TweenSequenceItem<LinearGradient>>[];
    for (var i = 0; i < gradients.length; i++) {
      items.add(
        TweenSequenceItem<LinearGradient>(
          tween: _LinearGradientTween(
            begin: gradients[i],
            end: gradients[(i + 1) % gradients.length],
          ),
          weight: durations[i],
        ),
      );
    }

    _gradientAnimation =
        TweenSequence<LinearGradient>(items).animate(_gradientController);

    if (widget.showAtmosphere) {
      _setupAtmosphere();
    }
  }

  @override
  void didUpdateWidget(covariant GradientPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAtmosphere && _atmosphereController == null) {
      _setupAtmosphere();
    } else if (!widget.showAtmosphere && _atmosphereController != null) {
      _atmosphereController!.dispose();
      _atmosphereController = null;
    }
  }

  void _setupAtmosphere() {
    _atmosphereController =
        AnimationController(vsync: this, duration: const Duration(seconds: 40))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _atmosphereController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _gradientController,
        if (_atmosphereController != null) _atmosphereController!,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(gradient: _gradientAnimation.value),
          child: Stack(
            children: [
              if (widget.showAtmosphere && _atmosphereController != null) ...[
                Positioned(
                  left: 50 + 20 * sin(2 * pi * _atmosphereController!.value),
                  top: 40 + 20 * cos(2 * pi * _atmosphereController!.value),
                  child: const Text('🚦', style: TextStyle(fontSize: 24)),
                ),
                Positioned(
                  right: 50 +
                      20 * cos(2 * pi * _atmosphereController!.value + pi / 2),
                  bottom: 40 +
                      20 * sin(2 * pi * _atmosphereController!.value + pi / 2),
                  child: const Text('🚦', style: TextStyle(fontSize: 24)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Tween for interpolating between two [LinearGradient]s.
class _LinearGradientTween extends Tween<LinearGradient> {
  _LinearGradientTween({super.begin, super.end});

  @override
  LinearGradient lerp(double t) {
    final beginColors = begin!.colors;
    final endColors = end!.colors;
    assert(beginColors.length == endColors.length);
    final colors = <Color>[];
    for (var i = 0; i < beginColors.length; i++) {
      colors.add(Color.lerp(beginColors[i], endColors[i], t)!);
    }
    return LinearGradient(
      colors: colors,
      begin: begin!.begin,
      end: begin!.end,
    );
  }
}

