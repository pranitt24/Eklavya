import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../design_system/nova_colors.dart';
import '../../design_system/nova_spacing.dart';

/// Full-Bleed Layered Village School & Evening Fair Stage for Level 4.
/// Eliminates all empty background space with:
/// - Layer 1 & 2: Dynamic Time-of-Day custom painted scenery
///     - Beats 1 & 2 (School Beats): Morning sky gradient, green Sahyadri hills,
///       classic red-tiled Zilla Parishad village school facade, bell tower, and road.
///     - Beats 3 & 4 (Fair / Jatra Beats): Warm sunset-to-twilight festival gradient,
///       glowing festival fairy light strings, and colourful village fair buntings.
/// - Full-stage background GestureDetector for gentle wrong-spot retry feedback.
/// - Layer 3: Anchored Lottie animations:
///     - Beat 1 (spot_item): School bus on road, school bag, waving Chintu, NOVA + glowing tap target.
///     - Beat 2 (fill_blanks): Classroom blackboard with 2D geometric shape animations.
///     - Beat 3 (voice_input): Giant spinning Ferris wheel & floating colourful balloons at the fair.
///     - Beat 4 / Default: Grand finale fair & school celebration with trophy preview.
class VillageSchoolFairStageWidget extends StatelessWidget {
  final bool isInteractiveTarget;
  final bool targetTapped;
  final VoidCallback? onTargetTap;
  final VoidCallback? onWrongSpotTap;
  final String? character;
  final String? prop;
  final int sceneIndex;
  final String title;

  const VillageSchoolFairStageWidget({
    super.key,
    this.isInteractiveTarget = false,
    this.targetTapped = false,
    this.onTargetTap,
    this.onWrongSpotTap,
    this.character,
    this.prop,
    this.sceneIndex = 0,
    this.title = 'गावाची शाळा आणि जत्रा • School & Fair',
  });

  bool get isFairScene => sceneIndex >= 2;

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

            // Dimensions scaled proportionally
            final double busW = math.min(260.0, cardW * 0.65);
            final double busH = math.min(180.0, cardH * 0.60);
            final double bagSize = math.min(75.0, cardH * 0.28);
            final double chintuH = math.min(145.0, cardH * 0.52);
            final double novaH = math.min(125.0, cardH * 0.44);
            final double ferrisSize = math.min(220.0, math.min(cardW * 0.60, cardH * 0.72));
            final double balloonsSize = math.min(130.0, cardH * 0.48);
            final double shapeSize = math.min(65.0, cardH * 0.24);

            return Stack(
              fit: StackFit.expand,
              children: [
                // =============================================================
                // LAYER 1 & 2: DYNAMIC CUSTOM-PAINTED SCENERY & BACKGROUND TAP
                // =============================================================
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (isInteractiveTarget && !targetTapped) ? onWrongSpotTap : null,
                    child: CustomPaint(
                      size: Size(cardW, cardH),
                      painter: VillageSchoolFairPainter(isFairScene: isFairScene),
                    ),
                  ),
                ),

                // =============================================================
                // LAYER 3: ANCHORED STAGE LOTTIES ACCORDING TO CURRENT STORY BEAT
                // =============================================================

                // --- BEAT 3 (Screen 9 / Scene 3): Evening Fair Ferris Wheel & Balloons ---
                if (sceneIndex == 3) ...[
                  // 1. Giant Spinning Ferris Wheel on the left-center
                  Positioned(
                    left: cardW * 0.05,
                    bottom: cardH * 0.12,
                    child: SizedBox(
                      width: ferrisSize,
                      height: ferrisSize,
                      child: Lottie.asset(
                        'assets/lottie/ferris_wheel.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 2. Floating Colorful Balloons on the right
                  Positioned(
                    right: cardW * 0.12,
                    top: cardH * 0.12,
                    child: SizedBox(
                      width: balloonsSize,
                      height: balloonsSize,
                      child: Lottie.asset(
                        'assets/lottie/balloons.json',
                        fit: BoxFit.contain,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: 0, end: -12, duration: 2200.ms, curve: Curves.easeInOut),
                  ),

                  // 3. Chintu waving near the balloons
                  Positioned(
                    right: cardW * 0.10,
                    bottom: cardH * 0.08,
                    child: SizedBox(
                      height: chintuH,
                      child: Lottie.asset(
                        'assets/lottie/Hand Waving Animation.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ]

                // --- BEAT 2 (Screen 7 / Scene 1): Classroom Shapes on Blackboard ---
                else if (sceneIndex == 1) ...[
                  // 1. Classroom Blackboard container in center
                  Positioned(
                    left: cardW * 0.08,
                    right: cardW * 0.08,
                    top: cardH * 0.15,
                    bottom: cardH * 0.28,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A2F), // Slate blackboard green
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF8B5A2B), width: 6), // Teak wooden frame
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x35000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '२-D आकार • 2D Geometric Shapes',
                            style: TextStyle(
                              color: Color(0xFFFEF3C7),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Divider(color: Color(0x40FFFFFF), thickness: 1, height: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Circle
                                _buildBoardShapeItem(
                                  lottiePath: 'assets/lottie/circle.json',
                                  label: 'वर्तुळ',
                                  size: shapeSize,
                                ),
                                // Triangle
                                _buildBoardShapeItem(
                                  lottiePath: 'assets/lottie/triangle.json',
                                  label: 'त्रिकोण',
                                  size: shapeSize,
                                ),
                                // Square
                                _buildBoardShapeItem(
                                  lottiePath: 'assets/lottie/square.json',
                                  label: 'चौकोन',
                                  size: shapeSize,
                                ),
                                // Rectangle
                                _buildBoardShapeItem(
                                  lottiePath: 'assets/lottie/rectangle.json',
                                  label: 'आयत',
                                  size: shapeSize,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. School Bag resting on student desk near bottom left
                  Positioned(
                    left: cardW * 0.12,
                    bottom: cardH * 0.05,
                    child: SizedBox(
                      width: bagSize,
                      height: bagSize,
                      child: Lottie.asset(
                        'assets/lottie/school_bag.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 3. NOVA observing on the bottom right
                  Positioned(
                    right: cardW * 0.10,
                    bottom: cardH * 0.05,
                    child: SizedBox(
                      height: novaH,
                      child: Lottie.asset(
                        'assets/lottie/Robot says hello.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ]

                // --- BEAT 4 / Default / Scene 4: Grand Finale Overview ---
                else if (sceneIndex >= 4) ...[
                  // Ferris Wheel background left
                  Positioned(
                    left: cardW * 0.04,
                    bottom: cardH * 0.10,
                    child: SizedBox(
                      width: ferrisSize * 0.90,
                      height: ferrisSize * 0.90,
                      child: Lottie.asset(
                        'assets/lottie/ferris_wheel.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Floating Balloons right
                  Positioned(
                    right: cardW * 0.08,
                    top: cardH * 0.12,
                    child: SizedBox(
                      width: balloonsSize * 0.85,
                      height: balloonsSize * 0.85,
                      child: Lottie.asset(
                        'assets/lottie/balloons.json',
                        fit: BoxFit.contain,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: 0, end: -10, duration: 2000.ms),
                  ),

                  // Trophy preview in center foreground
                  Positioned(
                    left: cardW * 0.38,
                    bottom: cardH * 0.06,
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: Lottie.asset(
                        'assets/lottie/trophy.json',
                        fit: BoxFit.contain,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.08, 1.08), duration: 1500.ms),
                  ),

                  // School Bag on the road
                  Positioned(
                    right: cardW * 0.28,
                    bottom: cardH * 0.08,
                    child: SizedBox(
                      width: bagSize * 0.85,
                      height: bagSize * 0.85,
                      child: Lottie.asset(
                        'assets/lottie/school_bag.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ]

                // --- BEAT 1 (Screen 6 / 8 / Scene 0 / 2): Spot School Bus on Road ---
                else ...[
                  // 1. Chintu waving on the sidewalk
                  Positioned(
                    left: cardW * 0.04,
                    bottom: cardH * 0.12,
                    child: SizedBox(
                      height: chintuH,
                      child: Lottie.asset(
                        'assets/lottie/Hand Waving Animation.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 2. Chintu's school bag on the sidewalk near him
                  Positioned(
                    left: cardW * 0.20,
                    bottom: cardH * 0.10,
                    child: SizedBox(
                      width: bagSize,
                      height: bagSize,
                      child: Lottie.asset(
                        'assets/lottie/school_bag.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 3. Yellow School Bus parked on the road
                  Positioned(
                    left: cardW * 0.32,
                    bottom: cardH * 0.06,
                    child: GestureDetector(
                      onTap: (isInteractiveTarget && !targetTapped) ? onTargetTap : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Interactive Pulsing Golden Glow Target Ring
                          if (isInteractiveTarget && !targetTapped)
                            Container(
                              width: busW + 28,
                              height: busH + 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: NovaColors.goldDark,
                                  width: 3.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x60F59E0B),
                                    blurRadius: 20,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                            )
                                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                .scale(
                                  begin: const Offset(0.96, 0.96),
                                  end: const Offset(1.08, 1.08),
                                  duration: 900.ms,
                                  curve: Curves.easeInOut,
                                ),

                          // Bus Animation
                          SizedBox(
                            width: busW,
                            height: busH,
                            child: Lottie.asset(
                              'assets/lottie/bus.json',
                              fit: BoxFit.contain,
                            ),
                          ),

                          // Target Prompt Pill
                          if (isInteractiveTarget && !targetTapped)
                            Positioned(
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x35000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.touch_app_rounded, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'इथे टॅप करा! • Tap here',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 4. NOVA greeting on the right
                  Positioned(
                    right: cardW * 0.03,
                    bottom: cardH * 0.10,
                    child: SizedBox(
                      height: novaH,
                      child: Lottie.asset(
                        'assets/lottie/Robot says hello.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],

                // Confetti Burst Overlay on Success
                if (targetTapped)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Lottie.asset(
                        'assets/lottie/Confetti Pop.json',
                        fit: BoxFit.cover,
                        repeat: false,
                      ),
                    ),
                  ),

                // =============================================================
                // LAYER 4: STAGE TITLE BADGE
                // =============================================================
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFairScene
                          ? const Color(0xFF4C1D95).withValues(alpha: 0.85)
                          : const Color(0xFF1E3A8A).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x20000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFairScene ? Icons.celebration_rounded : Icons.school_rounded,
                          color: isFairScene ? const Color(0xFFFDE047) : const Color(0xFF93C5FD),
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isFairScene
                              ? 'गावाची जत्रा • Evening Fair'
                              : 'गावाची शाळा • Village School',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
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

  Widget _buildBoardShapeItem({
    required String lottiePath,
    required String label,
    required double size,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Lottie.asset(
            lottiePath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0x40FFFFFF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom Canvas Painter rendering:
/// 1. School Scenery (Morning sky, green hills, Zilla Parishad school building facade, road)
/// 2. Fair Scenery (Sunset-to-twilight sky, festival buntings, glowing fairy lights, fairground)
class VillageSchoolFairPainter extends CustomPainter {
  final bool isFairScene;

  const VillageSchoolFairPainter({required this.isFairScene});

  @override
  void paint(Canvas canvas, Size size) {
    if (isFairScene) {
      _paintFairScene(canvas, size);
    } else {
      _paintSchoolScene(canvas, size);
    }
  }

  void _paintSchoolScene(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Morning Sky Gradient (#E0F2FE -> #BAE6FD -> #DCFCE7)
    final Rect skyRect = Rect.fromLTWH(0, 0, w, h);
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE0F2FE),
          Color(0xFFBAE6FD),
          Color(0xFFDCFCE7),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Distant Soft Green Sahyadri Hills
    final Paint hillPaint1 = Paint()..color = const Color(0xFFA7F3D0).withValues(alpha: 0.70);
    final Path hill1 = Path();
    hill1.moveTo(0, h * 0.55);
    hill1.quadraticBezierTo(w * 0.25, h * 0.38, w * 0.55, h * 0.52);
    hill1.quadraticBezierTo(w * 0.80, h * 0.42, w, h * 0.50);
    hill1.lineTo(w, h);
    hill1.lineTo(0, h);
    hill1.close();
    canvas.drawPath(hill1, hillPaint1);

    final Paint hillPaint2 = Paint()..color = const Color(0xFF6EE7B7).withValues(alpha: 0.85);
    final Path hill2 = Path();
    hill2.moveTo(0, h * 0.60);
    hill2.quadraticBezierTo(w * 0.35, h * 0.48, w * 0.70, h * 0.62);
    hill2.quadraticBezierTo(w * 0.88, h * 0.54, w, h * 0.62);
    hill2.lineTo(w, h);
    hill2.lineTo(0, h);
    hill2.close();
    canvas.drawPath(hill2, hillPaint2);

    // 3. Zilla Parishad Village School Building Facade on upper-right
    final double schoolX = w * 0.45;
    final double schoolY = h * 0.28;
    final double schoolW = w * 0.52;
    final double schoolH = h * 0.42;

    // School Wall (Warm cream/buff #FEF3C7)
    final Paint wallPaint = Paint()..color = const Color(0xFFFEF3C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(schoolX, schoolY + 22, schoolW, schoolH - 22),
        const Radius.circular(8),
      ),
      wallPaint,
    );

    // School Veranda Pillars
    final Paint pillarPaint = Paint()..color = const Color(0xFFFDE68A);
    for (int i = 0; i < 4; i++) {
      final double px = schoolX + 16 + (i * (schoolW - 32) / 3);
      canvas.drawRect(Rect.fromLTWH(px, schoolY + 28, 8, schoolH - 28), pillarPaint);
    }

    // School Red Mangalore Tiled Roof
    final Paint roofPaint = Paint()..color = const Color(0xFFDC2626);
    final Path roofPath = Path();
    roofPath.moveTo(schoolX - 10, schoolY + 24);
    roofPath.lineTo(schoolX + schoolW + 10, schoolY + 24);
    roofPath.lineTo(schoolX + schoolW - 12, schoolY);
    roofPath.lineTo(schoolX + 12, schoolY);
    roofPath.close();
    canvas.drawPath(roofPath, roofPaint);

    // Bell Tower on roof
    final double towerX = schoolX + schoolW * 0.45;
    canvas.drawRect(Rect.fromLTWH(towerX, schoolY - 20, 22, 20), wallPaint);
    final Path towerRoof = Path();
    towerRoof.moveTo(towerX - 6, schoolY - 20);
    towerRoof.lineTo(towerX + 28, schoolY - 20);
    towerRoof.lineTo(towerX + 11, schoolY - 34);
    towerRoof.close();
    canvas.drawPath(towerRoof, roofPaint);

    // Brass School Bell
    final Paint bellPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawCircle(Offset(towerX + 11, schoolY - 10), 4.5, bellPaint);

    // School Blackboard Wall Plaque
    final Paint boardPlq = Paint()..color = const Color(0xFF1E3A8A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(schoolX + 20, schoolY + 36, schoolW - 40, 16),
        const Radius.circular(4),
      ),
      boardPlq,
    );

    // 4. Village School Road (Warm earthen/terracotta paved street #D4A373)
    final double roadY = h * 0.70;
    final Rect roadRect = Rect.fromLTWH(0, roadY, w, h - roadY);
    final Paint roadPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE2B07E),
          Color(0xFFC48F5B),
        ],
      ).createShader(roadRect);
    canvas.drawRect(roadRect, roadPaint);

    // Road Sidewalk Kerb
    final Paint kerbPaint = Paint()..color = const Color(0xFFB45309).withValues(alpha: 0.6);
    canvas.drawLine(Offset(0, roadY), Offset(w, roadY), kerbPaint..strokeWidth = 3);

    // Dashed Road Markings
    final Paint dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 3;
    const double dashW = 18;
    const double spaceW = 14;
    double startX = 10;
    final double markY = roadY + (h - roadY) * 0.52;
    while (startX < w) {
      canvas.drawLine(Offset(startX, markY), Offset(math.min(startX + dashW, w), markY), dashPaint);
      startX += dashW + spaceW;
    }
  }

  void _paintFairScene(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Warm Sunset-to-Twilight Festival Sky (#FF9800 -> #8E24AA -> #311B92)
    final Rect skyRect = Rect.fromLTWH(0, 0, w, h);
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF311B92), // Deep festival twilight top
          Color(0xFF7B1FA2), // Violet
          Color(0xFFE65100), // Sunset orange
          Color(0xFFFFB74D), // Golden dusk horizon
        ],
        stops: [0.0, 0.40, 0.75, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Evening Twilight Sahyadri Silhouettes
    final Paint twilightHill = Paint()..color = const Color(0xFF4A148C).withValues(alpha: 0.65);
    final Path hill = Path();
    hill.moveTo(0, h * 0.52);
    hill.quadraticBezierTo(w * 0.30, h * 0.42, w * 0.60, h * 0.50);
    hill.quadraticBezierTo(w * 0.85, h * 0.44, w, h * 0.48);
    hill.lineTo(w, h);
    hill.lineTo(0, h);
    hill.close();
    canvas.drawPath(hill, twilightHill);

    // 3. Festive Earthen Fairground (#8D6E63 -> #5D4037)
    final double groundY = h * 0.68;
    final Rect groundRect = Rect.fromLTWH(0, groundY, w, h - groundY);
    final Paint groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFA1887F),
          Color(0xFF5D4037),
        ],
      ).createShader(groundRect);
    canvas.drawRect(groundRect, groundPaint);

    // 4. Festive Village Fair Buntings (Colourful triangular flags across top)
    _drawBuntingCurve(
      canvas: canvas,
      start: Offset(0, h * 0.08),
      ctrl: Offset(w * 0.5, h * 0.22),
      end: Offset(w, h * 0.09),
    );
    _drawBuntingCurve(
      canvas: canvas,
      start: Offset(0, h * 0.20),
      ctrl: Offset(w * 0.45, h * 0.32),
      end: Offset(w, h * 0.21),
    );

    // 5. Glowing Fairy Light Strings
    _drawFairyLights(
      canvas: canvas,
      start: Offset(0, h * 0.04),
      ctrl: Offset(w * 0.52, h * 0.16),
      end: Offset(w, h * 0.05),
    );
  }

  void _drawBuntingCurve({
    required Canvas canvas,
    required Offset start,
    required Offset ctrl,
    required Offset end,
  }) {
    final Paint stringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.50)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final Path rope = Path();
    rope.moveTo(start.dx, start.dy);
    rope.quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
    canvas.drawPath(rope, stringPaint);

    // Flags colors
    const flagColors = [
      Color(0xFFEF4444), // Red
      Color(0xFFF59E0B), // Gold
      Color(0xFF10B981), // Green
      Color(0xFF3B82F6), // Blue
      Color(0xFFA855F7), // Purple
      Color(0xFFEC4899), // Pink
    ];

    const int flagCount = 14;
    for (int i = 0; i < flagCount; i++) {
      final double t = (i + 0.5) / flagCount;
      // Quadratic bezier evaluation
      final double x = (1 - t) * (1 - t) * start.dx + 2 * (1 - t) * t * ctrl.dx + t * t * end.dx;
      final double y = (1 - t) * (1 - t) * start.dy + 2 * (1 - t) * t * ctrl.dy + t * t * end.dy;

      final Paint flagPaint = Paint()..color = flagColors[i % flagColors.length];
      final Path flag = Path();
      flag.moveTo(x - 6, y);
      flag.lineTo(x + 6, y);
      flag.lineTo(x, y + 13);
      flag.close();
      canvas.drawPath(flag, flagPaint);
    }
  }

  void _drawFairyLights({
    required Canvas canvas,
    required Offset start,
    required Offset ctrl,
    required Offset end,
  }) {
    final Paint wire = Paint()
      ..color = const Color(0x60FFFFFF)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final Path rope = Path();
    rope.moveTo(start.dx, start.dy);
    rope.quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
    canvas.drawPath(rope, wire);

    const int lightCount = 18;
    for (int i = 0; i < lightCount; i++) {
      final double t = (i + 0.5) / lightCount;
      final double x = (1 - t) * (1 - t) * start.dx + 2 * (1 - t) * t * ctrl.dx + t * t * end.dx;
      final double y = (1 - t) * (1 - t) * start.dy + 2 * (1 - t) * t * ctrl.dy + t * t * end.dy;

      // Soft glow
      canvas.drawCircle(
        Offset(x, y + 2),
        5.5,
        Paint()..color = const Color(0x70FDE047),
      );
      // Center filament
      canvas.drawCircle(
        Offset(x, y + 2),
        2.2,
        Paint()..color = const Color(0xFFFFFBEB),
      );
    }
  }

  @override
  bool shouldRepaint(covariant VillageSchoolFairPainter oldDelegate) {
    return oldDelegate.isFairScene != isFairScene;
  }
}
