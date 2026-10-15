import 'package:flutter/material.dart';

class AppTheme {
  static const Color primarySaffron = Color(0xFFE67E22);
  static const Color earthyBrown = Color(0xFF8D6E63);
  static const Color leafGreen = Color(0xFF27AE60);
  static const Color backgroundOffWhite = Color(0xFFFDFEFE);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundOffWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySaffron,
        primary: primarySaffron,
        secondary: leafGreen,
        tertiary: earthyBrown,
        surface: backgroundOffWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          elevation: 2,
        ),
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        color: Colors.white,
      ),
    );
  }
}
