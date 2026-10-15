import 'package:flutter/material.dart';
import '../../design_system/nova_colors.dart';
import '../../design_system/nova_typography.dart';

/// Segmented dashed progress bar matching `Progress.png` visual specification.
/// Displays gold rounded dashes for completed steps and count or '✓ Done' label.
class NovaProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double dashWidth;
  final double dashHeight;

  const NovaProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
    this.dashWidth = 24.0,
    this.dashHeight = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllCompleted = currentStep >= totalSteps;

    return Semantics(
      label: isAllCompleted
          ? 'Completed all steps'
          : 'Step $currentStep of $totalSteps',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalSteps, (index) {
              final bool isFilled = index < currentStep;
              return Container(
                width: dashWidth,
                height: dashHeight,
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6.0),
                decoration: BoxDecoration(
                  color: isFilled ? NovaColors.gold : const Color(0xFFE5E2F4),
                  borderRadius: BorderRadius.circular(dashHeight / 2),
                ),
              );
            }),
          ),
          const SizedBox(width: 10),
          Text(
            isAllCompleted ? '✓ Done' : '$currentStep / $totalSteps',
            style: NovaTypography.caption.copyWith(
              color: NovaColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
