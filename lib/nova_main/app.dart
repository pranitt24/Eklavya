import 'dart:math';
import 'package:flutter/material.dart';
import 'constants/app_strings.dart';
import 'routes/app_routes.dart';
import 'routes/route_transitions.dart';
import 'screens/accessibility/accessibility_settings_screen.dart';
import 'screens/accessibility/screen_off_simulation_screen.dart';
import 'screens/assessment/assessment_intro_screen.dart';
import 'screens/assessment/assessment_question_screen.dart';
import 'screens/assessment/assessment_result_screen.dart';
import 'screens/assessment/level_recommendation_screen.dart';
import 'screens/levels/level_complete_screen.dart';
import 'screens/levels/level_detail_screen.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/student_setup_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import '../core/design_system/nova_theme.dart';
import '../features/screens/class_selection_screen.dart';
import '../features/screens/home_hub_screen.dart';
import '../features/screens/level_road_screen.dart';
import '../features/screens/profile_screen.dart';
import '../features/screens/story_adventure_screen.dart';

/// Root application widget configuring themes, routes, and accessibility text scaling.
class NovaApp extends StatelessWidget {
  const NovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final accessibility = appState.accessibility;

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: accessibility.highContrast ? AppTheme.highContrastTheme : NovaTheme.lightTheme,
      builder: (context, child) {
        // Accessibility Text Scaling: multiply by 1.3 if largeText is ON, clamp at 2.0 total
        final currentScaler = MediaQuery.textScalerOf(context);
        final double baseScale = currentScaler.scale(10.0) / 10.0;
        final double effectiveScale = accessibility.largeText
            ? min(2.0, baseScale * 1.3)
            : min(2.0, baseScale);

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(effectiveScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        final bool reduceMotion = accessibility.reduceMotion;

        switch (settings.name) {
          case AppRoutes.splash:
            return MaterialPageRoute(builder: (_) => const SplashScreen());

          case AppRoutes.welcome:
            return RouteTransitions.horizontalSlide(const WelcomeScreen(), reduceMotion: reduceMotion);

          case AppRoutes.studentSetup:
            return RouteTransitions.horizontalSlide(const StudentSetupScreen(), reduceMotion: reduceMotion);

          case AppRoutes.assessmentIntro:
            return RouteTransitions.horizontalSlide(const AssessmentIntroScreen(), reduceMotion: reduceMotion);

          case AppRoutes.assessmentQuestion:
            return RouteTransitions.slideUp(const AssessmentQuestionScreen(), reduceMotion: reduceMotion);

          case AppRoutes.assessmentResult:
            return RouteTransitions.scaleFade(const AssessmentResultScreen(), reduceMotion: reduceMotion);

          case AppRoutes.levelRecommendation:
            return RouteTransitions.scaleFade(const LevelRecommendationScreen(), reduceMotion: reduceMotion);

          case AppRoutes.home:
            return RouteTransitions.horizontalSlide(const HomeHubScreen(), reduceMotion: reduceMotion);

          case AppRoutes.levelDetail:
            return RouteTransitions.slideUp(const LevelDetailScreen(), reduceMotion: reduceMotion);

          case AppRoutes.story:
            return RouteTransitions.slideUp(const StoryAdventureScreen(), reduceMotion: reduceMotion);

          case AppRoutes.levelComplete:
            return RouteTransitions.scaleFade(const LevelCompleteScreen(), reduceMotion: reduceMotion);

          case AppRoutes.accessibilitySettings:
            return RouteTransitions.slideUp(const AccessibilitySettingsScreen(), reduceMotion: reduceMotion);

          case AppRoutes.screenOffSimulation:
            return RouteTransitions.slideUp(const ScreenOffSimulationScreen(), reduceMotion: reduceMotion);

          case AppRoutes.classSelection:
            return RouteTransitions.horizontalSlide(const ClassSelectionScreen(), reduceMotion: reduceMotion);

          case AppRoutes.levelRoad:
            return RouteTransitions.horizontalSlide(const LevelRoadScreen(), reduceMotion: reduceMotion);

          case AppRoutes.profile:
            return RouteTransitions.horizontalSlide(const ProfileScreen(), reduceMotion: reduceMotion);

          default:
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
        }
      },
    );
  }
}
