import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/mascot_mood.dart';
import 'mascot_widget.dart';

enum CharacterIdentity {
  nova,
  chintu,
  meena,
  sheru,
  chiu,
  ganya,
}

/// 100% Vector & Lottie-ready character component.
/// Strictly eliminates raster photo cutouts and blurry PNG screenshots.
/// Automatically supports custom Lottie files if added to `assets/lottie/`.
class NovaVectorCharacter extends StatelessWidget {
  final CharacterIdentity character;
  final double size;
  final String? customLottieAsset;
  final NovaMood mascotMood;
  final bool isSpeaking;

  const NovaVectorCharacter({
    super.key,
    required this.character,
    this.size = 100.0,
    this.customLottieAsset,
    this.mascotMood = NovaMood.happy,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    if (customLottieAsset != null) {
      return Lottie.asset(
        customLottieAsset!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildVectorGraphic(context),
      );
    }

    return _buildVectorGraphic(context);
  }

  Widget _buildVectorGraphic(BuildContext context) {
    switch (character) {
      case CharacterIdentity.nova:
        return Lottie.asset(
          'assets/lottie/Robot says hello.json',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => SizedBox(
            width: size,
            height: size,
            child: Center(
              child: MascotWidget(
                size: size,
                mood: mascotMood,
                speaking: isSpeaking,
                showGlow: true,
              ),
            ),
          ),
        );

      case CharacterIdentity.chintu:
        return Lottie.asset(
          'assets/lottie/Hand Waving Animation.json',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => CustomPaint(
            size: Size(size, size),
            painter: _ChintuVectorPainter(),
          ),
        );

      case CharacterIdentity.meena:
        return CustomPaint(
          size: Size(size, size),
          painter: _MeenaVectorPainter(),
        );

      case CharacterIdentity.sheru:
        return CustomPaint(
          size: Size(size, size),
          painter: _SheruVectorPainter(),
        );

      case CharacterIdentity.chiu:
        return Lottie.asset(
          'assets/lottie/Blue Bird.json',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => CustomPaint(
            size: Size(size, size),
            painter: _ChiuVectorPainter(),
          ),
        );

      case CharacterIdentity.ganya:
        return CustomPaint(
          size: Size(size, size),
          painter: _GanyaVectorPainter(),
        );
    }
  }
}

/// Vector Painter for Chintu: Cheerful rural Maharashtra schoolboy with traditional cap & joyful smile
class _ChintuVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);

    final Paint skinPaint = Paint()..color = const Color(0xFFF9C69D);
    final Paint hairPaint = Paint()..color = const Color(0xFF2C2420);
    final Paint capPaint = Paint()..color = Colors.white;
    final Paint capShadow = Paint()..color = const Color(0xFFE2E8F0);
    final Paint shirtPaint = Paint()..color = const Color(0xFF3B82F6);
    final Paint featurePaint = Paint()
      ..color = const Color(0xFF271C44)
      ..strokeWidth = w * 0.035
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint eyeFill = Paint()..color = const Color(0xFF1E1B4B);
    final Paint blushPaint = Paint()..color = const Color(0x38F43F5E);
    final Paint mouthPaint = Paint()..color = const Color(0xFFE11D48);

    // Shirt / Torso
    final Path shirtPath = Path()
      ..moveTo(w * 0.2, h * 0.95)
      ..quadraticBezierTo(w * 0.5, h * 0.78, w * 0.8, h * 0.95)
      ..lineTo(w * 0.85, h)
      ..lineTo(w * 0.15, h)
      ..close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Collar
    final Path collarPath = Path()
      ..moveTo(w * 0.38, h * 0.82)
      ..lineTo(w * 0.5, h * 0.92)
      ..lineTo(w * 0.62, h * 0.82);
    canvas.drawPath(
      collarPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035,
    );

    // Neck
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.75), width: w * 0.22, height: h * 0.18),
      skinPaint,
    );

    // Face / Head
    final Rect faceRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy * 0.95),
      width: w * 0.58,
      height: h * 0.56,
    );
    canvas.drawOval(faceRect, skinPaint);

    // Ears
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.20, h * 0.47), width: w * 0.12, height: h * 0.14),
      skinPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.80, h * 0.47), width: w * 0.12, height: h * 0.14),
      skinPaint,
    );

    // Hair fringes
    final Path hairPath = Path()
      ..moveTo(w * 0.22, h * 0.34)
      ..quadraticBezierTo(w * 0.35, h * 0.38, w * 0.5, h * 0.32)
      ..quadraticBezierTo(w * 0.65, h * 0.38, w * 0.78, h * 0.34)
      ..quadraticBezierTo(w * 0.5, h * 0.18, w * 0.22, h * 0.34);
    canvas.drawPath(hairPath, hairPaint);

    // Traditional White Cap (Topi)
    final Path capPath = Path()
      ..moveTo(w * 0.18, h * 0.30)
      ..quadraticBezierTo(w * 0.5, h * 0.18, w * 0.82, h * 0.30)
      ..lineTo(w * 0.78, h * 0.14)
      ..quadraticBezierTo(w * 0.5, h * 0.08, w * 0.22, h * 0.14)
      ..close();
    canvas.drawPath(capPath, capPaint);
    canvas.drawPath(
      capPath,
      Paint()
        ..color = capShadow.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02,
    );

    // Eyes
    canvas.drawCircle(Offset(w * 0.38, h * 0.45), w * 0.052, eyeFill);
    canvas.drawCircle(Offset(w * 0.62, h * 0.45), w * 0.052, eyeFill);
    // Eye shine
    canvas.drawCircle(Offset(w * 0.36, h * 0.43), w * 0.02, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.60, h * 0.43), w * 0.02, Paint()..color = Colors.white);

    // Cheerful Eyebrows
    final Path leftBrow = Path()
      ..moveTo(w * 0.32, h * 0.38)
      ..quadraticBezierTo(w * 0.38, h * 0.35, w * 0.44, h * 0.38);
    final Path rightBrow = Path()
      ..moveTo(w * 0.56, h * 0.38)
      ..quadraticBezierTo(w * 0.62, h * 0.35, w * 0.68, h * 0.38);
    canvas.drawPath(leftBrow, featurePaint);
    canvas.drawPath(rightBrow, featurePaint);

    // Blushing Cheeks
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.32, h * 0.52), width: w * 0.12, height: h * 0.07),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.68, h * 0.52), width: w * 0.12, height: h * 0.07),
      blushPaint,
    );

    // Big Happy Mouth
    final Path mouthPath = Path()
      ..moveTo(w * 0.40, h * 0.56)
      ..quadraticBezierTo(w * 0.5, h * 0.67, w * 0.60, h * 0.56)
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.39, h * 0.56)
        ..quadraticBezierTo(w * 0.5, h * 0.67, w * 0.61, h * 0.56),
      featurePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector Painter for Meena: Cheerful rural girl with bright red ribbon pigtails
class _MeenaVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);

    final Paint skinPaint = Paint()..color = const Color(0xFFF7BD93);
    final Paint hairPaint = Paint()..color = const Color(0xFF1E1B18);
    final Paint ribbonPaint = Paint()..color = const Color(0xFFE11D48);
    final Paint dressPaint = Paint()..color = const Color(0xFF10B981);
    final Paint eyeFill = Paint()..color = const Color(0xFF111827);
    final Paint featurePaint = Paint()
      ..color = const Color(0xFF271C44)
      ..strokeWidth = w * 0.035
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Hair Pigtails behind
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.18, h * 0.56), width: w * 0.18, height: h * 0.28),
      hairPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.82, h * 0.56), width: w * 0.18, height: h * 0.28),
      hairPaint,
    );

    // Ribbons
    canvas.drawCircle(Offset(w * 0.20, h * 0.44), w * 0.07, ribbonPaint);
    canvas.drawCircle(Offset(w * 0.80, h * 0.44), w * 0.07, ribbonPaint);

    // Dress / Shoulders
    final Path dressPath = Path()
      ..moveTo(w * 0.22, h * 0.95)
      ..quadraticBezierTo(w * 0.5, h * 0.80, w * 0.78, h * 0.95)
      ..lineTo(w * 0.85, h)
      ..lineTo(w * 0.15, h)
      ..close();
    canvas.drawPath(dressPath, dressPaint);

    // Neck
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.74), width: w * 0.20, height: h * 0.16),
      skinPaint,
    );

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy * 0.92), width: w * 0.56, height: h * 0.54),
      skinPaint,
    );

    // Front Hair Bangs
    final Path bangsPath = Path()
      ..moveTo(w * 0.22, h * 0.34)
      ..quadraticBezierTo(w * 0.5, h * 0.12, w * 0.78, h * 0.34)
      ..quadraticBezierTo(w * 0.65, h * 0.38, w * 0.5, h * 0.32)
      ..quadraticBezierTo(w * 0.35, h * 0.38, w * 0.22, h * 0.34);
    canvas.drawPath(bangsPath, hairPaint);

    // Bindi
    canvas.drawCircle(Offset(w * 0.5, h * 0.38), w * 0.03, Paint()..color = const Color(0xFFDC2626));

    // Big Sparkly Eyes
    canvas.drawCircle(Offset(w * 0.38, h * 0.46), w * 0.054, eyeFill);
    canvas.drawCircle(Offset(w * 0.62, h * 0.46), w * 0.054, eyeFill);
    canvas.drawCircle(Offset(w * 0.36, h * 0.44), w * 0.022, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.60, h * 0.44), w * 0.022, Paint()..color = Colors.white);

    // Smile
    final Path mouthPath = Path()
      ..moveTo(w * 0.42, h * 0.58)
      ..quadraticBezierTo(w * 0.5, h * 0.68, w * 0.58, h * 0.58);
    canvas.drawPath(mouthPath, featurePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector Painter for Sheru: Village golden puppy
class _SheruVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);

    final Paint coatPaint = Paint()..color = const Color(0xFFFBBF24);
    final Paint earPaint = Paint()..color = const Color(0xFFD97706);
    final Paint snoutPaint = Paint()..color = const Color(0xFFFEF3C7);
    final Paint nosePaint = Paint()..color = const Color(0xFF1F2937);

    // Floppy Puppy Ears
    final Path leftEar = Path()
      ..moveTo(w * 0.26, h * 0.26)
      ..quadraticBezierTo(w * 0.10, h * 0.42, w * 0.16, h * 0.62)
      ..quadraticBezierTo(w * 0.24, h * 0.60, w * 0.32, h * 0.38)
      ..close();
    final Path rightEar = Path()
      ..moveTo(w * 0.74, h * 0.26)
      ..quadraticBezierTo(w * 0.90, h * 0.42, w * 0.84, h * 0.62)
      ..quadraticBezierTo(w * 0.76, h * 0.60, w * 0.68, h * 0.38)
      ..close();
    canvas.drawPath(leftEar, earPaint);
    canvas.drawPath(rightEar, earPaint);

    // Head
    canvas.drawCircle(Offset(center.dx, center.dy * 0.92), w * 0.33, coatPaint);

    // Snout
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, h * 0.58), width: w * 0.34, height: h * 0.26),
      snoutPaint,
    );

    // Nose
    final Path nosePath = Path()
      ..moveTo(w * 0.45, h * 0.50)
      ..lineTo(w * 0.55, h * 0.50)
      ..quadraticBezierTo(w * 0.5, h * 0.57, w * 0.45, h * 0.50);
    canvas.drawPath(nosePath, nosePaint);

    // Puppy Eyes
    canvas.drawCircle(Offset(w * 0.36, h * 0.42), w * 0.052, nosePaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.42), w * 0.052, nosePaint);
    canvas.drawCircle(Offset(w * 0.34, h * 0.40), w * 0.02, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.62, h * 0.40), w * 0.02, Paint()..color = Colors.white);

    // Red Collar
    final Path collar = Path()
      ..moveTo(w * 0.26, h * 0.84)
      ..quadraticBezierTo(w * 0.5, h * 0.94, w * 0.74, h * 0.84);
    canvas.drawPath(
      collar,
      Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.06
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.91), w * 0.045, Paint()..color = const Color(0xFFF59E0B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector Painter for Chiu: Village Sparrow bird
class _ChiuVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint bodyPaint = Paint()..color = const Color(0xFF92400E);
    final Paint chestPaint = Paint()..color = const Color(0xFFFEF3C7);
    final Paint wingPaint = Paint()..color = const Color(0xFFB45309);
    final Paint beakPaint = Paint()..color = const Color(0xFFF59E0B);
    final Paint eyePaint = Paint()..color = const Color(0xFF1E293B);

    // Round Bird Body
    canvas.drawCircle(Offset(w * 0.48, h * 0.52), w * 0.34, bodyPaint);

    // Light Chest / Belly
    final Path belly = Path()
      ..moveTo(w * 0.32, h * 0.38)
      ..quadraticBezierTo(w * 0.18, h * 0.56, w * 0.38, h * 0.78)
      ..quadraticBezierTo(w * 0.58, h * 0.82, w * 0.66, h * 0.68)
      ..close();
    canvas.drawPath(belly, chestPaint);

    // Wing
    final Path wing = Path()
      ..moveTo(w * 0.50, h * 0.42)
      ..quadraticBezierTo(w * 0.76, h * 0.46, w * 0.80, h * 0.68)
      ..quadraticBezierTo(w * 0.62, h * 0.70, w * 0.48, h * 0.54)
      ..close();
    canvas.drawPath(wing, wingPaint);

    // Cute Little Beak
    final Path beak = Path()
      ..moveTo(w * 0.20, h * 0.46)
      ..lineTo(w * 0.06, h * 0.52)
      ..lineTo(w * 0.20, h * 0.56)
      ..close();
    canvas.drawPath(beak, beakPaint);

    // Big Bird Eye
    canvas.drawCircle(Offset(w * 0.30, h * 0.44), w * 0.06, eyePaint);
    canvas.drawCircle(Offset(w * 0.28, h * 0.42), w * 0.024, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector Painter for Ganya: Energetic rural friend
class _GanyaVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);

    final Paint skinPaint = Paint()..color = const Color(0xFFF5AF84);
    final Paint hairPaint = Paint()..color = const Color(0xFF18181B);
    final Paint shirtPaint = Paint()..color = const Color(0xFF10B981);
    final Paint featurePaint = Paint()
      ..color = const Color(0xFF271C44)
      ..strokeWidth = w * 0.035
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Curly Hair Tuft behind
    canvas.drawCircle(Offset(w * 0.5, h * 0.26), w * 0.36, hairPaint);

    // Torso / Green Kurta
    final Path shirtPath = Path()
      ..moveTo(w * 0.2, h * 0.95)
      ..quadraticBezierTo(w * 0.5, h * 0.78, w * 0.8, h * 0.95)
      ..lineTo(w * 0.85, h)
      ..lineTo(w * 0.15, h)
      ..close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy * 0.96), width: w * 0.56, height: h * 0.54),
      skinPaint,
    );

    // Big Mischievous Eyes
    canvas.drawCircle(Offset(w * 0.37, h * 0.46), w * 0.054, Paint()..color = const Color(0xFF09090B));
    canvas.drawCircle(Offset(w * 0.63, h * 0.46), w * 0.054, Paint()..color = const Color(0xFF09090B));
    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.02, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.61, h * 0.44), w * 0.02, Paint()..color = Colors.white);

    // Broad Grin with teeth
    final Path smile = Path()
      ..moveTo(w * 0.36, h * 0.58)
      ..quadraticBezierTo(w * 0.5, h * 0.72, w * 0.64, h * 0.58)
      ..close();
    canvas.drawPath(smile, Paint()..color = Colors.white);
    canvas.drawPath(smile, featurePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
