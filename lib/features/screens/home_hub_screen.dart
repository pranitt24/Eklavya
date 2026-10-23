import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/nova_colors.dart';
import '../../core/design_system/nova_typography.dart';
import '../../core/design_system/nova_spacing.dart';
import '../../core/routing/boot_logic.dart';
import '../../core/routing/orientation_helper.dart';
import '../../core/services/nova_audio_service.dart';
import '../../core/widgets/nova/nova_avatar.dart';
import '../../core/widgets/nova/nova_button.dart';
import '../../core/widgets/nova/nova_speaker_button.dart';
import '../../core/widgets/nova/nova_robot_mascot.dart';
import '../../features/duel/duel_lobby_screen.dart';
import 'package:lottie/lottie.dart';
import '../../nova_main/demo/demo_controls.dart';
import '../accessibility/presentation/accessibility_settings_screen.dart';
import '../../nova_main/services/app_state.dart';
import 'class_selection_screen.dart';
import 'level_road_screen.dart';
import 'profile_screen.dart';

/// Screen 2: Home hub (`assets/Potrait screens/Home hub.png`).
/// Displays student greeting, streak & star badges, NOVA SAYS prompt banner,
/// Story Adventure card, Ganit Dangal card, and Bottom Navigation Bar.
class HomeHubScreen extends ConsumerStatefulWidget {
  const HomeHubScreen({super.key});

  @override
  ConsumerState<HomeHubScreen> createState() => _HomeHubScreenState();
}

class _HomeHubScreenState extends ConsumerState<HomeHubScreen> {
  int _currentNavIndex = 0;
  NovaSpeakerState _speakerState = NovaSpeakerState.listen;

  @override
  void initState() {
    super.initState();
    OrientationHelper.lockPortrait();
    NovaAudioService.instance.isPlayingNotifier.addListener(_onTtsStateChanged);
  }

  @override
  void dispose() {
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

  void _playNovaSaysAudio() {
    NovaAudioService.instance.speak("आज काय शिकायचे आहे? What shall we learn today?");
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final studentAsync = ref.watch(activeStudentProvider);

    final String studentName = studentAsync.maybeWhen(
      data: (s) => s.name.isNotEmpty ? s.name : appState.student.name,
      orElse: () => appState.student.name.isNotEmpty ? appState.student.name : 'आरव',
    );

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
                  // 1. Top Greeting Bar
                  Row(
                    children: [
                      NovaAvatar(
                        type: NovaAvatarType.chintu,
                        size: 56,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'नमस्कार, $studentName!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: NovaColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Center(
                                    child: Transform.scale(
                                      scale: 1.6,
                                      child: Lottie.asset(
                                        'assets/lottie/Animated Star Gold 3D Icon Loop.json',
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${appState.student.stars}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: NovaColors.ink,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('🔥', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 3),
                                Text(
                                  '${appState.student.streak} Days',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: NovaColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Evaluator Demo Controls Button
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
                          tooltip: 'Evaluator Demo Controls',
                          onPressed: () => DemoControlsSheet.show(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Accessibility Settings Button
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
                          icon: const Icon(Icons.accessibility_new_rounded, color: NovaColors.purple),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccessibilitySettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. NOVA Says Banner
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const NovaRobotMascot(size: 95),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
                              child: Text(
                                'NOVA SAYS...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: NovaColors.purple,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                                          'आज काय शिकायचे आहे?',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: NovaColors.ink,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'What shall we learn today?',
                                          style: NovaTypography.bodySecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  NovaSpeakerButton(
                                    state: _speakerState,
                                    onTap: _playNovaSaysAudio,
                                    size: 42,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'खेळूया, शिकूया!',
                        style: NovaTypography.headingLarge,
                      ),
                      Text(
                        'Your adventures',
                        style: NovaTypography.bodySecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Mode Card 1: Story Adventure (Teal/Emerald Gradient)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: NovaColors.storyAdventureGradient,
                      borderRadius: NovaSpacing.roundedCard,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x28059669),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: NovaSpacing.roundedCard,
                      child: Stack(
                        children: [
                          // Chintu Character on right aligned bottomRight so feet do not float
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Transform.scale(
                              scale: 1.25,
                              alignment: Alignment.bottomRight,
                              child: Lottie.asset(
                                'assets/lottie/Hand Waving Animation.json',
                                width: 140,
                                height: 140,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'EXPLORE • READ • PLAY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white70,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Story Adventure',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: NovaColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'चिंटूसोबत गावाची सफर',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 170,
                                  child: NovaButton(
                                    label: 'सुरू करा ->',
                                    variant: NovaButtonVariant.primary,
                                    height: 46,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ClassSelectionScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 5. Mode Card 2: Ganit Dangal (Orange/Purple Gradient)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: NovaColors.ganitDangalGradient,
                      borderRadius: NovaSpacing.roundedCard,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x28EC4899),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: NovaSpacing.roundedCard,
                      child: Stack(
                        children: [
                          // Mascot NOVA on right
                          const Positioned(
                            right: 14,
                            bottom: 12,
                            child: NovaRobotMascot(size: 130),
                          ),
                          // Content
                          Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'COUNT • THINK • WIN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white70,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ganit Dangal',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: NovaColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'खेळता खेळता गणित!',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 200,
                                child: NovaButton(
                                  label: 'दंगल सुरू करा 🥊',
                                  variant: NovaButtonVariant.secondary,
                                  height: 46,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const DuelLobbyScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Demo button moved to top header
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E2F4), width: 1.5)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0C271C44),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentNavIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentNavIndex = index;
            });
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LevelRoadScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }
          },
          backgroundColor: Colors.white,
          indicatorColor: NovaColors.purpleLight,
          height: 68,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: NovaColors.inkSoft),
              selectedIcon: Icon(Icons.home_rounded, color: NovaColors.purple, size: 28),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined, color: NovaColors.inkSoft),
              selectedIcon: Icon(Icons.emoji_events_rounded, color: NovaColors.gold, size: 28),
              label: 'Trophies',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: NovaColors.inkSoft),
              selectedIcon: Icon(Icons.settings_rounded, color: NovaColors.purple, size: 28),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
