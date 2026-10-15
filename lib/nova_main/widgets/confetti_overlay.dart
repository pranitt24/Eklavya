import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';

/// Lightweight CustomPainter confetti burst (<= 60 particles) honoring Reduce Motion.
class ConfettiOverlay extends StatefulWidget {
  final bool play;
  final int particleCount;
  final Widget? child;

  const ConfettiOverlay({
    super.key,
    required this.play,
    this.particleCount = 50,
    this.child,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _initParticles();

    if (widget.play) {
      _controller.forward(from: 0.0);
    }
  }

  void _initParticles() {
    final colors = [
      AppColors.sunYellow,
      AppColors.mint,
      AppColors.purple,
      AppColors.sky,
      AppColors.coral,
    ];

    _particles = List.generate(min(60, widget.particleCount), (index) {
      return _ConfettiParticle(
        x: _random.nextDouble(),
        speedY: 0.6 + _random.nextDouble() * 0.8,
        speedX: (_random.nextDouble() - 0.5) * 0.4,
        size: 6.0 + _random.nextDouble() * 8.0,
        color: colors[index % colors.length],
        rotationSpeed: (_random.nextDouble() - 0.5) * 4.0,
      );
    });
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _initParticles();
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (widget.play)
          IgnorePointer(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Lottie.asset(
                  'assets/lottie/Confetti Effects Lottie Animation.json',
                  fit: BoxFit.cover,
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _ConfettiPainter(
                        particles: _particles,
                        progress: _controller.value,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double speedY;
  final double speedX;
  final double size;
  final Color color;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.speedY,
    required this.speedX,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    for (final p in particles) {
      final double currY = (progress * p.speedY * size.height) - 20;
      final double currX = (p.x * size.width) + (sin(progress * pi * 2 + p.x) * 40 * p.speedX);
      final double opacity = (1.0 - progress * 0.9).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currX, currY);
      canvas.rotate(progress * p.rotationSpeed * pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
