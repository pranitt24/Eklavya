import 'package:flutter/material.dart';
import '../../design_system/nova_colors.dart';
import '../../design_system/nova_typography.dart';
import '../../design_system/nova_spacing.dart';
import '../../../nova_main/widgets/mascot_widget.dart';
import '../../../nova_main/models/story_beat.dart';
import 'nova_button.dart';

/// Pause and exit reassurance dialog matching `Modal.png` visual specification.
/// Features bilingual reassurance copy, robot mascot, and Resume / Home choices.
class NovaPauseModal extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onHome;

  const NovaPauseModal({
    super.key,
    required this.onResume,
    required this.onHome,
  });

  static Future<bool?> show(BuildContext context, {
    required VoidCallback onResume,
    required VoidCallback onHome,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      builder: (ctx) => Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: NovaPauseModal(
              onResume: () {
                Navigator.of(ctx).pop(false);
                onResume();
              },
              onHome: () {
                Navigator.of(ctx).pop(true);
                onHome();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        padding: const EdgeInsets.all(NovaSpacing.lg),
        decoration: BoxDecoration(
          color: NovaColors.cream,
          borderRadius: NovaSpacing.roundedModal,
          border: Border.all(color: const Color(0xFFDCD8E8), width: 8.0),
          boxShadow: NovaSpacing.modalShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Vector Mascot
                const MascotWidget(
                  size: 54,
                  mood: NovaMood.happy,
                  speaking: false,
                ),
                const SizedBox(width: NovaSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'थोडी विश्रांती घेऊया?',
                        style: NovaTypography.headingMedium,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Take a little break? Your progress is safe.',
                        style: NovaTypography.bodySecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: NovaSpacing.md),
            const Text(
              'तयार झाल्यावर पुन्हा खेळूया!',
              style: NovaTypography.bodyLarge,
            ),
            const SizedBox(height: NovaSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: NovaButton(
                    label: 'खेळूया • Resume',
                    variant: NovaButtonVariant.primary,
                    onPressed: onResume,
                    height: 52,
                  ),
                ),
                const SizedBox(width: NovaSpacing.md),
                Expanded(
                  child: NovaButton(
                    label: 'घरी जाऊ • Home',
                    variant: NovaButtonVariant.secondary,
                    onPressed: onHome,
                    height: 52,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
