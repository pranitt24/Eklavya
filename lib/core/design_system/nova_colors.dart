import 'package:flutter/material.dart';

/// Core color palette for the NOVA ("माझे गाव") rural EdTech design system.
/// Extracted directly from visual specifications in `assets/Design System/`.
class NovaColors {
  NovaColors._();

  // Core brand tokens
  static const Color cream = Color(0xFFFFFDF5); // Warm rural off-white / parchment background
  static const Color creamAlt = Color(0xFFFEFBF3);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F4);
  static const Color softGrey = Color(0xFFEAEFF8);
  static const Color disabledGrey = Color(0xFFB0B7C3);

  // Primary Purples & Deep Blues
  static const Color purple = Color(0xFF6C47FF); // Primary button, active border, branding
  static const Color purpleDark = Color(0xFF5432DE); // 3D button bevel shadow
  static const Color purpleLight = Color(0xFFF3E8FF); // Banner and speaker background
  static const Color purpleBorder = Color(0xFFDDD6FE); // Soft border for cards and containers
  static const Color navy = Color(0xFF1F2A6B); // Deep navy token for contrast
  static const Color indigo = Color(0xFF3F4BB8);

  // Golds / Sunshine
  static const Color gold = Color(0xFFFBBF24); // Stars, selection pills, level 1 node
  static const Color goldDark = Color(0xFFD97706); // Gold 3D button bevel & curve lines
  static const Color goldLight = Color(0xFFFEF3C7); // Gold card tint, replay button
  static const Color sunYellow = Color(0xFFFFD66B); // Sunshine yellow for mascot & highlights

  // Mint / Semantic Greens
  static const Color mint = Color(0xFFDCFCE7); // Success container & completion background
  static const Color green = Color(0xFF16A34A); // Success checkmarks, correct feedback
  static const Color greenDark = Color(0xFF15803D); // Green 3D button bevel
  static const Color greenBorder = Color(0xFF22C55E); // Green completed card border

  // Peach & Coral (Gentle Retry, Mic)
  static const Color peach = Color(0xFFFFE4D6); // Listening container background
  static const Color peachLight = Color(0xFFFFF7ED);
  static const Color coral = Color(0xFFF87171); // Mic pulsing button, retry outline
  static const Color coralDark = Color(0xFFDC2626); // Coral 3D bevel
  static const Color coralLight = Color(0xFFFFF1F2); // Gentle retry card background

  // Sky Blue (Standard 2 / Story Adventure)
  static const Color sky = Color(0xFF38BDF8);
  static const Color skyDark = Color(0xFF0284C7);
  static const Color skyLight = Color(0xFFE0F2FE);

  // Typography & Text Ink
  static const Color ink = Color(0xFF271C44); // Primary deep purple-black readable text
  static const Color inkSoft = Color(0xFF685F85); // Secondary bilingual translations, subtitles
  static const Color inkMuted = Color(0xFF9CA3AF); // Inactive/disabled icons & borders

  // Interactive Gradients
  static const LinearGradient storyAdventureGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ganitDangalGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGlowGradient = LinearGradient(
    colors: [Color(0xFF7E57FF), Color(0xFF6C47FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // High contrast theme tokens (WCAG AAA)
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcCard = Color(0xFF121212);
  static const Color hcText = Color(0xFFFFFFFF);
  static const Color hcTextSecondary = Color(0xFFFFFFB0);
  static const Color hcYellow = Color(0xFFFFEB3B);
  static const Color hcMint = Color(0xFF00FF88);
  static const Color hcCoral = Color(0xFFFF7B7B);
  static const Color hcSky = Color(0xFF64D2FF);
  static const Color hcBorder = Color(0xFFFFFFFF);
}
