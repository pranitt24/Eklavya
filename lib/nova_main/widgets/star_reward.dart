import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Animated star count-up reward with pop effect.
class StarReward extends StatefulWidget {
  final int stars;
  final bool animated;
  final VoidCallback? onCompleted;

  const StarReward({
    super.key,
    required this.stars,
    this.animated = true,
    this.onCompleted,
  });

  @override
  State<StarReward> createState() => _StarRewardState();
}

class _StarRewardState extends State<StarReward> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _countAnimation = Tween<double>(begin: 0.0, end: widget.stars.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted?.call();
        }
      });

    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (context, child) {
        final currentCount = _countAnimation.value.toInt();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: AppSpacing.roundedChip,
            border: Border.all(color: AppColors.sunYellow, width: 2.0),
            boxShadow: AppSpacing.softShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/Animated Star Gold 3D Icon Loop.json',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.star_rounded, color: AppColors.sunYellow, size: 36),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '+$currentCount Stars',
                style: AppTextStyles.headingMedium.copyWith(
                  color: const Color(0xFFB45309),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Horizontal Understanding Map bar with positive-only feedback labels and min 12% fill.
class SkillBar extends StatefulWidget {
  final String label;
  final String emoji;
  final double mastery; // 0.0 to 1.0
  final int animationDelayMs;

  const SkillBar({
    super.key,
    required this.label,
    required this.emoji,
    required this.mastery,
    this.animationDelayMs = 0,
  });

  @override
  State<SkillBar> createState() => _SkillBarState();
}

class _SkillBarState extends State<SkillBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    // Min visible fill 12% so no bar looks empty or discouraging
    final targetFill = widget.mastery.clamp(0.12, 1.0);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: targetFill).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: widget.animationDelayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _statusLabel {
    if (widget.mastery >= 0.8) {
      return 'Super strong 🌟';
    } else if (widget.mastery >= 0.5) {
      return 'Growing 🌱';
    } else {
      return 'Ready to explore 🔭';
    }
  }

  Color get _fillColor {
    if (widget.mastery >= 0.8) {
      return AppColors.sunYellow;
    } else if (widget.mastery >= 0.5) {
      return AppColors.mint;
    } else {
      return AppColors.sky;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text(widget.label, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                _statusLabel,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.indigo,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 16,
              color: AppColors.softGrey,
              child: AnimatedBuilder(
                animation: _fillAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _fillAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _fillColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
