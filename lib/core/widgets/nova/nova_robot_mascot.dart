import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Helper widget to compensate for the large internal transparent padding
/// inside `Robot says hello.json`, scaling the mascot so it renders
/// crisp, large, and properly proportioned.
class NovaRobotMascot extends StatelessWidget {
  final double size;
  final Alignment alignment;

  const NovaRobotMascot({
    super.key,
    this.size = 80,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Transform.scale(
          scale: 1.8,
          alignment: alignment,
          child: Lottie.asset(
            'assets/lottie/Robot says hello.json',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
