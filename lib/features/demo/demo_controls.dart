import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/bkt_game_master_engine.dart';
import '../../core/services/llm_game_master_service.dart';
import '../../core/services/nova_schema_repository.dart';
import '../accessibility/presentation/accessibility_settings_screen.dart';
import '../accessibility/presentation/screen_off_simulation_screen.dart';
import '../screens/home_hub_screen.dart';
import '../screens/story_adventure_screen.dart';
import '../../nova_main/models/assessment_question.dart';
import '../../nova_main/models/emotion_state.dart';
import '../../nova_main/screens/assessment/assessment_intro_screen.dart';
import '../../nova_main/screens/levels/level_complete_screen.dart';
import '../../nova_main/screens/levels/level_detail_screen.dart';
import '../../nova_main/screens/onboarding/welcome_screen.dart';
import '../../nova_main/services/app_state.dart';
import '../../nova_main/services/assessment_service.dart';
import '../../nova_main/theme/app_colors.dart';
import '../../nova_main/theme/app_spacing.dart';
import '../../nova_main/theme/app_text_styles.dart';
export 'demo_fab.dart';

/// Modal bottom sheet providing comprehensive testing controls for evaluators.
class DemoControlsSheet extends ConsumerStatefulWidget {
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
  ConsumerState<DemoControlsSheet> createState() => _DemoControlsSheetState();
}

class _DemoControlsSheetState extends ConsumerState<DemoControlsSheet> {
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
    final repo = ref.watch(novaSchemaRepositoryProvider);
    final llmService = ref.watch(llmGameMasterProvider);
    final int currentLevelNumber = repo.currentUser.currentLevel > 0
        ? repo.currentUser.currentLevel
        : (appState.student.currentLevel > 0 ? appState.student.currentLevel : 1);

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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
                    }),
                    _buildChip('Assessment', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AssessmentIntroScreen()));
                    }),
                    _buildChip('Adventure Map', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeHubScreen()));
                    }),
                    _buildChip('Level Detail', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelDetailScreen()));
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelCompleteScreen()));
                    }),
                    _buildChip('Accessibility', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessibilitySettingsScreen()));
                    }),
                    _buildChip('Screen-Off Sim', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenOffSimulationScreen()));
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
                const SizedBox(height: AppSpacing.lg),

                // GROUP 8: AI GAME MASTER & BKT ENGINE
                _buildSectionHeader('8. 🤖 AI Game Master & BKT Engine'),

                // 8.1 Live LLM Provider Selector
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'LLM Provider (Live Swappable)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      avatar: const Icon(Icons.bolt, size: 16, color: Colors.amber),
                      label: const Text('Gemini 2.5 Flash (Primary)'),
                      selected: llmService.activeProvider == LlmBackendProvider.gemini25Flash,
                      selectedColor: AppColors.purple.withValues(alpha: 0.18),
                      labelStyle: TextStyle(
                        color: llmService.activeProvider == LlmBackendProvider.gemini25Flash
                            ? AppColors.purple
                            : AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        ref.read(llmGameMasterProvider).setProvider(LlmBackendProvider.gemini25Flash);
                        setState(() {});
                        _toast('LLM Switched to Gemini 2.5 Flash');
                      },
                    ),
                    ChoiceChip(
                      avatar: const Icon(Icons.speed, size: 16, color: Colors.deepOrange),
                      label: const Text('Groq LPU (Ultra-Fast)'),
                      selected: llmService.activeProvider == LlmBackendProvider.groqUltraFast,
                      selectedColor: Colors.deepOrange.withValues(alpha: 0.18),
                      labelStyle: TextStyle(
                        color: llmService.activeProvider == LlmBackendProvider.groqUltraFast
                            ? Colors.deepOrange
                            : AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        ref.read(llmGameMasterProvider).setProvider(LlmBackendProvider.groqUltraFast);
                        setState(() {});
                        _toast('LLM Switched to Groq LPU');
                      },
                    ),
                    ChoiceChip(
                      avatar: const Icon(Icons.offline_bolt, size: 16, color: Colors.teal),
                      label: const Text('Dynamic Offline (Instant)'),
                      selected: llmService.activeProvider == LlmBackendProvider.dynamicLocalOffline,
                      selectedColor: Colors.teal.withValues(alpha: 0.18),
                      labelStyle: TextStyle(
                        color: llmService.activeProvider == LlmBackendProvider.dynamicLocalOffline
                            ? Colors.teal
                            : AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        ref.read(llmGameMasterProvider).setProvider(LlmBackendProvider.dynamicLocalOffline);
                        setState(() {});
                        _toast('LLM Switched to Dynamic Offline');
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 12),
                  child: Text(
                    'Active: ${_getProviderLabel(llmService.activeProvider)} • Last: ${llmService.lastUsedAdapter}',
                    style: const TextStyle(fontSize: 11, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                  ),
                ),

                // 8.2 Live Action Shortcuts
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Live Action Shortcuts',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.sync_rounded, size: 20),
                      label: Text(
                        '🔄 Regenerate Dynamic Story & Questions (L$currentLevelNumber)',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      onPressed: () => _generateAndLaunch(currentLevelNumber),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.purple, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Text('🐯', style: TextStyle(fontSize: 18)),
                      label: const Text(
                        'Jump to Level 2 (Banyan Grove & Dairy)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      onPressed: () => _generateAndLaunch(2),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: Color(0xFFF97316), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Text('🛒', style: TextStyle(fontSize: 18)),
                      label: const Text(
                        '🛒 Jump to Level 3 (Village Market)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      onPressed: () => _generateAndLaunch(3),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Text('🎡', style: TextStyle(fontSize: 18)),
                      label: const Text(
                        '🎡 Jump to Level 4 (School & Fair Finale)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      onPressed: () => _generateAndLaunch(4),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 8.3 Live BKT Mastery (p_learned) Readout & DDA Simulator
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Live BKT Latent Mastery & DDA Simulator',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: repo,
                  builder: (context, _) {
                    final user = repo.currentUser;
                    final compareState = repo.getBktState('MATH_COMPARE_01');
                    final marathiState = repo.getBktState('LANG_MARATHI_01');
                    final countState = repo.getBktState('MATH_COUNT_01');
                    final addState = repo.getBktState('MATH_ADD_01');
                    final marketState = repo.getBktState('MATH_MARKET_SUB_01');

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Player: ${user.username} (L${user.currentLevel})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.navy,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🪙 ', style: TextStyle(fontSize: 12)),
                                    Text(
                                      '${user.coinsBalance} coins',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 18),
                          _buildBktSkillRow('MATH_COMPARE_01', 'Size Comparison (मोठे / छोटे)', compareState.pLearned),
                          const SizedBox(height: 8),
                          _buildBktSkillRow('LANG_MARATHI_01', 'Marathi Vocab (मराठी संवाद)', marathiState.pLearned),
                          const SizedBox(height: 8),
                          _buildBktSkillRow('MATH_COUNT_01', 'Counting 1-10 (मोजणे)', countState.pLearned),
                          const SizedBox(height: 8),
                          _buildBktSkillRow('MATH_ADD_01', 'Single Addition (बेरीज)', addState.pLearned),
                          const SizedBox(height: 8),
                          _buildBktSkillRow('MATH_MARKET_SUB_01', 'Market Math (वजाबाकी व मोजणी)', marketState.pLearned),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: const Color(0xFFEFF6FF),
                        ),
                        onPressed: () {
                          repo.setAllBktMastery(0.15);
                          setState(() {});
                          _toast('BKT set to 15% (Tier 1 Easy)! Regenerate pulls Easy.');
                        },
                        child: const Text(
                          'Set Struggling\n(p = 0.15 -> Tier 1 Easy)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: const Color(0xFFECFDF5),
                        ),
                        onPressed: () {
                          repo.setAllBktMastery(0.85);
                          setState(() {});
                          _toast('BKT set to 85% (Tier 3 Hard)! Regenerate pulls Hard.');
                        },
                        child: const Text(
                          'Set Mastered\n(p = 0.85 -> Tier 3 Hard)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF047857),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  String _getProviderLabel(LlmBackendProvider provider) {
    switch (provider) {
      case LlmBackendProvider.gemini25Flash:
        return 'Gemini 2.5 Flash (Primary)';
      case LlmBackendProvider.groqUltraFast:
        return 'Groq LPU (Ultra-Fast)';
      case LlmBackendProvider.dynamicLocalOffline:
        return 'Dynamic Offline (Instant)';
    }
  }

  Widget _buildBktSkillRow(String id, String label, double pLearned) {
    final int tier = GameMasterContextAssembler.selectDifficultyTier(pLearned);
    final Color tierColor = tier == 1
        ? const Color(0xFF3B82F6)
        : tier == 2
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    final String tierText = tier == 1 ? 'Tier 1 (Easy)' : tier == 2 ? 'Tier 2 (Medium)' : 'Tier 3 (Hard)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tierColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tierText,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: tierColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(pLearned * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pLearned.clamp(0.01, 0.99),
            minHeight: 5,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(tierColor),
          ),
        ),
      ],
    );
  }

  Future<void> _generateAndLaunch(int levelNumber) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final llmService = ref.read(llmGameMasterProvider);
    final providerName = _getProviderLabel(llmService.activeProvider);

    navigator.pop();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Generating Level $levelNumber via $providerName...',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    try {
      final contract = await llmService.generateLevel(levelNumber: levelNumber);
      scaffoldMessenger.hideCurrentSnackBar();
      if (!mounted) return;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => StoryAdventureScreen(
            initialLevelId: levelNumber,
            generatedLevelContract: contract,
          ),
        ),
      );
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Level generation failed: $e'),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
