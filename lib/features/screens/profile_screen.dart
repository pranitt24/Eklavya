import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/nova_colors.dart';
import '../../core/design_system/nova_typography.dart';
import '../../core/design_system/nova_spacing.dart';
import '../../core/routing/orientation_helper.dart';
import '../../core/services/nova_audio_service.dart';
import '../../core/widgets/nova/nova_avatar.dart';
import '../../core/widgets/nova/nova_button.dart';
import '../../core/widgets/nova/nova_speaker_button.dart';
import '../../nova_main/demo/demo_controls.dart';
import '../../nova_main/services/app_state.dart';
import 'home_hub_screen.dart';

/// Screen 1: Profile screen (`assets/Potrait screens/Profile.png`).
/// Student profile builder ('माझी ओळख / My Profile') with avatar selector,
/// name input, age selector pills (5, 6, 7, 8), and continue CTA.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  int _selectedAge = 7;
  NovaAvatarType _selectedAvatar = NovaAvatarType.chintu;
  NovaSpeakerState _speakerState = NovaSpeakerState.listen;

  final List<int> _ageOptions = [5, 6, 7, 8];

  @override
  void initState() {
    super.initState();
    OrientationHelper.lockPortrait();
    _nameController = TextEditingController(text: 'आरव');
    NovaAudioService.instance.isPlayingNotifier.addListener(_onTtsStateChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    NovaAudioService.instance.isPlayingNotifier.removeListener(_onTtsStateChanged);
    super.dispose();
  }

  void _onTtsStateChanged() {
    if (mounted) {
      setState(() {
        _speakerState = NovaAudioService.instance.isPlaying
            ? NovaSpeakerState.playing
            : NovaSpeakerState.listen;
      });
    }
  }

  void _playPromptAudio() {
    NovaAudioService.instance.speak("चला, आपली ओळख करून घेऊया! Let's make this adventure yours.");
  }

  void _onSaveAndContinue() {
    final appState = AppStateScope.of(context);
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      appState.setStudentName(name);
    }
    // Navigate to Home hub
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeHubScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.cream,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'NOVA • MAJHE GAON',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: NovaColors.purple,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'माझी ओळख / My Profile',
                            style: NovaTypography.headingLarge,
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x10271C44),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.build_rounded, color: NovaColors.purple, size: 20),
                          tooltip: 'Demo Controls',
                          onPressed: () => DemoControlsSheet.show(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Prompt Banner
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: NovaColors.purpleLight,
                      borderRadius: NovaSpacing.roundedMd,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'चला, आपली ओळख करून घेऊया!',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: NovaColors.ink,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Let's make this adventure yours.",
                                style: NovaTypography.bodySecondary,
                              ),
                            ],
                          ),
                        ),
                        NovaSpeakerButton(
                          state: _speakerState,
                          onTap: _playPromptAudio,
                          size: 44,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Name Input
                  const Text(
                    'तुझे नाव / Your name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: NovaColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: NovaSpacing.roundedMd,
                      border: Border.all(color: NovaColors.purpleBorder.withValues(alpha: 0.6), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A271C44),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: NovaColors.ink,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'नाव लिहा...',
                              hintStyle: TextStyle(color: NovaColors.inkMuted),
                            ),
                          ),
                        ),
                        const Icon(Icons.edit_outlined, color: NovaColors.purple, size: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Age Selector Pills
                  const Text(
                    'तुझे वय / Your age',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: NovaColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _ageOptions.map((age) {
                      final bool isSelected = _selectedAge == age;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedAge = age);
                              NovaAudioService.instance.speak('$age वर्षे');
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              height: 64,
                              decoration: BoxDecoration(
                                color: isSelected ? NovaColors.gold : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? NovaColors.goldDark : const Color(0xFFE5E2F4),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(
                                          color: NovaColors.goldDark,
                                          offset: Offset(0, 4),
                                          blurRadius: 0,
                                        ),
                                      ]
                                    : const [
                                        BoxShadow(
                                          color: Color(0x0C271C44),
                                          offset: Offset(0, 3),
                                          blurRadius: 6,
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: Text(
                                  '$age',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: NovaColors.ink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 3. Avatar Selector
                  const Text(
                    'तुझा मित्र निवड / Pick your avatar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: NovaColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _buildAvatarCard(NovaAvatarType.chintu, 'Chintu'),
                      _buildAvatarCard(NovaAvatarType.meena, 'Meena'),
                      _buildAvatarCard(NovaAvatarType.nova, 'NOVA'),
                      _buildAvatarCard(NovaAvatarType.sheru, 'Sheru'),
                      _buildAvatarCard(NovaAvatarType.chiu, 'Chiu'),
                      _buildAvatarCard(NovaAvatarType.ganya, 'Ganya'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bottom CTA
                  NovaButton(
                    label: 'पुढे चला -> (Continue)',
                    variant: NovaButtonVariant.primary,
                    height: 56,
                    onPressed: _onSaveAndContinue,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(NovaAvatarType type, String label) {
    final bool isSelected = _selectedAvatar == type;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label avatar',
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedAvatar = type);
          NovaAudioService.instance.speak(label);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFEF3C7) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? NovaColors.gold : const Color(0xFFE5E2F4),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C271C44),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              NovaAvatar(
                type: type,
                size: 42,
                isSelected: false,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: NovaColors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
