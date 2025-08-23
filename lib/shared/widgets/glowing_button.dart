import 'package:flutter/material.dart';


/// A customizable button with a glowing effect.
class GlowingButton extends StatelessWidget {
  const GlowingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tone = GlowingButtonTone.primary,
    this.isLoading = false,
    this.onHover,
    this.onFocus,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final GlowingButtonTone tone;
  final bool isLoading;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocus;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    Color background;
    Color foreground;
    BorderSide? border;

    switch (tone) {
      case GlowingButtonTone.primary:
        background = colorScheme.primary;
        foreground = colorScheme.onPrimary;
        break;
      case GlowingButtonTone.secondary:
        background = colorScheme.secondary;
        foreground = colorScheme.onSecondary;
        break;
      case GlowingButtonTone.ghost:
        background = Colors.transparent;
        foreground = colorScheme.primary;
        border = BorderSide(color: colorScheme.primary);
        break;
    }

    final BorderRadius radius = BorderRadius.circular(8);

    return Focus(
      onFocusChange: onFocus,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          onHover: onHover,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              color: background,
              borderRadius: radius,
              border: border != null ? Border.fromBorderSide(border) : null,
              boxShadow: [
                BoxShadow(
                  color: foreground.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(foreground),
                        ),
                      )
                    : DefaultTextStyle.merge(
                        style: TextStyle(color: foreground),
                        child: child,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum GlowingButtonTone { primary, secondary, ghost }

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
 
