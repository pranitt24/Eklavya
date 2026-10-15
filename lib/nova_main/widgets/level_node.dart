import 'dart:math';
import 'package:flutter/material.dart';
import '../models/level_model.dart';
import '../models/story_beat.dart';
import '../services/haptics_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'mascot_widget.dart';

/// Interactive node on the winding Adventure Map with 5 visual states and animations.
class LevelNode extends StatefulWidget {
  final LevelModel level;
  final LevelState state;
  final bool isRecommended;
  final VoidCallback onTap;

  const LevelNode({
    super.key,
    required this.level,
    required this.state,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  State<LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<LevelNode> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _wobbleController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _wobbleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.state == LevelState.locked) {
      HapticsService.lightImpact();
      _wobbleController.forward(from: 0.0);

      // Friendly locked prompt toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Finish the level before this one first! 🌟'),
          backgroundColor: AppColors.navy,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    HapticsService.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrent = widget.state == LevelState.current;
    final bool isCompleted = widget.state == LevelState.completed;
    final bool isAvailable = widget.state == LevelState.available;
    final bool isLocked = widget.state == LevelState.locked;

    // Node size (milestone levels 5, 10, 15 are slightly bigger)
    final bool isMilestone = widget.level.number % 5 == 0;
    final double nodeDiameter = isCurrent ? 86.0 : (isMilestone ? 78.0 : 70.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _wobbleController]),
      builder: (context, child) {
        final wobbleAngle = sin(_wobbleController.value * pi * 4) * 0.12;

        return Transform.rotate(
          angle: wobbleAngle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "You are here" tag or Recommended badge
              if (isCurrent)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.sunYellow,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppSpacing.softShadow,
                  ),
                  child: const Text(
                    'You are here 📍',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                )
              else if (widget.isRecommended && !isCompleted)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.sunYellow,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppSpacing.softShadow,
                  ),
                  child: const Text(
                    '⭐ Recommended',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),

              // Main Circular Node
              GestureDetector(
                onTap: _handleTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Glow ring for current level
                    if (isCurrent)
                      Container(
                        width: nodeDiameter + 18 * _glowController.value,
                        height: nodeDiameter + 18 * _glowController.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.sunYellow.withValues(alpha: 0.8 - _glowController.value * 0.4),
                            width: 3.5,
                          ),
                        ),
                      ),

                    // Base circle
                    Container(
                      width: nodeDiameter,
                      height: nodeDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getNodeBgColor(widget.state),
                        border: Border.all(
                          color: _getNodeBorderColor(widget.state),
                          width: isCurrent ? 3.5 : 2.5,
                        ),
                        boxShadow: isCurrent ? AppSpacing.glowShadow : AppSpacing.softShadow,
                      ),
                      alignment: Alignment.center,
                      child: isLocked
                          ? const Icon(Icons.lock_rounded, color: AppColors.disabledGrey, size: 28)
                          : Text(
                              widget.level.emoji,
                              style: TextStyle(fontSize: isMilestone ? 36 : 30),
                            ),
                    ),

                    // Mini NOVA token peeking over current node
                    if (isCurrent)
                      const Positioned(
                        top: -24,
                        right: -10,
                        child: MascotWidget(
                          size: 44,
                          mood: NovaMood.excited,
                        ),
                      ),

                    // Check badge for completed
                    if (isCompleted)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.mint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                        ),
                      ),

                    // "Replay" chip for available
                    if (isAvailable && !isCompleted && !isCurrent)
                      Positioned(
                        bottom: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.sky,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Replay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              // Stars earned (for completed) or level topic label
              if (isCompleted)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (starIdx) {
                    final bool earned = starIdx < widget.level.earnedStars;
                    return Icon(
                      Icons.star_rounded,
                      color: earned ? AppColors.sunYellow : AppColors.disabledGrey,
                      size: 16,
                    );
                  }),
                )
              else
                Text(
                  'Lvl ${widget.level.number}',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? AppColors.disabledGrey : AppColors.navy,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getNodeBgColor(LevelState state) {
    switch (state) {
      case LevelState.completed:
        return const Color(0xFFE8FBF4);
      case LevelState.current:
        return Colors.white;
      case LevelState.available:
        return const Color(0xFFF0F8FF);
      case LevelState.locked:
        return const Color(0xFFECEEF5);
    }
  }

  Color _getNodeBorderColor(LevelState state) {
    switch (state) {
      case LevelState.completed:
        return AppColors.mint;
      case LevelState.current:
        return AppColors.sunYellow;
      case LevelState.available:
        return AppColors.sky;
      case LevelState.locked:
        return AppColors.borderLight;
    }
  }
}
