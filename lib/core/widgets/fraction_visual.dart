import 'dart:math';
import 'package:flutter/material.dart';
import '../models/visual_type.dart';
import '../design_system/nova_colors.dart';

/// CustomPainter rendering fraction circles, bars, and sliced pizzas.
class FractionVisual extends StatelessWidget {
  final String fractionStr; // e.g. "1/4", "1/2", "3/4", "2/4"
  final VisualType type;
  final double size;

  const FractionVisual({
    super.key,
    required this.fractionStr,
    this.type = VisualType.fractionCircles,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    int num = 1;
    int den = 2;
    final parts = fractionStr.split('/');
    if (parts.length == 2) {
      num = int.tryParse(parts[0]) ?? 1;
      den = int.tryParse(parts[1]) ?? 2;
    }

    return SizedBox(
      width: size,
      height: type == VisualType.fractionBars ? size * 0.45 : size,
      child: CustomPaint(
        painter: _FractionPainter(
          numerator: num,
          denominator: den,
          type: type,
        ),
      ),
    );
  }
}

class _FractionPainter extends CustomPainter {
  final int numerator;
  final int denominator;
  final VisualType type;

  _FractionPainter({
    required this.numerator,
    required this.denominator,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (type == VisualType.fractionBars) {
      _drawFractionBar(canvas, size);
    } else if (type == VisualType.pizza) {
      _drawPizza(canvas, size);
    } else {
      _drawFractionCircle(canvas, size);
    }
  }

  void _drawFractionCircle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 2;

    final bgPaint = Paint()
      ..color = NovaColors.softGrey
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final shadedPaint = Paint()
      ..color = NovaColors.sky
      ..style = PaintingStyle.fill;

    final double sweepAngle = (2 * pi / denominator) * numerator;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      true,
      shadedPaint,
    );

    // Slice division lines
    final linePaint = Paint()
      ..color = NovaColors.navy
      ..strokeWidth = 2.0;

    for (int i = 0; i < denominator; i++) {
      final double angle = -pi / 2 + (2 * pi / denominator) * i;
      final p2 = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      canvas.drawLine(center, p2, linePaint);
    }

    final borderPaint = Paint()
      ..color = NovaColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawPizza(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 2;

    // Crust
    final crustPaint = Paint()
      ..color = const Color(0xFFD49B55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, crustPaint);

    // Cheese
    final cheesePaint = Paint()
      ..color = NovaColors.sunYellow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.85, cheesePaint);

    // Shaded slice representing eaten or selected fraction
    final slicePaint = Paint()
      ..color = NovaColors.coral.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final double sweepAngle = (2 * pi / denominator) * numerator;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.85),
      -pi / 2,
      sweepAngle,
      true,
      slicePaint,
    );

    // Pepperoni dots on each slice
    final pepPaint = Paint()..color = const Color(0xFFC0392B);
    for (int i = 0; i < denominator; i++) {
      final double angle = -pi / 2 + (2 * pi / denominator) * (i + 0.5);
      final dot = Offset(center.dx + radius * 0.5 * cos(angle), center.dy + radius * 0.5 * sin(angle));
      canvas.drawCircle(dot, radius * 0.12, pepPaint);
    }

    // Cut lines
    final cutPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 2.0;

    for (int i = 0; i < denominator; i++) {
      final double angle = -pi / 2 + (2 * pi / denominator) * i;
      final p2 = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      canvas.drawLine(center, p2, cutPaint);
    }
  }

  void _drawFractionBar(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      const Radius.circular(8),
    );

    final bgPaint = Paint()
      ..color = NovaColors.softGrey
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, bgPaint);

    final double segmentWidth = (size.width - 4) / denominator;
    final shadedPaint = Paint()
      ..color = NovaColors.mint
      ..style = PaintingStyle.fill;

    for (int i = 0; i < numerator; i++) {
      final segRect = Rect.fromLTWH(2 + i * segmentWidth, 2, segmentWidth, size.height - 4);
      canvas.drawRect(segRect, shadedPaint);
    }

    // Dividers
    final linePaint = Paint()
      ..color = NovaColors.navy
      ..strokeWidth = 2.0;

    for (int i = 1; i < denominator; i++) {
      final double x = 2 + i * segmentWidth;
      canvas.drawLine(Offset(x, 2), Offset(x, size.height - 2), linePaint);
    }

    final borderPaint = Paint()
      ..color = NovaColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _FractionPainter oldDelegate) {
    return oldDelegate.numerator != numerator ||
        oldDelegate.denominator != denominator ||
        oldDelegate.type != type;
  }
}
