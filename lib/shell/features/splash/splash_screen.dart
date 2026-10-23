import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/audio/sound_service.dart';
import '../../theme.dart';

/// SplashScreen: A Netflix-style cinematic intro with scaling 3D toy logo,
/// dark indigo-black background, and synchronized whoosh sound.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _glowAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Trigger WhooshBoom audio immediately
    SoundService.instance.playIntroWhoosh();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_animController);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();

    // Auto-navigate to WelcomeScreen after 3.2 seconds
    _navTimer = Timer(const Duration(milliseconds: 3200), () {
      _navigateToWelcome();
    });
  }

  void _navigateToWelcome() {
    if (!mounted) return;
    try {
      context.go('/welcome');
    } catch (_) {}
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B18), // Deep indigo-black
      body: GestureDetector(
        onTap: _navigateToWelcome, // Allow skip on tap
        child: Stack(
          children: [
            // Ambient Radial Glow behind the Logo
            Center(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          GameColors.electricPurple.withValues(
                            alpha: 0.35 * _glowAnimation.value,
                          ),
                          GameColors.activeGold.withValues(
                            alpha: 0.15 * _glowAnimation.value,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Animated 3D Logo & Title
            Center(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 3D Toy Logo Styled Game Card
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 220,
                              maxHeight: 220,
                            ),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: Colors.amberAccent,
                                width: 6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: GameColors.electricPurple.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.asset(
                                'assets/images/logo/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    Image.asset(
                                  'assets/majhe_gaon_kid_friendly_3d_toy_logo/screen.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(
                                    Icons.toys_rounded,
                                    size: 140,
                                    color: GameColors.activeGold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Devanagari Brand Title
                          Text(
                            'माझे गाव',
                            style: GameTypography.displayHero(
                              color: Colors.white,
                            ).copyWith(
                              fontSize: 38,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: GameColors.electricPurple.withValues(alpha: 0.8),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Subtitle Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: GameColors.activeGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: GameColors.activeGold.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              'MAJHE GAON • खेळातून शिकूया!',
                              style: GameTypography.buttonSublabel(
                                color: GameColors.activeGoldLight,
                              ).copyWith(
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Tap hint at the bottom
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'स्पर्श करा • Tap to continue',
                  style: GameTypography.buttonSublabel(
                    color: Colors.white.withValues(alpha: 0.4),
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
