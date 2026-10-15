import 'dart:math';
import 'package:flutter/material.dart';

/// 100% Vector Rural Landscape Painter for Screen 6 & Screen 8.
/// Paints a picturesque rural Maharashtra village scene:
/// - Warm sunrise sky with golden gradient
/// - Soft Sahyadri mountain ridges
/// - Traditional rural village house with terracotta tiled roof (कौलारू छप्पर)
/// - Green farming fields, mud courtyard, and lush trees
class VillageScenePainter extends CustomPainter {
  final bool highlightChiu;
  final bool showTractor;

  const VillageScenePainter({
    this.highlightChiu = false,
    this.showTractor = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Morning Sunrise Sky (Warm Golden Gradient)
    final Rect fullRect = Offset.zero & size;
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFBAE6FD), // Soft sky blue
          Color(0xFFFEF3C7), // Morning gold
          Color(0xFFFFEDD5), // Peach warmth
        ],
        stops: [0.0, 0.45, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fullRect);
    canvas.drawRect(fullRect, skyPaint);

    // 2. Glowing Morning Sun rising over the hills
    final Paint sunGlow = Paint()
      ..color = const Color(0x52FBBF24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(Offset(w * 0.22, h * 0.26), 44, sunGlow);

    final Paint sunCore = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(Offset(w * 0.22, h * 0.26), 28, sunCore);

    // 3. Sahyadri Hills (Distant layered mountains)
    final Paint farMountain = Paint()..color = const Color(0xFFC7D2FE).withValues(alpha: 0.65);
    final Path farPath = Path()
      ..moveTo(0, h * 0.45)
      ..quadraticBezierTo(w * 0.22, h * 0.28, w * 0.45, h * 0.42)
      ..quadraticBezierTo(w * 0.72, h * 0.26, w, h * 0.38)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(farPath, farMountain);

    final Paint nearMountain = Paint()..color = const Color(0xFF86EFAC).withValues(alpha: 0.85);
    final Path nearPath = Path()
      ..moveTo(0, h * 0.54)
      ..quadraticBezierTo(w * 0.30, h * 0.42, w * 0.60, h * 0.52)
      ..quadraticBezierTo(w * 0.85, h * 0.44, w, h * 0.56)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(nearPath, nearMountain);

    // 4. Village Pasture & Fields (Lush green lower gradient)
    final Paint fieldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF22C55E),
          Color(0xFF16A34A),
          Color(0xFF15803D),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.58, w, h * 0.42));
    final Path fieldPath = Path()
      ..moveTo(0, h * 0.60)
      ..quadraticBezierTo(w * 0.45, h * 0.56, w, h * 0.62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(fieldPath, fieldPaint);

    // Earthen courtyard patch in foreground
    final Paint courtyardPaint = Paint()..color = const Color(0xFFFDE68A);
    final Path yardPath = Path()
      ..moveTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.40, h * 0.74, w * 0.85, h * 0.85)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(yardPath, courtyardPaint);

    // 5. Village Farm Trees
    _drawBanyanTree(canvas, Offset(w * 0.08, h * 0.55), 45);
    _drawPalmTree(canvas, Offset(w * 0.88, h * 0.50), 65);

    // 6. Traditional Village House (Rural Maharashtra Hut)
    // House coordinates: centered at approximately w * 0.48, h * 0.58
    final double houseW = w * 0.38;
    final double houseH = h * 0.34;
    final double houseX = w * 0.30;
    final double houseY = h * 0.52;

    // Mud Walls (Warm Ochre / Cream)
    final Paint wallPaint = Paint()..color = const Color(0xFFFFFBEB);
    final Rect wallRect = Rect.fromLTWH(houseX + houseW * 0.1, houseY + houseH * 0.42, houseW * 0.8, houseH * 0.58);
    canvas.drawRRect(RRect.fromRectAndRadius(wallRect, const Radius.circular(8)), wallPaint);

    // Mud veranda base
    canvas.drawRect(
      Rect.fromLTWH(houseX + houseW * 0.06, houseY + houseH * 0.94, houseW * 0.88, houseH * 0.08),
      Paint()..color = const Color(0xFFD97706),
    );

    // Wooden door
    final Rect doorRect = Rect.fromLTWH(houseX + houseW * 0.42, houseY + houseH * 0.58, houseW * 0.20, houseH * 0.40);
    canvas.drawRRect(RRect.fromRectAndRadius(doorRect, const Radius.circular(6)), Paint()..color = const Color(0xFF78350F));

    // Wooden windows with shutters
    final Rect winRect = Rect.fromLTWH(houseX + houseW * 0.18, houseY + houseH * 0.58, houseW * 0.14, houseH * 0.22);
    canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(4)), Paint()..color = const Color(0xFF0284C7));
    canvas.drawRRect(
      RRect.fromRectAndRadius(winRect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Terracotta Tiled Roof (कौलारू छप्पर - Overhanging Triangular Hip)
    final Path roofPath = Path()
      ..moveTo(houseX, houseY + houseH * 0.44)
      ..lineTo(houseX + houseW * 0.5, houseY + houseH * 0.08) // Apex where Chiu sits
      ..lineTo(houseX + houseW, houseY + houseH * 0.44)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFFDC2626)); // Terracotta red

    // Tile stripes
    final Paint tileLinePaint = Paint()
      ..color = const Color(0xFF991B1B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (int i = 1; i <= 6; i++) {
      final double fraction = i / 7.0;
      final double y = houseY + houseH * 0.08 + (houseH * 0.36 * fraction);
      final double currentWidth = houseW * fraction;
      canvas.drawLine(
        Offset(houseX + houseW * 0.5 - currentWidth * 0.5, y),
        Offset(houseX + houseW * 0.5 + currentWidth * 0.5, y),
        tileLinePaint,
      );
    }

    // 7. Chiu (Sparrow) perched right on the Roof Apex
    // Position of Chiu: (houseX + houseW * 0.5, houseY + houseH * 0.08)
    final Offset chiuPos = Offset(houseX + houseW * 0.5, houseY + houseH * 0.06);
    _drawChiuOnRoof(canvas, chiuPos, highlightChiu);

    // 8. Red Farm Tractor parked in the yard (Screen 6 / 8 context)
    if (showTractor) {
      _drawMiniTractor(canvas, Offset(w * 0.74, h * 0.78), 58);
    }
  }

  void _drawChiuOnRoof(Canvas canvas, Offset pos, bool highlight) {
    if (highlight) {
      // Animated pulse aura
      final Paint aura = Paint()
        ..color = const Color(0x66FBBF24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(pos, 22, aura);
    }

    final Paint birdBody = Paint()..color = const Color(0xFFB45309);
    final Paint birdChest = Paint()..color = const Color(0xFFFEF3C7);
    final Paint birdBeak = Paint()..color = const Color(0xFFF59E0B);
    final Paint birdEye = Paint()..color = const Color(0xFF1E293B);

    // Body
    canvas.drawCircle(Offset(pos.dx, pos.dy), 11, birdBody);
    // Belly
    canvas.drawOval(Rect.fromCenter(center: Offset(pos.dx - 3, pos.dy + 3), width: 10, height: 8), birdChest);
    // Wing
    final Path wing = Path()
      ..moveTo(pos.dx, pos.dy - 1)
      ..quadraticBezierTo(pos.dx + 10, pos.dy + 2, pos.dx + 8, pos.dy + 8)
      ..close();
    canvas.drawPath(wing, Paint()..color = const Color(0xFF78350F));
    // Beak
    final Path beak = Path()
      ..moveTo(pos.dx - 10, pos.dy - 1)
      ..lineTo(pos.dx - 16, pos.dy + 1)
      ..lineTo(pos.dx - 10, pos.dy + 3)
      ..close();
    canvas.drawPath(beak, birdBeak);
    // Eye
    canvas.drawCircle(Offset(pos.dx - 5, pos.dy - 3), 2, birdEye);
  }

  void _drawBanyanTree(Canvas canvas, Offset root, double radius) {
    final Paint trunk = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(root, Offset(root.dx, root.dy - 40), trunk);

    final Paint leaves = Paint()..color = const Color(0xFF15803D);
    canvas.drawCircle(Offset(root.dx - 18, root.dy - 55), radius * 0.7, leaves);
    canvas.drawCircle(Offset(root.dx + 18, root.dy - 55), radius * 0.7, leaves);
    canvas.drawCircle(Offset(root.dx, root.dy - 72), radius * 0.85, leaves);
  }

  void _drawPalmTree(Canvas canvas, Offset root, double height) {
    final Paint trunk = Paint()
      ..color = const Color(0xFF92400E)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final Path trunkPath = Path()
      ..moveTo(root.dx, root.dy)
      ..quadraticBezierTo(root.dx - 10, root.dy - height * 0.5, root.dx - 4, root.dy - height);
    canvas.drawPath(trunkPath, trunk);

    final Paint frond = Paint()
      ..color = const Color(0xFF16A34A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final Offset top = Offset(root.dx - 4, root.dy - height);
    canvas.drawLine(top, Offset(top.dx - 24, top.dy - 8), frond);
    canvas.drawLine(top, Offset(top.dx + 24, top.dy - 8), frond);
    canvas.drawLine(top, Offset(top.dx - 18, top.dy + 14), frond);
    canvas.drawLine(top, Offset(top.dx + 18, top.dy + 14), frond);
    canvas.drawLine(top, Offset(top.dx, top.dy - 22), frond);
  }

  void _drawMiniTractor(Canvas canvas, Offset pos, double size) {
    final Paint redPaint = Paint()..color = const Color(0xFFEF4444);
    final Paint darkWheel = Paint()..color = const Color(0xFF1F2937);
    final Paint yellowRim = Paint()..color = const Color(0xFFFBBF24);

    // Big Rear Wheel
    canvas.drawCircle(Offset(pos.dx + size * 0.30, pos.dy), size * 0.32, darkWheel);
    canvas.drawCircle(Offset(pos.dx + size * 0.30, pos.dy), size * 0.16, yellowRim);

    // Small Front Wheel
    canvas.drawCircle(Offset(pos.dx - size * 0.36, pos.dy + size * 0.08), size * 0.20, darkWheel);
    canvas.drawCircle(Offset(pos.dx - size * 0.36, pos.dy + size * 0.08), size * 0.10, yellowRim);

    // Tractor Bonnet
    final Path bonnet = Path()
      ..moveTo(pos.dx - size * 0.46, pos.dy - size * 0.02)
      ..lineTo(pos.dx + size * 0.05, pos.dy - size * 0.02)
      ..lineTo(pos.dx + size * 0.05, pos.dy - size * 0.42)
      ..lineTo(pos.dx - size * 0.40, pos.dy - size * 0.42)
      ..close();
    canvas.drawPath(bonnet, redPaint);

    // Cabin / Steering
    canvas.drawLine(
      Offset(pos.dx + size * 0.05, pos.dy - size * 0.25),
      Offset(pos.dx + size * 0.22, pos.dy - size * 0.50),
      Paint()..color = const Color(0xFF1F2937)..strokeWidth = 3,
    );

    // Exhaust Pipe
    canvas.drawLine(
      Offset(pos.dx - size * 0.26, pos.dy - size * 0.42),
      Offset(pos.dx - size * 0.26, pos.dy - size * 0.62),
      Paint()..color = const Color(0xFF374151)..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Rich, handcrafted Vector Tractor for Big/Small Quiz
class TractorVectorArt extends StatelessWidget {
  final double size;

  const TractorVectorArt({super.key, this.size = 140.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.3,
      height: size,
      child: CustomPaint(
        painter: _TractorPainter(),
      ),
    );
  }
}

class _TractorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint bodyRed = Paint()..color = const Color(0xFFDC2626);
    final Paint bodyHighlight = Paint()..color = const Color(0xFFEF4444);
    final Paint tireRubber = Paint()..color = const Color(0xFF18181B);
    final Paint rimYellow = Paint()..color = const Color(0xFFFBBF24);
    final Paint rimShadow = Paint()..color = const Color(0xFFD97706);
    final Paint metalDark = Paint()..color = const Color(0xFF3F3F46);

    // Rear Big Tire
    final Offset rearCenter = Offset(w * 0.76, h * 0.66);
    final double rearRadius = h * 0.32;
    canvas.drawCircle(rearCenter, rearRadius, tireRubber);

    // Deep Treads on Rear Tire
    final Paint treadPaint = Paint()
      ..color = const Color(0xFF27272A)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 8; i++) {
      final double angle = i * (pi / 4);
      final Offset p1 = rearCenter + Offset(cos(angle) * (rearRadius * 0.72), sin(angle) * (rearRadius * 0.72));
      final Offset p2 = rearCenter + Offset(cos(angle) * rearRadius, sin(angle) * rearRadius);
      canvas.drawLine(p1, p2, treadPaint);
    }

    // Rear Rim
    canvas.drawCircle(rearCenter, rearRadius * 0.55, rimYellow);
    canvas.drawCircle(rearCenter, rearRadius * 0.22, rimShadow);

    // Front Small Tire
    final Offset frontCenter = Offset(w * 0.24, h * 0.75);
    final double frontRadius = h * 0.20;
    canvas.drawCircle(frontCenter, frontRadius, tireRubber);
    canvas.drawCircle(frontCenter, frontRadius * 0.55, rimYellow);
    canvas.drawCircle(frontCenter, frontRadius * 0.22, rimShadow);

    // Engine Bonnet
    final Path bonnet = Path()
      ..moveTo(w * 0.12, h * 0.68)
      ..lineTo(w * 0.58, h * 0.68)
      ..lineTo(w * 0.58, h * 0.32)
      ..lineTo(w * 0.20, h * 0.32)
      ..quadraticBezierTo(w * 0.12, h * 0.34, w * 0.12, h * 0.68)
      ..close();
    canvas.drawPath(bonnet, bodyRed);

    // Top Highlight on Bonnet
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.34, w * 0.36, h * 0.07), const Radius.circular(4)),
      bodyHighlight,
    );

    // Front Headlight
    canvas.drawCircle(Offset(w * 0.14, h * 0.44), 8, Paint()..color = const Color(0xFFFEF08A));

    // Steering Column & Wheel
    canvas.drawLine(Offset(w * 0.54, h * 0.42), Offset(w * 0.64, h * 0.24), metalDark..strokeWidth = 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.66, h * 0.22), width: 22, height: 8),
      Paint()..color = const Color(0xFF18181B),
    );

    // Driver Seat
    final Path seat = Path()
      ..moveTo(w * 0.68, h * 0.44)
      ..quadraticBezierTo(w * 0.76, h * 0.44, w * 0.76, h * 0.32)
      ..lineTo(w * 0.82, h * 0.32)
      ..lineTo(w * 0.82, h * 0.48)
      ..lineTo(w * 0.68, h * 0.48)
      ..close();
    canvas.drawPath(seat, Paint()..color = const Color(0xFF18181B));

    // Exhaust Chimney (Puffing friendly smoke)
    canvas.drawLine(Offset(w * 0.32, h * 0.32), Offset(w * 0.32, h * 0.10), metalDark..strokeWidth = 6);
    canvas.drawCircle(Offset(w * 0.32, h * 0.08), 5, Paint()..color = const Color(0xFF71717A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Rich, handcrafted Vector Bicycle for Big/Small Quiz
class BicycleVectorArt extends StatelessWidget {
  final double size;

  const BicycleVectorArt({super.key, this.size = 140.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.3,
      height: size,
      child: CustomPaint(
        painter: _BicyclePainter(),
      ),
    );
  }
}

class _BicyclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint tirePaint = Paint()
      ..color = const Color(0xFF18181B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    final Paint spokePaint = Paint()
      ..color = const Color(0xFFA1A1AA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Paint framePaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Offset rearWheel = Offset(w * 0.25, h * 0.70);
    final Offset frontWheel = Offset(w * 0.75, h * 0.70);
    final double wheelRadius = h * 0.24;

    // Rear Wheel & Spokes
    canvas.drawCircle(rearWheel, wheelRadius, tirePaint);
    for (int i = 0; i < 6; i++) {
      final double angle = i * (pi / 3);
      canvas.drawLine(
        rearWheel - Offset(cos(angle) * wheelRadius, sin(angle) * wheelRadius),
        rearWheel + Offset(cos(angle) * wheelRadius, sin(angle) * wheelRadius),
        spokePaint,
      );
    }

    // Front Wheel & Spokes
    canvas.drawCircle(frontWheel, wheelRadius, tirePaint);
    for (int i = 0; i < 6; i++) {
      final double angle = i * (pi / 3);
      canvas.drawLine(
        frontWheel - Offset(cos(angle) * wheelRadius, sin(angle) * wheelRadius),
        frontWheel + Offset(cos(angle) * wheelRadius, sin(angle) * wheelRadius),
        spokePaint,
      );
    }

    // Frame Nodes
    final Offset bottomBracket = Offset(w * 0.46, h * 0.70);
    final Offset seatJunction = Offset(w * 0.38, h * 0.38);
    final Offset headTube = Offset(w * 0.66, h * 0.32);

    // Triangle Frame Lines
    canvas.drawLine(rearWheel, bottomBracket, framePaint);
    canvas.drawLine(bottomBracket, seatJunction, framePaint);
    canvas.drawLine(seatJunction, rearWheel, framePaint);
    canvas.drawLine(bottomBracket, headTube, framePaint);
    canvas.drawLine(seatJunction, headTube, framePaint);
    canvas.drawLine(headTube, frontWheel, framePaint);

    // Handlebar & Basket
    final Offset handleTop = Offset(w * 0.65, h * 0.22);
    canvas.drawLine(headTube, handleTop, framePaint);
    canvas.drawLine(Offset(handleTop.dx - 8, handleTop.dy), Offset(handleTop.dx + 12, handleTop.dy), framePaint);

    // Front Basket
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.70, h * 0.24, 22, 16), const Radius.circular(3)),
      Paint()..color = const Color(0xFFFBBF24),
    );

    // Saddle / Seat
    canvas.drawOval(
      Rect.fromCenter(center: Offset(seatJunction.dx, seatJunction.dy - 6), width: 24, height: 8),
      Paint()..color = const Color(0xFF18181B),
    );

    // Pedals
    canvas.drawCircle(bottomBracket, 6, Paint()..color = const Color(0xFF71717A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
