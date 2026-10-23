import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/haptics_service.dart';
import '../../demo/demo_fab.dart';
import '../../../nova_main/services/app_state.dart';
import '../../../nova_main/theme/app_colors.dart';
import '../../../nova_main/theme/app_spacing.dart';
import '../../../nova_main/theme/app_text_styles.dart';
import '../../../nova_main/widgets/primary_button.dart';
import '../widgets/accessibility_toggle.dart';
import 'screen_off_simulation_screen.dart';

/// Full-featured Accessibility Settings with live app-wide theme and text scale switching.
class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final settings = appState.accessibility;

    return Scaffold(
      backgroundColor: settings.highContrast ? AppColors.hcBackground : AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          AppStrings.accessibilityTitle,
          style: AppTextStyles.questionText.copyWith(
            color: settings.highContrast ? AppColors.hcText : AppColors.navy,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: settings.highContrast ? AppColors.hcText : AppColors.navy,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Voice Instructions
                      AccessibilityToggle(
                        icon: Icons.record_voice_over_rounded,
                        title: AppStrings.voiceInstructionsTitle,
                        subtitle: AppStrings.voiceInstructionsSubtitle,
                        value: settings.voiceInstructions,
                        previewText: 'NOVA will read aloud instructions and options.',
                        onChanged: (val) {
                          appState.updateAccessibility(settings.copyWith(voiceInstructions: val));
                        },
                      ),

                      // Haptic Feedback
                      AccessibilityToggle(
                        icon: Icons.vibration_rounded,
                        title: AppStrings.hapticFeedbackTitle,
                        subtitle: AppStrings.hapticFeedbackSubtitle,
                        value: settings.hapticFeedback,
                        previewText: 'Vibrates lightly when you tap buttons and select answers.',
                        onChanged: (val) {
                          appState.updateAccessibility(settings.copyWith(hapticFeedback: val));
                        },
                      ),
                      if (settings.hapticFeedback)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              icon: const Icon(Icons.touch_app_rounded, size: 18),
                              label: const Text(AppStrings.testHaptics),
                              onPressed: () => HapticsService.mediumImpact(),
                            ),
                          ),
                        ),

                      // Gesture Navigation
                      AccessibilityToggle(
                        icon: Icons.swipe_rounded,
                        title: AppStrings.gestureNavTitle,
                        subtitle: AppStrings.gestureNavSubtitle,
                        value: settings.gestureNavigation,
                        previewText: 'Swipe right for next, swipe left for previous, double tap to select.',
                        onChanged: (val) {
                          appState.updateAccessibility(settings.copyWith(gestureNavigation: val));
                        },
                      ),

                      // Large Text
                      AccessibilityToggle(
                        icon: Icons.text_fields_rounded,
                        title: AppStrings.largeTextTitle,
                        subtitle: AppStrings.largeTextSubtitle,
                        value: settings.largeText,
                        previewText: 'This sample text reflects enlarged font scaling.',
                        onChanged: (val) {
                          appState.updateAccessibility(settings.copyWith(largeText: val));
                        },
                      ),

                      // High Contrast
                      AccessibilityToggle(
                        icon: Icons.contrast_rounded,
                        title: AppStrings.highContrastTitle,
                        subtitle: AppStrings.highContrastSubtitle,
                        value: settings.highContrast,
                        previewText: 'Deep black background with crisp golden and white accents.',
                        onChanged: (val) {
                          appState.updateAccessibility(settings.copyWith(highContrast: val));
                        },
                      ),

                      // Reduce Motion
                      AccessibilityToggle(
                        icon: Icons.motion_photos_off_rounded,
                        title: AppStrings.reduceMotionTitle,
                        subtitle: AppStrings.reduceMotionSubtitle,
                        value: settings.reduceMotion,
                        previewText: 'Soft fades instead of bouncing animations.',
                        onChanged: (val) {
                          appState.updateAccessibility(settings.copyWith(reduceMotion: val));
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Screen-Off Mode Section
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: settings.highContrast ? AppColors.hcCard : Colors.white,
                          borderRadius: AppSpacing.roundedCard,
                          border: Border.all(
                            color: settings.highContrast ? AppColors.hcBorder : AppColors.borderLight,
                            width: 2.0,
                          ),
                          boxShadow: AppSpacing.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.hearing_rounded, color: AppColors.indigo, size: 28),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    AppStrings.screenOffModeTitle,
                                    style: AppTextStyles.questionText.copyWith(
                                      color: settings.highContrast ? AppColors.hcText : AppColors.navy,
                                      fontSize: 19,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.screenOffModeSubtitle,
                              style: AppTextStyles.bodySoft.copyWith(
                                color: settings.highContrast ? AppColors.hcTextSecondary : AppColors.inkSoft,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            PrimaryButton(
                              label: AppStrings.tryScreenOffBtn,
                              icon: Icons.headset_rounded,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ScreenOffSimulationScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const DemoFab(),
        ],
      ),
    );
  }
}
