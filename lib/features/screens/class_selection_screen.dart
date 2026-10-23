import 'package:flutter/material.dart';
import '../../core/design_system/nova_colors.dart';
import '../../core/design_system/nova_typography.dart';
import '../../core/design_system/nova_spacing.dart';
import '../../core/routing/orientation_helper.dart';
import '../../core/services/nova_audio_service.dart';
import '../../core/widgets/nova/nova_button.dart';
import '../../core/widgets/nova/nova_robot_mascot.dart';
import '../../core/widgets/nova/nova_speaker_button.dart';
import '../demo/demo_controls.dart';
import '../../nova_main/services/app_state.dart';
import 'level_road_screen.dart';

/// Screen 3: Class selection (`assets/Potrait screens/Class selection.png`).
/// 2x2 grid for selecting Class 1 to Class 4 with pastel cards, audio speaker buttons, and bottom CTA.
class ClassSelectionScreen extends StatefulWidget {
  const ClassSelectionScreen({super.key});

  @override
  State<ClassSelectionScreen> createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  int _selectedClass = 1;
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

  void _playPromptAudio() {
    NovaAudioService.instance.speak("तू कोणत्या इयत्तेत आहेस? तुमची इयत्ता निवडा.");
  }

  String _getClassSparkleText(int classId) {
    switch (classId) {
      case 1:
        return 'पहिली इयत्ता — चला, शिकूया!';
      case 2:
        return 'दुसरी इयत्ता — नवीन वाचन आणि शब्द!';
      case 3:
        return 'तिसरी इयत्ता — गणिताची गम्मत!';
      case 4:
        return 'चौथी इयत्ता — साहसी शोध मोहीम!';
      default:
        return 'चला, शिकूया!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

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
                  // App Bar / Top Navigation
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
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
                          icon: const Icon(Icons.arrow_back_rounded, color: NovaColors.ink),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'तुमची इयत्ता निवडा',
                              style: NovaTypography.headingLarge,
                            ),
                            Text(
                              'Choose your class',
                              style: NovaTypography.bodySecondary,
                            ),
                          ],
                        ),
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
                  const SizedBox(height: 18),

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
                                'तू कोणत्या इयत्तेत आहेस?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: NovaColors.ink,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Tap a block to pick your class.',
                                style: NovaTypography.bodySecondary,
                              ),
                            ],
                          ),
                        ),
                        NovaSpeakerButton(
                          state: _speakerState,
                          onTap: _playPromptAudio,
                          size: 46,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2x2 Grid for Classes 1 to 4
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.88,
                    children: [
                      _buildClassCard(
                        classId: 1,
                        marathiLabel: 'इयत्ता पहिली',
                        englishLabel: 'Standard 1',
                        assetPath: 'assets/images/generated/class_1_art.png',
                        fallbackIcon: Icons.wb_sunny_rounded,
                        bgColor: const Color(0xFFFEF3C7),
                        accentColor: const Color(0xFFF59E0B),
                      ),
                      _buildClassCard(
                        classId: 2,
                        marathiLabel: 'इयत्ता दुसरी',
                        englishLabel: 'Standard 2',
                        assetPath: 'assets/images/generated/class_2_art.png',
                        fallbackIcon: Icons.menu_book_rounded,
                        bgColor: const Color(0xFFE0F2FE),
                        accentColor: const Color(0xFF38BDF8),
                      ),
                      _buildClassCard(
                        classId: 3,
                        marathiLabel: 'इयत्ता तिसरी',
                        englishLabel: 'Standard 3',
                        assetPath: 'assets/images/generated/class_3_art.png',
                        fallbackIcon: Icons.shopping_basket_rounded,
                        bgColor: const Color(0xFFDCFCE7),
                        accentColor: const Color(0xFF22C55E),
                      ),
                      _buildClassCard(
                        classId: 4,
                        marathiLabel: 'इयत्ता चौथी',
                        englishLabel: 'Standard 4',
                        assetPath: 'assets/images/generated/class_4_art.png',
                        fallbackIcon: Icons.rocket_launch_rounded,
                        bgColor: const Color(0xFFFFE4E6),
                        accentColor: const Color(0xFFFB7185),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Selection Feedback with Sparkles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: NovaColors.purple, size: 22),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _getClassSparkleText(_selectedClass),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: NovaColors.purple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bottom CTA
                  NovaButton(
                    label: 'पुढे जा ->',
                    variant: NovaButtonVariant.primary,
                    height: 56,
                    onPressed: () {
                      appState.setClassNumber(_selectedClass);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LevelRoadScreen(),
                        ),
                      );
                    },
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

  void _showComingSoonModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            decoration: BoxDecoration(
              color: NovaColors.cream,
              borderRadius: NovaSpacing.roundedModal,
              border: Border.all(color: Colors.white, width: 3.5),
              boxShadow: NovaSpacing.modalShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mascot Header
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const NovaRobotMascot(size: 70),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Title
                const Text(
                  'लवकरच येत आहे! • Coming Soon! 🚧',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: NovaColors.ink,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: NovaColors.purpleLight,
                    borderRadius: NovaSpacing.roundedMd,
                  ),
                  child: const Text(
                    'इयत्ता २ री ते ४ थी चे नवीन धडे आणि गोष्टी तयार होत आहेत (In Progress). सध्या इयत्ता पहिली (Standard 1) चे २ लेव्हल्स खेळा!',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: NovaColors.ink,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 18),

                // Action Button
                NovaButton(
                  label: 'ठीक आहे! (Play Std 1) ->',
                  variant: NovaButtonVariant.primary,
                  height: 48,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClassCard({
    required int classId,
    required String marathiLabel,
    required String englishLabel,
    required String assetPath,
    required IconData fallbackIcon,
    required Color bgColor,
    required Color accentColor,
  }) {
    final bool isSelected = _selectedClass == classId;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$marathiLabel, $englishLabel',
      child: GestureDetector(
        onTap: () {
          if (classId > 1) {
            NovaAudioService.instance.speakCleanText(
              "ही इयत्ता लवकरच येत आहे! तोपर्यंत इयत्ता पहिलीचा सराव करूया!",
            );
            _showComingSoonModal(context);
            return;
          }
          setState(() {
            _selectedClass = classId;
          });
          NovaAudioService.instance.speak(marathiLabel);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: NovaSpacing.roundedCard,
            border: Border.all(
              color: isSelected ? NovaColors.purple : accentColor.withValues(alpha: 0.5),
              width: isSelected ? 3.5 : 2.0,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x286C47FF),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x0C271C44),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Class Number
              Positioned(
                top: 12,
                left: 14,
                child: Text(
                  '$classId',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? NovaColors.purple : NovaColors.ink,
                  ),
                ),
              ),

              // Selection Checkmark Badge (Standard 1)
              if (isSelected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: NovaColors.purple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Small, neat pill badge ("लवकरच • Coming Soon") for Standard 2, 3, 4
              if (classId > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: NovaColors.goldDark.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10271C44),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: NovaColors.goldDark,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'लवकरच • Coming Soon',
                          style: TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.w800,
                            color: NovaColors.goldDark,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Center Content: Artwork + Labels
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 8.0, right: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  accentColor.withValues(alpha: 0.25),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.6),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                fallbackIcon,
                                size: 36,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        marathiLabel,
                        style: NovaTypography.headingSmall.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: NovaColors.ink,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        englishLabel,
                        style: NovaTypography.caption.copyWith(
                          color: NovaColors.inkSoft,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
