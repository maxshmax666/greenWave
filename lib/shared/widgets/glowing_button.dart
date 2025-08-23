import 'package:flutter/material.dart';

/// A button with a subtle glowing animation.
///
/// Animation is kept local to avoid unnecessary parent rebuilds.
class GlowingButton extends StatefulWidget {
  const GlowingButton({super.key, required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Theme.of(context).colorScheme.primary;
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5 + 0.5 * _controller.value),
                blurRadius: 8 + 8 * _controller.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: widget.onPressed,
        child: widget.child,
      ),
    );
  }
}
