import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/onboarding/profile_picker_screen.dart';
import 'features/placement/diagnostic_test_screen.dart';
import 'features/saga_map/saga_map_screen.dart';
import 'features/gameplay/rotate_phone_screen.dart';
import 'features/gameplay/level_player_screen.dart';
import 'features/gameplay/celebration_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/profile-picker',
      name: 'profile-picker',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfilePickerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    ),
    GoRoute(
      path: '/diagnostic-test',
      name: 'diagnostic-test',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const DiagnosticTestScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    ),
    GoRoute(
      path: '/saga-map',
      name: 'saga-map',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SagaMapScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/rotate-phone',
      name: 'rotate-phone',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RotatePhoneScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/gameplay',
      name: 'gameplay',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LevelPlayerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/celebration',
      name: 'celebration',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: CelebrationScreen(
            completedLevelNumber: extra?['completedLevelNumber'] ?? 1,
            earnedStars: extra?['earnedStars'] ?? 3,
            coinsAwarded: extra?['coinsAwarded'] ?? 50,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
  ],
);
