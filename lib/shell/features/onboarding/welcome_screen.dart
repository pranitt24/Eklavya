import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/nova_tts_service.dart';
import '../../core/audio/sound_service.dart';
import '../../core/widgets/squishy_button.dart';
import '../../theme.dart';

/// WelcomeScreen: Storybook introduction screen with full-bleed village backdrop,
/// festive carved ribbon banner, NOVA & Chintu mascots, and squishy 3D CTA.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _showToast = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await NovaTtsService.instance.init(context);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        NovaTtsService.instance.speak('नमस्ते मित्रा! चल खेळूया!');
      }
    });
  }

  @override
  void dispose() {
    NovaTtsService.instance.stop();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerAudioToast() {
    SoundService.instance.playDingChime();
    NovaTtsService.instance.speak('नमस्ते मित्रा! चल खेळूया!');
    setState(() => _showToast = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/screens/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Safe Area Content
            SafeArea(
              child: Column(
                children: [
                  // Top HUD Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Audio Listen Chip Button
                      GestureDetector(
                        onTap: _triggerAudioToast,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: GameColors.activeGold,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: GameColors.activeGoldDark.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.volume_up_rounded,
                                  size: 18,
                                  color: GameColors.activeGoldDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ऐका • LISTEN',
                                style: GameTypography.buttonSublabel(
                                  color: GameColors.inkGrape,
                                ).copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Star Badge
                      const HudPillChip(
                        icon: Text('⭐', style: TextStyle(fontSize: 18)),
                        label: '५०',
                        sublabel: 'STARS',
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Carved 3D Wooden Ribbon Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFDE68A),
                                Color(0xFFFBBF24),
                                Color(0xFFFDE68A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: GameColors.activeGoldDark,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GameColors.activeGoldDark.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'माझे गाव',
                                style: GameTypography.displayHero(
                                  color: GameColors.inkGrape,
                                ).copyWith(fontSize: 34, height: 1.1),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'MAJHE GAON • MY VILLAGE',
                                  style: GameTypography.buttonSublabel(
                                    color: GameColors.electricPurple,
                                  ).copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Centerpiece Mascot Card
                        GameCard(
                          backgroundColor: Colors.white.withValues(alpha: 0.95),
                          borderColor: GameColors.cardBorderLavender,
                          elevation: 6,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Mascot Speech Bubble
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: GameColors.purpleContainer,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: GameColors.electricPurple.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('👋 ', style: TextStyle(fontSize: 18)),
                                      Text(
                                        'नमस्ते मित्रा! चल खेळूया!',
                                        style: GameTypography.headline(
                                          color: GameColors.electricPurple,
                                        ).copyWith(fontSize: 17),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Character Illustration Box: Circular Toy Badges for Chintu & NOVA
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFE0F2FE),
                                      Color(0xFFFFFDF5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: GameColors.activeGoldDark,
                                    width: 3.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        // 1. Chintu Circular Toy Badge
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 110,
                                                height: 110,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: GameColors.activeGoldDark,
                                                    width: 4.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: GameColors.activeGoldDark.withValues(alpha: 0.35),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipOval(
                                                  child: Image.asset(
                                                    'assets/images/characters/chintu.png',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (c1, e1, s1) => Image.asset(
                                                      'assets/full_body_3d_pixar_animation_style_cute_6_year_old_indian_village_boy_character/screen.png',
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (c, e, s) => const Icon(
                                                        Icons.face,
                                                        size: 60,
                                                        color: GameColors.activeGoldDark,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              _buildMascotTag(
                                                color: GameColors.activeGoldDark,
                                                name: 'चिंटू (CHINTU)',
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // 2. NOVA Circular Toy Badge
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 110,
                                                height: 110,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: GameColors.robotBlue,
                                                    width: 4.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: GameColors.robotBlue.withValues(alpha: 0.35),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipOval(
                                                  child: Image.asset(
                                                    'assets/nova/characters/char_nova_standing.webp',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (c2, e2, s2) => Image.asset(
                                                      'assets/full_body_3d_pixar_style_cute_friendly_chubby_blue_robot_character_named_nova/screen.png',
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (c, e, s) => const Icon(
                                                        Icons.android,
                                                        size: 60,
                                                        color: GameColors.robotBlue,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              _buildMascotTag(
                                                color: GameColors.robotBlue,
                                                name: 'नोव्हा (NOVA)',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Speaker Audio Button
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: SpeakerButton(
                                        size: 40,
                                        onPlay: () {
                                          SoundService.instance.playDingChime();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Interactive CTA Zone
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // Giant 64px Emerald Squishy 3D Play Button
                      Squishy3DButton(
                        height: 66,
                        backgroundColor: GameColors.emeraldGrass,
                        bevelColor: GameColors.emeraldGrassDark,
                        icon: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: GameColors.emeraldGrassDark,
                            size: 26,
                          ),
                        ),
                        label: 'सुरू करा! ▶',
                        sublabel: 'GET STARTED • LET\'S PLAY!',
                        onPressed: () {
                          context.go('/profile-picker');
                        },
                      ),
                      const SizedBox(height: 8),

                      // Kid-Safe Trust Banner
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: GameColors.emeraldGrassDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '१००% मोफत आणि सुरक्षित बाल-मित्र खेळ • Kid-Safe',
                            style: GameTypography.buttonSublabel(
                              color: GameColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Audio Toast Overlay
          if (_showToast)
            Positioned(
              top: 50,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: GameColors.inkGrape,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.record_voice_over_rounded,
                        color: GameColors.activeGoldLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'माझे गाव (Mājhē Gāv) — स्वागत आहे!',
                        style: GameTypography.buttonLabel(color: Colors.white)
                            .copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotTag({required Color color, required String name}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: GameTypography.buttonSublabel(color: GameColors.inkGrape)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
