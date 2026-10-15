import 'package:flutter/material.dart';

class MatchConnection {
  final int leftIndex;
  final int rightIndex;
  final Color color;

  const MatchConnection({
    required this.leftIndex,
    required this.rightIndex,
    required this.color,
  });
}

/// Custom painter rendering smooth, organic cubic bezier curves connecting
/// matching chip connection sockets, matching `Screen 10 · Match the following.png`.
class NovaMatchingBezierPainter extends CustomPainter {
  final Map<int, Offset> leftSocketPositions;
  final Map<int, Offset> rightSocketPositions;
  final List<MatchConnection> connections;
  final Offset? activeDragStart;
  final Offset? activeDragCurrent;
  final Color activeDragColor;

  NovaMatchingBezierPainter({
    required this.leftSocketPositions,
    required this.rightSocketPositions,
    required this.connections,
    this.activeDragStart,
    this.activeDragCurrent,
    this.activeDragColor = const Color(0xFF6C47FF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw established connections
    for (final conn in connections) {
      final p1 = leftSocketPositions[conn.leftIndex];
      final p2 = rightSocketPositions[conn.rightIndex];
      if (p1 != null && p2 != null) {
        _drawBezierCurve(canvas, p1, p2, conn.color, 6.0);
      }
    }

    // 2. Draw active dragging curve
    if (activeDragStart != null && activeDragCurrent != null) {
      _drawBezierCurve(
        canvas,
        activeDragStart!,
        activeDragCurrent!,
        activeDragColor.withValues(alpha: 0.85),
        5.0,
      );
    }
  }

  void _drawBezierCurve(Canvas canvas, Offset p1, Offset p2, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(p1.dx, p1.dy);

    final double deltaX = (p2.dx - p1.dx).abs();
    final double controlDistance = deltaX * 0.55;

    final Offset c1 = Offset(p1.dx + controlDistance, p1.dy);
    final Offset c2 = Offset(p2.dx - controlDistance, p2.dy);

    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    canvas.drawPath(path, paint);

    // Draw connection anchor dots at both endpoints
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(p1, strokeWidth * 0.8, dotPaint);
    canvas.drawCircle(p2, strokeWidth * 0.8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant NovaMatchingBezierPainter oldDelegate) {
    return true;
  }
}
