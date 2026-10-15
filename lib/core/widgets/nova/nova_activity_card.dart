import 'package:flutter/material.dart';
import '../../design_system/nova_colors.dart';
import '../../design_system/nova_typography.dart';
import '../../design_system/nova_spacing.dart';
import 'nova_button.dart';

/// Activity card widget matching `Activity card.png` specification.
/// Supports both Unlocked and Completed visual states.
class NovaActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onAction;
  final bool isCompleted;
  final String? imageAsset;

  const NovaActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onAction,
    this.isCompleted = false,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isCompleted ? NovaColors.green : NovaColors.purpleBorder;
    final Color bgColor = isCompleted ? const Color(0xFFF0FDF4) : Colors.white;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: NovaSpacing.roundedCard,
        border: Border.all(color: borderColor, width: isCompleted ? 2.0 : 1.5),
        boxShadow: NovaSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Village artwork header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackHeader(),
                    )
                  : _buildFallbackHeader(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(NovaSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NovaTypography.headingMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: NovaTypography.bodySecondary.copyWith(
                    color: isCompleted ? NovaColors.greenDark : NovaColors.inkSoft,
                    fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: NovaSpacing.md),
                NovaButton(
                  label: buttonLabel,
                  variant: isCompleted ? NovaButtonVariant.gold : NovaButtonVariant.primary,
                  onPressed: onAction,
                  height: 48,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade200,
            Colors.green.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.cottage_rounded,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }
}
