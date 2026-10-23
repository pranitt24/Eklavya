import 'package:flutter/material.dart';
import '../../theme.dart';
import '../audio/sound_service.dart';

/// Squishy3DButton is a chunky, tactile arcade-style push button
/// with physical 3D bevel extrusion and instant pop-click audio feedback.
class Squishy3DButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? label;
  final String? sublabel;
  final Widget? icon;
  final Color backgroundColor;
  final Color? bevelColor;
  final Color textColor;
  final double height;
  final double? width;
  final double bevelHeight;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final bool playSound;
  final LinearGradient? gradient;

  const Squishy3DButton({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.sublabel,
    this.icon,
    this.backgroundColor = GameColors.emeraldGrass,
    this.bevelColor,
    this.textColor = Colors.white,
    this.height = 64.0,
    this.width,
    this.bevelHeight = 5.0,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    this.playSound = true,
    this.gradient,
  });

  @override
  State<Squishy3DButton> createState() => _Squishy3DButtonState();
}

class _Squishy3DButtonState extends State<Squishy3DButton> {
  bool _isPressed = false;

  Color get _resolvedBevelColor {
    if (widget.bevelColor != null) return widget.bevelColor!;
    if (widget.backgroundColor == GameColors.emeraldGrass) {
      return GameColors.emeraldGrassDark;
    }
    if (widget.backgroundColor == GameColors.electricPurple) {
      return GameColors.electricPurpleDark;
    }
    if (widget.backgroundColor == GameColors.activeGold) {
      return GameColors.activeGoldDark;
    }
    if (widget.backgroundColor == GameColors.vibrantOrange) {
      return GameColors.vibrantOrangeDark;
    }
    if (widget.backgroundColor == GameColors.robotBlue) {
      return GameColors.robotBlueDark;
    }
    final hsl = HSLColor.fromColor(widget.backgroundColor);
    return hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    if (widget.playSound) {
      SoundService.instance.playPopClick();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(32.0);
    final pushOffset = _isPressed ? 3.0 : 0.0;
    final isEnabled = widget.onPressed != null;

    final faceColor = isEnabled
        ? widget.backgroundColor
        : const Color(0xFFD6D1E6);
    final bevelColor = isEnabled
        ? _resolvedBevelColor
        : const Color(0xFFB4ACCE);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOutQuad,
        child: SizedBox(
          width: widget.width,
          height: widget.height + widget.bevelHeight,
          child: Stack(
            children: [
              // Bottom Bevel Layer
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: widget.bevelHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: bevelColor,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: bevelColor.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Button Face
              Positioned(
                left: 0,
                right: 0,
                top: pushOffset,
                bottom: widget.bevelHeight - pushOffset,
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: widget.gradient == null ? faceColor : null,
                    gradient: widget.gradient,
                    borderRadius: radius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: widget.child ??
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              widget.icon!,
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.label != null)
                                    Text(
                                      widget.label!,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GameTypography.buttonLabel(
                                        color: widget.textColor,
                                      ),
                                    ),
                                  if (widget.sublabel != null)
                                    Text(
                                      widget.sublabel!,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GameTypography.buttonSublabel(
                                        color: widget.textColor.withValues(alpha: 0.85),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
