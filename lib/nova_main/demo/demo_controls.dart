import 'package:flutter/material.dart';
import '../../features/screens/story_adventure_screen.dart';
import '../models/assessment_question.dart';
import '../models/emotion_state.dart';
import '../routes/app_routes.dart';
import '../services/app_state.dart';
import '../services/assessment_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Modal bottom sheet providing comprehensive testing controls for evaluators.
class DemoControlsSheet extends StatefulWidget {
  const DemoControlsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DemoControlsSheet(),
    );
  }

  @override
  State<DemoControlsSheet> createState() => _DemoControlsSheetState();
}

class _DemoControlsSheetState extends State<DemoControlsSheet> {
  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.navy,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: Column(
          children: [
            // Drag handle and header
            Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.disabledGrey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.build_rounded, color: AppColors.purple, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Evaluator Demo Controls',
                      style: AppTextStyles.questionText.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Scrollable control groups
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // GROUP 1: QUICK JUMP
                _buildSectionHeader('1. Quick Navigation Jump'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Welcome', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.welcome);
                    }),
                    _buildChip('Assessment', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.assessmentIntro);
                    }),
                    _buildChip('Adventure Map', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.home);
                    }),
                    _buildChip('Level Detail', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.levelDetail);
                    }),
                    _buildChip('Story (Screen 6)', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryAdventureScreen(initialScreen: 6, startWithRotateModal: false)));
                    }),
                    _buildChip('Quiz (Screen 7)', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryAdventureScreen(initialScreen: 7, startWithRotateModal: false)));
                    }),
                    _buildChip('Chiu (Screen 8)', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryAdventureScreen(initialScreen: 8, startWithRotateModal: false)));
                    }),
                    _buildChip('Voice (Screen 9)', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryAdventureScreen(initialScreen: 9, startWithRotateModal: false)));
                    }),
                    _buildChip('Match (Screen 10)', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryAdventureScreen(initialScreen: 10, startWithRotateModal: false)));
                    }),
                    _buildChip('Celebration (Screen 11)', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryAdventureScreen(initialScreen: 11, startWithRotateModal: false)));
                    }),
                    _buildChip('Level Complete', () {
                      appState.startLevel(4);
                      appState.completeLevel();
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.levelComplete);
                    }),
                    _buildChip('Accessibility', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.accessibilitySettings);
                    }),
                    _buildChip('Screen-Off Sim', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.screenOffSimulation);
                    }),
                    _buildChip('🔄 Reset Demo', () {
                      appState.resetDemo();
                      _toast('Demo reset to initial state!');
                    }, isDestructive: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // GROUP 2: ASSESSMENT FORCING
                _buildSectionHeader('2. Force Assessment Outcome'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('All Strong (Level 6)', () {
                      _forceAssessment(appState, [1, 0, 1, 0, 1, 1, 0, 0]);
                      _toast('Forced All Strong -> Level 6!');
                    }),
                    _buildChip('Fractions Need Practice (Level 6)', () {
                      // Q7 wrong (index 1 instead of 0)
                      _forceAssessment(appState, [1, 0, 1, 0, 1, 1, 1, 0]);
                      _toast('Forced Fractions Weak -> Level 6!');
                    }),
                    _buildChip('Multiplication Moderate (Level 3)', () {
                      // Q5 wrong
                      _forceAssessment(appState, [1, 0, 1, 0, 0, 1, 0, 0]);
                      _toast('Forced Multiply Weak -> Level 3!');
                    }),
                    _buildChip('Just Starting (Level 1)', () {
                      // Q1 wrong
                      _forceAssessment(appState, [0, 0, 1, 0, 1, 1, 0, 0]);
                      _toast('Forced Numbers Weak -> Level 1!');
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Starting Level: ${appState.student.currentLevel}', style: AppTextStyles.label),
                    Expanded(
                      child: Slider(
                        value: appState.student.currentLevel.toDouble(),
                        min: 1,
                        max: 15,
                        divisions: 14,
                        label: '${appState.student.currentLevel}',
                        onChanged: (val) {
                          appState.setCurrentLevel(val.toInt());
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // GROUP 3: ANSWER OUTCOME
                _buildSectionHeader('3. Next Answer Outcome'),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Auto'),
                        selected: appState.forcedAnswerOutcome == null,
                        onSelected: (_) {
                          appState.setForceAnswerOutcome(null);
                          _toast('Answer outcome: Auto');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Force Correct'),
                        selected: appState.forcedAnswerOutcome == true,
                        onSelected: (_) {
                          appState.setForceAnswerOutcome(true);
                          _toast('Answer outcome: Force Correct');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Force Almost'),
                        selected: appState.forcedAnswerOutcome == false,
                        onSelected: (_) {
                          appState.setForceAnswerOutcome(false);
                          _toast('Answer outcome: Force Almost');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // GROUP 4: SIMULATE EMOTION
                _buildSectionHeader('4. Simulate Student Emotion'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('🚀 Confident'),
                      selected: appState.forcedEmotion == EmotionState.confident,
                      onSelected: (_) {
                        appState.setForcedEmotion(EmotionState.confident, lock: appState.lockEmotion);
                        _toast('Simulating Confident');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('💡 Confused'),
                      selected: appState.forcedEmotion == EmotionState.confused,
                      onSelected: (_) {
                        appState.setForcedEmotion(EmotionState.confused, lock: appState.lockEmotion);
                        _toast('Simulating Confused');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('🌱 Frustrated'),
                      selected: appState.forcedEmotion == EmotionState.frustrated,
                      onSelected: (_) {
                        appState.setForcedEmotion(EmotionState.frustrated, lock: appState.lockEmotion);
                        _toast('Simulating Frustrated');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('😊 Neutral'),
                      selected: appState.forcedEmotion == EmotionState.neutral,
                      onSelected: (_) {
                        appState.setForcedEmotion(EmotionState.neutral, lock: appState.lockEmotion);
                        _toast('Simulating Neutral');
                      },
                    ),
                  ],
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Lock emotion until changed'),
                  value: appState.lockEmotion,
                  onChanged: (val) {
                    appState.setForcedEmotion(appState.forcedEmotion, lock: val ?? false);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // GROUP 5: VOICE & LEVEL ACTIONS
                _buildSectionHeader('5. Voice & Level Actions'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Simulate Voice Mishear Once'),
                  subtitle: const Text('Recogniser returns "Fore" to demo retry'),
                  value: appState.voiceMishearOnce,
                  onChanged: (val) {
                    appState.setVoiceMishearOnce(val);
                    _toast('Voice mishear simulation: $val');
                  },
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Complete Current Level Now 🏆', () {
                      appState.completeLevel();
                      _toast('Completed current level!');
                    }),
                    _buildChip('Unlock All 15 Levels 🔓', () {
                      appState.unlockAllLevels();
                      _toast('All 15 levels unlocked!');
                    }),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // GROUP 6: CLASS SWITCHER
                _buildSectionHeader('6. Switch Class (1 to 6)'),
                Wrap(
                  spacing: 8,
                  children: List.generate(6, (i) {
                    final c = i + 1;
                    return ChoiceChip(
                      label: Text('Class $c'),
                      selected: appState.student.classNumber == c,
                      onSelected: (_) {
                        appState.setClassNumber(c);
                        _toast('Switched to Class $c');
                      },
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.lg),

                // GROUP 7: INFO READOUT
                _buildSectionHeader('7. Live System State'),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.softGrey,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Class: ${appState.student.classNumber}  •  Level: ${appState.student.currentLevel}\n'
                    'Tier: ${appState.currentTier}  •  Emotion: ${appState.currentEmotion.name}\n'
                    'Stars: ${appState.student.stars}  •  Streak: ${appState.student.streak}\n'
                    'Hints In Session: ${appState.hintsUsedInSession}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  void _forceAssessment(AppState appState, List<int> answers) {
    final outcome = AssessmentService.evaluate(
      questions: const [
        AssessmentQuestion(id: '1', classNumber: 4, skillTag: 'numbers', question: '', options: [], correctIndex: 1, semanticLabel: ''),
        AssessmentQuestion(id: '2', classNumber: 4, skillTag: 'shapes', question: '', options: [], correctIndex: 0, semanticLabel: ''),
        AssessmentQuestion(id: '3', classNumber: 4, skillTag: 'addsub', question: '', options: [], correctIndex: 1, semanticLabel: ''),
        AssessmentQuestion(id: '4', classNumber: 4, skillTag: 'addsub', question: '', options: [], correctIndex: 0, semanticLabel: ''),
        AssessmentQuestion(id: '5', classNumber: 4, skillTag: 'multiply', question: '', options: [], correctIndex: 1, semanticLabel: ''),
        AssessmentQuestion(id: '6', classNumber: 4, skillTag: 'divide', question: '', options: [], correctIndex: 1, semanticLabel: ''),
        AssessmentQuestion(id: '7', classNumber: 4, skillTag: 'fractions', question: '', options: [], correctIndex: 0, semanticLabel: ''),
        AssessmentQuestion(id: '8', classNumber: 4, skillTag: 'patterns', question: '', options: [], correctIndex: 0, semanticLabel: ''),
      ],
      selectedOptionIndices: answers,
      gateLevels: const {'numbers': 1, 'addsub': 2, 'multiply': 3, 'divide': 4, 'fractions': 6},
    );
    appState.submitAssessment(outcome);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: AppColors.navy,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ActionChip(
      backgroundColor: isDestructive ? const Color(0xFFFFECEC) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isDestructive ? AppColors.coral : AppColors.borderLight,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppColors.coral : AppColors.navy,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      onPressed: onTap,
    );
  }
}
