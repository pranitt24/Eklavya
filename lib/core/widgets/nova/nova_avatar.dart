import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../design_system/nova_colors.dart';
import 'nova_vector_character.dart';

enum NovaAvatarType {
  chintu,
  nova,
  meena,
  sheru,
  chiu,
  ganya,
}

/// Circular character avatar matching `Avatar.png` visual specification.
/// Features 100% vector / Lottie graphics with no blurry photo cutouts.
class NovaAvatar extends StatelessWidget {
  final NovaAvatarType type;
  final double size;
  final bool isSelected;
  final bool isPurpleBorder;
  final VoidCallback? onTap;
  final String? customLottiePath;

  const NovaAvatar({
    super.key,
    required this.type,
    this.size = 80.0,
    this.isSelected = false,
    this.isPurpleBorder = false,
    this.onTap,
    this.customLottiePath,
  });

  CharacterIdentity get characterIdentity {
    switch (type) {
      case NovaAvatarType.chintu:
        return CharacterIdentity.chintu;
      case NovaAvatarType.nova:
        return CharacterIdentity.nova;
      case NovaAvatarType.meena:
        return CharacterIdentity.meena;
      case NovaAvatarType.sheru:
        return CharacterIdentity.sheru;
      case NovaAvatarType.chiu:
        return CharacterIdentity.chiu;
      case NovaAvatarType.ganya:
        return CharacterIdentity.ganya;
    }
  }

  Color get backgroundColor {
    switch (type) {
      case NovaAvatarType.chintu:
        return const Color(0xFFFEF3C7);
      case NovaAvatarType.nova:
        return const Color(0xFFEDE9FE);
      case NovaAvatarType.meena:
        return const Color(0xFFFFE4E6);
      case NovaAvatarType.sheru:
        return const Color(0xFFFEF9C3);
      case NovaAvatarType.chiu:
        return const Color(0xFFE0F2FE);
      case NovaAvatarType.ganya:
        return const Color(0xFFDCFCE7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isSelected
        ? NovaColors.purple
        : (isPurpleBorder ? NovaColors.purple : NovaColors.gold);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: size > 60 ? 3.5 : 2.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14271C44),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Center(
                  child: type == NovaAvatarType.chintu
                      ? Transform.scale(
                          scale: 1.9,
                          alignment: Alignment.topCenter,
                          child: Lottie.asset(
                            'assets/lottie/Hand Waving Animation.json',
                            width: size,
                            height: size,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => NovaVectorCharacter(
                              character: characterIdentity,
                              size: size * 0.74,
                              customLottieAsset: customLottiePath,
                            ),
                          ),
                        )
                      : NovaVectorCharacter(
                          character: characterIdentity,
                          size: size * 0.74,
                          customLottieAsset: customLottiePath,
                        ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: size * 0.32,
                  height: size * 0.32,
                  decoration: BoxDecoration(
                    color: NovaColors.purple,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2E000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: size * 0.20,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
