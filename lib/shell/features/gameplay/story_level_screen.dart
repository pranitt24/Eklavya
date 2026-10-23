import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import '../../core/audio/sound_service.dart';
import '../../core/widgets/landscape_split_layout.dart';
import '../../core/widgets/squishy_button.dart';
import '../../theme.dart';
import 'celebration_screen.dart';

/// StoryLevelScreen: Interactive landscape story level featuring:
/// 1. Pixar village courtyard story background (Left 58%)
/// 2. 2-second Story Interruption Mechanic triggering NOVA robot with speech bubble
/// 3. Database placeholder wireframe card component
/// 4. Icon-heavy visual validation with giant glowing White Tick (✅) & White Cross (❌) buttons
/// 5. Low-latency audio cues & confetti celebration
class StoryLevelScreen extends StatefulWidget {
  const StoryLevelScreen({super.key});

  @override
  State<StoryLevelScreen> createState() => _StoryLevelScreenState();
}

class _StoryLevelScreenState extends State<StoryLevelScreen> {
  // Story interruption state
  bool _isStoryPaused = false;
  Timer? _storyTimer;

  // Question selection & feedback state
  int? _selectedOptionIndex; // 0 for Tractor (correct), 1 for Bicycle (wrong)
  bool? _isCurrentSelectionCorrect;
  bool _showHint = false;
  int _shakeTriggerKey = 0;

  @override
  void initState() {
    super.initState();
    // Interruption logic: 2 seconds after level begins, NOVA interrupts the story
    _storyTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isStoryPaused = true;
        });
        SoundService.instance.playPopClick();
      }
    });
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    super.dispose();
  }

  void _handleOptionSelect(int index) {
    SoundService.instance.playPopClick();
    setState(() {
      _selectedOptionIndex = index;
      _isCurrentSelectionCorrect = null;
      _showHint = false;
    });
  }

  /// Triggered either directly by tapping the White Tick (✅) or selecting the correct choice
  void _validateCorrectAnswer() {
    setState(() {
      _selectedOptionIndex = 0; // Select tractor
      _isCurrentSelectionCorrect = true;
      _showHint = false;
    });

    // 1. Play happy ding chime
    SoundService.instance.playDingChime();

    // 2. Fire Confetti explosion overlay
    Confetti.launch(
      context,
      options: const ConfettiOptions(
        particleCount: 80,
        spread: 80,
        y: 0.5,
      ),
    );

    // 3. Navigate to Celebration Party Modal after celebratory delay
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        CelebrationScreen.show(
          context,
          completedLevelNumber: 4,
          earnedStars: 3,
          coinsAwarded: 50,
        );
      }
    });
  }

  /// Triggered either directly by tapping the White Cross (❌) or selecting wrong choice
  void _validateWrongAnswer() {
    setState(() {
      _selectedOptionIndex = 1; // Select bicycle
      _isCurrentSelectionCorrect = false;
      _showHint = true;
      _shakeTriggerKey++;
    });

    // 1. Play gentle boing bloop
    SoundService.instance.playBoingBloop();
  }

  @override
  Widget build(BuildContext context) {
    return LandscapeSplitLayout(
      levelTitle: 'लेव्हल ४ • वाहन शोध',
      currentStep: 2,
      totalSteps: 3,
      leftImageAsset: 'assets/images/screens/screen_1_big_vs_small_toy_game.png',
      // Left Stage Overlay (Villagers & tractor story animation)
      leftStage: Stack(
        children: [
          // Story Mode Status Pill
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: GameColors.sunflowerGold.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _isStoryPaused ? '⏸️ कथा थांबवली (Story Paused)' : '📖 कथा सुरू आहे... (Story Playing)',
                    style: GameTypography.buttonSublabel(color: Colors.white).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Glowing Story Interruption Pulse Badge on Village Scene
          if (_isStoryPaused)
            Positioned(
              bottom: 24,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: GameColors.sunflowerGold.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: GameColors.sunflowerGold.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🚜', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'गावातील मोठी वाहने',
                      style: GameTypography.marathiHeadingMedium(color: GameColors.clayBrown).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
        ],
      ),

      // Right Board Content: Question & Interruption Mechanic
      rightContent: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            // -----------------------------------------------------------------
            // 1. Story Interruption Mascot & Speech Bubble
            // -----------------------------------------------------------------
            if (!_isStoryPaused)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎧', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 10),
                      Text(
                        'कथा ऐका आणि पहा...\n(Listen to the village story...)',
                        style: GameTypography.marathiHeadingMedium(color: GameColors.clayBrown),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(GameColors.activeGold),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // NOVA Robot cutout + Speech Bubble
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NOVA mascot cutout avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: GameColors.sunflowerGold, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: GameColors.sunflowerGold.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/characters/nova.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/full_body_3d_pixar_style_cute_friendly_chubby_blue_robot_character_named_nova/screen.png',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Center(
                            child: Text('🤖', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                      ),
                    ),
                  ).animate().scale(begin: const Offset(0.0, 0.0), duration: 400.ms, curve: Curves.elasticOut),

                  const SizedBox(width: 8),

                  // Speech Bubble
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GameColors.sunflowerGold, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'नोव्हा विचारतोय:',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GameTypography.buttonSublabel(color: GameColors.electricPurple).copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => SoundService.instance.playPopClick(),
                                child: const Icon(Icons.volume_up_rounded, color: GameColors.sunflowerGold, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'थांबा! मोठे वाहन कोणते? 🚜 vs 🚲',
                            style: GameTypography.marathiHeadingMedium(color: GameColors.clayBrown).copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Wait! Which vehicle is bigger?',
                            style: GameTypography.buttonSublabel(color: GameColors.woodBarkBrown).copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // -----------------------------------------------------------------
              // 2. Database Placeholder Wireframe Card Area
              // -----------------------------------------------------------------
              Expanded(
                child: Animate(
                  key: ValueKey(_shakeTriggerKey),
                  effects: _isCurrentSelectionCorrect == false
                      ? [const ShakeEffect(duration: Duration(milliseconds: 450), hz: 4)]
                      : [],
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isCurrentSelectionCorrect == true
                            ? GameColors.meadowGreen
                            : (_isCurrentSelectionCorrect == false
                                ? GameColors.coralRed
                                : GameColors.skyBlue.withValues(alpha: 0.6)),
                        width: _isCurrentSelectionCorrect != null ? 3.5 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isCurrentSelectionCorrect == true
                              ? GameColors.meadowGreen.withValues(alpha: 0.3)
                              : const Color(0x1A000000),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dynamic DB Wireframe Metadata Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: GameColors.skyBlue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: GameColors.skyBlue.withValues(alpha: 0.5), width: 1),
                                ),
                                child: Text(
                                  '📦 DYNAMIC DB QUESTION SLOT',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GameTypography.buttonSublabel(color: GameColors.skyBlueDark).copyWith(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '२ पैकी १ निवडा (Choose 1)',
                              style: GameTypography.buttonSublabel(color: Colors.grey.shade600).copyWith(fontSize: 9),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Interactive Question Choices inside Placeholder Wireframe
                        Expanded(
                          child: Row(
                            children: [
                              // Option A: Tractor 🚜 (CORRECT)
                              Expanded(
                                child: _buildChoiceCard(
                                  index: 0,
                                  emoji: '🚜',
                                  labelMarathi: 'मोठा ट्रॅक्टर',
                                  labelEnglish: 'Big Tractor',
                                  isSelected: _selectedOptionIndex == 0,
                                  isCorrect: _isCurrentSelectionCorrect == true && _selectedOptionIndex == 0,
                                  onTap: () => _handleOptionSelect(0),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Option B: Bicycle 🚲 (WRONG)
                              Expanded(
                                child: _buildChoiceCard(
                                  index: 1,
                                  emoji: '🚲',
                                  labelMarathi: 'छोटी सायकल',
                                  labelEnglish: 'Small Bicycle',
                                  isSelected: _selectedOptionIndex == 1,
                                  isWrong: _isCurrentSelectionCorrect == false && _selectedOptionIndex == 1,
                                  onTap: () => _handleOptionSelect(1),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Soft Hint Banner if wrong answer
                        if (_showHint) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: GameColors.coralRed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: GameColors.coralRed.withValues(alpha: 0.4), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'छान प्रयत्न! पुन्हा एकदा करून बघूया!\n(Good try! Let\'s try once more!)',
                                    style: GameTypography.marathiBody(color: GameColors.coralRedDark).copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 250.ms),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // -----------------------------------------------------------------
              // 3. Icon-Heavy Visual Buttons: Glowing White Tick (✅) & Cross (❌)
              // -----------------------------------------------------------------
              Row(
                children: [
                  // Soft Coral Squishy3DButton with White Cross (❌) for retry / wrong demo
                  Expanded(
                    flex: 1,
                    child: Squishy3DButton(
                      backgroundColor: GameColors.coralRed,
                      bevelColor: GameColors.coralRedDark,
                      height: 50,
                      onPressed: _validateWrongAnswer,
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Giant Glowing Emerald Squishy3DButton with White Tick (✅)
                  Expanded(
                    flex: 2,
                    child: Squishy3DButton(
                      backgroundColor: GameColors.meadowGreen,
                      bevelColor: GameColors.meadowGreenDark,
                      height: 50,
                      onPressed: _validateCorrectAnswer,
                      child: Center(
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.35),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                         .scale(
                           begin: const Offset(0.92, 0.92),
                           end: const Offset(1.08, 1.08),
                           duration: 800.ms,
                         ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required int index,
    required String emoji,
    required String labelMarathi,
    required String labelEnglish,
    required bool isSelected,
    bool isCorrect = false,
    bool isWrong = false,
    required VoidCallback onTap,
  }) {
    Color borderColor = Colors.grey.shade300;
    Color bgColor = GameColors.storybookCream;

    if (isCorrect) {
      borderColor = GameColors.meadowGreen;
      bgColor = GameColors.meadowGreenLight.withValues(alpha: 0.25);
    } else if (isWrong) {
      borderColor = GameColors.coralRed;
      bgColor = GameColors.coralRed.withValues(alpha: 0.15);
    } else if (isSelected) {
      borderColor = GameColors.sunflowerGold;
      bgColor = GameColors.activeGoldLight.withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected || isCorrect || isWrong ? 3.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: GameColors.sunflowerGold.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji illustration
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 34),
                  ),
                  const SizedBox(height: 2),
                  // Marathi Label
                  Text(
                    labelMarathi,
                    style: GameTypography.marathiHeadingMedium(color: GameColors.clayBrown).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // English Sublabel
                  Text(
                    labelEnglish,
                    style: GameTypography.buttonSublabel(color: GameColors.woodBarkBrown).copyWith(
                      fontSize: 9.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
