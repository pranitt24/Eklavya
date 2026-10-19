import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../design_system/nova_colors.dart';
import '../../design_system/nova_spacing.dart';

/// Full-Bleed Layered Indian Village Weekly Market Stage for Level 3.
/// Eliminates all empty background space with:
/// - Layer 1: Warm festive bazaar sky gradient (#FFF3D6 -> #FFE0B2 -> #C8F0D4)
///           + custom-painted festive triangular village fair buntings (🟠🟢🟣🟡)
/// - Layer 2: Distant green Sahyadri hills + wide warm terracotta market road (#E2B07E)
///           + full-stage background GestureDetector for gentle wrong-spot retry feedback
/// - Layer 3: Anchored Lottie animations:
///           - Beat 1: Food stall, Fruit basket, Waving farmer, Parked bicycle + glowing ring
///           - Beat 2: Weighing scale & Fruit basket on stall
///           - Beat 3: Waving farmer, Piggy bank & Weighing scale
///           - Beat 4 / Default: Full festive market overview
/// - Layer 4: Festive title pill & tap celebrations
class VillageMarketStageWidget extends StatelessWidget {
  final bool isInteractiveTarget;
  final bool targetTapped;
  final VoidCallback? onTargetTap;
  final VoidCallback? onWrongSpotTap;
  final String? character;
  final String? prop;
  final int sceneIndex;
  final String title;

  const VillageMarketStageWidget({
    super.key,
    this.isInteractiveTarget = false,
    this.targetTapped = false,
    this.onTargetTap,
    this.onWrongSpotTap,
    this.character,
    this.prop,
    this.sceneIndex = 0,
    this.title = 'गावाचा आठवडी बाजार • Village Market',
  });

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

            // Dimensions scaled to visual panel container
            final double stallW = math.min(230.0, cardW * 0.56);
            final double stallH = math.min(185.0, cardH * 0.62);
            final double farmerW = math.min(150.0, cardW * 0.38);
            final double farmerH = math.min(170.0, cardH * 0.58);
            final double bicycleW = math.min(115.0, cardW * 0.28);
            final double bicycleH = math.min(95.0, cardH * 0.32);
            final double fruitBasketSize = math.min(85.0, cardH * 0.30);
            final double scaleSize = math.min(95.0, cardH * 0.33);
            final double piggySize = math.min(110.0, cardH * 0.38);

            return Stack(
              fit: StackFit.expand,
              children: [
                // =============================================================
                // LAYER 1 & 2: FESTIVE BAZAAR SKY, BUNTING, HILLS & TERRACOTTA ROAD
                // =============================================================
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (isInteractiveTarget && !targetTapped) ? onWrongSpotTap : null,
                    child: CustomPaint(
                      size: Size(cardW, cardH),
                      painter: const VillageMarketFestivePainter(),
                    ),
                  ),
                ),

                // =============================================================
                // LAYER 3: ANCHORED STAGE LOTTIES ACCORDING TO CURRENT STORY BEAT
                // =============================================================

                // --- BEAT 3 (Screen 9 / Scene 3): Piggy Bank & Farmer Counting ---
                if (sceneIndex == 3) ...[
                  // 1. Weighing Scale in background left
                  Positioned(
                    left: cardW * 0.08,
                    bottom: cardH * 0.16,
                    child: SizedBox(
                      width: scaleSize,
                      height: scaleSize,
                      child: Lottie.asset(
                        'assets/lottie/weighing_scale.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 2. Piggy Bank on market counter / stand
                  Positioned(
                    left: cardW * 0.26,
                    bottom: cardH * 0.08,
                    child: SizedBox(
                      width: piggySize,
                      height: piggySize,
                      child: Lottie.asset(
                        'assets/lottie/piggy_bank.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 3. Waving Farmer friend standing proudly on the right
                  Positioned(
                    right: cardW * 0.06,
                    bottom: cardH * 0.04,
                    child: SizedBox(
                      width: farmerW * 1.1,
                      height: farmerH * 1.1,
                      child: Lottie.asset(
                        'assets/lottie/farmer_waving.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ]

                // --- BEAT 2 (Screen 7 / Scene 1): Weighing Fruits on the Scale ---
                else if (sceneIndex == 1) ...[
                  // 1. Food Stall on the market walkway
                  Positioned(
                    left: cardW * 0.04,
                    bottom: cardH * 0.04,
                    child: SizedBox(
                      width: stallW,
                      height: stallH,
                      child: Lottie.asset(
                        'assets/lottie/food stall.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 2. Weighing scale on stall area
                  Positioned(
                    left: cardW * 0.38,
                    bottom: cardH * 0.14,
                    child: SizedBox(
                      width: scaleSize * 1.1,
                      height: scaleSize * 1.1,
                      child: Lottie.asset(
                        'assets/lottie/weighing_scale.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 3. Fruit basket ready for comparison
                  Positioned(
                    left: cardW * 0.22,
                    bottom: cardH * 0.06,
                    child: SizedBox(
                      width: fruitBasketSize,
                      height: fruitBasketSize,
                      child: Lottie.asset(
                        'assets/lottie/fruit_basket.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 4. Farmer standing on the right
                  Positioned(
                    right: cardW * 0.04,
                    bottom: cardH * 0.04,
                    child: SizedBox(
                      width: farmerW,
                      height: farmerH,
                      child: Lottie.asset(
                        'assets/lottie/farmer_waving.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ]

                // --- BEAT 1 (Screen 6 / Scene 0 & Screen 8 / Scene 2) & BEAT 4 (Scene 4) ---
                else ...[
                  // 1. Blue Bicycle parked on far left of village path
                  Positioned(
                    left: cardW * 0.02,
                    bottom: cardH * 0.05,
                    child: SizedBox(
                      width: bicycleW,
                      height: bicycleH,
                      child: Lottie.asset(
                        'assets/lottie/bicycle.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 2. Main Village Food Stall on center-left
                  Positioned(
                    left: cardW * 0.20,
                    bottom: cardH * 0.05,
                    child: SizedBox(
                      width: stallW,
                      height: stallH,
                      child: Lottie.asset(
                        'assets/lottie/food stall.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 3. Fresh Fruit Basket displayed near stall
                  Positioned(
                    left: cardW * 0.44,
                    bottom: cardH * 0.05,
                    child: SizedBox(
                      width: fruitBasketSize,
                      height: fruitBasketSize,
                      child: Lottie.asset(
                        'assets/lottie/fruit_basket.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 4. Waving Farmer Friend beside stall
                  Positioned(
                    right: cardW * 0.02,
                    bottom: cardH * 0.04,
                    child: SizedBox(
                      width: farmerW,
                      height: farmerH,
                      child: Lottie.asset(
                        'assets/lottie/farmer_waving.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 5. Interactive Target Ring over Food Stall (Screen 8 / spot_item)
                  if (isInteractiveTarget) ...[
                    Positioned(
                      left: cardW * 0.20 + (stallW * 0.28),
                      bottom: cardH * 0.05 + (stallH * 0.20),
                      child: GestureDetector(
                        onTap: onTargetTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 88,
                          height: 88,
                          alignment: Alignment.center,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: targetTapped ? NovaColors.green : NovaColors.gold,
                                width: 3.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (targetTapped ? NovaColors.green : NovaColors.gold)
                                      .withValues(alpha: 0.55),
                                  blurRadius: 16,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                begin: const Offset(0.90, 0.90),
                                end: const Offset(1.18, 1.18),
                                duration: 1100.ms,
                              ),
                        ),
                      ),
                    ),

                    // "दुकान / STALL!" badge once discovered
                    if (targetTapped)
                      Positioned(
                        left: cardW * 0.20 + (stallW * 0.24),
                        bottom: cardH * 0.05 + (stallH * 0.70),
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
                            'दुकान / STALL!',
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
                // LAYER 4: FLOATING TITLE PILL
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

/// Rich Vector Backdrop Painter for Level 3 Indian Village Weekly Market:
/// - Golden afternoon sky gradient (#FFF3D6 -> #FFE0B2 -> #C8F0D4)
/// - Festive triangular fair buntings / toran (🟠🟢🟣🟡) strung across top
/// - Distant soft green Sahyadri hills (#81C784, #4CAF50)
/// - Wide warm terracotta market walkway (#E2B07E and #D4A373)
/// - Distant village vendor canopy silhouettes & sun glow
class VillageMarketFestivePainter extends CustomPainter {
  const VillageMarketFestivePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect fullRect = Offset.zero & size;

    // 1. SKY GRADIENT: Golden Festive Afternoon (#FFF3D6 -> #FFE0B2 -> #C8F0D4)
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFF3D6), // Golden festive top glow
          Color(0xFFFFE0B2), // Warm peach fair atmosphere
          Color(0xFFC8F0D4), // Soft green horizon blend
        ],
        stops: [0.0, 0.45, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fullRect);
    canvas.drawRect(fullRect, skyPaint);

    // 2. WARM AFTERNOON SUN GLOW
    final Offset sunCenter = Offset(w * 0.82, h * 0.16);
    final Paint sunGlow = Paint()
      ..color = const Color(0x44FBBF24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(sunCenter, 48, sunGlow);

    final Paint sunCore = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawCircle(sunCenter, 24, sunCore);

    // 3. DISTANT ROLLING GREEN HILLS
    final Paint farHillPaint = Paint()..color = const Color(0xFF81C784);
    final Path farHillPath = Path()
      ..moveTo(0, h * 0.45)
      ..quadraticBezierTo(w * 0.28, h * 0.32, w * 0.54, h * 0.42)
      ..quadraticBezierTo(w * 0.80, h * 0.34, w, h * 0.44)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(farHillPath, farHillPaint);

    final Paint midHillPaint = Paint()..color = const Color(0xFF4CAF50);
    final Path midHillPath = Path()
      ..moveTo(0, h * 0.58)
      ..quadraticBezierTo(w * 0.35, h * 0.46, w * 0.68, h * 0.55)
      ..quadraticBezierTo(w * 0.86, h * 0.50, w, h * 0.56)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(midHillPath, midHillPaint);

    // 4. WIDE WARM TERRACOTTA MARKET WALKWAY (#E2B07E & #D4A373)
    final Paint roadBasePaint = Paint()..color = const Color(0xFFD4A373);
    final Path roadBasePath = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.45, h * 0.62, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(roadBasePath, roadBasePaint);

    final Paint roadTopPaint = Paint()..color = const Color(0xFFE2B07E);
    final Path roadTopPath = Path()
      ..moveTo(0, h * 0.68)
      ..quadraticBezierTo(w * 0.48, h * 0.64, w, h * 0.69)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(roadTopPath, roadTopPaint);

    // Subtle stone/paving texture lines on road
    final Paint texturePaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 1; i <= 4; i++) {
      final double y = h * (0.72 + (i * 0.06));
      canvas.drawLine(Offset(w * 0.05, y), Offset(w * 0.95, y + 2), texturePaint);
    }

    // 5. FESTIVE TRIANGULAR FAIR BUNTINGS / TORAN (🟠🟢🟣🟡)
    _drawFestiveBuntingString(
      canvas: canvas,
      start: Offset(0, h * 0.08),
      control: Offset(w * 0.50, h * 0.18),
      end: Offset(w, h * 0.08),
      width: w,
    );

    _drawFestiveBuntingString(
      canvas: canvas,
      start: Offset(0, h * 0.16),
      control: Offset(w * 0.50, h * 0.25),
      end: Offset(w, h * 0.15),
      width: w,
      flagCount: 9,
    );
  }

  void _drawFestiveBuntingString({
    required Canvas canvas,
    required Offset start,
    required Offset control,
    required Offset end,
    required double width,
    int flagCount = 11,
  }) {
    // String line
    final Paint stringPaint = Paint()
      ..color = const Color(0x8878350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path stringPath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(stringPath, stringPaint);

    // Bunting flag colors: Orange, Green, Purple, Gold
    final List<Color> flagColors = [
      const Color(0xFFF97316), // Orange
      const Color(0xFF10B981), // Green
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF59E0B), // Gold
      const Color(0xFFEC4899), // Pink
    ];

    // Compute sample points along curve for hanging triangular flags
    for (int i = 0; i < flagCount; i++) {
      final double t = (i + 0.5) / flagCount;
      // Quadratic bezier point: (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
      final double x = (1 - t) * (1 - t) * start.dx + 2 * (1 - t) * t * control.dx + t * t * end.dx;
      final double y = (1 - t) * (1 - t) * start.dy + 2 * (1 - t) * t * control.dy + t * t * end.dy;

      final Color color = flagColors[i % flagColors.length];
      final Paint flagPaint = Paint()..color = color;

      final Path flag = Path()
        ..moveTo(x - 8, y)
        ..lineTo(x + 8, y)
        ..lineTo(x, y + 14)
        ..close();
      canvas.drawPath(flag, flagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
