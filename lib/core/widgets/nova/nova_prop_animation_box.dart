import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Standardized animation wrapper for Quiz option cards and Matching chips.
/// Automatically applies per-asset scale factor so animations are properly
/// proportioned without clipping or appearing too small.
class NovaPropAnimationBox extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final double? customScale;
  final bool isBigVsSmall;
  final BoxFit fit;

  const NovaPropAnimationBox({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.customScale,
    this.isBigVsSmall = false,
    this.fit = BoxFit.contain,
  });

  /// Automatically applies the exact per-asset scale factors
  static double getScaleFor(String assetPath, {bool isBigVsSmall = false}) {
    if (assetPath.contains('Robot says hello')) return 1.75;
    if (assetPath.contains('tractor')) return isBigVsSmall ? 2.0 : 1.55;
    if (assetPath.contains('Eda region 1')) return 1.35;
    if (assetPath.contains('Mango Tree Animation')) return 1.25;
    if (assetPath.contains('Cute Tiger')) return 1.30;
    if (assetPath.contains('cow')) return 1.35;
    if (assetPath.contains('Blue Bird')) return 1.20;
    if (assetPath.contains('weighing_scale')) return 1.30;
    if (assetPath.contains('farmer_waving')) return 1.25;
    if (assetPath.contains('bicycle')) return isBigVsSmall ? 1.40 : 1.20;
    if (assetPath.contains('piggy_bank')) return 1.30;
    if (assetPath.contains('fruit_basket')) return 1.25;
    if (assetPath.contains('food stall')) return 1.15;
    if (assetPath.contains('bus')) return isBigVsSmall ? 1.50 : 1.25;
    if (assetPath.contains('school_bag')) return 1.20;
    if (assetPath.contains('triangle')) return 1.20;
    if (assetPath.contains('square')) return 1.20;
    if (assetPath.contains('rectangle')) return 1.20;
    if (assetPath.contains('circle')) return 1.20;
    if (assetPath.contains('ferris_wheel')) return 1.15;
    if (assetPath.contains('balloons')) return 1.20;
    if (assetPath.contains('trophy')) return 1.25;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final double scale = customScale ?? getScaleFor(assetPath, isBigVsSmall: isBigVsSmall);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Transform.scale(
          scale: scale,
          child: Lottie.asset(
            assetPath,
            width: width,
            height: height,
            fit: fit,
          ),
        ),
      ),
    );
  }
}
