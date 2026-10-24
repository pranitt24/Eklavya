import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

import '../audio/sound_service.dart';

enum CelebrationType {
  correctAnswer,
  levelComplete,
  placementComplete,
}

/// Lightweight non-blocking celebration overlay:
/// - Floating animated balloon emojis (flutter_animate)
/// - Confetti burst
/// - Cheer sound effect
/// - Automatically removes in ~1.4s, never blocks touch input (IgnorePointer)
class CelebrationOverlay {
  static void show(
    BuildContext context, {
    CelebrationType type = CelebrationType.correctAnswer,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    // Cheer sound
    SoundService.instance.playDingChime();

    // Confetti burst
    final particleCount = type == CelebrationType.levelComplete
        ? 150
        : type == CelebrationType.placementComplete
            ? 120
            : 70;
    final spread = type == CelebrationType.levelComplete ? 95.0 : 70.0;

    try {
      Confetti.launch(
        context,
        options: ConfettiOptions(
          particleCount: particleCount,
          spread: spread,
          y: type == CelebrationType.levelComplete ? 0.45 : 0.55,
        ),
      );
    } catch (_) {}

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => IgnorePointer(
        child: _FloatingBalloonsWidget(type: type),
      ),
    );

    overlay.insert(entry);

    Timer(const Duration(milliseconds: 1400), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _FloatingBalloonsWidget extends StatelessWidget {
  final CelebrationType type;

  const _FloatingBalloonsWidget({required this.type});

  @override
  Widget build(BuildContext context) {
    final isBig = type != CelebrationType.correctAnswer;

    final items = [
      {'emoji': '🎈', 'dx': -120.0, 'delay': 0},
      {'emoji': '🎈', 'dx': -60.0, 'delay': 60},
      {'emoji': '🌟', 'dx': 0.0, 'delay': 120},
      {'emoji': '🎈', 'dx': 60.0, 'delay': 40},
      {'emoji': '🎈', 'dx': 120.0, 'delay': 90},
      if (isBig) ...[
        {'emoji': '🎉', 'dx': -180.0, 'delay': 150},
        {'emoji': '🎊', 'dx': 180.0, 'delay': 170},
        {'emoji': '⭐', 'dx': -30.0, 'delay': 200},
        {'emoji': '✨', 'dx': 30.0, 'delay': 220},
      ],
    ];

    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 0; i < items.length; i++)
          _buildBalloon(
            items[i]['emoji'] as String,
            items[i]['dx'] as double,
            items[i]['delay'] as int,
            isBig,
          ),
        if (isBig)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFBBF24), width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🎉 ', style: TextStyle(fontSize: 28)),
                  Text(
                    'शाब्बास! उत्कृष्ट!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C47FF),
                    ),
                  ),
                  Text(' 🌟', style: TextStyle(fontSize: 28)),
                ],
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.05, 1.05),
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                )
                .then(delay: 600.ms)
                .fadeOut(duration: 350.ms),
          ),
      ],
    );
  }

  Widget _buildBalloon(String emoji, double dx, int delayMs, bool isBig) {
    return Positioned(
      bottom: 120,
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Text(
          emoji,
          style: TextStyle(fontSize: isBig ? 48 : 38),
        )
            .animate(delay: Duration(milliseconds: delayMs))
            .fadeIn(duration: 200.ms)
            .slideY(
              begin: 0.2,
              end: isBig ? -1.2 : -0.9,
              duration: 1200.ms,
              curve: Curves.easeOutCubic,
            )
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1.15, 1.15),
              duration: 600.ms,
            )
            .fadeOut(delay: 800.ms, duration: 400.ms),
      ),
    );
  }
}
