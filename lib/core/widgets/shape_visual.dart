import 'package:flutter/material.dart';
import '../design_system/nova_colors.dart';

/// CustomPainter rendering geometric shapes for questions and answers.
class ShapeVisual extends StatelessWidget {
  final String shape; // 'square', 'rectangle', 'triangle', 'circle'
  final double size;
  final Color? color;

  const ShapeVisual({
    super.key,
    required this.shape,
    this.size = 56.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShapePainter(
          shape: shape.toLowerCase(),
          color: color ?? NovaColors.purple,
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final String shape;
  final Color color;

  _ShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double pad = 4.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    switch (shape) {
      case 'square':
        final rect = Rect.fromLTWH(pad, pad, w, w);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), fillPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);
        break;

      case 'rectangle':
        final rect = Rect.fromLTWH(pad, pad + h * 0.15, w, h * 0.7);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), fillPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);
        break;

      case 'triangle':
        final path = Path()
          ..moveTo(size.width / 2, pad)
          ..lineTo(size.width - pad, size.height - pad)
          ..lineTo(pad, size.height - pad)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;

      case 'circle':
      default:
        final center = Offset(size.width / 2, size.height / 2);
        final radius = w / 2;
        canvas.drawCircle(center, radius, fillPaint);
        canvas.drawCircle(center, radius, borderPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.color != color;
  }
}
