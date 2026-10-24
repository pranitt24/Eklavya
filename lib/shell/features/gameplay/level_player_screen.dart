import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/services/level_api.dart';
import '../../../features/scene/level_models.dart';
import '../../../features/scene/level_player.dart';
import '../../../features/scene/nova_assets.dart';
import '../../../features/scene/question_panel.dart';
import '../../../features/voice_engine/voice_answer_matcher.dart';
import '../../core/audio/sound_service.dart';
import '../../theme.dart';

/// LevelPlayerScreen: Multi-task story level player:
/// 1. Plays all scenes in order (intro -> 3 question scenes -> wrap scene).
/// 2. Narrates scene text, shows questions, accepts voice or tap fallback.
/// 3. Wrong answer allows child to retry once before revealing answer.
/// 4. Counts correct answers across all questions.
/// 5. Only after the final scene completes does it navigate to /celebration.
class LevelPlayerScreen extends StatefulWidget {
  const LevelPlayerScreen({super.key});

  @override
  State<LevelPlayerScreen> createState() => _LevelPlayerScreenState();
}

class _LevelPlayerScreenState extends State<LevelPlayerScreen> {
  final LevelApi _levelApi = LevelApi();
  final FlutterTts _flutterTts = FlutterTts();
  final String _language = 'mr';

  LevelSpec? _level;
  NovaAssets? _assets;
  bool _isLoading = true;
  String? _errorMessage;
  bool _navigatingToCelebration = false;

  // Multi-task story answer tracking
  int _correctCount = 0;
  int _totalQuestions = 0;
  final Set<String> _attemptedQuestions = <String>{};
  final Set<String> _correctQuestions = <String>{};

  @override
  void initState() {
    super.initState();
    _lockLandscape();
    _initTts();
    _loadLevelAndAssets();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _restorePortrait();
    super.dispose();
  }

  Future<void> _lockLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _restorePortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('mr-IN');
      await _flutterTts.setSpeechRate(0.40);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> _loadLevelAndAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final assets = await NovaAssets.load();

      // (a) Try GET http://127.0.0.1:8000/levels?grade=1 via LevelApi
      LevelSpec? chosenLevel;
      try {
        final serverLevels = await _levelApi.listLevels(grade: 1, timeout: const Duration(seconds: 3));
        if (serverLevels.isNotEmpty) {
          final randomIndex = Random().nextInt(serverLevels.length);
          chosenLevel = LevelSpec.fromJson(serverLevels[randomIndex]);
          debugPrint('Loaded level from server: ${chosenLevel.levelId} (${chosenLevel.scenes.length} scenes, ${chosenLevel.questions.length} questions)');
        }
      } catch (netErr) {
        debugPrint('Backend server unreachable or error: $netErr');
      }

      // Fallback to bundled demo levels if server unreachable or empty
      if (chosenLevel == null) {
        debugPrint('Falling back to bundled demo levels...');
        final idxString = await rootBundle.loadString('assets/nova/demo/index.json');
        final List<dynamic> demoFiles = jsonDecode(idxString) as List<dynamic>;
        if (demoFiles.isNotEmpty) {
          final fileName = demoFiles.first.toString();
          final jsonString = await rootBundle.loadString('assets/nova/demo/$fileName');
          chosenLevel = LevelSpec.fromJsonString(jsonString);
          debugPrint('Loaded fallback demo level: ${chosenLevel.levelId}');
        }
      }

      if (chosenLevel == null) {
        throw Exception('No levels available from server or demo bundle');
      }

      if (mounted) {
        setState(() {
          _assets = assets;
          _level = chosenLevel;
          _totalQuestions = chosenLevel?.questions.length ?? 0;
          _correctCount = 0;
          _attemptedQuestions.clear();
          _correctQuestions.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onNarrate(String text) {
    if (text.isEmpty) return;
    try {
      _flutterTts.stop();
      _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Narration TTS error: $e');
    }
  }

  void _onSfx(String sfxId) {
    if (sfxId.contains('cheer')) {
      SoundService.instance.playDingChime();
    } else if (sfxId.contains('oops')) {
      SoundService.instance.playBoingBloop();
    } else {
      SoundService.instance.playPopClick();
    }
  }

  void _onAnswer(String questionId, bool correct, int responseMs) {
    debugPrint('LevelPlayer onAnswer: $questionId, correct=$correct in ${responseMs}ms');
    _attemptedQuestions.add(questionId);

    if (correct) {
      if (!_correctQuestions.contains(questionId)) {
        _correctQuestions.add(questionId);
        setState(() => _correctCount++);
      }
      SoundService.instance.playDingChime();
      Confetti.launch(
        context,
        options: const ConfettiOptions(
          particleCount: 85,
          spread: 80,
          y: 0.5,
        ),
      );
      // In multi-task stories, answering one question does NOT navigate to celebration.
      // The scene reaction plays, then LevelPlayer advances to the next scene.
    } else {
      SoundService.instance.playBoingBloop();
    }
  }

  void _onFinished() {
    debugPrint('LevelPlayer onFinished: $_correctCount / $_totalQuestions correct');
    if (_navigatingToCelebration) return;
    _navigatingToCelebration = true;

    final total = _totalQuestions > 0 ? _totalQuestions : 3;
    final earnedStars = (_correctCount == total)
        ? 3
        : (_correctCount >= (total / 2.0).ceil())
            ? 2
            : 1;
    final coins = _correctCount * 20;

    // Only after the final scene go to /celebration
    context.go(
      '/celebration',
      extra: {
        'completedLevelNumber': 1,
        'earnedStars': earnedStars,
        'coinsAwarded': coins,
      },
    );
  }

  Widget _buildVoiceQuestion(QuestionSpec q, String lang, void Function(bool correct) submit) {
    return _VoiceWithTapFallbackWidget(
      key: ValueKey<String>(q.id),
      question: q,
      lang: lang,
      flutterTts: _flutterTts,
      onSubmit: submit,
    );
  }

  Future<void> _exitToSagaMap() async {
    SoundService.instance.playPopClick();
    await _restorePortrait();
    if (mounted) {
      context.go('/saga-map');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: GameColors.activeGold),
              const SizedBox(height: 20),
              Text(
                'गोष्ट सुरू होत आहे... ✨\nLoading Multi-task Story...',
                textAlign: TextAlign.center,
                style: GameTypography.marathiHeadingLarge(color: Colors.white).copyWith(fontSize: 22),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || _level == null || _assets == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: GameColors.coralRed, size: 64),
                const SizedBox(height: 12),
                Text(
                  'खेळ लोड करताना त्रुटी आली!',
                  style: GameTypography.marathiHeadingLarge(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'Unknown error',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: _loadLevelAndAssets,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameColors.activeGold,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('पुन्हा प्रयत्न करा (Retry)', style: TextStyle(color: Colors.black87)),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: _exitToSagaMap,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('नकाशा (Exit)', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: SafeArea(
        child: Stack(
          children: [
            LevelPlayer(
              key: ValueKey<String>('${_level!.levelId}_$_language'),
              level: _level!,
              assets: _assets!,
              language: _language,
              onNarrate: _onNarrate,
              onSfx: _onSfx,
              onAnswer: _onAnswer,
              onFinished: _onFinished,
              voiceBuilder: _buildVoiceQuestion,
            ),

            // Top HUD Overlay: Back to Saga Map & Score Badge
            Positioned(
              top: 8,
              left: 12,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _exitToSagaMap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 4),
                          Text('नकाशा', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  if (_totalQuestions > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: GameColors.sunflowerGold.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '$_correctCount / $_totalQuestions',
                            style: const TextStyle(color: Color(0xFF3E2723), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper to generate multiple-choice alternatives around the numeric answer
List<int> _buildNumberOptions(int answer) {
  final set = <int>{answer};
  var delta = 1;
  while (set.length < 4 && delta < 20) {
    if (answer - delta >= 0 && set.length < 4) set.add(answer - delta);
    if (set.length < 4) set.add(answer + delta);
    delta++;
  }
  final list = set.toList()..sort();
  return list;
}

/// Rich interactive question asking widget with Marathi Speech-to-Text,
/// TTS prompt repeat button, retry on 1st wrong attempt, and prominent tap fallback buttons.
class _VoiceWithTapFallbackWidget extends StatefulWidget {
  final QuestionSpec question;
  final String lang;
  final FlutterTts flutterTts;
  final void Function(bool correct) onSubmit;

  const _VoiceWithTapFallbackWidget({
    super.key,
    required this.question,
    required this.lang,
    required this.flutterTts,
    required this.onSubmit,
  });

  @override
  State<_VoiceWithTapFallbackWidget> createState() => _VoiceWithTapFallbackWidgetState();
}

class _VoiceWithTapFallbackWidgetState extends State<_VoiceWithTapFallbackWidget>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _recognizedWords = '';
  String? _sttError;

  int _wrongAttempts = 0;
  bool _submitted = false;
  String? _feedbackMessage;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _speakPrompt();
    _initSpeech();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _speakPrompt() async {
    final text = widget.question.prompt.of(widget.lang);
    if (text.isNotEmpty) {
      try {
        await widget.flutterTts.speak(text);
      } catch (_) {}
    }
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (err) {
          debugPrint('STT error: ${err.errorMsg}');
          if (mounted) {
            setState(() {
              _isListening = false;
              _sttError = err.errorMsg;
            });
          }
        },
        onStatus: (status) {
          debugPrint('STT status: $status');
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isListening) {
              setState(() => _isListening = false);
            }
          }
        },
      );
      if (mounted) {
        setState(() => _speechAvailable = available);
      }
    } catch (e) {
      debugPrint('Speech init failed: $e');
    }
  }

  Future<void> _startListening() async {
    if (_submitted) return;
    SoundService.instance.playPopClick();

    if (!_speechAvailable) {
      await _initSpeech();
    }

    final answerStr = widget.question.answer?.toString() ?? '';

    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _sttError = null;
    });

    try {
      String? targetLocale = 'mr_IN';
      try {
        final locales = await _speech.locales();
        final hasMr = locales.any((l) => l.localeId.startsWith('mr'));
        if (!hasMr) targetLocale = null;
      } catch (_) {}

      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          localeId: targetLocale,
          listenFor: const Duration(seconds: 7),
          pauseFor: const Duration(seconds: 3),
        ),
        onResult: (result) {
          if (!mounted) return;
          final words = result.recognizedWords;
          setState(() => _recognizedWords = words);

          if (VoiceAnswerMatcher.evaluateAnswer(words, answerStr)) {
            _speech.stop();
            _handleSubmit(true);
          } else if (result.finalResult && words.isNotEmpty) {
            _speech.stop();
            _handleSubmit(false);
          }
        },
      );
    } catch (e) {
      debugPrint('Listen error: $e');
      if (mounted) {
        setState(() => _isListening = false);
      }
    }
  }

  void _handleSubmit(bool correct) {
    if (_submitted) return;
    _speech.stop();

    if (correct) {
      _submitted = true;
      setState(() {
        _feedbackMessage = 'बरोबर उत्तर! 🌟 (Correct!)';
      });
      widget.onSubmit(true);
    } else {
      _wrongAttempts++;
      if (_wrongAttempts == 1) {
        // First wrong answer: allow child to retry once!
        setState(() {
          _feedbackMessage = 'चुकीचे उत्तर. पुन्हा प्रयत्न करा! 🔄 (Try again!)';
        });
        widget.onSubmit(false);
      } else {
        // Second wrong answer: moves on
        _submitted = true;
        setState(() {
          _feedbackMessage = 'योग्य उत्तर पुढे दाखवले आहे...';
        });
        widget.onSubmit(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final promptText = localizeDigits(q.prompt.of(widget.lang), widget.lang);
    final answerStr = q.answer?.toString() ?? '';

    // Determine fallback options
    List<String> options = [];
    if (q.options.isNotEmpty) {
      options = q.options.map((o) => o.toString()).toList();
    } else {
      final ansNum = int.tryParse(answerStr) ?? (q.answer is num ? (q.answer as num).round() : 1);
      options = _buildNumberOptions(ansNum).map((n) => n.toString()).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Question Prompt & Audio Repeat Button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                promptText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  fontFamilyFallback: kNovaFontFallback,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, color: GameColors.activeGoldDark, size: 28),
              tooltip: 'ऐका (Listen again)',
              onPressed: () {
                SoundService.instance.playPopClick();
                _speakPrompt();
              },
            ),
          ],
        ),

        if (_feedbackMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            _feedbackMessage!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _wrongAttempts == 1 ? Colors.orange.shade800 : Colors.green.shade800,
              fontFamilyFallback: kNovaFontFallback,
            ),
          ),
        ],

        const SizedBox(height: 10),

        // VOICE INPUT SECTION
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isListening
                ? const Color(0xFFFFF176).withValues(alpha: 0.35)
                : const Color(0xFFEDE7F6).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isListening ? GameColors.activeGoldDark : GameColors.electricPurple.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              ScaleTransition(
                scale: _isListening ? _pulseScale : const AlwaysStoppedAnimation(1.0),
                child: Material(
                  color: _isListening ? GameColors.coralRed : GameColors.electricPurple,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _isListening ? () => _speech.stop() : _startListening,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isListening
                          ? 'ऐकत आहे... बोला! 🎤 (Listening...)'
                          : 'माईक दाबून उत्तर द्या (Tap to speak)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _isListening ? GameColors.coralRed : GameColors.electricPurple,
                        fontFamilyFallback: kNovaFontFallback,
                      ),
                    ),
                    if (_recognizedWords.isNotEmpty)
                      Text(
                        'ऐकले: "$_recognizedWords"',
                        style: const TextStyle(fontSize: 13, color: Colors.black87, fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (_sttError != null && _recognizedWords.isEmpty)
                      const Text(
                        'खालील बटणांमधून उत्तर निवडा 👇',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // TAP FALLBACK SECTION: ALWAYS VISIBLE
        Row(
          children: const [
            Icon(Icons.touch_app_rounded, size: 16, color: GameColors.woodBarkBrown),
            SizedBox(width: 4),
            Text(
              'किंवा उत्तर निवडा • Or Tap Answer:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: GameColors.woodBarkBrown,
                fontFamilyFallback: kNovaFontFallback,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Large tap fallback buttons
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            for (final opt in options)
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 70, minHeight: 52),
                child: ElevatedButton(
                  onPressed: _submitted ? null : () {
                    SoundService.instance.playPopClick();
                    final isCorrect = (opt.trim() == answerStr.trim());
                    _handleSubmit(isCorrect);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: GameColors.inkGrape,
                    elevation: 4,
                    shadowColor: GameColors.sunflowerGold.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: GameColors.sunflowerGold, width: 2.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    localizeDigits(opt, widget.lang),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamilyFallback: kNovaFontFallback,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
