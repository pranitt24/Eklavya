import 'package:flutter/material.dart';
import '../../design_system/nova_colors.dart';
import '../../design_system/nova_typography.dart';
import '../../design_system/nova_spacing.dart';
import '../../../nova_main/widgets/mascot_widget.dart';
import '../../../nova_main/models/story_beat.dart';
import 'nova_button.dart';

enum NovaQuizFeedbackType {
  correct,
  retry,
}

/// Quiz feedback card widget matching `Quiz feedback.png` visual specification.
/// Renders affirmative green card for success and gentle peach card for retry without timers or penalties.
class NovaQuizFeedbackCard extends StatelessWidget {
  final NovaQuizFeedbackType type;
  final String heading;
  final String bodyTitle;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final bool showStars;

  const NovaQuizFeedbackCard({
    super.key,
    required this.type,
    required this.heading,
    required this.bodyTitle,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    this.showStars = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = type == NovaQuizFeedbackType.correct;
    final Color bgColor = isCorrect ? const Color(0xFFE8F8F0) : const Color(0xFFFFF1E8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NovaSpacing.lg, vertical: NovaSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: NovaSpacing.roundedCard,
        boxShadow: NovaSpacing.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated Vector Mascot
          MascotWidget(
            size: 64,
            mood: isCorrect ? NovaMood.celebrating : NovaMood.thinking,
            speaking: true,
          ),
          const SizedBox(height: 10),

          // 3 Stars on celebration
          if (showStars && isCorrect) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star_rounded, color: NovaColors.gold, size: 28),
                SizedBox(width: 4),
                Icon(Icons.star_rounded, color: NovaColors.gold, size: 34),
                SizedBox(width: 4),
                Icon(Icons.star_rounded, color: NovaColors.gold, size: 28),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Heading
          Text(
            heading,
            style: NovaTypography.headingLarge.copyWith(
              color: isCorrect ? NovaColors.green : NovaColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Body title
          Text(
            bodyTitle,
            style: NovaTypography.headingSmall.copyWith(
              color: NovaColors.ink,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Subtitle / English translation
          Text(
            subtitle,
            style: NovaTypography.bodySecondary.copyWith(
              color: NovaColors.inkSoft,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NovaSpacing.lg),

          // Action Button
          NovaButton(
            label: actionLabel,
            variant: isCorrect ? NovaButtonVariant.primary : NovaButtonVariant.retry,
            onPressed: onAction,
            height: 48,
          ),
        ],
      ),
    );
  }
}
