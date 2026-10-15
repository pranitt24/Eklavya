import 'package:flutter/material.dart';
import '../models/answer_option.dart';
import '../services/haptics_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'fraction_visual.dart';
import 'shape_visual.dart';

/// Large, accessible answer option card with visual support, distinct icons, and gentle feedback.
class AnswerOptionWidget extends StatefulWidget {
  final AnswerOptionModel option;
  final OptionState state;
  final VoidCallback onTap;
  final int? index;

  const AnswerOptionWidget({
    super.key,
    required this.option,
    required this.state,
    required this.onTap,
    this.index,
  });

  @override
  State<AnswerOptionWidget> createState() => _AnswerOptionWidgetState();
}

class _AnswerOptionWidgetState extends State<AnswerOptionWidget> with SingleTickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.state == OptionState.disabled) return;
    HapticsService.lightImpact();
    _popController.forward().then((_) => _popController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;
    Widget statusIcon;

    switch (widget.state) {
      case OptionState.correct:
        borderColor = AppColors.mint;
        backgroundColor = const Color(0xFFE8FBF4);
        statusIcon = Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.mint,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
        );
        break;

      case OptionState.gentleTryAgain:
        borderColor = AppColors.coral;
        backgroundColor = const Color(0xFFFFF1F0);
        statusIcon = Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.loop_rounded, color: AppColors.coral, size: 20),
        );
        break;

      case OptionState.selected:
        borderColor = AppColors.indigo;
        backgroundColor = const Color(0xFFF0F2FF);
        statusIcon = Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.indigo,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
        );
        break;

      case OptionState.disabled:
        borderColor = AppColors.borderLight;
        backgroundColor = AppColors.softGrey.withValues(alpha: 0.6);
        statusIcon = const SizedBox(width: 34);
        break;

      case OptionState.idle:
        borderColor = AppColors.borderLight;
        backgroundColor = Colors.white;
        statusIcon = Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.softGrey,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.index != null ? String.fromCharCode(65 + widget.index!) : '•',
            style: AppTextStyles.label.copyWith(color: AppColors.inkSoft, fontWeight: FontWeight.bold),
          ),
        );
        break;
    }

    return Semantics(
      button: true,
      label: widget.option.semanticLabel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: AppSpacing.minOptionHeight),
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppSpacing.roundedCard,
              border: Border.all(color: borderColor, width: 2.2),
              boxShadow: widget.state == OptionState.selected || widget.state == OptionState.correct
                  ? AppSpacing.softShadow
                  : null,
            ),
            child: Row(
              children: [
                statusIcon,
                const SizedBox(width: AppSpacing.md),
                // Visual presentation if present (fractions, shapes, pizza)
                if (widget.option.visualType != VisualType.none) ...[
                  _buildOptionVisual(widget.option),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(
                    widget.option.label,
                    style: AppTextStyles.questionText.copyWith(
                      fontSize: 21,
                      color: widget.state == OptionState.disabled
                          ? AppColors.disabledGrey
                          : AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionVisual(AnswerOptionModel opt) {
    if (opt.visualType == VisualType.fractionCircles ||
        opt.visualType == VisualType.fractionBars ||
        opt.visualType == VisualType.pizza) {
      return FractionVisual(
        fractionStr: opt.visualData ?? '1/2',
        type: opt.visualType,
        size: 52,
      );
    } else if (opt.visualType == VisualType.customShapes) {
      return ShapeVisual(
        shape: opt.visualData ?? 'square',
        size: 46,
      );
    }
    return const SizedBox.shrink();
  }
}
