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
