import 'package:flutter/material.dart';
import '../../design_system/nova_colors.dart';
import '../../design_system/nova_typography.dart';
import '../../design_system/nova_spacing.dart';

enum NovaButtonVariant {
  primary,
  secondary,
  correct,
  retry,
  completed,
  gold,
}

/// Tactile, 3D pill button matching NOVA visual design specifications.
/// Includes top highlight line, solid depth shadow, and tactile press animation.
class NovaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final NovaButtonVariant variant;
  final Widget? icon;
  final double height;
  final double? width;
  final bool isSelected;
  final bool isLoading;

  const NovaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = NovaButtonVariant.primary,
    this.icon,
    this.height = 54.0,
    this.width,
    this.isSelected = false,
    this.isLoading = false,
  });

  @override
  State<NovaButton> createState() => _NovaButtonState();
}

class _NovaButtonState extends State<NovaButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bgColor;
    Color bevelColor;
    Color textColor;
    Border? border;

    switch (widget.variant) {
      case NovaButtonVariant.primary:
        bgColor = NovaColors.purple;
        bevelColor = NovaColors.purpleDark;
        textColor = Colors.white;
        if (widget.isSelected) {
          border = Border.all(color: NovaColors.gold, width: 3.0);
        }
        break;

      case NovaButtonVariant.secondary:
        bgColor = Colors.white;
        bevelColor = const Color(0xFFD5D2E8);
        textColor = NovaColors.ink;
        border = Border.all(color: NovaColors.purpleBorder, width: 1.5);
        break;

      case NovaButtonVariant.correct:
        bgColor = NovaColors.green;
        bevelColor = NovaColors.greenDark;
        textColor = Colors.white;
        break;

      case NovaButtonVariant.retry:
        bgColor = NovaColors.coralLight;
        bevelColor = const Color(0xFFFCA5A5);
        textColor = NovaColors.ink;
        border = Border.all(color: NovaColors.coral, width: 2.0);
        break;

      case NovaButtonVariant.completed:
        bgColor = NovaColors.green;
        bevelColor = NovaColors.greenDark;
        textColor = Colors.white;
        break;

      case NovaButtonVariant.gold:
        bgColor = NovaColors.goldLight;
        bevelColor = const Color(0xFFFDE68A);
        textColor = NovaColors.ink;
        border = Border.all(color: NovaColors.gold, width: 1.5);
        break;
    }

    if (!isEnabled) {
      bgColor = const Color(0xFFE5E7EB);
      bevelColor = const Color(0xFFD1D5DB);
      textColor = NovaColors.inkMuted;
      border = null;
    }

    final double effectiveHeight = widget.height.clamp(NovaSpacing.minTouchTarget, 100.0);
    const double bevelDepth = 4.0;
    final double topMargin = _isPressed ? bevelDepth : 0.0;
    final double bottomBevel = _isPressed ? 0.0 : bevelDepth;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          width: widget.width,
          height: effectiveHeight,
          margin: EdgeInsets.only(top: topMargin, bottom: _isPressed ? 0.0 : 0.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: NovaSpacing.roundedPill,
            border: border,
            boxShadow: isEnabled && !_isPressed
                ? [
                    BoxShadow(
                      color: bevelColor,
                      offset: Offset(0, bottomBevel),
                      blurRadius: 0,
                    ),
                    const BoxShadow(
                      color: Color(0x1A271C44),
                      offset: Offset(0, 6),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Subtle inner top highlight line (as seen in spec)
              if (widget.variant == NovaButtonVariant.primary ||
                  widget.variant == NovaButtonVariant.correct ||
                  widget.variant == NovaButtonVariant.completed)
                Positioned(
                  top: 4,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              widget.icon!,
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                widget.label,
                                style: NovaTypography.buttonPrimary.copyWith(
                                  color: textColor,
                                  fontSize: effectiveHeight < 50 ? 15 : 18,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
