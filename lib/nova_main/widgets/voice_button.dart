import 'dart:math';
import 'package:flutter/material.dart';
import '../services/haptics_service.dart';
import '../services/voice_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Circular 88dp interactive mic button with animated concentric ripples and live waveform.
class VoiceButton extends StatefulWidget {
  final VoiceRecognitionState state;
  final VoidCallback onTap;
  final double size;

  const VoiceButton({
    super.key,
    required this.state,
    required this.onTap,
    this.size = 88.0,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isListening = widget.state == VoiceRecognitionState.listening;
    final bool isProcessing = widget.state == VoiceRecognitionState.processing;

    String caption;
    switch (widget.state) {
      case VoiceRecognitionState.listening:
        caption = "I'm listening…";
        break;
      case VoiceRecognitionState.processing:
        caption = 'Processing…';
        break;
      case VoiceRecognitionState.recognized:
        caption = 'Recognized!';
        break;
      case VoiceRecognitionState.error:
        caption = 'Let\'s try again';
        break;
      case VoiceRecognitionState.idle:
        caption = 'Tap and say your answer';
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            HapticsService.lightImpact();
            widget.onTap();
          },
          child: SizedBox(
            width: widget.size + 40,
            height: widget.size + 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Expanding concentric ripple rings when listening
                if (isListening)
                  AnimatedBuilder(
                    animation: _rippleController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(widget.size + 40, widget.size + 40),
                        painter: _RipplePainter(progress: _rippleController.value),
                      );
                    },
                  ),
                // Main round mic button
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isListening
                        ? AppColors.purpleSkyGradient
                        : AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: (isListening ? AppColors.purple : AppColors.navy)
                            .withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isProcessing
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : isListening
                          ? _buildWaveform()
                          : const Icon(
                              Icons.mic_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          caption,
          style: AppTextStyles.labelSoft.copyWith(
            color: isListening ? AppColors.indigo : AppColors.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveformController,
      builder: (context, child) {
        final t = _waveformController.value;
        const heights = [14.0, 26.0, 36.0, 24.0, 18.0];

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final double factor = sin((t * pi) + (index * 0.7)).abs();
            final double h = max(8.0, heights[index] * factor);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 4.5,
              height: h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;

  _RipplePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final double ringProgress = (progress + (i * 0.33)) % 1.0;
      final double radius = 35 + ringProgress * (maxRadius - 35);
      final double opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.35;

      final paint = Paint()
        ..color = AppColors.sky.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) => oldDelegate.progress != progress;
}
