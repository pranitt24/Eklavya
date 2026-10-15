import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:majhe_gaon/core/routing/boot_logic.dart';
import 'package:majhe_gaon/features/screens/class_selection_screen.dart';
import 'package:majhe_gaon/features/duel/duel_lobby_screen.dart';

import '../../demo/demo_fab.dart';
import '../../models/accessibility_settings.dart';
import '../../models/story_beat.dart';
import '../../routes/app_routes.dart';
import '../../services/app_state.dart';
import '../../services/haptics_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/mascot_widget.dart';
import '../../widgets/offline_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/speech_bubble.dart';

/// Welcome screen welcoming the child explorer with animated NOVA and audio help options.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  NovaMood _currentMood = NovaMood.excited;
  bool _showAudioBubble = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _currentMood = NovaMood.happy;
        });
      }
    });
  }

  void _onAudioHelpPressed(AppState appState) async {
    HapticsService.mediumImpact();
    // Turn on Voice Instructions + Haptics + Large Text
    appState.updateAccessibility(AccessibilitySettings.audioAssisted());

    setState(() {
      _showAudioBubble = true;
      _currentMood = NovaMood.encouraging;
    });

    final flutterTts = FlutterTts();
    await flutterTts.setLanguage("mr-IN");
    await flutterTts.speak('ठीक आहे! मी तुम्हाला सर्व काही सांगेन.');

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.studentSetup);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final bool isSpeaking = appState.accessibility.voiceInstructions;

    final studentAsync = ref.watch(activeStudentProvider);
    final studentName = studentAsync.maybeWhen(
      data: (student) => student.name,
      orElse: () => 'Nikhil',
    );

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Large floating NOVA mascot (~180)
                      MascotWidget(
                        size: 175,
                        mood: _currentMood,
                        speaking: isSpeaking || _showAudioBubble,
                        showGlow: true,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Optional Audio Help confirmation speech bubble
                      if (_showAudioBubble) ...[
                        const SpeechBubble(
                          text: 'ठीक आहे! मी तुम्हाला सर्व काही सांगेन.',
                          speaker: 'NOVA',
                          typewriter: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Greetings
                      Text(
                        'नमस्कार, $studentName!',
                        style: AppTextStyles.headingLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'नवीन काहीतरी शिकायला तयार आहात?',
                        style: AppTextStyles.bodySoft,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ▶ Primary Action: [ Let's Begin ]
                      PrimaryButton(
                        label: 'चला सुरू करूया',
                        icon: Icons.rocket_launch_rounded,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ClassSelectionScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Ganit Dangal Button
                      PrimaryButton(
                        label: 'गणित दंगल (Ganit Dangal)',
                        icon: Icons.emoji_events_rounded,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DuelLobbyScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Secondary Action: [ 🔊 I Need Audio Help ]
                      SecondaryButton(
                        label: '🔊 मला ऑडिओ मदत हवी आहे',
                        onPressed: () => _onAudioHelpPressed(appState),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Offline status message
                      const OfflineBadge(),
                      const SizedBox(height: 6),
                      Text(
                        'तुम्हाला जे काही हवे आहे ते तुमच्या डिव्हाइसवरच आहे.',
                        style: AppTextStyles.labelSoft.copyWith(fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const DemoFab(),
        ],
      ),
    );
  }
}
