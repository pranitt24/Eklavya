import 'package:flutter/material.dart';
import '../../../core/services/haptics_service.dart';
import '../../../nova_main/theme/app_colors.dart';
import '../../../nova_main/theme/app_spacing.dart';
import '../../../nova_main/theme/app_text_styles.dart';

/// Accessibility toggle tile with icon, title, description, and preview text.
class AccessibilityToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? previewText;

  const AccessibilityToggle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.previewText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(
          color: value ? AppColors.indigo : AppColors.borderLight,
          width: value ? 2.0 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: value ? const Color(0xFFEEF2FF) : AppColors.softGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: value ? AppColors.indigo : AppColors.inkSoft,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelSoft.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.indigo,
                onChanged: (newVal) {
                  HapticsService.selectionClick();
                  onChanged(newVal);
                },
              ),
            ],
          ),
          if (previewText != null && value) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                previewText!,
                style: AppTextStyles.labelSoft.copyWith(fontSize: 12, color: AppColors.indigo),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Caption pill showing spoken text when Voice Instructions is ON.
class NovaSpeechCaption extends StatelessWidget {
  final String text;
  final bool visible;

  const NovaSpeechCaption({
    super.key,
    required this.text,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible || text.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xE61F2A6B), // 90% navy
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_up_rounded, color: AppColors.sunYellow, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gesture guide legend for Screen-Off mode and accessibility users.
class GestureLegend extends StatelessWidget {
  const GestureLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: const Text(
        'Swipe Right → Next  •  Swipe Left → Back\nDouble Tap → Select  •  Shake → Repeat',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFF1F5F9),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}
