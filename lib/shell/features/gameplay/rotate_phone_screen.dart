import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/audio/sound_service.dart';
import '../../core/widgets/squishy_button.dart';
import '../../theme.dart';

/// RotatePhoneScreen: Orientation gate with magical twilight night sky,
/// glowing tablet rotation illustration, and ready confirmation button.
class RotatePhoneScreen extends StatefulWidget {
  const RotatePhoneScreen({super.key});

  @override
  State<RotatePhoneScreen> createState() => _RotatePhoneScreenState();
}

class _RotatePhoneScreenState extends State<RotatePhoneScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  Future<void> _handleReady() async {
    SoundService.instance.playPopClick();
    // Lock orientation to landscape mode
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (mounted) {
      context.go('/gameplay', extra: GoRouterState.of(context).extra);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep twilight navy
      body: Stack(
        children: [
          // 1. Full-Bleed Magical Twilight Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.4),
                  radius: 1.2,
                  colors: [
                    Color(0xFF4338CA), // Royal Indigo Glow
                    Color(0xFF1E1B4B), // Deep Midnight Purple
                    Color(0xFF0F172A), // Dark Slate Twilight
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Floating Ambient Twinkling Stars
          const Positioned(top: 40, left: 30, child: Text('⭐', style: TextStyle(fontSize: 22))),
          const Positioned(top: 120, right: 40, child: Text('✨', style: TextStyle(fontSize: 20))),
          const Positioned(bottom: 180, left: 40, child: Text('🌟', style: TextStyle(fontSize: 24))),
          const Positioned(bottom: 140, right: 35, child: Text('⭐', style: TextStyle(fontSize: 20))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top HUD Pill: Cinema Mode & Speaker Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('🎬', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'सिनेमा मोड • Cinema Mode',
                              style: GameTypography.buttonSublabel(
                                color: Colors.white,
                              ).copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      SpeakerButton(
                        size: 44,
                        color: GameColors.activeGold,
                        onPlay: () {
                          SoundService.instance.playDingChime();
                        },
                      ),
                    ],
                  ),

                  // Center Illustration Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tablet Rotation Scene Container
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ambient Radial Glow
                            Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: GameColors.electricPurple.withValues(alpha: 0.25),
                              ),
                            ),

                            // Main 3D Artwork (NOVA holding tablet)
                            Container(
                              width: 230,
                              height: 230,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.asset(
                                  'assets/images/screens/screen_5_turn_your_phone_cartoon_full_height_fixed.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Image.asset(
                                    'assets/screen_5_turn_your_phone_cartoon_full_height_fixed/screen.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (c1, e1, s1) => Container(
                                      color: GameColors.electricPurple,
                                      child: const Center(
                                        child: Icon(
                                          Icons.screen_rotation_rounded,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Orbiting Dashed Ring with 90° Badge
                            RotationTransition(
                              turns: _orbitController,
                              child: Container(
                                width: 270,
                                height: 270,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: GameColors.activeGold.withValues(alpha: 0.6),
                                    width: 3,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                            ),

                            // Top 90 Deg Badge
                            Positioned(
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: GameColors.activeGold,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.screen_rotation_rounded, size: 16, color: GameColors.inkGrape),
                                    const SizedBox(width: 4),
                                    Text(
                                      '९०° Rotate!',
                                      style: GameTypography.buttonSublabel(
                                        color: GameColors.inkGrape,
                                      ).copyWith(fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Bubbly Big Devanagari Title
                      Text(
                        'फोन आडवा करा! ✨',
                        style: GameTypography.displayHero(
                          color: Colors.white,
                        ).copyWith(
                          fontSize: 32,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: GameColors.activeGold.withValues(alpha: 0.8),
                              blurRadius: 16,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Subtitle Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '(Turn your phone sideways for big screen!)',
                          style: GameTypography.bodyLarge(
                            color: Colors.white.withValues(alpha: 0.9),
                          ).copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  // Bottom Giant 3D Green Ready Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Squishy3DButton(
                        height: 66,
                        backgroundColor: GameColors.emeraldGrass,
                        bevelColor: GameColors.emeraldGrassDark,
                        icon: const Icon(
                          Icons.thumb_up_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        label: 'तयार आहे! 👍 (READY!)',
                        sublabel: '(OK! I TURNED IT)',
                        onPressed: _handleReady,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'गोष्टीची मोठी स्क्रीन सुरू होत आहे! 🎬 • Story starts in wide-screen',
                        style: GameTypography.buttonSublabel(
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
