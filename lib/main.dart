import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design_system/nova_theme.dart';
import 'core/routing/boot_logic.dart';
import 'features/screens/home_hub_screen.dart';
import 'features/screens/profile_screen.dart';
import 'nova_main/services/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  runApp(
    ProviderScope(
      child: AppStateScope(
        appState: appState,
        child: const MajheGaonApp(),
      ),
    ),
  );
}

class MajheGaonApp extends StatelessWidget {
  const MajheGaonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Majhe Gaon',
      debugShowCheckedModeBanner: false,
      theme: NovaTheme.lightTheme,
      home: const BootRouter(),
    );
  }
}

class BootRouter extends ConsumerWidget {
  const BootRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootState = ref.watch(bootLogicProvider);

    return bootState.when(
      data: (hasProfiles) {
        if (hasProfiles) {
          return const HomeHubScreen();
        } else {
          return const ProfileScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Error loading database: $err'),
        ),
      ),
    );
  }
}
