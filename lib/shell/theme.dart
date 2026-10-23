import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'audio/game_audio.dart';

/// GameColors defines the complete vibrant, warm, toybox palette
/// inspired by Toca Boca and Candy Crush for "Majhe Gaon".
class GameColors {
  // Canvas & Surfaces (strictly no harsh pure white #FFFFFF for full screen base)
  static const Color canvasBase = Color(0xFFFFFDF5); // Warm sunlit cream canvas
  static const Color canvasCream = Color(0xFFFFFBEB); // Warm amber-50 HUD surface
  static const Color canvasMint = Color(0xFFF0FDF4); // Soft lush green tint
  static const Color canvasLavender = Color(0xFFFAF5FF); // Soft lavender cloud
  static const Color canvasSky = Color(0xFFEFF6FF); // Soft morning sky

  // Twilight Night Sky (Screen 5 & Cinema Mode)
  static const Color twilightDark = Color(0xFF1E1B4B); // Deep Indigo
  static const Color twilightBlue = Color(0xFF4338CA); // Royal Blue
  static const LinearGradient twilightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [twilightDark, twilightBlue],
  );

  // Primary Grass / Main CTAs
  static const Color emeraldGrass = Color(0xFF10B981); // Emerald-500
  static const Color emeraldGrassDark = Color(0xFF047857); // Bevel ridge (Emerald-700)
  static const Color emeraldGrassLight = Color(0xFF34D399); // Top glossy highlight
  static const Color emeraldCompleted = Color(0xFF059669); // Unlocked completed levels

  static const LinearGradient emeraldButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF34D399), Color(0xFF059669)],
  );

  // Hero / Electric Purple (NOVA & Mission Triggers)
  static const Color electricPurple = Color(0xFF6C47FF);
  static const Color electricPurpleDark = Color(0xFF5432DE); // Bevel ridge
  static const Color electricPurpleLight = Color(0xFF9070FF);
  static const Color purpleContainer = Color(0xFFF3E8FF);

  static const LinearGradient purpleButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF8B6CFF), Color(0xFF5432DE)],
  );

  // Active Gold / Accent (Saga Nodes, Coins, Stars, Streaks)
  static const Color activeGold = Color(0xFFFBBF24); // Amber-400
  static const Color activeGoldDark = Color(0xFFD97706); // Bevel ridge (Amber-600)
  static const Color activeGoldLight = Color(0xFFFDE047); // Yellow-300 highlight
  static const Color activeGoldDeep = Color(0xFFB45309);

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFDE047), Color(0xFFF59E0B)],
  );

  // Vibrant Orange (Audio Narrator & Prompt Buttons)
  static const Color vibrantOrange = Color(0xFFF97316);
  static const Color vibrantOrangeDark = Color(0xFFC2410C); // Bevel ridge
  static const Color vibrantOrangeLight = Color(0xFFFB923C);

  // Sky Blue / Robot NOVA
  static const Color robotBlue = Color(0xFF38BDF8);
  static const Color robotBlueDark = Color(0xFF0284C7); // Bevel ridge

  // Locked Level Nodes
  static const Color lockedBackground = Color(0xFFEDE9FE);
  static const Color lockedBorder = Color(0xFFDDD6FE);

  // Typography & Inks (never pure black #000000; warm grape undertones)
  static const Color inkGrape = Color(0xFF271C44); // Deep Grape Black
  static const Color inkMuted = Color(0xFF5E5478);
  static const Color inkLight = Color(0xFF8B82A8);

  // Card Borders & Highlights
  static const Color cardBorderLavender = Color(0xFFEDE5FF);
  static const Color cardBorderAmber = Color(0xFFFDE68A);

  // Storybook & Gameplay Aliases
  static const Color storybookCream = Color(0xFFFFFDF5);
  static const Color sunflowerGold = Color(0xFFFBBF24);
  static const Color meadowGreen = Color(0xFF10B981);
  static const Color meadowGreenDark = Color(0xFF047857);
  static const Color meadowGreenLight = Color(0xFF34D399);
  static const Color coralRed = Color(0xFFEF4444);
  static const Color coralRedDark = Color(0xFFB91C1C);
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color skyBlueDark = Color(0xFF0284C7);
  static const Color clayBrown = Color(0xFF78350F);
  static const Color woodBarkBrown = Color(0xFF92400E);
}

/// GameTypography provides font styles with dual Devanagari & Latin support
class GameTypography {
  static TextStyle displayHero({Color color = GameColors.inkGrape}) =>
      GoogleFonts.baloo2(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.25,
      );

  static TextStyle displayHeroMedium({Color color = GameColors.inkGrape}) =>
      GoogleFonts.baloo2(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.3,
      );

  static TextStyle headline({Color color = GameColors.inkGrape}) =>
      GoogleFonts.baloo2(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle marathiHeadingLarge({Color color = GameColors.inkGrape}) =>
      GoogleFonts.baloo2(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.25,
      );

  static TextStyle marathiHeadingMedium({Color color = GameColors.inkGrape}) =>
      GoogleFonts.baloo2(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle marathiBody({Color color = GameColors.inkGrape}) =>
      GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.35,
      );

  static TextStyle bodyLarge({Color color = GameColors.inkGrape}) =>
      GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.4,
      );

  static TextStyle bodyMedium({Color color = GameColors.inkGrape}) =>
      GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle buttonLabel({Color color = Colors.white}) =>
      GoogleFonts.baloo2(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.5,
      );

  static TextStyle buttonSublabel({Color color = Colors.white70}) =>
      GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle hudBadge({Color color = GameColors.inkGrape}) =>
      GoogleFonts.baloo2(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: color,
      );
}

/// Chunky3DButton: A tactile, squishy 3D button with bottom bevel extrusion
/// and satisfying physics that triggers PopClick audio on tap.
class Chunky3DButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? label;
  final String? sublabel;
  final Widget? icon;
  final Widget? child;
  final Color color;
  final Color? bevelColor;
  final Color textColor;
  final double height;
  final double? width;
  final double bevelHeight;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final bool playSound;
  final LinearGradient? gradient;

  const Chunky3DButton({
    super.key,
    required this.onPressed,
    this.label,
    this.sublabel,
    this.icon,
    this.child,
    this.color = GameColors.emeraldGrass,
    this.bevelColor,
    this.textColor = Colors.white,
    this.height = 64.0,
    this.width,
    this.bevelHeight = 5.0,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    this.playSound = true,
    this.gradient,
  });

  @override
  State<Chunky3DButton> createState() => _Chunky3DButtonState();
}

class _Chunky3DButtonState extends State<Chunky3DButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  Color get _effectiveBevelColor {
    if (widget.bevelColor != null) return widget.bevelColor!;
    if (widget.color == GameColors.emeraldGrass) return GameColors.emeraldGrassDark;
    if (widget.color == GameColors.electricPurple) return GameColors.electricPurpleDark;
    if (widget.color == GameColors.activeGold) return GameColors.activeGoldDark;
    if (widget.color == GameColors.vibrantOrange) return GameColors.vibrantOrangeDark;
    if (widget.color == GameColors.robotBlue) return GameColors.robotBlueDark;
    final hsl = HSLColor.fromColor(widget.color);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    if (widget.playSound) {
      GameAudio.playPop();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(32.0);
    final topOffset = _isPressed ? (widget.bevelHeight - 1.5) : 0.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutQuad,
        child: SizedBox(
          width: widget.width,
          height: widget.height + widget.bevelHeight,
          child: Stack(
            children: [
              // Bottom 3D Bevel Shadow
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: widget.bevelHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: _effectiveBevelColor,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: _effectiveBevelColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Interactive Button Face (translates down on press)
              Positioned(
                left: 0,
                right: 0,
                top: topOffset,
                bottom: widget.bevelHeight - topOffset,
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: widget.gradient == null ? widget.color : null,
                    gradient: widget.gradient,
                    borderRadius: radius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
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
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.label != null)
                                  Text(
                                    widget.label!,
                                    textAlign: TextAlign.center,
                                    style: GameTypography.buttonLabel(
                                      color: widget.textColor,
                                    ),
                                  ),
                                if (widget.sublabel != null)
                                  Text(
                                    widget.sublabel!,
                                    textAlign: TextAlign.center,
                                    style: GameTypography.buttonSublabel(
                                      color: widget.textColor.withValues(alpha: 0.85),
                                    ),
                                  ),
                              ],
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

/// Floating HUD Pill for Coins, Stars, and Streaks
class HudPillChip extends StatelessWidget {
  final Widget icon;
  final String label;
  final String? sublabel;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const HudPillChip({
    super.key,
    required this.icon,
    required this.label,
    this.sublabel,
    this.backgroundColor = GameColors.canvasCream,
    this.borderColor = GameColors.cardBorderAmber,
    this.textColor = GameColors.inkGrape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: GameColors.inkGrape.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            label,
            style: GameTypography.hudBadge(color: textColor),
          ),
          if (sublabel != null) ...[
            const SizedBox(width: 4),
            Text(
              sublabel!,
              style: GameTypography.buttonSublabel(color: GameColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Circular Tactile Audio Speaker Prompt Button (48x48)
class SpeakerButton extends StatefulWidget {
  final VoidCallback? onPlay;
  final Color color;
  final double size;

  const SpeakerButton({
    super.key,
    this.onPlay,
    this.color = GameColors.vibrantOrange,
    this.size = 48.0,
  });

  @override
  State<SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<SpeakerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bevel = 4.0;
    final topOffset = _isPressed ? (bevel - 1.0) : 0.0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        GameAudio.playPop();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPlay?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: widget.size,
        height: widget.size + bevel,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: bevel,
              child: Container(
                decoration: BoxDecoration(
                  color: GameColors.vibrantOrangeDark,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: topOffset,
              bottom: bevel - topOffset,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Storybook rounded card container with 3D soft border
class GameCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const GameCard({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = GameColors.cardBorderLavender,
    this.elevation = 4.0,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: GameColors.inkGrape.withValues(alpha: 0.08),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
          BoxShadow(
            color: borderColor.withValues(alpha: 0.5),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Central GameTheme configuration
class GameTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: GameColors.canvasBase,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GameColors.electricPurple,
        primary: GameColors.electricPurple,
        secondary: GameColors.activeGold,
        surface: GameColors.canvasBase,
      ),
      textTheme: GoogleFonts.baloo2TextTheme(),
    );
  }
}
