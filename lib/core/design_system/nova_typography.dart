import 'package:flutter/material.dart';
import 'nova_colors.dart';

/// Rural EdTech vernacular bilingual typography scale.
/// Uses Baloo 2 for Marathi Devanagari headings & learning copy,
/// and Nunito for English labels, navigation, and bilingual subtitles.
/// Works 100% offline with system Devanagari fallback fonts.
class NovaTypography {
  NovaTypography._();

  static const String fontBaloo2 = 'Baloo 2';
  static const String fontNunito = 'Nunito';

  static const List<String> marathiFallback = [
    'Baloo 2',
    'Mukta',
    'Noto Sans Devanagari',
    'Hind',
    'Roboto',
    'sans-serif',
  ];

  static const List<String> englishFallback = [
    'Nunito',
    'Roboto',
    'sans-serif',
  ];

  // Headings (Marathi-first) - generous height prevents clipping Devanagari matras
  static const TextStyle display = TextStyle(
    fontFamily: fontBaloo2,
    fontFamilyFallback: marathiFallback,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: NovaColors.ink,
    height: 1.35,
  );

  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontBaloo2,
    fontFamilyFallback: marathiFallback,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: NovaColors.ink,
    height: 1.35,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontBaloo2,
    fontFamilyFallback: marathiFallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: NovaColors.ink,
    height: 1.35,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontBaloo2,
    fontFamilyFallback: marathiFallback,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: NovaColors.ink,
    height: 1.4,
  );

  // Body & Learning Copy
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBaloo2,
    fontFamilyFallback: marathiFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: NovaColors.ink,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBaloo2,
    fontFamilyFallback: marathiFallback,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: NovaColors.ink,
    height: 1.45,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: fontNunito,
    fontFamilyFallback: englishFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: NovaColors.inkSoft,
    height: 1.35,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontNunito,
    fontFamilyFallback: englishFallback,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: NovaColors.inkSoft,
    height: 1.25,
  );

  // Buttons & Badges
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: fontBaloo2,
    fontFamilyFallback: marathiFallback,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.2,
    height: 1.25,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: fontBaloo2,
    fontFamilyFallback: marathiFallback,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: NovaColors.ink,
    height: 1.25,
  );

  static const TextStyle chipText = TextStyle(
    fontFamily: fontBaloo2,
    fontFamilyFallback: marathiFallback,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: NovaColors.ink,
    height: 1.3,
  );

  static const TextStyle chipSubtitle = TextStyle(
    fontFamily: fontNunito,
    fontFamilyFallback: englishFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: NovaColors.inkSoft,
    height: 1.25,
  );
}
