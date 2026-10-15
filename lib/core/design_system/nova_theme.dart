import 'package:flutter/material.dart';
import 'nova_colors.dart';
import 'nova_typography.dart';
import 'nova_spacing.dart';

/// Central theme configuration for NOVA ("माझे गाव").
class NovaTheme {
  NovaTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: NovaColors.cream,
      primaryColor: NovaColors.purple,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: NovaColors.purple,
        onPrimary: Colors.white,
        secondary: NovaColors.gold,
        onSecondary: NovaColors.ink,
        error: NovaColors.coral,
        onError: Colors.white,
        surface: NovaColors.cardWhite,
        onSurface: NovaColors.ink,
      ),
      fontFamily: NovaTypography.fontBaloo2,
      fontFamilyFallback: NovaTypography.marathiFallback,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: NovaColors.ink),
        titleTextStyle: NovaTypography.headingLarge,
      ),
      cardTheme: CardThemeData(
        color: NovaColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: NovaSpacing.roundedCard,
          side: const BorderSide(color: NovaColors.purpleBorder, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(NovaSpacing.minTouchTarget, NovaSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: NovaSpacing.roundedPill,
          ),
          backgroundColor: NovaColors.purple,
          foregroundColor: Colors.white,
          textStyle: NovaTypography.buttonPrimary,
          elevation: 0,
        ),
      ),
    );
  }
}
