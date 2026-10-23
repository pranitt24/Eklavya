import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shell/core/audio/sound_service.dart';
import 'shell/routes.dart';
import 'shell/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SoundService.instance.init();
  runApp(const ShellApp());
}

class ShellApp extends StatelessWidget {
  const ShellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'माझे गाव (Majhe Gaon)',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.themeData,
      routerConfig: appRouter,
    );
  }
}
