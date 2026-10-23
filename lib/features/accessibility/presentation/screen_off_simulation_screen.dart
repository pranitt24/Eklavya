import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/mascot_mood.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/widgets/nova/mascot_widget.dart';
import '../../../nova_main/theme/app_colors.dart';
import '../../../nova_main/theme/app_spacing.dart';
import '../../../nova_main/theme/app_text_styles.dart';
import '../widgets/accessibility_toggle.dart';

/// Immersive #07090F eyes-free audio lesson simulation with gesture navigation and escape.
class ScreenOffSimulationScreen extends StatefulWidget {
  const ScreenOffSimulationScreen({super.key});

  @override
  State<ScreenOffSimulationScreen> createState() => _ScreenOffSimulationScreenState();
}

class _ScreenOffSimulationScreenState extends State<ScreenOffSimulationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _currentStepIndex = 0;
  String _gestureFeedback = '';
  bool _feedbackSpoken = false;

  static const List<String> lessonSteps = [
    'We found 8 apples in the magical garden! Let\'s share them between 2 baskets fairly.',
    'Question: 8 apples are shared between 2 baskets. How many apples go in each basket?',
    'Option one: Two apples.',
    'Option two: Four apples.',
    'Option three: Six apples.',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onSwipeRight() {
    HapticsService.lightImpact();
    setState(() {
      _gestureFeedback = 'gesture recognised: Swipe Right (Next)';
      if (_currentStepIndex < lessonSteps.length - 1) {
        _currentStepIndex++;
      }
    });
  }

  void _onSwipeLeft() {
    HapticsService.lightImpact();
    setState(() {
      _gestureFeedback = 'gesture recognised: Swipe Left (Back)';
      if (_currentStepIndex > 0) {
        _currentStepIndex--;
      }
    });
  }

  void _onDoubleTap() {
    HapticsService.mediumImpact();
    setState(() {
      _gestureFeedback = 'gesture recognised: Double Tap (Select)';
      if (_currentStepIndex == 3) {
        // Option 2 (Four apples - correct)
        _feedbackSpoken = true;
      }
    });
  }

  void _onSimulateShake() {
    HapticsService.mediumImpact();
    setState(() {
      _gestureFeedback = 'gesture recognised: Shake (Repeat)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentText = _feedbackSpoken
        ? 'Yes! Four apples in each basket. Brilliant math thinking!'
        : lessonSteps[_currentStepIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 200) {
              _onSwipeRight();
            } else if (details.primaryVelocity! < -200) {
              _onSwipeLeft();
            }
          }
        },
        onDoubleTap: _onDoubleTap,
        child: SafeArea(
          child: Stack(
            children: [
              // Escape Exit Button Top Right
              Positioned(
                top: 10,
                right: 16,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppStrings.exitScreenOffBtn),
                ),
              ),

              // Center Eyes-Free Audio Visuals
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Concentric Audio Waves & Speaker
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final double waveScale = 1.0 + (_pulseController.value * 0.15);
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140 * waveScale,
                                height: 140 * waveScale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1E293B).withValues(alpha: 0.4),
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF0F172A),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.volume_up_rounded,
                                  color: AppColors.sunYellow,
                                  size: 52,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Minimal NOVA Mascot
                      const MascotWidget(
                        size: 72,
                        mood: NovaMood.speaking,
                        speaking: true,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Status Header
                      Text(
                        'NOVA is speaking…',
                        style: AppTextStyles.labelSoft.copyWith(
                          color: AppColors.sunYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // High Contrast Narration Text (for sighted reviewers)
                      Text(
                        currentText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Shake Simulation Button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.vibration_rounded, color: AppColors.sunYellow),
                        label: const Text(
                          'Simulate Shake (Repeat)',
                          style: TextStyle(color: AppColors.sunYellow, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.sunYellow),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: _onSimulateShake,
                      ),
                    ],
                  ),
                ),
              ),

              // Persistent Gesture Legend & Recognised Toast at Bottom
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_gestureFeedback.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _gestureFeedback,
                          style: const TextStyle(color: AppColors.sunYellow, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const GestureLegend(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
