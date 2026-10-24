import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/audio/sound_service.dart';
import '../../core/models/level_progress.dart';
import '../../core/widgets/celebration_overlay.dart';
import '../../core/widgets/squishy_button.dart';
import '../../theme.dart';

/// CelebrationScreen: Full-screen blurred modal rewarding level completion with:
/// - 3D popping treasure chest / trophy celebration illustration
/// - 3 bouncing golden stars (⭐⭐⭐)
/// - +50 Points coin badge
/// - Congratulations & praise in Marathi + English
/// - Reversion of device orientation back to portrait upon clicking NEXT LEVEL!
class CelebrationScreen extends StatefulWidget {
  final int completedLevelNumber;
  final int earnedStars;
  final int coinsAwarded;
  final bool autoLaunchConfetti;

  const CelebrationScreen({
    super.key,
    this.completedLevelNumber = 4,
    this.earnedStars = 3,
    this.coinsAwarded = 50,
    this.autoLaunchConfetti = true,
  });

  /// Static helper to display the celebration modal over any landscape screen
  static Future<void> show(
    BuildContext context, {
    int completedLevelNumber = 4,
    int earnedStars = 3,
    int coinsAwarded = 50,
    bool autoLaunchConfetti = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => CelebrationScreen(
        completedLevelNumber: completedLevelNumber,
        earnedStars: earnedStars,
        coinsAwarded: coinsAwarded,
        autoLaunchConfetti: autoLaunchConfetti,
      ),
    );
  }

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> {
  @override
  void initState() {
    super.initState();
    // Play celebratory ding chime audio
    SoundService.instance.playDingChime();

    // Update GameState immediately to record 3 stars & +50 coins
    GameState.instance.completeLevel(
      widget.completedLevelNumber,
      widget.earnedStars,
      widget.coinsAwarded,
    );

    // Launch celebration pop-up (balloons + confetti + cheer)
    if (widget.autoLaunchConfetti) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          CelebrationOverlay.show(context, type: CelebrationType.levelComplete);
        }
      });
    }
  }

  Future<void> _handleNextLevel() async {
    SoundService.instance.playPopClick();

    // Revert orientation back to portrait for the Saga Map
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (mounted) {
      // If shown inside a dialog, dismiss dialog first
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      context.go('/saga-map');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: const Color(0x660F172A), // Soft dark overlay
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 580),
                decoration: BoxDecoration(
                  color: GameColors.storybookCream, // #FFFDF5
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: GameColors.sunflowerGold,
                    width: 5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ---------------------------------------------------------
                    // 1. Centerpiece: Popping 3D Celebration Chest Artwork
                    // ---------------------------------------------------------
                    SizedBox(
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Sunburst radial glow
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  GameColors.activeGold.withValues(alpha: 0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1.15, 1.15),
                                duration: 800.ms,
                                curve: Curves.easeOutBack,
                              ),

                          // Celebration Party / Trophy Chest Image
                          Image.asset(
                            'assets/images/screens/screen_5_trophy_celebration_party.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/screen_5_trophy_celebration_party/screen.png',
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Text(
                                '🏆🎁✨',
                                style: TextStyle(fontSize: 64),
                              ),
                            ),
                          ).animate().scale(
                                begin: const Offset(0.5, 0.5),
                                end: const Offset(1.0, 1.0),
                                duration: 600.ms,
                                curve: Curves.elasticOut,
                              ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ---------------------------------------------------------
                    // 2. Congratulations Marathi Heading & Compliment
                    // ---------------------------------------------------------
                    Text(
                      'अभिनंदन! 🎉',
                      style: GameTypography.displayHero(color: GameColors.clayBrown).copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: GameColors.sunflowerGold.withValues(alpha: 0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 4),

                    Text(
                      'तू खूप हुशार आहेस! 🌟\n(You are very smart!)',
                      style: GameTypography.marathiHeadingMedium(color: GameColors.meadowGreenDark).copyWith(
                        fontSize: 16,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 14),

                    // ---------------------------------------------------------
                    // 3. Reward Display: 3 Giant Bouncing Golden Stars & Coin Badge
                    // ---------------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Star 1
                        _buildStar(index: 0, delayMs: 200),
                        const SizedBox(width: 8),
                        // Star 2 (Middle, slightly raised & larger)
                        _buildStar(index: 1, delayMs: 400, isCenter: true),
                        const SizedBox(width: 8),
                        // Star 3
                        _buildStar(index: 2, delayMs: 600),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // +50 Points Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: GameColors.activeGoldLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GameColors.activeGold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: GameColors.activeGold.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            '+50 Points (नाणी)',
                            style: GameTypography.buttonLabel(color: GameColors.clayBrown).copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------
                    // 4. Return Navigation: Giant Green NEXT LEVEL Button
                    // ---------------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      child: Squishy3DButton(
                        label: 'पुढील लेव्हल 🚀 (NEXT LEVEL)',
                        backgroundColor: GameColors.meadowGreen,
                        bevelColor: GameColors.meadowGreenDark,
                        height: 60,
                        onPressed: _handleNextLevel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStar({required int index, required int delayMs, bool isCenter = false}) {
    final double size = isCenter ? 44 : 36;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: GameColors.sunflowerGold,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: GameColors.activeGold.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '⭐',
          style: TextStyle(fontSize: isCenter ? 22 : 18),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          delay: Duration(milliseconds: delayMs),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }
}
