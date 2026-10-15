import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../demo/demo_fab.dart';
import '../../models/answer_option.dart';
import '../../models/emotion_state.dart';
import '../../models/question_model.dart';
import '../../models/story_beat.dart';
import '../../routes/app_routes.dart';
import '../../services/adaptive_engine.dart';
import '../../services/app_state.dart';
import '../../services/haptics_service.dart';
import '../../services/voice_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/adaptive_difficulty_stars.dart';
import '../../widgets/adventure_progress_indicator.dart';
import '../../widgets/answer_option_widget.dart';
import '../../widgets/emotion_feedback_card.dart';
import '../../widgets/hint_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/speech_bubble.dart';
import '../../widgets/story_card.dart';
import '../../widgets/voice_button.dart';

/// Flagship interactive Story & Question learning session loop.
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  // Session progression states
  int _currentBeatIndex = 0;
  bool _isInBeatMode = true;
  bool _isOutroMode = false;

  // Active question state
  int? _selectedOptionIndex;
  OptionState _optionState = OptionState.idle;
  bool _showHints = false;
  AdaptiveEvaluation? _activeEvaluation;
  VoiceRecognitionState _voiceState = VoiceRecognitionState.idle;
  final MockVoiceService _voiceService = MockVoiceService();

  // Tier change toast tracking
  int _lastTier = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  void _onBeatContinue(AppState appState) {
    HapticsService.lightImpact();
    final beats = appState.activeLevel?.storyBeats ?? [];

    if (_isOutroMode) {
      // Outro beat finished -> Navigate to Level Complete
      appState.completeLevel();
      Navigator.pushReplacementNamed(context, AppRoutes.levelComplete);
      return;
    }

    if (_currentBeatIndex < beats.length - 2) {
      setState(() {
        _currentBeatIndex++;
      });
    } else {
      // Transition from intro beats to question session
      setState(() {
        _isInBeatMode = false;
        _resetQuestionState();
      });
    }
  }

  void _resetQuestionState() {
    _selectedOptionIndex = null;
    _optionState = OptionState.idle;
    _showHints = false;
    _activeEvaluation = null;
    _voiceState = VoiceRecognitionState.idle;
  }

  void _onAnswerSelected(AppState appState, int index) {
    if (_activeEvaluation != null && _activeEvaluation!.isCorrect) return;

    final question = appState.getActiveQuestion();
    if (question == null) return;

    setState(() {
      _selectedOptionIndex = index;
    });

    final eval = appState.answerQuestion(index);

    setState(() {
      _activeEvaluation = eval;
      _optionState = eval.isCorrect ? OptionState.correct : OptionState.gentleTryAgain;
    });

    // Check if tier changed to show toast
    if (eval.nextTier != _lastTier) {
      _lastTier = eval.nextTier;
      final msg = eval.nextTier > _lastTier
          ? "You're getting really good at this! Let's try a tricky one! 🚀"
          : "Let's take one step back together. 🌱";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.navy,
          duration: const Duration(milliseconds: 1800),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onNextQuestionSlot(AppState appState) {
    HapticsService.lightImpact();
    final int currentSlot = appState.sessionQuestionSlot;

    if (currentSlot >= 4) {
      // 5 questions completed -> transition to outro beat
      setState(() {
        _isInBeatMode = true;
        _isOutroMode = true;
        final beats = appState.activeLevel?.storyBeats ?? [];
        _currentBeatIndex = beats.isNotEmpty ? beats.length - 1 : 0;
      });
    } else {
      appState.advanceToNextQuestionSlot();
      setState(() {
        _resetQuestionState();
      });
    }
  }

  void _startVoiceInput(AppState appState, QuestionModel question) async {
    setState(() {
      _voiceState = VoiceRecognitionState.listening;
    });

    final recognizedText = await _voiceService.listenForAnswer(
      question: question,
      forceMishear: appState.voiceMishearOnce,
      forceCorrect: appState.forcedAnswerOutcome,
    );

    if (!mounted) return;

    setState(() {
      _voiceState = VoiceRecognitionState.recognized;
    });

    // Show simulated recognition confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedCard),
        title: Row(
          children: [
            const Icon(Icons.record_voice_over_rounded, color: AppColors.indigo, size: 28),
            const SizedBox(width: 8),
            Text(
              AppStrings.youSaid.replaceAll('{text}', recognizedText),
              style: AppTextStyles.questionText.copyWith(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _voiceState = VoiceRecognitionState.idle;
              });
            },
            child: Text(AppStrings.sayItAgain, style: AppTextStyles.buttonSecondary),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.mint),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _voiceState = VoiceRecognitionState.idle;
              });

              // Match recognized text to option
              int matchedIdx = question.options.indexWhere(
                (o) => o.label.toUpperCase() == recognizedText.toUpperCase(),
              );
              if (matchedIdx == -1) {
                matchedIdx = question.correctIndex;
              }
              _onAnswerSelected(appState, matchedIdx);
            },
            child: Text(AppStrings.thatsRight, style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  void _onExitPressed() {
    HapticsService.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedCard),
        title: Text(AppStrings.pauseAdventureTitle, style: AppTextStyles.questionText),
        content: const Text(
          'Your progress in this adventure is waiting for you.',
          style: TextStyle(fontSize: 17),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.stayButton, style: AppTextStyles.buttonSecondary),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
            },
            child: Text(AppStrings.leaveButton, style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final level = appState.activeLevel ?? appState.currentCourse.getLevel(appState.student.currentLevel);
    final beats = level.storyBeats;
    final currentBeat = beats.isNotEmpty
        ? beats[_currentBeatIndex.clamp(0, beats.length - 1)]
        : const StoryBeat(id: 'def', narration: 'Let\'s explore together!');

    final question = appState.getActiveQuestion();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.inkSoft, size: 26),
                        onPressed: _onExitPressed,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Level ${level.number} · ${level.topic}',
                              style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.navy,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 5 Question Session Dots
                            AdventureProgressIndicator(
                              current: appState.sessionQuestionSlot + 1,
                              total: 5,
                              useStars: false,
                            ),
                          ],
                        ),
                      ),
                      AdaptiveDifficultyStars(tier: appState.currentTier),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: AppColors.inkSoft),
                        onSelected: (val) {
                          if (val == 'screen_off') {
                            Navigator.pushNamed(context, AppRoutes.screenOffSimulation);
                          } else if (val == 'step_by_step') {
                            appState.resolveQuestionWithHelp();
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'screen_off',
                            child: Row(
                              children: [
                                Icon(Icons.hearing_rounded, color: AppColors.indigo),
                                SizedBox(width: 8),
                                Text('Screen-Off Mode'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'step_by_step',
                            child: Row(
                              children: [
                                Icon(Icons.help_outline_rounded, color: AppColors.mint),
                                SizedBox(width: 8),
                                Text('Solve with NOVA'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Main Content Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: AppSpacing.sm),

                            // 1. Illustrated Scene (~40% height)
                            StoryCard(
                              sceneType: currentBeat.sceneType,
                              novaMood: _activeEvaluation != null
                                  ? (_activeEvaluation!.isCorrect ? NovaMood.celebrating : NovaMood.encouraging)
                                  : currentBeat.novaMood,
                              interactionType: currentBeat.interactionType,
                              itemsToCount: currentBeat.itemsToCount,
                              itemsToShare: currentBeat.itemsToShare,
                              basketCount: currentBeat.basketCount,
                              onActivityCompleted: () {
                                HapticsService.mediumImpact();
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // 2. Speech Bubble
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: SpeechBubble(
                                text: _isInBeatMode ? currentBeat.narration : (question?.prompt ?? ''),
                                speaker: 'NOVA',
                                typewriter: true,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Quick Simulate Emotion chips for fast evaluator testing
                            if (!_isInBeatMode)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      const Text('Simulate:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.inkSoft)),
                                      const SizedBox(width: 6),
                                      _buildQuickEmotionChip('🚀 Confident', EmotionState.confident, appState),
                                      _buildQuickEmotionChip('💡 Confused', EmotionState.confused, appState),
                                      _buildQuickEmotionChip('🌱 Frustrated', EmotionState.frustrated, appState),
                                    ],
                                  ),
                                ),
                              ),

                            // 3. Action Area
                            if (_isInBeatMode) ...[
                              const SizedBox(height: AppSpacing.xl),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                                child: PrimaryButton(
                                  label: _isOutroMode ? 'Complete Adventure 🎉' : AppStrings.nextButton,
                                  onPressed: () => _onBeatContinue(appState),
                                ),
                              ),
                            ] else if (question != null) ...[
                              // Active Question Area
                              if (_activeEvaluation != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  child: EmotionFeedbackCard(
                                    state: _activeEvaluation!.emotion,
                                    isCorrect: _activeEvaluation!.isCorrect,
                                    message: _activeEvaluation!.message,
                                    primaryLabel: _activeEvaluation!.isCorrect
                                        ? (_activeEvaluation!.emotion == EmotionState.confident
                                            ? AppStrings.nextChallenge
                                            : AppStrings.nextButton)
                                        : AppStrings.tryAgain,
                                    stepByStepSteps: _activeEvaluation!.stepByStepSteps,
                                    onPrimary: () {
                                      if (_activeEvaluation!.isCorrect) {
                                        _onNextQuestionSlot(appState);
                                      } else {
                                        setState(() {
                                          _activeEvaluation = null;
                                          _selectedOptionIndex = null;
                                          _optionState = OptionState.idle;
                                        });
                                      }
                                    },
                                    secondaryLabel: !_activeEvaluation!.isCorrect && !_showHints
                                        ? AppStrings.giveHint
                                        : null,
                                    onSecondary: () {
                                      setState(() {
                                        _showHints = true;
                                      });
                                    },
                                  ),
                                ),
                              ] else ...[
                                // Voice Mic Button
                                Center(
                                  child: VoiceButton(
                                    state: _voiceState,
                                    onTap: () => _startVoiceInput(appState, question),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),

                                // Progressive Hint Stack
                                if (_showHints)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                    child: HintCard(
                                      hints: question.hints,
                                      revealedCount: appState.currentQuestionHints == 0 ? 1 : appState.currentQuestionHints,
                                      onNextHint: () => appState.useHint(),
                                      onClose: () {
                                        setState(() {
                                          _showHints = false;
                                        });
                                      },
                                    ),
                                  ),

                                // Answer Options (3 choices)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  child: Column(
                                    children: List.generate(question.options.length, (idx) {
                                      return AnswerOptionWidget(
                                        option: question.options[idx],
                                        index: idx,
                                        state: _selectedOptionIndex == idx
                                            ? _optionState
                                            : OptionState.idle,
                                        onTap: () => _onAnswerSelected(appState, idx),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),

                                // Hint Trigger text button
                                if (!_showHints)
                                  Center(
                                    child: TextButton.icon(
                                      icon: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.indigo, size: 20),
                                      label: const Text(
                                        AppStrings.giveHint,
                                        style: TextStyle(color: AppColors.indigo, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      onPressed: () {
                                        HapticsService.selectionClick();
                                        appState.useHint();
                                        setState(() {
                                          _showHints = true;
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const DemoFab(),
        ],
      ),
    );
  }

  Widget _buildQuickEmotionChip(String label, EmotionState state, AppState appState) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: () {
          appState.setForcedEmotion(state);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Simulated $label for next answer!'),
              duration: const Duration(milliseconds: 1000),
            ),
          );
        },
      ),
    );
  }
}
