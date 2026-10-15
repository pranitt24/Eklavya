import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/story_beat.dart';
import '../theme/app_colors.dart';

/// MascotWidget draws NOVA: a friendly round robot-star companion with rich animated expressions.
class MascotWidget extends StatefulWidget {
  final NovaMood mood;
  final double size;
  final bool speaking;
  final bool showGlow;

  const MascotWidget({
    super.key,
    this.mood = NovaMood.happy,
    this.size = 120.0,
    this.speaking = false,
    this.showGlow = false,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late AnimationController _mouthController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();

    // Idle vertical floating sine loop (±6 px)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Periodic blink loop (~3.5 s interval)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();

    // Speaking mouth animation
    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    if (widget.speaking) {
      _mouthController.repeat(reverse: true);
    }

    // Excited bounce loop
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.mood == NovaMood.excited || widget.mood == NovaMood.celebrating) {
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.speaking != oldWidget.speaking) {
      if (widget.speaking) {
        _mouthController.repeat(reverse: true);
      } else {
        _mouthController.stop();
        _mouthController.value = 0.0;
      }
    }

    if (widget.mood != oldWidget.mood) {
      if (widget.mood == NovaMood.excited || widget.mood == NovaMood.celebrating) {
        if (!_bounceController.isAnimating) {
          _bounceController.repeat(reverse: true);
        }
      } else {
        _bounceController.stop();
        _bounceController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _blinkController.dispose();
    _mouthController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.asset(
        'assets/lottie/Robot says hello.json',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return AnimatedBuilder(
            animation: Listenable.merge([
              _floatController,
              _blinkController,
              _mouthController,
              _bounceController,
            ]),
            builder: (context, child) {
              // Calculate float offset
              double floatOffset = sin(_floatController.value * 2 * pi) * 6.0;
              if (widget.mood == NovaMood.excited) {
                floatOffset -= _bounceController.value * 12.0;
              }

              // Calculate blink factor (1.0 = open, 0.0 = closed)
              final blinkProgress = _blinkController.value;
              double eyeOpenFactor = 1.0;
              if (widget.mood == NovaMood.sleepy) {
                eyeOpenFactor = 0.35;
              } else if (blinkProgress > 0.95) {
                eyeOpenFactor = (1.0 - (blinkProgress - 0.95) / 0.05).clamp(0.0, 1.0);
              }

              return Transform.translate(
                offset: Offset(0, floatOffset),
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    painter: _NovaMascotPainter(
                      mood: widget.mood,
                      eyeOpenFactor: eyeOpenFactor,
                      mouthOpenFactor: widget.speaking ? _mouthController.value : 0.0,
                      showGlow: widget.showGlow,
                      animationProgress: _floatController.value,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NovaMascotPainter extends CustomPainter {
  final NovaMood mood;
  final double eyeOpenFactor;
  final double mouthOpenFactor;
  final bool showGlow;
  final double animationProgress;

  _NovaMascotPainter({
    required this.mood,
    required this.eyeOpenFactor,
    required this.mouthOpenFactor,
    required this.showGlow,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final double bodyRadius = size.width * 0.36;
    final centerOffset = Offset(center, center + size.height * 0.06);

    // 1. Glow effect (if enabled)
    if (showGlow || mood == NovaMood.celebrating) {
      final glowPaint = Paint()
        ..color = AppColors.sunYellow.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(centerOffset, bodyRadius + 10, glowPaint);
    }

    // 2. Antenna with glowing Star tip
    final antennaPaint = Paint()
      ..color = AppColors.navy
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final antennaStart = Offset(center, centerOffset.dy - bodyRadius + 2);
    final antennaEnd = Offset(center, centerOffset.dy - bodyRadius - size.height * 0.16);

    canvas.drawLine(antennaStart, antennaEnd, antennaPaint);

    // Star tip on antenna
    _drawStar(
      canvas,
      antennaEnd,
      size.width * 0.11,
      AppColors.sunYellow,
      mood == NovaMood.listening,
    );

    // 3. Tiny arms
    final armPaint = Paint()
      ..color = AppColors.purple
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (mood == NovaMood.celebrating) {
      // Arms raised high
      canvas.drawLine(
        Offset(centerOffset.dx - bodyRadius * 0.85, centerOffset.dy),
        Offset(centerOffset.dx - bodyRadius * 1.25, centerOffset.dy - bodyRadius * 0.7),
        armPaint,
      );
      canvas.drawLine(
        Offset(centerOffset.dx + bodyRadius * 0.85, centerOffset.dy),
        Offset(centerOffset.dx + bodyRadius * 1.25, centerOffset.dy - bodyRadius * 0.7),
        armPaint,
      );
    } else {
      // Gentle resting arms
      canvas.drawLine(
        Offset(centerOffset.dx - bodyRadius * 0.9, centerOffset.dy + bodyRadius * 0.2),
        Offset(centerOffset.dx - bodyRadius * 1.15, centerOffset.dy + bodyRadius * 0.35),
        armPaint,
      );
      canvas.drawLine(
        Offset(centerOffset.dx + bodyRadius * 0.9, centerOffset.dy + bodyRadius * 0.2),
        Offset(centerOffset.dx + bodyRadius * 1.15, centerOffset.dy + bodyRadius * 0.35),
        armPaint,
      );
    }

    // 4. Main Body: Purple -> Sky gradient
    final bodyRect = Rect.fromCircle(center: centerOffset, radius: bodyRadius);
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.purple, AppColors.sky],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect);

    canvas.drawCircle(centerOffset, bodyRadius, bodyPaint);

    // Outer subtle border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(centerOffset, bodyRadius, borderPaint);

    // 5. Rosy Cheeks
    final cheekPaint = Paint()
      ..color = AppColors.coral.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final double cheekY = centerOffset.dy + bodyRadius * 0.18;
    final double cheekSpacing = bodyRadius * 0.62;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerOffset.dx - cheekSpacing, cheekY),
        width: bodyRadius * 0.32,
        height: bodyRadius * 0.18,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerOffset.dx + cheekSpacing, cheekY),
        width: bodyRadius * 0.32,
        height: bodyRadius * 0.18,
      ),
      cheekPaint,
    );

    // 6. Large Glossy Eyes
    final double eyeRadius = bodyRadius * 0.25;
    final double eyeSpacing = bodyRadius * 0.42;
    double eyeCenterY = centerOffset.dy - bodyRadius * 0.08;

    // Mood adjustment for eye position
    double lookOffsetX = 0.0;
    double lookOffsetY = 0.0;
    if (mood == NovaMood.thinking) {
      lookOffsetX = eyeRadius * 0.45;
      lookOffsetY = -eyeRadius * 0.35;
    }

    final leftEyeCenter = Offset(centerOffset.dx - eyeSpacing + lookOffsetX, eyeCenterY + lookOffsetY);
    final rightEyeCenter = Offset(centerOffset.dx + eyeSpacing + lookOffsetX, eyeCenterY + lookOffsetY);

    final eyePaint = Paint()..color = AppColors.navy;
    final eyeHeight = max(1.5, eyeRadius * 2 * eyeOpenFactor);

    // Draw Left & Right Eyes
    canvas.drawOval(
      Rect.fromCenter(center: leftEyeCenter, width: eyeRadius * 1.8, height: eyeHeight),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: rightEyeCenter, width: eyeRadius * 1.8, height: eyeHeight),
      eyePaint,
    );

    // Glossy eye highlights (only when eyes are open)
    if (eyeOpenFactor > 0.5) {
      final highlightPaint = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(leftEyeCenter.dx - eyeRadius * 0.3, leftEyeCenter.dy - eyeRadius * 0.3),
        eyeRadius * 0.35,
        highlightPaint,
      );
      canvas.drawCircle(
        Offset(rightEyeCenter.dx - eyeRadius * 0.3, rightEyeCenter.dy - eyeRadius * 0.3),
        eyeRadius * 0.35,
        highlightPaint,
      );
    }

    // 7. Mouth Expression
    final mouthPaint = Paint()
      ..color = AppColors.navy
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.035;

    final mouthY = centerOffset.dy + bodyRadius * 0.28;

    if (mouthOpenFactor > 0.05) {
      // Speaking animated mouth
      final openMouthPaint = Paint()
        ..color = AppColors.navy
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerOffset.dx, mouthY),
          width: bodyRadius * 0.38,
          height: bodyRadius * (0.2 + mouthOpenFactor * 0.25),
        ),
        openMouthPaint,
      );

      // Soundwave pulse arcs beside mouth
      _drawSoundWaves(canvas, centerOffset, bodyRadius);
    } else {
      // Normal smile
      final mouthPath = Path();
      if (mood == NovaMood.excited || mood == NovaMood.celebrating) {
        mouthPath.moveTo(centerOffset.dx - bodyRadius * 0.26, mouthY - 2);
        mouthPath.quadraticBezierTo(
          centerOffset.dx,
          mouthY + bodyRadius * 0.34,
          centerOffset.dx + bodyRadius * 0.26,
          mouthY - 2,
        );
      } else {
        mouthPath.moveTo(centerOffset.dx - bodyRadius * 0.22, mouthY);
        mouthPath.quadraticBezierTo(
          centerOffset.dx,
          mouthY + bodyRadius * 0.22,
          centerOffset.dx + bodyRadius * 0.22,
          mouthY,
        );
      }
      canvas.drawPath(mouthPath, mouthPaint);
    }

    // 8. Thinking "..." bubble or sprout for encouraging
    if (mood == NovaMood.thinking) {
      _drawThinkingDots(canvas, centerOffset, bodyRadius);
    } else if (mood == NovaMood.encouraging) {
      _drawSprout(canvas, centerOffset, bodyRadius);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color, bool pulse) {
    final path = Path();
    final double r = pulse ? radius * (1.0 + sin(animationProgress * 2 * pi) * 0.2) : radius;
    final double innerR = r * 0.45;
    const int points = 5;

    for (int i = 0; i < points * 2; i++) {
      final double rad = i * pi / points - pi / 2;
      final double currR = (i % 2 == 0) ? r : innerR;
      final double x = center.dx + currR * cos(rad);
      final double y = center.dy + currR * sin(rad);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, starPaint);
  }

  void _drawSoundWaves(Canvas canvas, Offset center, double radius) {
    final wavePaint = Paint()
      ..color = AppColors.sky
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final rightX = center.dx + radius * 1.15;
    final waveY = center.dy + radius * 0.28;

    // 2 subtle concentric wave arcs
    canvas.drawArc(
      Rect.fromCircle(center: Offset(rightX, waveY), radius: 10),
      -pi / 3,
      2 * pi / 3,
      false,
      wavePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(rightX, waveY), radius: 18),
      -pi / 3,
      2 * pi / 3,
      false,
      wavePaint,
    );
  }

  void _drawThinkingDots(Canvas canvas, Offset center, double radius) {
    final dotPaint = Paint()..color = AppColors.purple;
    final bubbleX = center.dx + radius * 0.85;
    final bubbleY = center.dy - radius * 0.7;

    canvas.drawCircle(Offset(bubbleX, bubbleY), 3.0, dotPaint);
    canvas.drawCircle(Offset(bubbleX + 7, bubbleY - 6), 4.5, dotPaint);
    canvas.drawCircle(Offset(bubbleX + 16, bubbleY - 14), 6.5, dotPaint);
  }

  void _drawSprout(Canvas canvas, Offset center, double radius) {
    final sproutPaint = Paint()
      ..color = AppColors.mint
      ..style = PaintingStyle.fill;

    final sproutCenter = Offset(center.dx + radius * 0.8, center.dy - radius * 0.6);
    canvas.drawCircle(sproutCenter, 5.0, sproutPaint);
  }

  @override
  bool shouldRepaint(covariant _NovaMascotPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.eyeOpenFactor != eyeOpenFactor ||
        oldDelegate.mouthOpenFactor != mouthOpenFactor ||
        oldDelegate.showGlow != showGlow ||
        oldDelegate.animationProgress != animationProgress;
  }
}
