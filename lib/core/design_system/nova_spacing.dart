import 'package:flutter/material.dart';

/// Spacing, dimensions, elevation, and border radii for the NOVA design system.
class NovaSpacing {
  NovaSpacing._();

  // Spacing scales
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Accessibility Safeguard: Minimum touch target size (WCAG 2.1 AA)
  static const double minTouchTarget = 48.0;

  // Border Radii
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusCard = 24.0;
  static const double radiusModal = 32.0;
  static const double radiusPill = 60.0;

  static final BorderRadius roundedSm = BorderRadius.circular(radiusSm);
  static final BorderRadius roundedMd = BorderRadius.circular(radiusMd);
  static final BorderRadius roundedCard = BorderRadius.circular(radiusCard);
  static final BorderRadius roundedModal = BorderRadius.circular(radiusModal);
  static final BorderRadius roundedPill = BorderRadius.circular(radiusPill);

  // Soft modern drop shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0C271C44),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x1F271C44),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Color(0x2E271C44),
      blurRadius: 28,
      offset: Offset(0, 10),
    ),
  ];
}
