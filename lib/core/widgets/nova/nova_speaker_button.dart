import 'package:flutter/material.dart';
import '../../design_system/nova_colors.dart';
import '../../design_system/nova_typography.dart';

enum NovaSpeakerState {
  listen,
  playing,
  mute,
}

/// Vernacular Audio/TTS playback button matching `Speaker.png` visual specification.
/// Supports Listen, Playing (active lavender ring), and Mute states with optional label.
class NovaSpeakerButton extends StatelessWidget {
  final NovaSpeakerState state;
  final VoidCallback onTap;
  final String? label;
  final double size;

  const NovaSpeakerButton({
    super.key,
    this.state = NovaSpeakerState.listen,
    required this.onTap,
    this.label,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;
    Border? border;
    IconData icon;

    switch (state) {
      case NovaSpeakerState.listen:
        bgColor = Colors.white;
        iconColor = NovaColors.purple;
        border = Border.all(color: NovaColors.purpleBorder.withValues(alpha: 0.5), width: 1.0);
        icon = Icons.volume_up_rounded;
        break;

      case NovaSpeakerState.playing:
        bgColor = NovaColors.purpleLight;
        iconColor = NovaColors.purple;
        border = Border.all(color: NovaColors.purple, width: 2.0);
        icon = Icons.volume_up_rounded;
        break;

      case NovaSpeakerState.mute:
        bgColor = Colors.white;
        iconColor = NovaColors.inkMuted;
        border = Border.all(color: const Color(0xFFE5E7EB), width: 1.0);
        icon = Icons.volume_off_rounded;
        break;
    }

    final double effectiveSize = size.clamp(32.0, 80.0);

    final Widget buttonCircle = Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14271C44),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: effectiveSize * 0.52,
          color: iconColor,
        ),
      ),
    );

    if (label == null) {
      return Semantics(
        button: true,
        label: state == NovaSpeakerState.playing ? 'Playing audio' : 'Listen audio',
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: buttonCircle,
        ),
      );
    }

    return Semantics(
      button: true,
      label: '$label audio button',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buttonCircle,
              const SizedBox(width: 8),
              Text(
                label!,
                style: NovaTypography.bodySecondary.copyWith(
                  fontWeight: FontWeight.w700,
                  color: state == NovaSpeakerState.mute ? NovaColors.inkMuted : NovaColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
