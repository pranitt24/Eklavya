import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../design_system/nova_colors.dart';
import '../../design_system/nova_spacing.dart';

/// Full-Bleed Layered Village Meadow & Grove Stage for Level 2.
/// Eliminates all empty background space with:
/// - Layer 1: Warm golden-hour sky gradient + morning sun + drifting clouds
/// - Layer 2: Distant Sahyadri green hills + village hut silhouette + terracotta path
/// - Layer 3: Properly anchored Mango Tree, Cute Tiger, or Village Cow & Milk Carton
/// - Layer 4: Foreground grass tufts + floating story title pill
class BanyanGroveStageWidget extends StatelessWidget {
  final bool isInteractiveTarget;
  final bool targetTapped;
  final VoidCallback? onTargetTap;
  final VoidCallback? onWrongSpotTap;
  final String? character;
  final String? prop;
  final int sceneIndex;
  final String title;

  const BanyanGroveStageWidget({
    super.key,
    this.isInteractiveTarget = false,
    this.targetTapped = false,
    this.onTargetTap,
    this.onWrongSpotTap,
    this.character,
    this.prop,
    this.sceneIndex = 0,
    this.title = 'वडाचे झाड आणि डेअरी • Banyan Grove',
  });

  bool get _isDairyScene {
    if (character == 'char_cow' || prop == 'prop_milk') return true;
    // Scene 1 (Screen 7) is Dairy in Level 2
    return sceneIndex == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: NovaSpacing.roundedCard,
        boxShadow: NovaSpacing.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: NovaSpacing.roundedCard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cardW = constraints.maxWidth;
            final double cardH = constraints.maxHeight;

            final double tigerSize = math.min(145.0, cardH * 0.54);
            final double cowW = math.min(175.0, cardW * 0.44);
            final double cowH = math.min(155.0, cardH * 0.52);
            final double milkSize = math.min(95.0, cardH * 0.35);

            return Stack(
              fit: StackFit.expand,
              children: [
                // =============================================================
                // LAYER 1 & 2: SKY, SUN, CLOUDS, SAHYADRI HILLS, PATH & WRONG SPOT DETECTION
                // =============================================================
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (isInteractiveTarget && !targetTapped) ? onWrongSpotTap : null,
                    child: CustomPaint(
                      size: Size(cardW, cardH),
                      painter: const BanyanGroveMeadowPainter(),
                    ),
                  ),
                ),

                // =============================================================
                // LAYER 3: MAIN STAGE LOTTIES ANCHORED TO MEADOW & PATH
                // =============================================================

                // 1. Lush Mango Tree & Grove Backdrop (Fills 100% of stage container - eliminates harsh rectangular box edge)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Lottie.asset(
                      'assets/lottie/Mango Tree Animation.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // 2. Stage Actors: Either Cow + Milk Carton (Dairy Scene) or Cute Tiger (Meadow Scene)
                if (_isDairyScene && !isInteractiveTarget) ...[
                  // Village Cow grazing on lush meadow grass
                  Positioned(
                    right: cardW * 0.16,
                    bottom: cardH * 0.04,
                    child: SizedBox(
                      width: cowW,
                      height: cowH,
                      child: Lottie.asset(
                        'assets/lottie/cow.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Fresh Milk Carton standing on meadow path
                  Positioned(
                    right: cardW * 0.03,
                    bottom: cardH * 0.06,
                    child: SizedBox(
                      width: milkSize,
                      height: milkSize,
                      child: Lottie.asset(
                        'assets/lottie/Eda region 1.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ] else ...[
                  // Cute Tiger sitting in foreground on the terracotta path
                  Positioned(
                    right: cardW * 0.08,
                    bottom: cardH * 0.05,
                    child: SizedBox(
                      width: tigerSize,
                      height: tigerSize,
                      child: Lottie.asset(
                        'assets/lottie/Cute Tiger.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Screen 8 Interactive Target Ring over Cute Tiger
                  if (isInteractiveTarget) ...[
                    Positioned(
                      right: cardW * 0.08 + (tigerSize * 0.12),
                      bottom: cardH * 0.05 + (tigerSize * 0.14),
                      child: GestureDetector(
                        onTap: onTargetTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 82,
                          height: 82,
                          alignment: Alignment.center,
                          child: Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: targetTapped ? NovaColors.green : NovaColors.gold,
                                width: 3.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (targetTapped ? NovaColors.green : NovaColors.gold)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 14,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                begin: const Offset(0.90, 0.90),
                                end: const Offset(1.15, 1.15),
                                duration: 1100.ms,
                              ),
                        ),
                      ),
                    ),

                    if (targetTapped)
                      Positioned(
                        top: cardH * 0.20,
                        right: cardW * 0.08,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: NovaColors.gold,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3D271C44),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'वाघोबा सापडला! / FOUND!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: NovaColors.ink,
                            ),
                          ),
                        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                      ),
                  ],
                ],

                // =============================================================
                // LAYER 4: FLOATING STORY BANNER
                // =============================================================
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A271C44),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Rich Vector Backdrop Painter for Level 2:
/// - Golden-hour sky with warm gradient (#FFF4D2 -> #C8F4F9 -> #A7E8BD)
/// - Morning sun in top-left with soft glow
/// - Gentle layered white clouds
/// - Distant Sahyadri mountain ridges (#7BC67E and #56AB62)
/// - Cozy village hut silhouette on the ridge (#B45309 and #D97706)
/// - Warm terracotta winding meadow path (#E5B887)
/// - Soft grass tuft accents along foreground edge
class BanyanGroveMeadowPainter extends CustomPainter {
  const BanyanGroveMeadowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect fullRect = Offset.zero & size;

    // 1. LAYER 1: WARM GOLDEN-HOUR SKY GRADIENT (#FFF4D2 -> #C8F4F9 -> #A7E8BD)
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFF4D2), // Warm golden morning glow
          Color(0xFFC8F4F9), // Soft fresh sky cyan
          Color(0xFFA7E8BD), // Meadow atmosphere blend
        ],
        stops: [0.0, 0.45, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fullRect);
    canvas.drawRect(fullRect, skyPaint);

    // 2. GLOWING MORNING SUN (Top-Left Corner)
    final Offset sunCenter = Offset(w * 0.16, h * 0.18);
    final Paint sunGlow = Paint()
      ..color = const Color(0x55FBBF24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(sunCenter, 46, sunGlow);

    final Paint sunOuter = Paint()..color = const Color(0x99FEF08A);
    canvas.drawCircle(sunCenter, 32, sunOuter);

    final Paint sunCore = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(sunCenter, 22, sunCore);

    // 3. DRIFTING CLOUDS
    _drawCloud(canvas, Offset(w * 0.46, h * 0.14), 48, 20);
    _drawCloud(canvas, Offset(w * 0.78, h * 0.20), 58, 24);
    _drawCloud(canvas, Offset(w * 0.24, h * 0.26), 40, 16);

    // 4. LAYER 2: DISTANT SAHYADRI HILLS (#7BC67E)
    final Paint farHillPaint = Paint()..color = const Color(0xFF7BC67E);
    final Path farHillPath = Path()
      ..moveTo(0, h * 0.46)
      ..quadraticBezierTo(w * 0.22, h * 0.32, w * 0.48, h * 0.42)
      ..quadraticBezierTo(w * 0.76, h * 0.30, w, h * 0.40)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(farHillPath, farHillPaint);

    // 5. VILLAGE HUT SILHOUETTE ON THE FAR RIDGE
    _drawDistantHut(canvas, Offset(w * 0.72, h * 0.34));

    // 6. NEAR ROLLING MEADOW HILL (#56AB62)
    final Paint nearHillPaint = Paint()..color = const Color(0xFF56AB62);
    final Path nearHillPath = Path()
      ..moveTo(0, h * 0.60)
      ..quadraticBezierTo(w * 0.28, h * 0.48, w * 0.62, h * 0.58)
      ..quadraticBezierTo(w * 0.84, h * 0.52, w, h * 0.58)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(nearHillPath, nearHillPaint);

    // 7. WARM TERRACOTTA VILLAGE MEADOW PATH (#E5B887)
    final Paint pathEdgePaint = Paint()
      ..color = const Color(0xFFD4A373)
      ..style = PaintingStyle.fill;
    final Path pathEdge = Path()
      ..moveTo(w * 0.26, h * 0.57)
      ..quadraticBezierTo(w * 0.46, h * 0.68, w * 0.64, h * 0.74)
      ..quadraticBezierTo(w * 0.88, h * 0.82, w, h * 0.92)
      ..lineTo(w, h)
      ..lineTo(w * 0.70, h)
      ..quadraticBezierTo(w * 0.48, h * 0.84, w * 0.32, h * 0.76)
      ..quadraticBezierTo(w * 0.20, h * 0.68, w * 0.18, h * 0.60)
      ..close();
    canvas.drawPath(pathEdge, pathEdgePaint);

    final Paint pathPaint = Paint()
      ..color = const Color(0xFFE5B887)
      ..style = PaintingStyle.fill;
    final Path path = Path()
      ..moveTo(w * 0.28, h * 0.58)
      ..quadraticBezierTo(w * 0.46, h * 0.69, w * 0.65, h * 0.75)
      ..quadraticBezierTo(w * 0.88, h * 0.83, w, h * 0.94)
      ..lineTo(w, h)
      ..lineTo(w * 0.74, h)
      ..quadraticBezierTo(w * 0.50, h * 0.85, w * 0.34, h * 0.77)
      ..quadraticBezierTo(w * 0.22, h * 0.69, w * 0.20, h * 0.61)
      ..close();
    canvas.drawPath(path, pathPaint);

    // 8. FOREGROUND MEADOW BLEND & GRASS TUFTS (#4CAF50 & #388E3C)
    final Paint foregroundGrass = Paint()..color = const Color(0xFF43A047);
    final Path fgPath = Path()
      ..moveTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.22, h * 0.78, w * 0.42, h * 0.88)
      ..lineTo(w * 0.42, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(fgPath, foregroundGrass);

    _drawGrassTuft(canvas, Offset(w * 0.06, h * 0.84), 16);
    _drawGrassTuft(canvas, Offset(w * 0.18, h * 0.88), 18);
    _drawGrassTuft(canvas, Offset(w * 0.34, h * 0.94), 15);
    _drawGrassTuft(canvas, Offset(w * 0.58, h * 0.96), 14);
    _drawGrassTuft(canvas, Offset(w * 0.88, h * 0.97), 16);
  }

  void _drawCloud(Canvas canvas, Offset center, double width, double height) {
    final Paint cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.78)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: width, height: height * 0.7),
        Radius.circular(height * 0.35),
      ),
      cloudPaint,
    );
    canvas.drawCircle(Offset(center.dx - width * 0.22, center.dy - height * 0.15), height * 0.42, cloudPaint);
    canvas.drawCircle(Offset(center.dx + width * 0.08, center.dy - height * 0.25), height * 0.52, cloudPaint);
    canvas.drawCircle(Offset(center.dx + width * 0.30, center.dy - height * 0.10), height * 0.38, cloudPaint);
  }

  void _drawDistantHut(Canvas canvas, Offset pos) {
    final Paint wallPaint = Paint()..color = const Color(0xFFFEF3C7);
    final Paint roofPaint = Paint()..color = const Color(0xFFD97706);
    final Paint treePaint = Paint()..color = const Color(0xFF2E7D32);

    // Tiny tree beside hut
    canvas.drawCircle(Offset(pos.dx - 8, pos.dy - 3), 9, treePaint);

    // Hut wall
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, 18, 12), wallPaint);

    // Terracotta roof
    final Path roof = Path()
      ..moveTo(pos.dx - 3, pos.dy)
      ..lineTo(pos.dx + 9, pos.dy - 8)
      ..lineTo(pos.dx + 21, pos.dy)
      ..close();
    canvas.drawPath(roof, roofPaint);
  }

  void _drawGrassTuft(Canvas canvas, Offset pos, double height) {
    final Paint grassPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path tuft = Path()
      ..moveTo(pos.dx - 4, pos.dy)
      ..quadraticBezierTo(pos.dx - 7, pos.dy - height * 0.7, pos.dx - 9, pos.dy - height)
      ..moveTo(pos.dx, pos.dy)
      ..quadraticBezierTo(pos.dx + 1, pos.dy - height * 0.8, pos.dx + 2, pos.dy - height * 1.1)
      ..moveTo(pos.dx + 4, pos.dy)
      ..quadraticBezierTo(pos.dx + 7, pos.dy - height * 0.7, pos.dx + 9, pos.dy - height * 0.9);
    canvas.drawPath(tuft, grassPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
