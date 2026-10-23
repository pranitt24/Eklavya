import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../theme.dart';
import '../audio/sound_service.dart';

/// LandscapeSplitLayout: Reusable 58% / 42% split-screen scaffold for landscape gameplay.
/// - Left Stage (58%): Full-bleed 3D Pixar village background with rounded right edge.
/// - Right Board (42%): Floating warm cream storybook board with golden border & HUD.
class LandscapeSplitLayout extends StatelessWidget {
  /// Custom widget for the left village stage.
  final Widget? leftStage;

  /// Background asset for the left village stage (default to Screen 1 toy game).
  final String leftImageAsset;

  /// Content to be rendered inside the right storybook board.
  final Widget rightContent;

  /// Current level step (1-indexed)
  final int currentStep;

  /// Total steps in this level
  final int totalSteps;

  /// Optional level title (e.g. "लेव्हल ४: मोठे vs छोटे")
  final String? levelTitle;

  /// Callback when pause button is tapped
  final VoidCallback? onPause;

  const LandscapeSplitLayout({
    super.key,
    this.leftStage,
    this.leftImageAsset = 'assets/images/screens/screen_1_big_vs_small_toy_game.png',
    required this.rightContent,
    this.currentStep = 1,
    this.totalSteps = 3,
    this.levelTitle,
    this.onPause,
  });

  void _defaultPauseDialog(BuildContext context) {
    SoundService.instance.playPopClick();
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameColors.storybookCream,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: GameColors.sunflowerGold, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏸️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'खेळ थांबवला आहे!',
                style: GameTypography.marathiHeadingLarge(color: GameColors.clayBrown),
              ),
              Text(
                'Game Paused',
                style: GameTypography.buttonSublabel(color: GameColors.woodBarkBrown),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: GameColors.coralRed, width: 2.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        SoundService.instance.playPopClick();
                        Navigator.of(dialogCtx).pop();
                        // Revert orientation to portrait
                        await SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                        if (context.mounted) {
                          context.go('/saga-map');
                        }
                      },
                      child: Text(
                        'नकाशा (Exit)',
                        style: GameTypography.marathiBody(color: GameColors.coralRed).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameColors.meadowGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        SoundService.instance.playPopClick();
                        Navigator.of(dialogCtx).pop();
                      },
                      child: Text(
                        'पुढे चला (Resume)',
                        style: GameTypography.marathiBody(color: Colors.white).copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B), // Deep slate backing
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final leftWidth = totalWidth * 0.58;
            final rightWidth = totalWidth * 0.42;

            return Row(
              children: [
                // -------------------------------------------------------------
                // 1. LEFT STAGE (58% width): Pixar Village Scene
                // -------------------------------------------------------------
                SizedBox(
                  width: leftWidth,
                  height: constraints.maxHeight,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(32),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Village background artwork
                        Image.asset(
                          leftImageAsset,
                          fit: BoxFit.cover,
                          alignment: Alignment.centerLeft,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/screen_1_big_vs._small_toy_game/screen.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.centerLeft,
                            errorBuilder: (c, e, s) => Container(
                              color: const Color(0xFF5E8B3D),
                              child: const Center(
                                child: Text('🏡 Village Courtyard', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ),

                        // Soft right inner vignette shadow
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.25),
                                ],
                                stops: const [0.75, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Custom interactive left overlay if supplied
                        ?leftStage,
                      ],
                    ),
                  ),
                ),

                // -------------------------------------------------------------
                // 2. RIGHT BOARD (42% width): Storybook Cream Interactive Board
                // -------------------------------------------------------------
                SizedBox(
                  width: rightWidth,
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: GameColors.storybookCream, // #FFFDF5
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: GameColors.sunflowerGold,
                          width: 4.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3D000000),
                            blurRadius: 16,
                            offset: Offset(-4, 6),
                          ),
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Column(
                          children: [
                            // -------------------------------------------------
                            // Top Board Header: Progress Beads & Pause Button
                            // -------------------------------------------------
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: GameColors.sunflowerGold.withValues(alpha: 0.18),
                                border: Border(
                                  bottom: BorderSide(
                                    color: GameColors.sunflowerGold.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Star-Bead Progress Indicator
                                  Row(
                                    children: List.generate(totalSteps, (index) {
                                      final isFilled = index < currentStep;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 6.0),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isFilled
                                                ? GameColors.activeGold
                                                : Colors.black.withValues(alpha: 0.08),
                                            border: Border.all(
                                              color: isFilled
                                                  ? GameColors.activeGoldDark
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            boxShadow: isFilled
                                                ? [
                                                    BoxShadow(
                                                      color: GameColors.activeGold.withValues(alpha: 0.4),
                                                      blurRadius: 6,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              isFilled ? '⭐' : '⚪',
                                              style: TextStyle(fontSize: isFilled ? 13 : 10),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),

                                  // Level indicator pill
                                  if (levelTitle != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: GameColors.sunflowerGold, width: 1),
                                      ),
                                      child: Text(
                                        levelTitle!,
                                        style: GameTypography.buttonSublabel(color: GameColors.clayBrown).copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                  // Pause Button (Squishy 3D Pill)
                                  GestureDetector(
                                    onTap: onPause ?? () => _defaultPauseDialog(context),
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: GameColors.activeGold,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: GameColors.activeGoldDark,
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: GameColors.activeGoldDark,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.pause_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // -------------------------------------------------
                            // Dynamic Content Area
                            // -------------------------------------------------
                            Expanded(
                              child: rightContent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
