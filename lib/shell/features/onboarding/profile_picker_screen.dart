import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/audio/sound_service.dart';
import '../../core/models/user_profile.dart';
import '../../core/widgets/squishy_button.dart';
import '../../theme.dart';

/// ProfilePickerScreen: Onboarding screen where the child enters their name,
/// chooses their age (5-8), and selects one of 6 fun companion avatars.
class ProfilePickerScreen extends StatefulWidget {
  const ProfilePickerScreen({super.key});

  @override
  State<ProfilePickerScreen> createState() => _ProfilePickerScreenState();
}

class _ProfilePickerScreenState extends State<ProfilePickerScreen> {
  late final TextEditingController _nameController;
  final UserProfile _profile = UserProfile.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profile.name);
    _nameController.addListener(() {
      _profile.setName(_nameController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onAgeSelected(int age) {
    setState(() {
      _profile.setAge(age);
    });
  }

  void _onAvatarSelected(String avatarId) {
    setState(() {
      _profile.setAvatar(avatarId);
    });
  }

  void _submitProfile() {
    if (_nameController.text.trim().isNotEmpty) {
      _profile.setName(_nameController.text.trim());
    }
    SoundService.instance.playDingChime();
    context.go('/diagnostic-test');
  }

  @override
  Widget build(BuildContext context) {
    final devanagariAges = {5: '५', 6: '६', 7: '७', 8: '८'};

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/screens/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
              children: [
                // Top Cloud Mascot Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: GameColors.inkGrape.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // NOVA Mini Peeker Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0F2FE),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/characters/nova.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/full_body_3d_pixar_style_cute_friendly_chubby_blue_robot_character_named_nova/screen.png',
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.android_rounded,
                                  color: GameColors.robotBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Speech Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'तुझी ओळख निवड! 🎈',
                                style: GameTypography.headline(
                                  color: GameColors.electricPurple,
                                ).copyWith(fontSize: 18),
                              ),
                              Text(
                                'Create your profile!',
                                style: GameTypography.buttonSublabel(
                                  color: GameColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Interactive Audio Speaker
                        SpeakerButton(
                          size: 42,
                          color: GameColors.electricPurple,
                          onPlay: () {
                            SoundService.instance.playDingChime();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Scrollable Configuration Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 6),

                        // 1. Name Input Field Card
                        _buildSectionHeader(
                          icon: Icons.edit_note_rounded,
                          titleDevanagari: 'तुझे नाव लिहा',
                          titleEnglish: 'Your Name',
                          accentColor: GameColors.electricPurple,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: GameColors.cardBorderLavender,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GameColors.electricPurple.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: GameTypography.displayHero(
                              color: GameColors.inkGrape,
                            ).copyWith(fontSize: 24),
                            decoration: InputDecoration(
                              icon: const Text('🏷️', style: TextStyle(fontSize: 22)),
                              border: InputBorder.none,
                              hintText: 'नाव येथे लिहा...',
                              hintStyle: GameTypography.bodyLarge(
                                color: GameColors.inkLight,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 2. Age Selector ("वय निवडा")
                        _buildSectionHeader(
                          icon: Icons.cake_rounded,
                          titleDevanagari: 'वय निवडा',
                          titleEnglish: 'Select Age',
                          accentColor: GameColors.activeGoldDark,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: UserProfile.availableAges.map((age) {
                            final isSelected = _profile.age == age;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: _buildAgeButton(
                                  age: age,
                                  devanagariNum: devanagariAges[age] ?? '$age',
                                  isSelected: isSelected,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // 3. Friend Avatar Picker ("मित्र निवडा")
                        _buildSectionHeader(
                          icon: Icons.face_rounded,
                          titleDevanagari: 'मित्र निवडा',
                          titleEnglish: 'Pick an Avatar',
                          accentColor: GameColors.emeraldGrassDark,
                        ),
                        const SizedBox(height: 10),

                        // 2x3 Avatar Grid
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: UserProfile.availableAvatars.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.95,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final avatar = UserProfile.availableAvatars[index];
                            final isSelected =
                                _profile.selectedAvatar == avatar.id;
                            return _buildAvatarCard(avatar, isSelected);
                          },
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom CTA Zone
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    border: const Border(
                      top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    ),
                  ),
                  child: Squishy3DButton(
                    height: 64,
                    backgroundColor: GameColors.electricPurple,
                    bevelColor: GameColors.electricPurpleDark,
                    label: 'पुढे चला! 🚀',
                    sublabel: 'CONTINUE TO DIAGNOSTIC ADVENTURE',
                    onPressed: _submitProfile,
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String titleDevanagari,
    required String titleEnglish,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          titleDevanagari,
          style: GameTypography.headline(color: GameColors.inkGrape)
              .copyWith(fontSize: 18),
        ),
        const SizedBox(width: 6),
        Text(
          '($titleEnglish)',
          style: GameTypography.buttonSublabel(color: GameColors.inkMuted),
        ),
      ],
    );
  }

  Widget _buildAgeButton({
    required int age,
    required String devanagariNum,
    required bool isSelected,
  }) {
    final bgColor = isSelected ? GameColors.activeGold : Colors.white;
    final bevelColor =
        isSelected ? GameColors.activeGoldDark : const Color(0xFFDDD6FE);
    final textColor = isSelected ? Colors.white : GameColors.inkGrape;

    return Squishy3DButton(
      height: 72,
      padding: EdgeInsets.zero,
      backgroundColor: bgColor,
      bevelColor: bevelColor,
      onPressed: () => _onAgeSelected(age),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                devanagariNum,
                style: GameTypography.displayHero(color: textColor).copyWith(
                  fontSize: 26,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$age yrs',
                style: GameTypography.buttonSublabel(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : GameColors.inkMuted,
                ),
              ),
            ],
          ),
          if (isSelected)
            const Positioned(
              top: -12,
              child: Text('👑', style: TextStyle(fontSize: 18)),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(AvatarItem avatar, bool isSelected) {
    return GestureDetector(
      onTap: () {
        SoundService.instance.playPopClick();
        _onAvatarSelected(avatar.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutQuad,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? GameColors.activeGold : Colors.transparent,
            width: isSelected ? 3.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? GameColors.activeGoldDark.withValues(alpha: 0.35)
                  : GameColors.inkGrape.withValues(alpha: 0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Character Portrait with Glow Ring
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        avatar.accentColor.withValues(alpha: 0.3),
                        avatar.accentColor,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Center(
                      child: avatar.id == 'chintu'
                          ? Image.asset(
                              'assets/images/characters/chintu.png',
                              fit: BoxFit.cover,
                              errorBuilder: (c1, e1, s1) =>
                                  Text(avatar.emoji, style: const TextStyle(fontSize: 36)),
                            )
                          : avatar.id == 'nova'
                              ? Image.asset(
                                  'assets/images/characters/nova.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (c2, e2, s2) => Text(
                                      avatar.emoji,
                                      style: const TextStyle(fontSize: 36)),
                                )
                              : Text(
                                  avatar.emoji,
                                  style: const TextStyle(fontSize: 38),
                                ),
                    ),
                  ),
                ),

                // Checkmark Badge when Selected
                if (isSelected)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: GameColors.emeraldGrass,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Name Labels
            Text(
              '${avatar.nameMarathi} ${avatar.emoji}',
              style: GameTypography.buttonLabel(
                color: isSelected
                    ? GameColors.electricPurple
                    : GameColors.inkGrape,
              ).copyWith(fontSize: 16),
            ),
            Text(
              avatar.nameEnglish,
              style: GameTypography.buttonSublabel(
                color: isSelected
                    ? GameColors.electricPurple
                    : GameColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
