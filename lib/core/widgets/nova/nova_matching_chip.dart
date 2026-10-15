import 'package:flutter/material.dart';
import '../../design_system/nova_colors.dart';
import '../../design_system/nova_typography.dart';
import '../../design_system/nova_spacing.dart';

enum NovaMatchingChipState {
  defaultState,
  selected,
  pressed,
  correct,
  incorrect,
  completed,
}

enum ConnectionDotSide {
  left,
  right,
}

/// Bilingual interactive matching chip widget matching `Matching chip.png` spec.
/// Supports 6 explicit states with color outlines, checkmarks, state labels, and connection sockets.
class NovaMatchingChip extends StatelessWidget {
  final String text;
  final String subtitle;
  final Widget? leadingIcon;
  final NovaMatchingChipState state;
  final ConnectionDotSide dotSide;
  final VoidCallback? onTap;
  final GlobalKey? socketKey;

  const NovaMatchingChip({
    super.key,
    required this.text,
    required this.subtitle,
    this.leadingIcon,
    this.state = NovaMatchingChipState.defaultState,
    this.dotSide = ConnectionDotSide.right,
    this.onTap,
    this.socketKey,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = NovaColors.purpleBorder.withValues(alpha: 0.6);
    Color dotColor = NovaColors.inkMuted;
    bool isDotFilled = false;
    double borderWidth = 1.5;
    String displaySubtitle = subtitle;

    switch (state) {
      case NovaMatchingChipState.defaultState:
        bgColor = Colors.white;
        borderColor = const Color(0xFFE5E2F4);
        dotColor = const Color(0xFFD4D0E8);
        isDotFilled = false;
        break;

      case NovaMatchingChipState.selected:
        bgColor = const Color(0xFFF3E8FF);
        borderColor = NovaColors.purple;
        borderWidth = 2.5;
        dotColor = NovaColors.purple;
        isDotFilled = true;
        displaySubtitle = '• Selected • निवडले';
        break;

      case NovaMatchingChipState.pressed:
        bgColor = const Color(0xFFEDE9FE);
        borderColor = NovaColors.purple;
        borderWidth = 2.5;
        dotColor = NovaColors.purple;
        isDotFilled = true;
        displaySubtitle = '↓ Pressed • दाबले';
        break;

      case NovaMatchingChipState.correct:
        bgColor = const Color(0xFFE8F8F0);
        borderColor = NovaColors.goldDark;
        borderWidth = 2.5;
        dotColor = NovaColors.goldDark;
        isDotFilled = true;
        displaySubtitle = '✓ $subtitle';
        break;

      case NovaMatchingChipState.incorrect:
        bgColor = const Color(0xFFFFF1E8);
        borderColor = NovaColors.coral;
        borderWidth = 2.0;
        dotColor = NovaColors.coral;
        isDotFilled = false;
        displaySubtitle = '↺ Try another • पुन्हा बघ';
        break;

      case NovaMatchingChipState.completed:
        bgColor = const Color(0xFFE8F8F0);
        borderColor = NovaColors.goldDark;
        borderWidth = 2.5;
        dotColor = NovaColors.goldDark;
        isDotFilled = true;
        displaySubtitle = '✓ Completed • $subtitle';
        break;
    }

    final Widget socketWidget = Container(
      key: socketKey,
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: isDotFilled ? dotColor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: dotColor, width: 2.0),
      ),
    );

    return Semantics(
      button: true,
      label: '$text, $displaySubtitle',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: NovaSpacing.roundedMd,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A271C44),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              if (dotSide == ConnectionDotSide.left) ...[
                socketWidget,
                const SizedBox(width: 10),
              ],
              if (leadingIcon != null) ...[
                leadingIcon!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: NovaTypography.chipText.copyWith(
                        fontSize: 16,
                        color: NovaColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displaySubtitle,
                      style: NovaTypography.chipSubtitle.copyWith(
                        color: state == NovaMatchingChipState.selected
                            ? NovaColors.purple
                            : (state == NovaMatchingChipState.incorrect
                                ? NovaColors.coralDark
                                : (state == NovaMatchingChipState.correct ||
                                        state == NovaMatchingChipState.completed
                                    ? NovaColors.greenDark
                                    : NovaColors.inkSoft)),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (dotSide == ConnectionDotSide.right) ...[
                const SizedBox(width: 10),
                socketWidget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
