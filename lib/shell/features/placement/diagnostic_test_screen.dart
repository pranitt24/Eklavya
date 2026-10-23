import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/audio/sound_service.dart';
import '../../core/models/level_progress.dart';
import '../../core/widgets/squishy_button.dart';
import '../../theme.dart';

class DiagnosticQuestion {
  final int questionNumber;
  final String marathiPrompt;
  final String englishPrompt;
  final String visualEmoji;
  final String visualDescription;
  final List<DiagnosticOption> options;
  final int correctOptionIndex;

  const DiagnosticQuestion({
    required this.questionNumber,
    required this.marathiPrompt,
    required this.englishPrompt,
    required this.visualEmoji,
    required this.visualDescription,
    required this.options,
    required this.correctOptionIndex,
  });
}

class DiagnosticOption {
  final String emoji;
  final String titleMarathi;
  final String titleEnglish;

  const DiagnosticOption({
    required this.emoji,
    required this.titleMarathi,
    required this.titleEnglish,
  });
}

/// DiagnosticTestScreen: Adaptive placement quiz with 3 interactive questions,
/// custom 3D placeholder database wireframe card, and automatic placement to Level 4.
class DiagnosticTestScreen extends StatefulWidget {
  const DiagnosticTestScreen({super.key});

  @override
  State<DiagnosticTestScreen> createState() => _DiagnosticTestScreenState();
}

class _DiagnosticTestScreenState extends State<DiagnosticTestScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerCorrect = false;
  int _starsEarned = 0;
  bool _showPlacementDialog = false;

  final List<DiagnosticQuestion> _questions = const [
    DiagnosticQuestion(
      questionNumber: 1,
      marathiPrompt: '३ कोपरे असणारा आकार कोणता? 🤔',
      englishPrompt: 'Which shape has 3 corners?',
      visualEmoji: '📐',
      visualDescription: 'आकार ओळखा: ३ बाजू आणि ३ टोकदार कोपरे',
      options: [
        DiagnosticOption(
          emoji: '🔺',
          titleMarathi: 'त्रिकोण',
          titleEnglish: 'Triangle',
        ),
        DiagnosticOption(
          emoji: '🟦',
          titleMarathi: 'चौकोन',
          titleEnglish: 'Square',
        ),
        DiagnosticOption(
          emoji: '🔴',
          titleMarathi: 'वर्तुळ',
          titleEnglish: 'Circle',
        ),
      ],
      correctOptionIndex: 0,
    ),
    DiagnosticQuestion(
      questionNumber: 2,
      marathiPrompt: '१२ मासे + ३ मासे = किती? 🐟',
      englishPrompt: '12 Fish + 3 Fish = How many?',
      visualEmoji: '🌊',
      visualDescription: 'नदीतील मासे मोजा: १२ + ३ = ?',
      options: [
        DiagnosticOption(
          emoji: '🐟',
          titleMarathi: '१४ मासे',
          titleEnglish: '14 Fish',
        ),
        DiagnosticOption(
          emoji: '🐟',
          titleMarathi: '१५ मासे',
          titleEnglish: '15 Fish',
        ),
        DiagnosticOption(
          emoji: '🐟',
          titleMarathi: '१६ मासे',
          titleEnglish: '16 Fish',
        ),
      ],
      correctOptionIndex: 1,
    ),
    DiagnosticQuestion(
      questionNumber: 3,
      marathiPrompt: 'पाण्यात न राहणारी वस्तू कोणती? 🌊',
      englishPrompt: 'Which one does NOT belong in water?',
      visualEmoji: '🏞️',
      visualDescription: 'नदीकाठचा परिसर: प्राणी व वस्तू ओळखा',
      options: [
        DiagnosticOption(
          emoji: '🐸',
          titleMarathi: 'बेडूक',
          titleEnglish: 'Frog',
        ),
        DiagnosticOption(
          emoji: '🦆',
          titleMarathi: 'बदक',
          titleEnglish: 'Duck',
        ),
        DiagnosticOption(
          emoji: '🪁',
          titleMarathi: 'पतंग',
          titleEnglish: 'Kite',
        ),
      ],
      correctOptionIndex: 2,
    ),
  ];

  DiagnosticQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  void _handleOptionSelect(int index) {
    if (_selectedOptionIndex != null) return; // Prevent double tap

    final isCorrect = index == _currentQuestion.correctOptionIndex;
    setState(() {
      _selectedOptionIndex = index;
      _isAnswerCorrect = isCorrect;
    });

    if (isCorrect) {
      SoundService.instance.playDingChime();
      GameState.instance.addCoins(10);
      setState(() => _starsEarned++);
    } else {
      SoundService.instance.playBoingBloop();
    }

    // Move to next question or complete quiz
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOptionIndex = null;
          _isAnswerCorrect = false;
        });
      } else {
        // Complete Diagnostic Test
        GameState.instance.completeDiagnosticPlacement();
        setState(() => _showPlacementDialog = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/screens/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [

          SafeArea(
            child: Column(
              children: [
                // Top HUD Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Exit / Back Button
                      GestureDetector(
                        onTap: () => context.go('/profile-picker'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: GameColors.cardBorderLavender,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GameColors.inkGrape.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: GameColors.electricPurple,
                            size: 24,
                          ),
                        ),
                      ),

                      // 3 Glowing Toy Star Slots
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: GameColors.activeGoldDark,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: GameColors.activeGoldDark.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (starIndex) {
                            final isEarned = starIndex < _starsEarned;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Text(
                                isEarned ? '⭐' : '☆',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: isEarned
                                      ? GameColors.activeGoldDark
                                      : Colors.grey,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Question Step Badge & Coins
                      HudPillChip(
                        icon: const Text('🪙', style: TextStyle(fontSize: 18)),
                        label: '${GameState.instance.coins}',
                        sublabel: 'प्रश्न ${_currentQuestionIndex + 1}/३',
                        backgroundColor: GameColors.canvasCream,
                        borderColor: GameColors.cardBorderAmber,
                      ),
                    ],
                  ),
                ),

                // Main Interactive Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 6),

                        // NOVA Speech Prompt Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: GameColors.cardBorderLavender,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GameColors.electricPurple.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // 3D NOVA Avatar
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F2FE),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/characters/nova.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) =>
                                        Image.asset(
                                      'assets/full_body_3d_pixar_style_cute_friendly_chubby_blue_robot_character_named_nova/screen.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (c1, e1, s1) => const Icon(
                                        Icons.android_rounded,
                                        color: GameColors.robotBlue,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Prompt Question
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentQuestion.marathiPrompt,
                                      style: GameTypography.headline(
                                        color: GameColors.inkGrape,
                                      ).copyWith(fontSize: 18, height: 1.2),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _currentQuestion.englishPrompt,
                                      style: GameTypography.buttonSublabel(
                                        color: GameColors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Speaker Tap Button
                              SpeakerButton(
                                size: 44,
                                color: GameColors.activeGold,
                                onPlay: () {
                                  SoundService.instance.playDingChime();
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // REUSABLE 3D PLACEHOLDER DATABASE WIREFRAME CARD
                        _buildPlaceholderWireframeCard(_currentQuestion),

                        const SizedBox(height: 14),

                        // 3 CHUNKY INTERACTIVE SELECTION OPTIONS
                        ...List.generate(
                          _currentQuestion.options.length,
                          (index) => _buildOptionCard(
                            option: _currentQuestion.options[index],
                            index: index,
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CELEBRATION & AUTO-PLACEMENT DIALOG
          if (_showPlacementDialog) _buildPlacementModal(context),
        ],
      ),
    ),
  );
}

  /// Reusable 3D Skeuomorphic Toy Container Frame matching
  /// majhe_gaon_reusable_ui_placeholder_asset_component
  Widget _buildPlaceholderWireframeCard(DiagnosticQuestion question) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF6D28D9),
            Color(0xFF4C1D95),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B0764).withValues(alpha: 0.5),
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF4C1D95).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Container(
        // Inner Gold Bevel Ring
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDE047),
              Color(0xFFF59E0B),
              Color(0xFFD97706),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.all(5),
        child: Container(
          // Cream Slab Surface
          decoration: BoxDecoration(
            color: const Color(0xFFFAF5FF),
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Header Tag (Dynamic DB Wireframe Slot)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: GameColors.purpleContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'चित्र / कृती • QUESTION CARD',
                      style: GameTypography.buttonSublabel(
                        color: GameColors.electricPurple,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const Text('✨', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),

              // Dashed Inner Drop Slot (Visual Graphic for current question)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFA78BFA),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        question.visualEmoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.visualDescription,
                        style: GameTypography.bodyMedium(
                          color: GameColors.inkGrape,
                        ).copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
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

  Widget _buildOptionCard({
    required DiagnosticOption option,
    required int index,
  }) {
    final isSelected = _selectedOptionIndex == index;
    final isCorrectOption = index == _currentQuestion.correctOptionIndex;

    Color cardBg = Colors.white;
    Color borderColor = GameColors.cardBorderLavender;
    Color bevelColor = const Color(0xFFDDD6FE);

    if (isSelected) {
      if (_isAnswerCorrect) {
        cardBg = const Color(0xFFDCFCE7); // Emerald success green
        borderColor = GameColors.emeraldGrass;
        bevelColor = GameColors.emeraldGrassDark;
      } else {
        cardBg = const Color(0xFFFFE4E6); // Rose wrong color
        borderColor = Colors.redAccent;
        bevelColor = Colors.red.shade700;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _handleOptionSelect(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 72,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: isSelected ? 3.0 : 2.0),
            boxShadow: [
              BoxShadow(
                color: bevelColor,
                offset: Offset(0, isSelected ? 2 : 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Icon Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: GameColors.canvasCream,
                  shape: BoxShape.circle,
                  border: Border.all(color: GameColors.cardBorderAmber, width: 2),
                ),
                child: Center(
                  child: Text(
                    option.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title Labels
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.titleMarathi,
                      style: GameTypography.buttonLabel(
                        color: GameColors.inkGrape,
                      ).copyWith(fontSize: 20),
                    ),
                    Text(
                      option.titleEnglish,
                      style: GameTypography.buttonSublabel(
                        color: GameColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Success checkmark or selection indicator
              if (isSelected && isCorrectOption)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: GameColors.emeraldGrass,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Animated Placement Celebration Modal Popup
  Widget _buildPlacementModal(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: GameColors.activeGold, width: 4),
              boxShadow: [
                BoxShadow(
                  color: GameColors.activeGoldDark.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉 🚀 🏆', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  'शाब्बास! छान खेळलास!',
                  style: GameTypography.displayHero(
                    color: GameColors.inkGrape,
                  ).copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'तुझा प्रवास टप्पा ४ पासून सुरू होत आहे!\n(Level 4 Unlocked!)',
                  style: GameTypography.headline(
                    color: GameColors.electricPurple,
                  ).copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Star & Coin Rewards Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: GameColors.canvasCream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GameColors.cardBorderAmber, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('⭐⭐⭐', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('+३० 🪙 नाणी!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Primary CTA to Saga Map
                Squishy3DButton(
                  height: 64,
                  backgroundColor: GameColors.emeraldGrass,
                  bevelColor: GameColors.emeraldGrassDark,
                  label: 'नकाशावर चला! ➔',
                  sublabel: 'EXPLORE VILLAGE SAGA MAP',
                  onPressed: () {
                    SoundService.instance.playPopClick();
                    context.go('/saga-map');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
