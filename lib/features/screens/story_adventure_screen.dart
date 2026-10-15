import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/nova_colors.dart';
import '../../core/design_system/nova_typography.dart';
import '../../core/design_system/nova_spacing.dart';
import '../../core/routing/orientation_helper.dart';
import '../../core/services/nova_audio_service.dart';
import 'package:lottie/lottie.dart';
import '../../nova_main/demo/demo_controls.dart';
import '../../core/widgets/nova/nova_button.dart';
import '../../core/widgets/nova/nova_matching_chip.dart';
import '../../core/widgets/nova/nova_matching_bezier_painter.dart';
import '../../core/widgets/nova/nova_pause_modal.dart';
import '../../core/widgets/nova/nova_progress_bar.dart';
import '../../core/widgets/nova/nova_speaker_button.dart';
import '../../core/widgets/nova/nova_village_painter.dart';
import '../../core/widgets/nova/nova_robot_mascot.dart';
import '../../features/diagnostic/adaptive_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../features/voice_engine/voice_answer_matcher.dart';
import '../../nova_main/services/app_state.dart';
import '../../core/models/nova_schema_models.dart';
import '../../core/data/nova_seed_catalog.dart';
import '../../core/services/bkt_game_master_engine.dart';
import '../../core/widgets/nova/banyan_grove_stage_widget.dart';
import '../../core/widgets/nova/nova_prop_animation_box.dart';
import 'level_road_screen.dart';

/// Flagship Landscape Story Engine implementing Screens 5 through 11:
/// - Screen 5: Rotate Phone Modal
/// - Screen 6: Village Story (Bilingual split screen)
/// - Screen 7: Big vs Small Quiz (Interactive selection & BKT engine)
/// - Screen 8: Touch the Bird (Interactive village canvas & celebration)
/// - Screen 9: Voice Activity (Vosk STT / Vernacular pronunciation & optional tap)
/// - Screen 10: Match the Following (Cubic bezier curve line-matching & multi-state chips)
/// - Screen 11: Level Celebration (Earned badges, stars, and high five)
class StoryAdventureScreen extends ConsumerStatefulWidget {
  final int initialLevelId;
  final int initialScreen;
  final bool startWithRotateModal;
  final GeneratedLevelContract? generatedLevelContract;

  const StoryAdventureScreen({
    super.key,
    this.initialLevelId = 1,
    this.initialScreen = 6,
    this.startWithRotateModal = true,
    this.generatedLevelContract,
  });

  @override
  ConsumerState<StoryAdventureScreen> createState() => _StoryAdventureScreenState();
}

class _StoryAdventureScreenState extends ConsumerState<StoryAdventureScreen> with TickerProviderStateMixin {
  // Screen 5 modal state
  late bool _showRotateModal;

  // Active Story Step: 6 (Story), 7 (Quiz), 8 (Bird), 9 (Voice), 10 (Matching), 11 (Celebration)
  late int _activeScreen;

  // Dynamic Level Contract & Telemetry Logs
  GeneratedLevelContract? _levelContract;
  final List<GameplayLogRecord> _levelLogs = [];
  bool _bktProcessed = false;

  // BKT Engine & Performance
  final DiagnosticManager _diagnosticManager = DiagnosticManager();
  final StudentPerformanceState _bktState = StudentPerformanceState(pMastery: 0.15, consecutiveFails: 0);
  late DateTime _stepStartTime;

  // Audio State
  NovaSpeakerState _speakerState = NovaSpeakerState.listen;

  // Micro-celebration confetti state
  bool _showConfettiPop = false;

  void _triggerConfettiPop() {
    setState(() {
      _showConfettiPop = true;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _showConfettiPop = false;
        });
      }
    });
  }

  // --- Story Progression Beat (Story Bridge / Filler) ---
  bool _showingStoryBridge = true;

  // --- Screen 7 Quiz State ---
  // null = idle, true = correct, false = retry
  bool? _quizAnswerOutcome;
  int? _selectedOptionIndex;

  // --- Screen 8 Bird / Tiger State ---
  bool _birdTapped = false;
  int _birdAttempts = 0;
  bool _wrongSpotFeedback = false;

  // --- Screen 9 Voice State ---
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  bool _voiceListening = false;
  bool _voiceSuccess = false;
  String _liveRecognizedTranscript = '';
  String? _voiceGentlePrompt;
  Timer? _voiceFallbackTimer;
  String _voiceLocaleId = 'mr_IN';

  // --- Screen 10 Matching State ---
  Map<int, int> get _activeCorrectMatches {
    return const {0: 0, 1: 1, 2: 2};
  }

  final List<MatchConnection> _establishedConnections = [];
  int? _selectedLeftChip;
  int? _selectedRightChip;
  bool? _matchingOutcome; // true = success, false = incorrect retry, null = selecting
  Offset? _activeDragStart;
  Offset? _activeDragCurrent;

  final Map<int, GlobalKey> _leftSocketKeys = {0: GlobalKey(), 1: GlobalKey(), 2: GlobalKey()};
  final Map<int, GlobalKey> _rightSocketKeys = {0: GlobalKey(), 1: GlobalKey(), 2: GlobalKey()};
  final GlobalKey _matchingStackKey = GlobalKey();

  // Animation controller for pulsing mic and rings
  late AnimationController _pulseController;

  GeneratedSceneContract? _getScene(int index) {
    if (_levelContract != null &&
        _levelContract!.scenes.isNotEmpty &&
        index >= 0 &&
        index < _levelContract!.scenes.length) {
      return _levelContract!.scenes[index];
    }
    return null;
  }

  void _recordStepLog({
    required String defaultQuestionId,
    required bool isCorrect,
    required int attempts,
  }) {
    final sceneIndex = _activeScreen - 6;
    final scene = _getScene(sceneIndex);
    final qId = (scene?.questionData.originalQuestionId.isNotEmpty == true)
        ? scene!.questionData.originalQuestionId
        : defaultQuestionId;
    final timeTakenSec = DateTime.now().difference(_stepStartTime).inSeconds;

    _levelLogs.add(
      GameplayLogRecord(
        logId: 'log_${DateTime.now().millisecondsSinceEpoch}_$qId',
        userId: 'usr_default_01',
        questionId: qId,
        isCorrect: isCorrect,
        attempts: attempts,
        timeTakenSec: timeTakenSec,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _processBktOnCelebration() {
    if (_bktProcessed) return;
    _bktProcessed = true;

    try {
      final bktEvaluator = ref.read(bktMasteryEvaluatorProvider);
      bktEvaluator.processCompletedLevelLogs(_levelLogs);
    } catch (e) {
      debugPrint('BKT celebration sync error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _showRotateModal = widget.startWithRotateModal && widget.initialScreen == 6;
    _activeScreen = widget.initialScreen;
    _showingStoryBridge = (widget.initialScreen >= 7 && widget.initialScreen <= 10);
    if (!_showRotateModal) {
      OrientationHelper.lockLandscape();
    }
    _stepStartTime = DateTime.now();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _levelContract = widget.generatedLevelContract ??
        (widget.initialLevelId == 2
            ? NovaSeedCatalog.level2BanyanGroveContract
            : NovaSeedCatalog.level1VillageMorningContract);

    NovaAudioService.instance.isPlayingNotifier.addListener(_onTtsStateChanged);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voiceFallbackTimer?.cancel();
    _speech.stop();
    NovaAudioService.instance.isPlayingNotifier.removeListener(_onTtsStateChanged);
    OrientationHelper.lockPortrait();
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

  void _onDismissRotateModal() {
    setState(() {
      _showRotateModal = false;
    });
    OrientationHelper.lockLandscape();
    _playScreenAudio();
  }

  String _getStoryBridgeMarathi(int screenNumber) {
    final scene = _getScene(screenNumber - 6);
    final intro = scene?.questionData.storyBridgeIntro;
    if (intro != null && intro.trim().isNotEmpty) {
      return intro;
    }
    final isLevel2 = widget.initialLevelId == 2;
    switch (screenNumber) {
      case 7:
        return isLevel2
            ? "वाघोबाला मदत केल्यावर चिंटू गावातील डेअरीमध्ये पोहोचला. तिथे कपिला गाय उभी आहे आणि ताजे दूध तयार आहे!"
            : "चिवताईचे गाणे ऐकून चिंटू अंगणात आला. आता शेतात जाण्यासाठी ट्रॅक्टर आणि सायकल तयार आहेत!";
      case 8:
        return isLevel2
            ? "डेअरीमध्ये गोड दूध पाहिले! आता वडाच्या झाडाखाली सावलीत कोण विश्रांती घेत आहे ते शोधूया!"
            : "ट्रॅक्टर आणि सायकल पाहून झाली! आता छतावर कोण गोड गाणे गात आहे ते शोधूया!";
      case 9:
        return isLevel2
            ? "वाघोबाने शेपूट हलवली! आता डेअरी काका विचारत आहेत आपल्याला किती दूध हवे आहे. माईकमध्ये सांगूया!"
            : "चिवताईने पंख फडफडवले! वाटेत चिंटूला त्याचा मित्र नोव्हा भेटला. चला, त्याला प्रेमाने नमस्कार करूया!";
      case 10:
        return isLevel2
            ? "छान बोललास! आता शेतातील, बागेतील आणि डेअरीतील सर्व वस्तूंच्या योग्य जोड्या लावूया!"
            : "वाह! खूप छान आवाज! सकाळची सर्व कामे झाली. आता आपण पाहिलेल्या सर्व गोष्टींच्या जोड्या जुळवूया!";
      default:
        return "";
    }
  }

  String _getStoryBridgeEnglish(int screenNumber) {
    final isLevel2 = widget.initialLevelId == 2;
    switch (screenNumber) {
      case 7:
        return isLevel2
            ? "After helping tiger friend, Chintu reached the village dairy. The cow has fresh milk!"
            : "Hearing Chiu sing, Chintu came to the yard. Tractor and bicycle are ready!";
      case 8:
        return isLevel2
            ? "We checked the fresh milk! Now let us find who is resting under the shady banyan tree!"
            : "We inspected the vehicles! Now let us find who is singing sweetly on the rooftop!";
      case 9:
        return isLevel2
            ? "Tiger wagged his tail! Now dairy uncle asks how much milk we need. Say it into the mic!"
            : "Chiu flapped her wings! On the path, Chintu met Nova. Let us say good morning!";
      case 10:
        return isLevel2
            ? "Superb! Now let us match each farm, garden, and dairy item to its place!"
            : "Wonderful voice! Now let us match the morning items together!";
      default:
        return "";
    }
  }

  void _playScreenAudio() {
    if (_showingStoryBridge && _activeScreen >= 7 && _activeScreen <= 10) {
      final bridgeText = _getStoryBridgeMarathi(_activeScreen);
      NovaAudioService.instance.speakCleanText(bridgeText);
      return;
    }
    _playScreenQuestionAudio();
  }

  void _playScreenQuestionAudio() {
    final scene = _getScene(_activeScreen - 6);
    switch (_activeScreen) {
      case 6:
        final text = (scene?.narrativeText.isNotEmpty == true)
            ? scene!.narrativeText
            : (widget.initialLevelId == 2
                ? "वडाच्या झाडाखाली चिंटू आणि नोव्हा भेटले आहेत"
                : "सूर्याची सोनेरी किरणे आली गाव जागे झाले चिवताई छतावर गाऊ लागली");
        NovaAudioService.instance.speakCleanText(
          text,
          dedicatedMarathiText: scene?.questionData.ttsMarathiText,
        );
        break;
      case 7:
        final text = (scene?.questionData.storyQuestionText.isNotEmpty == true)
            ? scene!.questionData.storyQuestionText
            : (widget.initialLevelId == 2
                ? "यातील मोठी वस्तू कोणती गाय की दुधाचा डबा"
                : "यातील मोठी वस्तू कोणती ट्रॅक्टर की सायकल");
        NovaAudioService.instance.speakCleanText(
          text,
          dedicatedMarathiText: scene?.questionData.ttsMarathiText,
        );
        break;
      case 8:
        final text = (scene?.questionData.storyQuestionText.isNotEmpty == true)
            ? scene!.questionData.storyQuestionText
            : (widget.initialLevelId == 2
                ? "झाडाखाली कोण बसले आहे वाघोबाला टॅप करा"
                : "छतावर कोण बसले आहे चिवताईला टॅप करा");
        NovaAudioService.instance.speakCleanText(
          text,
          dedicatedMarathiText: scene?.questionData.ttsMarathiText,
        );
        break;
      case 9:
        final text = (scene?.questionData.storyQuestionText.isNotEmpty == true)
            ? scene!.questionData.storyQuestionText
            : (widget.initialLevelId == 2
                ? "आपल्याला तीन दुधाचे डबे हवे आहेत माईकमध्ये तीन बोला"
                : "मित्राला भेटल्यावर काय म्हणायचे माईकमध्ये शुभ प्रभात बोला");
        NovaAudioService.instance.speakCleanText(
          text,
          dedicatedMarathiText: scene?.questionData.ttsMarathiText,
        );
        break;
      case 10:
        final text = (scene?.questionData.storyQuestionText.isNotEmpty == true)
            ? scene!.questionData.storyQuestionText
            : (widget.initialLevelId == 2
                ? "बागेतील आणि डेअरीतील योग्य जोड्या जुळवा"
                : "सकाळच्या गोष्टींच्या योग्य जोड्या जुळवा");
        NovaAudioService.instance.speakCleanText(
          text,
          dedicatedMarathiText: scene?.questionData.ttsMarathiText,
        );
        break;
      case 11:
        NovaAudioService.instance.speakCleanText(
          widget.initialLevelId == 2
              ? "खूप छान तू दुसरी पातळी जिंकलीस अभिनंदन"
              : "खूप छान तू पहिली पातळी जिंकलीस अभिनंदन",
        );
        break;
    }
  }

  void _handleExit() {
    NovaPauseModal.show(
      context,
      onResume: () {},
      onHome: () {
        OrientationHelper.lockPortrait();
        Navigator.of(context).maybePop();
      },
    );
  }

  // --- Real-time Per-Question BKT Adaptation & Narrative Filler Weaver ---
  void _adaptNextBeat({
    required int currentBeat,
    required int nextBeat,
    required int nextScreenIndex,
    required String skillId,
    required bool isCorrect,
  }) {
    try {
      final int nextTier = ref
          .read(bktMasteryEvaluatorProvider)
          .evaluateSingleAnswerAndGetNextTier(
            skillId: skillId,
            isCorrectFirstTry: isCorrect,
          );

      if (_levelContract != null &&
          _levelContract!.scenes.length > nextScreenIndex) {
        final QuestionCandidate? nextQ = NovaSeedCatalog.getQuestionForBeat(
          levelId: widget.initialLevelId,
          beatIndex: nextBeat,
          difficultyTier: nextTier,
        );

        final String fillerBridge = NovaSeedCatalog.buildMarathiFillerBridge(
          levelId: widget.initialLevelId,
          fromBeat: currentBeat,
          toBeat: nextBeat,
          gotPreviousCorrect: isCorrect,
        );

        if (nextQ != null) {
          final currentNextScene = _levelContract!.scenes[nextScreenIndex];
          final updatedScene = currentNextScene.copyWith(
            narrativeText: fillerBridge,
            questionData: currentNextScene.questionData.copyWith(
              questionType: nextQ.questionType,
              originalQuestionId: nextQ.questionId,
              storyQuestionText: nextQ.coreLogicText,
              options: nextQ.payloadData['options'] != null
                  ? List<String>.from(nextQ.payloadData['options'])
                  : currentNextScene.questionData.options,
              correctAnswer: (nextQ.payloadData['correct_answer'] ??
                      nextQ.payloadData['expected_phrase'] ??
                      currentNextScene.questionData.correctAnswer)
                  .toString(),
              explanationHint: nextQ.payloadData['explanation_hint']?.toString(),
              payloadData: nextQ.payloadData,
              storyBridgeIntro: nextQ.storyBridgeIntro,
              ttsMarathiText: nextQ.ttsMarathiText,
            ),
          );

          final updatedScenes =
              List<GeneratedSceneContract>.from(_levelContract!.scenes);
          updatedScenes[nextScreenIndex] = updatedScene;
          if (!mounted) return;
          setState(() {
            _levelContract = _levelContract!.copyWith(scenes: updatedScenes);
          });
        }
      }
    } catch (e) {
      debugPrint('Real-time BKT adaptation error: $e');
    }
  }

  // --- Step 7 Quiz Handlers ---
  void _onOptionSelected(int selectedIndex) {
    final scene = _getScene(1);
    final isLevel2 = widget.initialLevelId == 2;
    final List<String> options = (scene?.questionData.options != null &&
            scene!.questionData.options!.length >= 2)
        ? scene.questionData.options!
        : (isLevel2 ? ['गाय', 'दुधाचा डबा'] : ['ट्रॅक्टर', 'सायकल']);

    final String correctAnswer = (scene?.questionData.correctAnswer != null &&
            scene!.questionData.correctAnswer.isNotEmpty)
        ? scene.questionData.correctAnswer
        : options[0];

    final selected = options[selectedIndex].trim().toLowerCase();
    final target = correctAnswer.trim().toLowerCase();
    final bool isCorrect = (selected == target) ||
        (selected.contains(target) || target.contains(selected));

    final timeMs = DateTime.now().difference(_stepStartTime).inMilliseconds;
    _diagnosticManager.evaluateResponse(isCorrect, timeMs, _bktState);

    final qId = scene?.questionData.originalQuestionId.isNotEmpty == true
        ? scene!.questionData.originalQuestionId
        : (isLevel2 ? 'Q_GROVE_02_T1' : 'Q_VILL_02_T1');

    _recordStepLog(
      defaultQuestionId: qId,
      isCorrect: isCorrect,
      attempts: 1,
    );

    // Real-time BKT adaptation for Screen 8 (Beat 1 Spot Item)
    _adaptNextBeat(
      currentBeat: 2,
      nextBeat: 1,
      nextScreenIndex: 2,
      skillId: 'MATH_COMPARE_01',
      isCorrect: isCorrect,
    );

    setState(() {
      _selectedOptionIndex = selectedIndex;
      _quizAnswerOutcome = isCorrect;
    });

    if (isCorrect) {
      _triggerConfettiPop();
      final String correctFeedback = scene?.questionData.payloadData?['correct_feedback_marathi'] ??
          (scene?.questionData.explanationHint?.isNotEmpty == true
              ? 'शाब्बास! ${scene!.questionData.explanationHint}'
              : (isLevel2
                  ? "शाब्बास! गाय मोठी आहे!"
                  : "शाब्बास! ट्रॅक्टर मोठा आहे!"));
      NovaAudioService.instance.speakCleanText(correctFeedback);
    } else {
      final String wrongFeedback = scene?.questionData.payloadData?['wrong_feedback_marathi'] ??
          (isLevel2
              ? "दुधाचा डबा लहान आहे! मोठी वस्तू कोणती ते पुन्हा निवड!"
              : "सायकल लहान आहे! मोठी वस्तू कोणती ते पुन्हा निवड!");
      NovaAudioService.instance.speakCleanText(wrongFeedback);
    }
  }

  // --- Step 8 Bird Handlers ---
  void _onWrongSpotTapped() {
    if (_birdTapped) return;
    _birdAttempts++;
    setState(() {
      _wrongSpotFeedback = true;
    });

    final isLevel2 = widget.initialLevelId == 2;
    final hint = isLevel2
        ? "तिथे नाही! तो वाघोबा नाही. झाडाखाली चमकणाऱ्या वर्तुळात बघ!"
        : "तिथे नाही! ती चिवताई नाही. छतावर चमकणाऱ्या वर्तुळात बघ!";

    NovaAudioService.instance.speakCleanText(hint);
  }

  void _tapBird() {
    if (_birdTapped) return;
    _birdAttempts++;
    setState(() {
      _birdTapped = true;
      _wrongSpotFeedback = false;
    });

    final scene = _getScene(2);
    final qId = scene?.questionData.originalQuestionId.isNotEmpty == true
        ? scene!.questionData.originalQuestionId
        : (widget.initialLevelId == 2 ? 'Q_GROVE_01_T1' : 'Q_VILL_01_T1');

    _recordStepLog(
      defaultQuestionId: qId,
      isCorrect: true,
      attempts: _birdAttempts,
    );
    _triggerConfettiPop();

    // Real-time BKT adaptation for Screen 9 (Beat 3 Voice Activity)
    _adaptNextBeat(
      currentBeat: 1,
      nextBeat: 3,
      nextScreenIndex: 3,
      skillId: 'MATH_COUNT_01',
      isCorrect: true,
    );

    NovaAudioService.instance.speakCleanText(
      widget.initialLevelId == 2
          ? "शाब्बास! वाघोबा झाडाखाली बसला आहे!"
          : "शाब्बास! वर! चिवताई छतावर बसली आहे!",
    );
  }

  // --- Step 9 Voice Handlers ---
  Future<void> _initSpeechIfNeeded() async {
    if (_speechInitialized) return;
    try {
      final available = await _speech.initialize(
        onError: (val) {
          debugPrint('STT error: ${val.errorMsg}');
          if (mounted && _voiceListening && !_voiceSuccess) {
            setState(() {
              _voiceListening = false;
              _voiceGentlePrompt = "पुन्हा बोलून बघ किंवा खालील बटण दाब";
            });
          }
        },
        onStatus: (status) {
          debugPrint('STT status: $status');
          if ((status == 'notListening' || status == 'done') && mounted) {
            if (_voiceListening && !_voiceSuccess) {
              setState(() => _voiceListening = false);
            }
          }
        },
      );

      if (available) {
        _speechInitialized = true;
        try {
          final systemLocales = await _speech.locales();
          final hasMarathi = systemLocales
              .any((loc) => loc.localeId.toLowerCase().startsWith('mr'));
          final hasHindi = systemLocales
              .any((loc) => loc.localeId.toLowerCase().startsWith('hi'));
          if (hasMarathi) {
            _voiceLocaleId = systemLocales
                .firstWhere(
                    (loc) => loc.localeId.toLowerCase().startsWith('mr'))
                .localeId;
          } else if (hasHindi) {
            _voiceLocaleId = systemLocales
                .firstWhere(
                    (loc) => loc.localeId.toLowerCase().startsWith('hi'))
                .localeId;
          } else {
            _voiceLocaleId = 'en_IN';
          }
        } catch (_) {
          _voiceLocaleId = 'mr_IN';
        }
      }
    } catch (e) {
      debugPrint('Speech init failed: $e');
    }
  }

  Future<void> _triggerVoiceInput() async {
    if (_voiceSuccess) return;

    // 1. Stop any active TTS so the mic does not record the app's own speaker
    await NovaAudioService.instance.stop();

    final scene = _getScene(3);
    final expectedPhrase = scene?.questionData.correctAnswer ??
        (widget.initialLevelId == 2 ? "तीन" : "शुभ प्रभात");

    await _initSpeechIfNeeded();

    if (!_speechInitialized || !_speech.isAvailable) {
      if (mounted) {
        setState(() {
          _voiceListening = false;
          _voiceGentlePrompt = "पुन्हा बोलून बघ: '$expectedPhrase' किंवा खालील बटण दाब";
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _voiceListening = true;
        _voiceGentlePrompt = null;
        _liveRecognizedTranscript = '';
      });
    }

    // 6-second gentle timeout for silence or no speech
    _voiceFallbackTimer?.cancel();
    _voiceFallbackTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _voiceSuccess) return;
      _speech.stop();
      setState(() {
        _voiceListening = false;
        _voiceGentlePrompt = "पुन्हा स्पष्ट आवाजात बोलून बघ!";
      });
      NovaAudioService.instance.speakCleanText("पुन्हा स्पष्ट आवाजात बोलून बघ!");
    });

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          final spoken = result.recognizedWords;
          setState(() {
            _liveRecognizedTranscript = spoken;
          });

          final variants = VoiceAnswerMatcher.getVariantsForExpected(expectedPhrase);
          final bool matches = VoiceAnswerMatcher.evaluateAnswer(spoken, expectedPhrase) ||
              VoiceAnswerMatcher.evaluateAnswerAgainstVariants(spoken, variants);

          if (matches) {
            _handleVoiceSuccess(expectedPhrase);
          } else if (result.finalResult && spoken.trim().length >= 2) {
            _voiceFallbackTimer?.cancel();
            _speech.stop();
            setState(() {
              _voiceListening = false;
              _voiceGentlePrompt = "पुन्हा स्पष्ट आवाजात बोलून बघ!";
            });
            NovaAudioService.instance.speakCleanText("पुन्हा स्पष्ट आवाजात बोलून बघ!");
          }
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.confirmation,
        ),
        // ignore: deprecated_member_use
        localeId: _voiceLocaleId,
      );
    } catch (e) {
      debugPrint('STT listen error: $e');
      if (mounted) {
        setState(() {
          _voiceListening = false;
          _voiceGentlePrompt = "पुन्हा स्पष्ट आवाजात बोलून बघ!";
        });
      }
    }
  }

  void _handleVoiceSuccess(String expectedPhrase) {
    if (_voiceSuccess) return;
    _voiceFallbackTimer?.cancel();
    _speech.stop();

    final scene = _getScene(3);
    final qId = scene?.questionData.originalQuestionId.isNotEmpty == true
        ? scene!.questionData.originalQuestionId
        : (widget.initialLevelId == 2 ? 'Q_GROVE_03_T1' : 'Q_VILL_03_T1');

    _recordStepLog(
      defaultQuestionId: qId,
      isCorrect: true,
      attempts: 1,
    );

    if (mounted) {
      setState(() {
        _voiceListening = false;
        _voiceSuccess = true;
        _voiceGentlePrompt = null;
      });
    }

    _triggerConfettiPop();

    // Real-time BKT adaptation for Screen 10 (Beat 4 Matching)
    _adaptNextBeat(
      currentBeat: 3,
      nextBeat: 4,
      nextScreenIndex: 4,
      skillId: widget.initialLevelId == 2 ? 'MATH_ADD_01' : 'LANG_MARATHI_01',
      isCorrect: true,
    );

    NovaAudioService.instance.speak("शाब्बास! $expectedPhrase!");

    // Smooth auto-advance after celebration audio finishes
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _activeScreen == 9 && _voiceSuccess) {
        _goToScreen(10);
      }
    });
  }

  void _handleVoiceFallbackTap() {
    final scene = _getScene(3);
    final expectedPhrase = scene?.questionData.correctAnswer ??
        (widget.initialLevelId == 2 ? "तीन" : "शुभ प्रभात");
    _handleVoiceSuccess(expectedPhrase);
  }

  // --- Step 10 Matching Handlers ---
  void _onLeftChipTapped(int index) {
    if (_establishedConnections.any((c) => c.leftIndex == index)) return;
    setState(() {
      _selectedLeftChip = index;
      _matchingOutcome = null;
    });
    if (_selectedRightChip != null) {
      _evaluateMatch(index, _selectedRightChip!);
    }
  }

  void _onRightChipTapped(int index) {
    if (_establishedConnections.any((c) => c.rightIndex == index)) return;
    setState(() {
      _selectedRightChip = index;
      _matchingOutcome = null;
    });
    if (_selectedLeftChip != null) {
      _evaluateMatch(_selectedLeftChip!, index);
    }
  }

  void _evaluateMatch(int leftIdx, int rightIdx) {
    final bool isCorrect = _activeCorrectMatches[leftIdx] == rightIdx;

    if (isCorrect) {
      Color curveColor;
      if (leftIdx == 0) {
        curveColor = NovaColors.goldDark;
      } else if (leftIdx == 1) {
        curveColor = NovaColors.purple;
      } else {
        curveColor = const Color(0xFF0D9488); // Teal
      }

      setState(() {
        _establishedConnections.add(
          MatchConnection(leftIndex: leftIdx, rightIndex: rightIdx, color: curveColor),
        );
        _selectedLeftChip = null;
        _selectedRightChip = null;
        _matchingOutcome = true;
      });
      _triggerConfettiPop();

      if (_establishedConnections.length == 3) {
        final scene = _getScene(4);
        final qId = scene?.questionData.originalQuestionId.isNotEmpty == true
            ? scene!.questionData.originalQuestionId
            : (widget.initialLevelId == 2 ? 'Q_GROVE_04_T1' : 'Q_VILL_04_T1');

        _recordStepLog(
          defaultQuestionId: qId,
          isCorrect: true,
          attempts: 1,
        );
        try {
          ref.read(bktMasteryEvaluatorProvider).evaluateSingleAnswerAndGetNextTier(
            skillId: widget.initialLevelId == 2 ? 'MATH_ADD_01' : 'LANG_MARATHI_01',
            isCorrectFirstTry: true,
          );
        } catch (_) {}
        NovaAudioService.instance.speak("शाब्बास! सगळ्या जोड्या जुळल्या!");
      } else {
        NovaAudioService.instance.speak("छान! बरोबर जोडी!");
      }
    } else {
      setState(() {
        _matchingOutcome = false;
      });
      NovaAudioService.instance.speak("पुन्हा बघूया! दुसरी जोडी निवडा.");
    }
  }

  Offset? _getSocketCenter(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = _matchingStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || stackBox == null) return null;
    final globalPos = renderBox.localToGlobal(Offset.zero);
    final localPos = stackBox.globalToLocal(globalPos);
    return Offset(localPos.dx + renderBox.size.width / 2, localPos.dy + renderBox.size.height / 2);
  }

  void _goToScreen(int screenNumber) {
    if (!mounted) return;
    NovaAudioService.instance.stop();
    _speech.stop();
    _voiceFallbackTimer?.cancel();
    setState(() {
      _activeScreen = screenNumber;
      _showingStoryBridge = (screenNumber >= 7 && screenNumber <= 10);
      _stepStartTime = DateTime.now();
      _quizAnswerOutcome = null;
      _selectedOptionIndex = null;
      _birdTapped = false;
      _birdAttempts = 0;
      _wrongSpotFeedback = false;
      _voiceListening = false;
      _voiceSuccess = false;
      _liveRecognizedTranscript = '';
      _voiceGentlePrompt = null;
      if (screenNumber == 6) {
        _establishedConnections.clear();
        _selectedLeftChip = null;
        _selectedRightChip = null;
        _matchingOutcome = null;
      }
    });
    if (screenNumber == 11) {
      _processBktOnCelebration();
    }
    _playScreenAudio();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    // If Screen 5 modal is active, display it over blurred level road background
    if (_showRotateModal) {
      return _buildScreen5RotateModal();
    }

    return Scaffold(
      backgroundColor: NovaColors.cream,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top Global Landscape Header Bar
                _buildLandscapeHeader(appState),
                // Main Content Screen Router
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: _buildActiveScreenContent(appState),
                  ),
                ),
              ],
            ),
          ),
          if (_showConfettiPop)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/Confetti Pop.json',
                    repeat: false,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 5: ROTATE PHONE MODAL
  // ===========================================================================
  Widget _buildScreen5RotateModal() {
    return Scaffold(
      backgroundColor: const Color(0xFF1B162E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background vector landscape
          const Opacity(
            opacity: 0.35,
            child: CustomPaint(
              size: Size.infinite,
              painter: VillageRoadPainter(),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 680),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: NovaColors.cream,
                  borderRadius: NovaSpacing.roundedModal,
                  border: Border.all(color: Colors.white, width: 4.0),
                  boxShadow: NovaSpacing.modalShadow,
                ),
                child: Row(
                  children: [
                    // Rotating phone graphic and mascot
                    Expanded(
                      flex: 4,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Rotating phone visual
                          Transform.rotate(
                            angle: -0.25,
                            child: Container(
                              width: 100,
                              height: 60,
                              decoration: BoxDecoration(
                                color: NovaColors.purple,
                                borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3D271C44),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.crop_landscape_rounded, color: Colors.white, size: 34),
                            ),
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .rotate(begin: -0.1, end: 0.1, duration: 1200.ms, curve: Curves.easeInOut),

                        // Animated Lottie NOVA mascot
                        Positioned(
                          bottom: 0,
                          left: 10,
                          child: Lottie.asset(
                            'assets/lottie/Robot says hello.json',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Modal Instructions & CTA
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.initialLevelId == 2
                              ? 'NOVA • BANYAN GROVE & DAIRY • LEVEL 2'
                              : 'NOVA • MAJHE GAON • LEVEL 1',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: NovaColors.purple,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Text(
                                'गोष्ट पाहण्यासाठी फोन आडवा करा!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: NovaColors.ink,
                                ),
                              ),
                            ),
                            NovaSpeakerButton(
                              state: _speakerState,
                              onTap: () {
                                NovaAudioService.instance.speak("गोष्ट पाहण्यासाठी फोन आडवा करा!");
                              },
                              size: 38,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '(Turn your phone sideways for the story!)',
                          style: NovaTypography.bodySecondary,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: NovaColors.purpleLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.initialLevelId == 2
                                ? 'चिंटू, वाघोबा आणि NOVA तयार आहेत!'
                                : 'चिंटू आणि NOVA तयार आहेत!',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: NovaColors.purple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        NovaButton(
                          label: 'पुढे चला -> (Continue)',
                          variant: NovaButtonVariant.primary,
                          height: 44,
                          onPressed: _onDismissRotateModal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  // ===========================================================================
  // GLOBAL LANDSCAPE HEADER
  // ===========================================================================
  Widget _buildLandscapeHeader(AppState appState) {
    final bool isLevel2 = widget.initialLevelId == 2;
    String title = isLevel2 ? 'वडाचे झाड आणि डेअरी' : 'गावाची सफर';
    String subtitle = isLevel2 ? 'NOVA • BANYAN GROVE / Dairy story' : 'NOVA • MAJHE GAON / Village story';
    int progressStep = 1;
    String? statusBadge;
    Color statusBadgeColor = NovaColors.goldLight;
    Color statusTextColor = NovaColors.goldDark;

    switch (_activeScreen) {
      case 6:
        title = isLevel2 ? 'वडाचे झाड आणि डेअरी' : 'गावाची सफर';
        subtitle = isLevel2 ? 'NOVA • BANYAN GROVE / Story' : 'NOVA • MAJHE GAON / Village story';
        progressStep = 1;
        break;
      case 7:
        title = isLevel2 ? 'आंबे मोजणी' : 'मोठे आणि छोटे';
        subtitle = isLevel2 ? 'NOVA • BANYAN GROVE / Counting' : 'NOVA • MAJHE GAON / Big & small';
        progressStep = 2;
        if (_quizAnswerOutcome == true) {
          statusBadge = 'QUIZ • CORRECT';
          statusBadgeColor = const Color(0xFFFEF3C7);
          statusTextColor = const Color(0xFFB45309);
        } else if (_quizAnswerOutcome == false) {
          statusBadge = 'QUIZ • RETRY';
          statusBadgeColor = const Color(0xFFFEE2E2);
          statusTextColor = const Color(0xFFDC2626);
        }
        break;
      case 8:
        title = isLevel2 ? 'वाघोबा कुठे आहे?' : 'चिवताई कुठे आहे?';
        subtitle = isLevel2 ? 'NOVA • BANYAN GROVE / Find Tiger' : 'NOVA • MAJHE GAON / Find Chiu';
        progressStep = 3;
        if (_birdTapped) {
          statusBadge = isLevel2 ? 'TIGER • CELEBRATION' : 'BIRD • CELEBRATION';
          statusBadgeColor = const Color(0xFFFEF3C7);
          statusTextColor = const Color(0xFFB45309);
        }
        break;
      case 9:
        title = isLevel2 ? 'गाईचे दूध' : 'सकाळचा नमस्कार';
        subtitle = isLevel2 ? 'NOVA • DAIRY / Fresh milk' : 'NOVA • MAJHE GAON / Good morning';
        progressStep = 4;
        if (_voiceSuccess) {
          statusBadge = 'VOICE • SUCCESS';
          statusBadgeColor = const Color(0xFFFEF3C7);
          statusTextColor = const Color(0xFFB45309);
        }
        break;
      case 10:
        title = 'जोड्या जुळवा!';
        subtitle = isLevel2 ? 'NOVA • DAIRY / Match the following' : 'NOVA • MAJHE GAON / Match the following';
        progressStep = 5;
        if (_establishedConnections.length == 3) {
          statusBadge = 'MATCH • COMPLETED';
          statusBadgeColor = const Color(0xFFFEF3C7);
          statusTextColor = const Color(0xFFB45309);
        } else if (_matchingOutcome == false) {
          statusBadge = 'MATCH • TRY AGAIN';
          statusBadgeColor = const Color(0xFFFEE2E2);
          statusTextColor = const Color(0xFFDC2626);
        } else if (_selectedLeftChip != null || _selectedRightChip != null) {
          statusBadge = 'MATCH • SELECTED';
          statusBadgeColor = const Color(0xFFFEF3C7);
          statusTextColor = const Color(0xFFB45309);
        }
        break;
      case 11:
        title = isLevel2 ? 'वडाचे झाड • शाब्बास!' : 'माझे गाव • शाब्बास!';
        subtitle = isLevel2 ? 'NOVA • BANYAN GROVE / Level 2 complete' : 'NOVA • MAJHE GAON / Level 1 complete';
        progressStep = 5;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        children: [
          // Home button
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: NovaColors.purpleBorder.withValues(alpha: 0.6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C271C44),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: _handleExit,
              child: Row(
                children: const [
                  Icon(Icons.home_rounded, color: NovaColors.purple, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: NovaColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: NovaColors.inkSoft,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Active feedback badge if any
          if (statusBadge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusBadgeColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                statusBadge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: statusTextColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Segmented Progress Bar
          NovaProgressBar(
            currentStep: progressStep,
            totalSteps: 5,
            dashWidth: 22,
            dashHeight: 7,
          ),
          const SizedBox(width: 10),

          // Mute Button
          ValueListenableBuilder<bool>(
            valueListenable: NovaAudioService.instance.isMutedNotifier,
            builder: (context, isMuted, _) {
              return NovaSpeakerButton(
                state: isMuted ? NovaSpeakerState.mute : NovaSpeakerState.listen,
                label: 'Mute',
                onTap: () {
                  NovaAudioService.instance.toggleMute();
                },
                size: 38,
              );
            },
          ),
          const SizedBox(width: 8),

          // Evaluator Demo Controls Button
          GestureDetector(
            onTap: () => DemoControlsSheet.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: NovaColors.purpleLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NovaColors.purple.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.build_rounded, size: 15, color: NovaColors.purple),
                  SizedBox(width: 4),
                  Text(
                    'Demo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: NovaColors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ROUTER FOR ACTIVE SCREEN
  // ===========================================================================
  Widget _buildActiveScreenContent(AppState appState) {
    switch (_activeScreen) {
      case 6:
        return _buildScreen6VillageStory();
      case 7:
        return _buildScreen7BigVsSmallQuiz();
      case 8:
        return _buildScreen8TouchBird();
      case 9:
        return _buildScreen9VoiceActivity();
      case 10:
        return _buildScreen10MatchFollowing();
      case 11:
        return _buildScreen11Celebration(appState);
      default:
        return _buildScreen6VillageStory();
    }
  }

  // ===========================================================================
  // ===========================================================================
  // REUSABLE RICH VILLAGE CANVAS (Screen 6 & Screen 8)
  // ===========================================================================
  Widget _buildVillageCanvas({bool isInteractiveBird = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: NovaSpacing.roundedCard,
        boxShadow: NovaSpacing.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: NovaSpacing.roundedCard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cardW = constraints.maxWidth;
            final double cardH = constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Rich 3D Village Background Artwork with wrong-spot detection (cropped top 8% to cleanly eliminate cut-off text)
                Positioned(
                  top: -cardH * 0.08,
                  left: 0,
                  right: 0,
                  bottom: -cardH * 0.02,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (isInteractiveBird && !_birdTapped) ? _onWrongSpotTapped : null,
                    child: Image.asset(
                      'assets/images/village_story_bg.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => const CustomPaint(
                        size: Size.infinite,
                        painter: VillageScenePainter(),
                      ),
                    ),
                  ),
                ),

                // Screen 8 Interactive Chiu Target: ONLY glowing golden pulsing ring over painted bird
                if (isInteractiveBird) ...[
                  Positioned(
                    left: cardW * 0.54 - 40,
                    top: cardH * 0.32 - 40,
                    child: GestureDetector(
                      onTap: _tapBird,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _birdTapped ? NovaColors.green : NovaColors.gold,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_birdTapped ? NovaColors.green : NovaColors.gold).withValues(alpha: 0.5),
                                blurRadius: 12,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .scale(begin: const Offset(0.90, 0.90), end: const Offset(1.15, 1.15), duration: 1100.ms),
                      ),
                    ),
                  ),
                  if (_birdTapped)
                    Positioned(
                      top: cardH * 0.18,
                      left: cardW * 0.54 - 45,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: NovaColors.gold,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3D271C44),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'वर / TOP!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: NovaColors.ink,
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    ),
                ],

                // "माझी सकाळ • My morning" pill tag cleanly placed at top-left
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A271C44),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'माझी सकाळ • My morning',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // BANYAN GROVE & DAIRY CANVAS (Level 2 Left Visual Panel)
  // ===========================================================================
  Widget _buildBanyanGroveCanvas({bool isInteractiveTarget = false}) {
    final sceneIndex = _activeScreen - 6;
    final scene = _getScene(sceneIndex);
    return BanyanGroveStageWidget(
      isInteractiveTarget: isInteractiveTarget,
      targetTapped: _birdTapped,
      onTargetTap: _tapBird,
      onWrongSpotTap: _onWrongSpotTapped,
      character: scene?.environment.character,
      prop: scene?.environment.prop,
      sceneIndex: sceneIndex,
      title: 'वडाचे झाड आणि डेअरी • Banyan Grove',
    );
  }

  Widget _buildVisualPanel({bool isInteractive = false}) {
    if (widget.initialLevelId == 2) {
      return _buildBanyanGroveCanvas(isInteractiveTarget: isInteractive);
    }
    return _buildVillageCanvas(isInteractiveBird: isInteractive);
  }

  // ===========================================================================
  // STORY PROGRESSION BEAT (Story Filler Bridge Card)
  // ===========================================================================
  void _onDismissStoryBridge() {
    NovaAudioService.instance.stop();
    setState(() {
      _showingStoryBridge = false;
    });
    _playScreenQuestionAudio();
  }

  Widget _buildStoryBridgeCard({required VoidCallback onContinue}) {
    final marathi = _getStoryBridgeMarathi(_activeScreen);
    final english = _getStoryBridgeEnglish(_activeScreen);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NovaColors.purpleLight,
        borderRadius: NovaSpacing.roundedCard,
        border: Border.all(color: NovaColors.purple.withValues(alpha: 0.25), width: 1.5),
        boxShadow: NovaSpacing.cardShadow,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const NovaRobotMascot(size: 56),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: NovaColors.goldLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'गोष्ट पुढे चालली... • STORY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: NovaColors.goldDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    NovaSpeakerButton(
                      state: _speakerState,
                      label: 'Listen',
                      onTap: _playScreenAudio,
                      size: 38,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  marathi,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  english,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: NovaColors.inkSoft,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                NovaButton(
                  label: 'पुढे ऐका / प्रश्न पहा ->',
                  variant: NovaButtonVariant.primary,
                  height: 48,
                  onPressed: onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SCREEN 6: VILLAGE STORY
  // ===========================================================================
  Widget _buildScreen6VillageStory() {
    final scene = _getScene(0);
    final String marathiText = scene?.narrativeText.isNotEmpty == true
        ? scene!.narrativeText
        : (widget.initialLevelId == 2
            ? 'वडाच्या झाडाखाली वाघोबा आणि नोव्हा भेटले आहेत! चला डेअरीकडे जाऊया.'
            : 'सूर्याची सोनेरी किरणे आली... गाव जागे झाले! चिवताई छतावर गाऊ लागली!');
    final String englishText = widget.initialLevelId == 2
        ? 'Nova and tiger friend meet under the banyan tree! Let us head to the dairy.'
        : 'Golden rays arrive... the village wakes! Chiu sings on the roof.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Village / Banyan Grove Illustration Canvas
        Expanded(
          flex: 11,
          child: _buildVisualPanel(isInteractive: false),
        ),
        const SizedBox(width: 18),

        // Right Column: Bilingual Narration & Actions
        Expanded(
          flex: 9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: NovaColors.purpleLight,
                    borderRadius: NovaSpacing.roundedCard,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const NovaRobotMascot(size: 64),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'NOVA SAYS...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: NovaColors.purple,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                NovaSpeakerButton(
                                  state: _speakerState,
                                  label: 'Listen',
                                  onTap: _playScreenAudio,
                                  size: 36,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              marathiText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: NovaColors.ink,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              englishText,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: NovaColors.inkSoft,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: NovaButton(
                      label: 'पुढे -> Next Beat',
                      variant: NovaButtonVariant.primary,
                      height: 44,
                      onPressed: () => _goToScreen(7),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: NovaButton(
                      label: 'Skip ->',
                      variant: NovaButtonVariant.secondary,
                      height: 44,
                      onPressed: () => _goToScreen(7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SCREEN 7: BIG VS SMALL QUIZ
  // ===========================================================================
  Widget _buildScreen7BigVsSmallQuiz() {
    final bool isLevel2 = widget.initialLevelId == 2;
    final scene = _getScene(1);

    if (_showingStoryBridge) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: _buildVisualPanel(isInteractive: false),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 9,
            child: _buildStoryBridgeCard(
              onContinue: _onDismissStoryBridge,
            ),
          ),
        ],
      );
    }

    final String promptMarathi = scene?.questionData.storyQuestionText.isNotEmpty == true
        ? scene!.questionData.storyQuestionText
        : (isLevel2 ? 'यातील मोठी वस्तू कोणती? (गाय की दुधाचा डबा?)' : 'यातील मोठी वस्तू कोणती? (ट्रॅक्टर की सायकल?)');
    final String promptEnglish = scene?.questionData.payloadData?['english_text'] ??
        scene?.questionData.explanationHint ??
        (isLevel2 ? 'Which object is big? Tap your answer.' : 'Which object is big? Tap your answer.');

    final List<String> options = (scene?.questionData.options != null &&
            scene!.questionData.options!.length >= 2)
        ? scene.questionData.options!
        : (isLevel2 ? ['गाय', 'दुधाचा डबा'] : ['ट्रॅक्टर', 'सायकल']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Prompt banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: NovaColors.purpleLight,
            borderRadius: NovaSpacing.roundedMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promptMarathi,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.ink,
                        height: 1.25,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      promptEnglish,
                      style: NovaTypography.bodySecondary,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              NovaSpeakerButton(
                state: _speakerState,
                onTap: _playScreenAudio,
                size: 38,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Cards & Feedback row
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card 1: Red Tractor (Level 1) or Cow (Level 2)
              Expanded(
                flex: 7,
                child: _buildQuizSelectionCard(
                  imageAsset: isLevel2 ? 'assets/images/generated/cow.png' : 'assets/images/generated/tractor.png',
                  label: options[0],
                  fallbackIcon: isLevel2 ? Icons.pets_rounded : Icons.agriculture_rounded,
                  isTargetBig: true,
                  isSelected: _selectedOptionIndex == 0 && _quizAnswerOutcome == true,
                  isGentleRetry: _selectedOptionIndex == 0 && _quizAnswerOutcome == false,
                  onTap: () => _onOptionSelected(0),
                  customVisual: isLevel2
                      ? const NovaPropAnimationBox(
                          assetPath: 'assets/lottie/cow.json',
                          height: 115,
                        )
                      : const NovaPropAnimationBox(
                          assetPath: 'assets/lottie/tractor.json',
                          height: 120,
                          isBigVsSmall: true,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Card 2: Blue Bicycle (Level 1) or Milk Can (Level 2)
              Expanded(
                flex: 7,
                child: _buildQuizSelectionCard(
                  imageAsset: isLevel2 ? 'assets/images/generated/milk.png' : 'assets/images/generated/bicycle.png',
                  label: options[1],
                  fallbackIcon: isLevel2 ? Icons.local_drink_rounded : Icons.pedal_bike_rounded,
                  isTargetBig: false,
                  isSelected: _selectedOptionIndex == 1 && _quizAnswerOutcome == true,
                  isGentleRetry: _selectedOptionIndex == 1 && _quizAnswerOutcome == false,
                  onTap: () => _onOptionSelected(1),
                  customVisual: isLevel2
                      ? const NovaPropAnimationBox(
                          assetPath: 'assets/lottie/Eda region 1.json',
                          height: 95,
                        )
                      : const SizedBox(
                          height: 90,
                          child: Center(
                            child: BicycleVectorArt(size: 78),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Right Sidebar: Prompt / Feedback
              Expanded(
                flex: 6,
                child: _buildQuizSidebarFeedback(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizSelectionCard({
    required String imageAsset,
    required String label,
    required IconData fallbackIcon,
    required bool isTargetBig,
    required bool isSelected,
    required bool isGentleRetry,
    required VoidCallback onTap,
    Widget? customVisual,
  }) {
    Color borderColor = NovaColors.purpleBorder.withValues(alpha: 0.5);
    Color bgColor = Colors.white;
    double borderWidth = 1.5;

    if (isSelected) {
      borderColor = NovaColors.green;
      borderWidth = 3.0;
      bgColor = const Color(0xFFF0FDF4);
    } else if (isGentleRetry) {
      borderColor = NovaColors.coral;
      borderWidth = 2.5;
      bgColor = const Color(0xFFFFF1E8);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: NovaSpacing.roundedCard,
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: NovaSpacing.cardShadow,
        ),
        child: Stack(
          children: [
            // Status Icon badge
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: NovaColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                ),
              ),
            if (isGentleRetry)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: NovaColors.coral,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                ),
              ),
            // Artwork & bottom pill
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: customVisual ??
                            (isTargetBig
                                ? const NovaPropAnimationBox(
                                    assetPath: 'assets/lottie/tractor.json',
                                    height: 120,
                                    isBigVsSmall: true,
                                  )
                                : const SizedBox(
                                    height: 90,
                                    child: Center(
                                      child: BicycleVectorArt(size: 78),
                                    ),
                                  )),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: (isSelected || isGentleRetry) ? const Color(0xFFFEF3C7) : NovaColors.purpleLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        label,
                        style: NovaTypography.chipText.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: NovaColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSidebarFeedback() {
    final bool isLevel2 = widget.initialLevelId == 2;
    final scene = _getScene(1);

    if (_quizAnswerOutcome == true) {
      final String correctMarathi = scene?.questionData.payloadData?['correct_feedback_marathi'] ??
          (scene?.questionData.explanationHint?.isNotEmpty == true
              ? scene!.questionData.explanationHint!
              : (isLevel2 ? 'गाय मोठी आहे!' : 'ट्रॅक्टर मोठा आहे!'));
      final String correctEnglish = scene?.questionData.payloadData?['correct_feedback_english'] ??
          (isLevel2 ? 'Yes! The cow is big.' : 'Yes! The tractor is big.');

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F0),
          borderRadius: NovaSpacing.roundedCard,
          border: Border.all(color: NovaColors.green.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NovaRobotMascot(size: 64),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star_rounded, color: NovaColors.gold, size: 20),
                    SizedBox(width: 3),
                    Icon(Icons.star_rounded, color: NovaColors.gold, size: 24),
                    SizedBox(width: 3),
                    Icon(Icons.star_rounded, color: NovaColors.gold, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'शाब्बास!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: NovaColors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  correctMarathi,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                const SizedBox(height: 2),
                Text(
                  correctEnglish,
                  style: NovaTypography.caption,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                NovaButton(
                  label: 'पुढे चला ->',
                  variant: NovaButtonVariant.primary,
                  height: 40,
                  onPressed: () => _goToScreen(8),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_quizAnswerOutcome == false) {
      final String wrongMarathi = scene?.questionData.payloadData?['wrong_feedback_marathi'] ??
          (isLevel2
              ? 'दुधाचा डबा लहान आहे! मोठी वस्तू कोणती ते पुन्हा निवड!'
              : 'सायकल लहान आहे! मोठी वस्तू कोणती ते पुन्हा निवड!');
      final String wrongEnglish = scene?.questionData.payloadData?['wrong_feedback_english'] ??
          (isLevel2
              ? 'The milk can is smaller. Tap the cow!'
              : 'That bicycle is smaller. Tap the tractor!');

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1E8),
          borderRadius: NovaSpacing.roundedCard,
          border: Border.all(color: NovaColors.coral.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NovaRobotMascot(size: 64),
                const SizedBox(height: 4),
                const Text(
                  'पुन्हा बघूया!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: NovaColors.coral,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  wrongMarathi,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                const SizedBox(height: 2),
                Text(
                  wrongEnglish,
                  style: NovaTypography.caption,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                NovaButton(
                  label: 'पुन्हा प्रयत्न ↺',
                  variant: NovaButtonVariant.retry,
                  height: 40,
                  onPressed: () {
                    setState(() {
                      _quizAnswerOutcome = null;
                      _selectedOptionIndex = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default idle guidance
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: NovaSpacing.roundedCard,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const NovaRobotMascot(size: 64),
              const SizedBox(height: 6),
              const Text(
                'बघ आणि निवड!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: NovaColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isLevel2 ? 'कोणती वस्तू मोठी?' : 'कोणती वस्तू मोठी?',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: NovaColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isLevel2 ? 'Look at both items.' : 'Look at both objects.',
                style: NovaTypography.caption,
              ),
              const SizedBox(height: 10),
              NovaButton(
                label: 'Skip ->',
                variant: NovaButtonVariant.secondary,
                height: 40,
                onPressed: () => _goToScreen(8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SCREEN 8: TOUCH THE BIRD
  // ===========================================================================
  Widget _buildScreen8TouchBird() {
    final bool isLevel2 = widget.initialLevelId == 2;
    final scene = _getScene(2);
    final String promptQuestion = scene?.questionData.storyQuestionText.isNotEmpty == true
        ? scene!.questionData.storyQuestionText
        : (isLevel2 ? 'झाडाखाली कोण बसले आहे?' : 'छतावर कोण बसले आहे?');
    final String promptAction = isLevel2 ? 'वाघोबाला टॅप कर!' : 'चिवताईला टॅप कर!';
    final String promptEnglish = scene?.questionData.payloadData?['english_text'] ??
        (isLevel2
            ? 'Who is under the tree? Tap the cute tiger.'
            : 'Who is on the roof? Tap the glowing bird.');

    if (_showingStoryBridge) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: _buildVisualPanel(isInteractive: false),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 9,
            child: _buildStoryBridgeCard(
              onContinue: _onDismissStoryBridge,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Interactive village / banyan grove canvas
        Expanded(
          flex: 11,
          child: _buildVisualPanel(isInteractive: true),
        ),
        const SizedBox(width: 18),

        // Right Column: Instructions, Wrong Spot guidance, or Celebration
        Expanded(
          flex: 9,
          child: _birdTapped
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F0),
                    borderRadius: NovaSpacing.roundedCard,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.star_rounded, color: NovaColors.gold, size: 24),
                              SizedBox(width: 4),
                              Icon(Icons.star_rounded, color: NovaColors.gold, size: 30),
                              SizedBox(width: 4),
                              Icon(Icons.star_rounded, color: NovaColors.gold, size: 24),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isLevel2 ? 'शाब्बास! झाडाखाली!' : 'शाब्बास! वर!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: NovaColors.green,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isLevel2 ? 'Cute Tiger is resting! Hooray!' : 'Chiu is on TOP! Hooray!',
                            style: NovaTypography.bodySecondary,
                          ),
                          const SizedBox(height: 12),
                          NovaButton(
                            label: 'पुढे चला ->',
                            variant: NovaButtonVariant.primary,
                            height: 40,
                            onPressed: () => _goToScreen(9),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : (_wrongSpotFeedback
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E8),
                        borderRadius: NovaSpacing.roundedCard,
                        border: Border.all(color: NovaColors.coral, width: 2.0),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const NovaRobotMascot(size: 64),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'तिथे नाही! पुन्हा बघ...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: NovaColors.coral,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isLevel2
                                                ? 'तो वाघोबा नाही! झाडाखाली चमकणाऱ्या वर्तुळात बघ!'
                                                : 'ती चिवताई नाही! छतावर चमकणाऱ्या वर्तुळात बघ!',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: NovaColors.ink,
                                              height: 1.25,
                                            ),
                                            maxLines: 3,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isLevel2
                                                ? 'Not there! Look at the glowing circle under the tree!'
                                                : 'Not there! Look at the glowing circle on the roof!',
                                            style: NovaTypography.caption,
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                NovaButton(
                                  label: 'शोधत आहे... 🔍',
                                  variant: NovaButtonVariant.secondary,
                                  height: 40,
                                  onPressed: () {
                                    setState(() => _wrongSpotFeedback = false);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: NovaColors.purpleLight,
                        borderRadius: NovaSpacing.roundedCard,
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        promptQuestion,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: NovaColors.ink,
                                          height: 1.25,
                                        ),
                                        maxLines: 3,
                                      ),
                                    ),
                                    NovaSpeakerButton(
                                      state: _speakerState,
                                      onTap: _playScreenAudio,
                                      size: 36,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const NovaRobotMascot(size: 64),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            promptAction,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: NovaColors.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            promptEnglish,
                                            style: NovaTypography.bodySecondary,
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                NovaButton(
                                  label: 'Skip ->',
                                  variant: NovaButtonVariant.secondary,
                                  height: 40,
                                  onPressed: () => _goToScreen(9),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
        ),
      ],
    );
  }

  // ===========================================================================
  // SCREEN 9: VOICE ACTIVITY
  // ===========================================================================
  Widget _buildScreen9VoiceActivity() {
    final bool isLevel2 = widget.initialLevelId == 2;
    final scene = _getScene(3);
    final String targetPhrase = scene?.questionData.correctAnswer.isNotEmpty == true
        ? scene!.questionData.correctAnswer
        : (isLevel2 ? 'दूध' : 'शुभ प्रभात');
    final String promptIntro = scene?.questionData.storyQuestionText.isNotEmpty == true
        ? scene!.questionData.storyQuestionText
        : (isLevel2 ? 'गाईपासून काय मिळते? म्हणा:' : 'म्हणून बघ...');
    final String promptEnglish = scene?.questionData.payloadData?['english_text'] ??
        (isLevel2 ? '(Fresh Milk!)' : '(Good Morning!)');

    if (_showingStoryBridge) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: _buildVisualPanel(isInteractive: false),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 9,
            child: _buildStoryBridgeCard(
              onContinue: _onDismissStoryBridge,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Pulsing Microphone or Recognized Feedback
        Expanded(
          flex: 10,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _voiceSuccess ? const Color(0xFFE8F8F0) : const Color(0xFFFFF1E8),
              borderRadius: NovaSpacing.roundedCard,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing Mic Button
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Concentric rings
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _voiceSuccess
                                  ? const Color(0xFF86EFAC)
                                  : (_voiceListening ? const Color(0xFFFCA5A5) : const Color(0xFFFED7AA)),
                              width: 2.0,
                            ),
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 1000.ms),

                        // Center Coral/Green Button
                        GestureDetector(
                          onTap: _triggerVoiceInput,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _voiceSuccess ? NovaColors.green : NovaColors.coral,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_voiceSuccess ? NovaColors.green : NovaColors.coral).withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.mic_rounded, size: 40, color: Colors.white),
                          ),
                        ),

                        if (_voiceSuccess)
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: NovaColors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Waveform Equalizer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(8, (i) {
                        return Container(
                          width: 5,
                          height: (10 + (i % 3) * 6).toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            color: _voiceSuccess ? NovaColors.green : NovaColors.coral,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      _voiceSuccess
                          ? '● Recognized! • ऐकले!'
                          : (_voiceListening ? '🎙️ ऐकत आहे... आता बोला!' : 'माईक दाबा आणि स्पष्ट बोला'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _voiceSuccess ? NovaColors.green : NovaColors.coral,
                      ),
                    ),
                    if (_liveRecognizedTranscript.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _voiceSuccess ? NovaColors.green : NovaColors.coral,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'तुम्ही म्हणालात: "$_liveRecognizedTranscript"',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _voiceSuccess ? NovaColors.green : NovaColors.ink,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    if (_voiceGentlePrompt != null && !_voiceSuccess) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          _voiceGentlePrompt!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB45309),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Right Column: Prompt & Tap Alternative
        Expanded(
          flex: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: NovaColors.purpleLight,
              borderRadius: NovaSpacing.roundedCard,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  promptIntro,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: NovaColors.inkSoft,
                                  ),
                                ),
                                Text(
                                  targetPhrase,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: NovaColors.ink,
                                  ),
                                ),
                                Text(
                                  promptEnglish,
                                  style: NovaTypography.bodySecondary,
                                ),
                              ],
                            ),
                          ),
                          NovaSpeakerButton(
                            state: _speakerState,
                            onTap: _playScreenAudio,
                            size: 38,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // NOVA helper or success card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _voiceSuccess ? const Color(0xFFE8F8F0) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const NovaRobotMascot(size: 64),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _voiceSuccess
                                        ? (isLevel2 ? 'शाब्बास! गाईचे गोड दूध!' : 'शाब्बास! शुभ प्रभात!')
                                        : 'बोल किंवा खालील बटण दाब!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _voiceSuccess ? NovaColors.green : NovaColors.ink,
                                    ),
                                  ),
                                  Text(
                                    _voiceSuccess
                                        ? (isLevel2 ? 'Superb! Cows give fresh milk.' : 'You did it! Your greeting was heard.')
                                        : 'Say it into the mic or use the skip button below.',
                                    style: NovaTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Actions: Tap option or Proceed
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: NovaButton(
                              label: 'माईक चालत नाही? येथे टॅप करून पुढे जा (Skip Mic)',
                              variant: NovaButtonVariant.secondary,
                              height: 44,
                              onPressed: _handleVoiceFallbackTap,
                            ),
                          ),
                          if (_voiceSuccess) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: NovaButton(
                                label: 'पुढे ->',
                                variant: NovaButtonVariant.primary,
                                height: 44,
                                onPressed: () => _goToScreen(10),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          'Tap if microphone is unavailable • Speaking is always encouraged',
                          style: TextStyle(fontSize: 10, color: NovaColors.inkSoft),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SCREEN 10: MATCH THE FOLLOWING
  // ===========================================================================
  Widget _buildScreen10MatchFollowing() {
    final int matchedCount = _establishedConnections.length;
    final bool isLevel2 = widget.initialLevelId == 2;

    if (_showingStoryBridge) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: _buildVisualPanel(isInteractive: false),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 9,
            child: _buildStoryBridgeCard(
              onContinue: _onDismissStoryBridge,
            ),
          ),
        ],
      );
    }

    final String promptMarathi = isLevel2
        ? 'बागेतील आणि डेअरीतील योग्य जोड्या जुळवा!'
        : 'सकाळच्या गोष्टींच्या योग्य जोड्या जुळवा!';
    final String promptEnglish = isLevel2
        ? 'Match each farm and dairy friend to its home.'
        : 'Drag to match • Or tap a picture, then its word.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: NovaColors.purpleLight,
            borderRadius: NovaSpacing.roundedMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promptMarathi,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.ink,
                      ),
                      maxLines: 2,
                    ),
                    Text(
                      promptEnglish,
                      style: NovaTypography.bodySecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$matchedCount/3 matched',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              NovaSpeakerButton(
                state: _speakerState,
                onTap: _playScreenAudio,
                size: 40,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Interactive matching canvas and columns
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column & Right Column Stack with Custom Bezier Line Painter
              Expanded(
                flex: 14,
                child: Stack(
                  key: _matchingStackKey,
                  children: [
                    // Bezier Curve Painter Layer (wrapped in IgnorePointer so it never intercepts touch events)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            final Map<int, Offset> leftPositions = {};
                            final Map<int, Offset> rightPositions = {};

                            for (int i = 0; i < 3; i++) {
                              final pL = _getSocketCenter(_leftSocketKeys[i]!);
                              if (pL != null) leftPositions[i] = pL;
                              final pR = _getSocketCenter(_rightSocketKeys[i]!);
                              if (pR != null) rightPositions[i] = pR;
                            }

                            return CustomPaint(
                              painter: NovaMatchingBezierPainter(
                                leftSocketPositions: leftPositions,
                                rightSocketPositions: rightPositions,
                                connections: _establishedConnections,
                                activeDragStart: _activeDragStart,
                                activeDragCurrent: _activeDragCurrent,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Matching Chips Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Chips
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: () {
                              final scene = _getScene(4);
                              final pairs = scene?.questionData.payloadData?['pairs'] as List?;
                              if (pairs != null && pairs.length >= 3) {
                                return [
                                  _buildLeftMatchingChip(
                                    index: 0,
                                    text: pairs[0]['a'].toString(),
                                    subtitle: isLevel2 ? 'जोडी १ • Pair 1' : 'सकाळ • Morning',
                                    leadingWidget: buildIconForMatchPair(
                                      pairs[0]['a'].toString(),
                                      pairs[0]['b'].toString(),
                                    ),
                                  ),
                                  _buildLeftMatchingChip(
                                    index: 1,
                                    text: pairs[1]['a'].toString(),
                                    subtitle: isLevel2 ? 'जोडी २ • Pair 2' : 'साथीदार • Friend',
                                    leadingWidget: buildIconForMatchPair(
                                      pairs[1]['a'].toString(),
                                      pairs[1]['b'].toString(),
                                    ),
                                  ),
                                  _buildLeftMatchingChip(
                                    index: 2,
                                    text: pairs[2]['a'].toString(),
                                    subtitle: isLevel2 ? 'जोडी ३ • Pair 3' : 'काम • Action',
                                    leadingWidget: buildIconForMatchPair(
                                      pairs[2]['a'].toString(),
                                      pairs[2]['b'].toString(),
                                    ),
                                  ),
                                ];
                              }
                              return isLevel2
                                  ? [
                                      _buildLeftMatchingChip(
                                        index: 0,
                                        text: 'गाय',
                                        subtitle: 'Cow',
                                        leadingWidget: buildIconForMatchPair('गाय', 'दूध'),
                                      ),
                                      _buildLeftMatchingChip(
                                        index: 1,
                                        text: 'आंबा',
                                        subtitle: 'Mango',
                                        leadingWidget: buildIconForMatchPair('आंबा', 'झाड'),
                                      ),
                                      _buildLeftMatchingChip(
                                        index: 2,
                                        text: 'वाघ',
                                        subtitle: 'Tiger',
                                        leadingWidget: buildIconForMatchPair('वाघ', 'जंगल'),
                                      ),
                                    ]
                                  : [
                                      _buildLeftMatchingChip(
                                        index: 0,
                                        text: 'सूर्य',
                                        subtitle: 'Sun',
                                        leadingWidget: buildIconForMatchPair('सूर्य', 'सकाळ'),
                                      ),
                                      _buildLeftMatchingChip(
                                        index: 1,
                                        text: 'ट्रॅक्टर',
                                        subtitle: 'Tractor',
                                        leadingWidget: buildIconForMatchPair('ट्रॅक्टर', 'मोठा'),
                                      ),
                                      _buildLeftMatchingChip(
                                        index: 2,
                                        text: 'चिवताई',
                                        subtitle: 'Chiu',
                                        leadingWidget: buildIconForMatchPair('चिवताई', 'छत'),
                                      ),
                                    ];
                            }(),
                          ),
                        ),
                        // Helper pill in center when a chip is selected
                        if (_selectedLeftChip != null && _selectedRightChip == null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: NovaColors.purpleLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Tap a word ->',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: NovaColors.purple),
                            ),
                          )
                        else
                          const SizedBox(width: 40),

                        // Right Chips
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: () {
                              final scene = _getScene(4);
                              final pairs = scene?.questionData.payloadData?['pairs'] as List?;
                              if (pairs != null && pairs.length >= 3) {
                                return [
                                  _buildRightMatchingChip(
                                    index: 0,
                                    text: pairs[0]['b'].toString(),
                                    subtitle: 'Match',
                                  ),
                                  _buildRightMatchingChip(
                                    index: 1,
                                    text: pairs[1]['b'].toString(),
                                    subtitle: 'Match',
                                  ),
                                  _buildRightMatchingChip(
                                    index: 2,
                                    text: pairs[2]['b'].toString(),
                                    subtitle: 'Match',
                                  ),
                                ];
                              }
                              return isLevel2
                                  ? [
                                      _buildRightMatchingChip(
                                        index: 0,
                                        text: 'दूध',
                                        subtitle: 'Milk',
                                      ),
                                      _buildRightMatchingChip(
                                        index: 1,
                                        text: 'झाड',
                                        subtitle: 'Tree',
                                      ),
                                      _buildRightMatchingChip(
                                        index: 2,
                                        text: 'जंगल',
                                        subtitle: 'Jungle',
                                      ),
                                    ]
                                  : [
                                      _buildRightMatchingChip(
                                        index: 0,
                                        text: 'सकाळ',
                                        subtitle: 'Morning',
                                      ),
                                      _buildRightMatchingChip(
                                        index: 1,
                                        text: 'मोठा',
                                        subtitle: 'Big',
                                      ),
                                      _buildRightMatchingChip(
                                        index: 2,
                                        text: 'छत',
                                        subtitle: 'Roof',
                                      ),
                                    ];
                            }(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Right Column Sidebar: Instructions & Celebration
              Expanded(
                flex: 6,
                child: _buildMatchingSidebar(matchedCount),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Dynamically builds the matching icon based on pair concepts
  Widget buildIconForMatchPair(String leftText, String rightText) {
    final String combined = '$leftText $rightText'.toLowerCase();

    if (combined.contains('ट्रॅक्टर') || combined.contains('tractor') || combined.contains('चाके')) {
      return Lottie.asset(
        'assets/lottie/tractor.json',
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    } else if (combined.contains('सायकल') || combined.contains('bicycle')) {
      return const Icon(
        Icons.directions_bike_rounded,
        color: Color(0xFF0284C7),
        size: 24,
      );
    } else if (combined.contains('चिवताई') ||
        combined.contains('चिमणी') ||
        combined.contains('पक्षी') ||
        combined.contains('bird') ||
        combined.contains('छत')) {
      return Lottie.asset(
        'assets/lottie/Blue Bird.json',
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    } else if (combined.contains('सूर्य') || combined.contains('सकाळ') || combined.contains('sun')) {
      return Lottie.asset(
        'assets/lottie/Animated Star Gold 3D Icon Loop.json',
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    } else if (combined.contains('वाघ') ||
        combined.contains('वाघोबा') ||
        combined.contains('tiger') ||
        combined.contains('जंगल')) {
      return Lottie.asset(
        'assets/lottie/Cute Tiger.json',
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    } else if (combined.contains('गाय') || combined.contains('cow')) {
      return Lottie.asset(
        'assets/lottie/cow.json',
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    } else if (combined.contains('दूध') || combined.contains('milk') || combined.contains('डेअरी')) {
      return Lottie.asset(
        'assets/lottie/Eda region 1.json',
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    } else if (combined.contains('आंबा') ||
        combined.contains('आंबे') ||
        combined.contains('झाड') ||
        combined.contains('mango')) {
      return ClipOval(
        child: SizedBox(
          width: 30,
          height: 30,
          child: Lottie.asset(
            'assets/lottie/Mango Tree Animation.json',
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (combined.contains('+') || combined.contains('बेरीज')) {
      return const Icon(
        Icons.calculate_rounded,
        color: NovaColors.purple,
        size: 22,
      );
    } else if (combined.contains('मोठे') || combined.contains('छोटे')) {
      return const Icon(
        Icons.compare_arrows_rounded,
        color: NovaColors.purple,
        size: 22,
      );
    } else if (combined.contains('वर') || combined.contains('खाली')) {
      return const Icon(
        Icons.swap_vert_rounded,
        color: NovaColors.coral,
        size: 22,
      );
    }

    return const Icon(
      Icons.star_rounded,
      color: NovaColors.goldDark,
      size: 22,
    );
  }

  Widget _buildLeftMatchingChip({
    required int index,
    required String text,
    required String subtitle,
    Widget? leadingWidget,
    IconData? icon,
    Color? iconColor,
    String? customLottie,
  }) {
    NovaMatchingChipState chipState = NovaMatchingChipState.defaultState;
    if (_establishedConnections.any((c) => c.leftIndex == index)) {
      chipState = NovaMatchingChipState.completed;
    } else if (_selectedLeftChip == index) {
      chipState = (_matchingOutcome == false)
          ? NovaMatchingChipState.incorrect
          : NovaMatchingChipState.selected;
    }

    final Color effectiveColor = iconColor ?? NovaColors.purple;

    return NovaMatchingChip(
      text: text,
      subtitle: subtitle,
      state: chipState,
      dotSide: ConnectionDotSide.right,
      socketKey: _leftSocketKeys[index],
      leadingIcon: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: leadingWidget ??
              (customLottie != null
                  ? NovaPropAnimationBox(
                      assetPath: customLottie,
                      width: 30,
                      height: 30,
                    )
                  : Icon(icon ?? Icons.star_rounded, color: effectiveColor, size: 22)),
        ),
      ),
      onTap: () => _onLeftChipTapped(index),
    );
  }

  Widget _buildRightMatchingChip({
    required int index,
    required String text,
    required String subtitle,
  }) {
    NovaMatchingChipState chipState = NovaMatchingChipState.defaultState;
    if (_establishedConnections.any((c) => c.rightIndex == index)) {
      chipState = NovaMatchingChipState.completed;
    } else if (_selectedRightChip == index) {
      chipState = (_matchingOutcome == false)
          ? NovaMatchingChipState.incorrect
          : NovaMatchingChipState.selected;
    }

    return NovaMatchingChip(
      text: text,
      subtitle: subtitle,
      state: chipState,
      dotSide: ConnectionDotSide.left,
      socketKey: _rightSocketKeys[index],
      onTap: () => _onRightChipTapped(index),
    );
  }

  Widget _buildMatchingSidebar(int matchedCount) {
    final bool isLevel2 = widget.initialLevelId == 2;

    if (matchedCount == 3) {
      // Completed state matching Matching feedback · Completed.png
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F0),
          borderRadius: NovaSpacing.roundedCard,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NovaRobotMascot(size: 64),
                const SizedBox(height: 4),
                const Text(
                  'शाब्बास!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: NovaColors.green,
                  ),
                ),
                const Text(
                  'सगळ्या जोड्या जुळल्या!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                ),
                const Text(
                  'All pairs matched. You did it!',
                  style: NovaTypography.caption,
                ),
                const SizedBox(height: 10),
                NovaButton(
                  label: 'बक्षीस पाहूया! ->',
                  variant: NovaButtonVariant.primary,
                  height: 40,
                  onPressed: () => _goToScreen(11),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_matchingOutcome == false) {
      // Gently incorrect retry state
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1E8),
          borderRadius: NovaSpacing.roundedCard,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NovaRobotMascot(size: 64),
                const SizedBox(height: 4),
                const Text(
                  'पुन्हा बघूया!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: NovaColors.ink,
                  ),
                ),
                Text(
                  isLevel2 ? 'दूध डेअरीतून मिळते.' : 'सूर्य सकाळी उगवतो.',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: NovaColors.ink,
                  ),
                ),
                Text(
                  isLevel2
                      ? 'Milk comes from the dairy. Try another pair.'
                      : 'The sun rises in the morning. Try another pair.',
                  style: NovaTypography.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                NovaButton(
                  label: 'पुन्हा प्रयत्न ↺',
                  variant: NovaButtonVariant.retry,
                  height: 40,
                  onPressed: () {
                    setState(() {
                      _selectedLeftChip = null;
                      _selectedRightChip = null;
                      _matchingOutcome = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default guidance
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: NovaSpacing.roundedCard,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const NovaRobotMascot(size: 64),
              const SizedBox(height: 6),
              const Text(
                'जोडी शोधूया!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: NovaColors.ink,
                ),
              ),
              const Text(
                'ओढून किंवा टॅप करून जुळव!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NovaColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Drag to a match, or tap one chip on each side.',
                style: NovaTypography.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              NovaButton(
                label: 'ऐकूया • Listen',
                variant: NovaButtonVariant.secondary,
                height: 40,
                onPressed: _playScreenAudio,
              ),
              const SizedBox(height: 4),
              const Text(
                'No timer • Take your time',
                style: TextStyle(fontSize: 10, color: NovaColors.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SCREEN 11: CELEBRATION
  // ===========================================================================
  Widget _buildScreen11Celebration(AppState appState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Chintu + NOVA High-five Artwork & Stars
        Expanded(
          flex: 9,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: NovaSpacing.roundedCard,
              boxShadow: NovaSpacing.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: NovaSpacing.roundedCard,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Base background gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFEF3C7),
                          Color(0xFFEDE9FE),
                          Color(0xFFDCFCE7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Full-card celebration confetti effects loop across entire background
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Lottie.asset(
                        'assets/lottie/Confetti Effects Lottie Animation.json',
                        fit: BoxFit.cover,
                        repeat: true,
                      ),
                    ),
                  ),

                  // Chintu and Nova celebrating right next to each other in the center
                  Positioned.fill(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Lottie.asset(
                            'assets/lottie/Hand Waving Animation.json',
                            height: 170,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),
                          const NovaRobotMascot(
                            size: 140,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3 Gold Stars at top
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset('assets/lottie/Animated Star Gold 3D Icon Loop.json', width: 34, height: 34, fit: BoxFit.contain),
                        const SizedBox(width: 8),
                        Lottie.asset('assets/lottie/Animated Star Gold 3D Icon Loop.json', width: 44, height: 44, fit: BoxFit.contain),
                        const SizedBox(width: 8),
                        Lottie.asset('assets/lottie/Animated Star Gold 3D Icon Loop.json', width: 34, height: 34, fit: BoxFit.contain),
                      ],
                    ),
                  ),

                  // Bottom High-five pill
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x28271C44),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.initialLevelId == 2
                              ? 'वाघोबा + NOVA • High five!'
                              : 'चिंटू + NOVA • High five!',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: NovaColors.purple,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Right Column: Summary, 5 Badges, and Exits
        Expanded(
          flex: 11,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.initialLevelId == 2
                          ? 'LEVEL 2 • COMPLETE ✓'
                          : 'LEVEL 1 • COMPLETE ✓',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.purple,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.initialLevelId == 2
                          ? 'खूप छान!\nतू २ री पातळी जिंकलीस!'
                          : 'खूप छान!\nतू १ ली पातळी जिंकलीस!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: NovaColors.ink,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.initialLevelId == 2
                          ? 'Awesome! You completed Level 2!'
                          : 'Awesome! You completed Level 1!',
                      style: NovaTypography.bodySecondary,
                    ),
                    const SizedBox(height: 8),

                    // Badges Section
                    const Text(
                      'YOUR LEARNING BADGES • तुझी कमाई',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: NovaColors.purple,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // 5 Badges Row
                    Row(
                      children: widget.initialLevelId == 2
                          ? [
                              _buildCelebrationBadge(Icons.park_rounded, const Color(0xFF10B981), 'वडाचे झाड', 'Banyan Tree'),
                              _buildCelebrationBadge(Icons.calculate_rounded, const Color(0xFFF59E0B), 'आंबे मोजणी', 'Mango Count'),
                              _buildCelebrationBadge(Icons.storefront_rounded, NovaColors.purple, 'डेअरी सफर', 'Dairy Trip'),
                              _buildCelebrationBadge(Icons.local_drink_rounded, const Color(0xFF0284C7), 'गोड दूध', 'Fresh Milk'),
                              _buildCelebrationBadge(Icons.pets_rounded, const Color(0xFFEA580C), 'वाघोबा मित्र', 'Tiger Friend'),
                            ]
                          : [
                              _buildCelebrationBadge(Icons.wb_sunny_rounded, const Color(0xFFF59E0B), 'सकाळ • रात्र', 'Morning/Night'),
                              _buildCelebrationBadge(Icons.agriculture_rounded, const Color(0xFFDC2626), 'मोठे • छोटे', 'Big vs Small'),
                              _buildCelebrationBadge(Icons.arrow_upward_rounded, NovaColors.purple, 'वर • खाली', 'Top vs Bottom'),
                              _buildCelebrationBadge(Icons.flutter_dash_rounded, const Color(0xFF0284C7), 'छतावर चिऊ', 'Chiu on Roof'),
                              _buildCelebrationBadge(Icons.cruelty_free_rounded, const Color(0xFF16A34A), 'जमिनीवर गण्या', 'Ganya Ground'),
                            ],
                    ),
                    const SizedBox(height: 12),

                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: NovaButton(
                            label: 'पुन्हा खेळू • Play Again',
                            variant: NovaButtonVariant.primary,
                            height: 44,
                            onPressed: () {
                              _goToScreen(6);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: NovaButton(
                            label: 'घरी जाऊ • Back to Home',
                            variant: NovaButtonVariant.secondary,
                            height: 44,
                            onPressed: () {
                              OrientationHelper.lockPortrait();
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCelebrationBadge(IconData icon, Color badgeColor, String marathi, String english) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E2F4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A271C44),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 1.5),
              ),
              child: Center(
                child: Icon(icon, color: badgeColor, size: 17),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              marathi,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: NovaColors.ink),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              english,
              style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w600, color: NovaColors.inkSoft),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
