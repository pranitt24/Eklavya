import 'package:flutter/services.dart';

/// Small local haptics adapter used by the UI prototype.
/// It is intentionally dependency-free and safe to call on platforms
/// where haptics are unavailable.
class HapticsService {
  HapticsService._();

  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
