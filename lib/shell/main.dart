import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/audio/sound_service.dart';
import 'routes.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SoundService.instance.init();
  runApp(const MajheGaonApp());
}

class MajheGaonApp extends StatelessWidget {
  const MajheGaonApp({super.key});

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
