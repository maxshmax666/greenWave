import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Visual tone of [GlowingButton].
enum GlowingButtonTone { primary, secondary, ghost }

/// A custom button that shows a subtle glow on hover and focus.
class GlowingButton extends StatefulWidget {
  const GlowingButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.tone = GlowingButtonTone.primary,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String text;
  final GlowingButtonTone tone;
  final bool loading;

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    BorderSide? border;

    switch (widget.tone) {
      case GlowingButtonTone.primary:
        bg = scheme.primary;
        fg = scheme.onPrimary;
        break;
      case GlowingButtonTone.secondary:
        bg = scheme.secondary;
        fg = scheme.onSecondary;
        break;
      case GlowingButtonTone.ghost:
        bg = Colors.transparent;
        fg = scheme.primary;
        border = BorderSide(color: scheme.primary);
        break;
    }

    final glowColor = bg == Colors.transparent ? scheme.primary : bg;

    return Focus(
      onFocusChange: (v) => setState(() => _focus = v),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppTheme.radius,
            border: border,
            boxShadow: _hover || _focus
                ? [
                    BoxShadow(
                      color: glowColor.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppTheme.radius as BorderRadius?,
              onTap: widget.loading ? null : widget.onPressed,
              child: Padding(
                padding: AppTheme.padding,
                child: widget.loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(fg),
                        ),
                      )
                    : Text(
                        widget.text,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: fg),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
