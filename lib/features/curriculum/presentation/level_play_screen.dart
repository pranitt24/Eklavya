import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math' as math;
import 'package:majhe_gaon/features/curriculum/curriculum_loader.dart';
import 'package:majhe_gaon/features/diagnostic/adaptive_engine.dart';
import 'package:majhe_gaon/features/voice_engine/voice_input_widget.dart';

class LevelPlayScreen extends StatefulWidget {
  final int levelId;

  const LevelPlayScreen({super.key, required this.levelId});

  @override
  State<LevelPlayScreen> createState() => _LevelPlayScreenState();
}

class _LevelPlayScreenState extends State<LevelPlayScreen> with SingleTickerProviderStateMixin {
  final CurriculumLoader _curriculumLoader = CurriculumLoader();
  final DiagnosticManager _diagnosticManager = DiagnosticManager();
  final FlutterTts _flutterTts = FlutterTts();

  LevelModel? _level;
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _showScaffoldHint = false;
  bool _showSuccessOverlay = false;
  late DateTime _questionStartTime;
  
  late AnimationController _shakeController;

  // Initialize standard BKT state for a new level
  final StudentPerformanceState _performanceState = StudentPerformanceState(
    pMastery: 0.10,
    consecutiveFails: 0,
  );

  final TextEditingController _tapAnswerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadLevel();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("mr-IN");
  }

  Future<void> _loadLevel() async {
    final levels = await _curriculumLoader.loadStd3Levels();
    final level = levels.firstWhere(
      (l) => l.levelId == widget.levelId,
      orElse: () => levels.first,
    );
    setState(() {
      _level = level;
      _isLoading = false;
      _questionStartTime = DateTime.now();
    });
    _playStoryIntro(level.storyIntro);
  }

  Future<void> _playStoryIntro(String text) async {
    await _flutterTts.speak(text);
  }

  void _handleAnswer(bool isCorrect) {
    final timeTakenMs = DateTime.now().difference(_questionStartTime).inMilliseconds;
    final action = _diagnosticManager.evaluateResponse(
      isCorrect,
      timeTakenMs,
      _performanceState,
    );

    if (isCorrect) {
      _tapAnswerController.clear();
      setState(() {
        _showScaffoldHint = false;
        _showSuccessOverlay = true;
      });
      
      _flutterTts.speak("खूप छान!"); // Great job

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _showSuccessOverlay = false;
          if (_currentQuestionIndex < _level!.questionPool.length - 1) {
            _currentQuestionIndex++;
            _questionStartTime = DateTime.now();
          } else {
            _flutterTts.speak("अभिनंदन! तुम्ही पातळी पूर्ण केली आहे.");
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.of(context).pop();
            });
          }
        });
      });
    } else {
      _shakeController.forward(from: 0.0);
      if (action == AdaptationAction.scaffoldWithinLevel) {
        setState(() {
          _showScaffoldHint = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _tapAnswerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Widget _buildCardShake(Widget child) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final sineValue = math.sin(_shakeController.value * 4 * math.pi);
        return Transform.translate(
          offset: Offset(sineValue * 12, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_level == null) {
      return const Scaffold(body: Center(child: Text("Level not found")));
    }

    final currentQuestion = _level!.questionPool[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _level!.questionPool.length;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('${_level!.subject} - Level ${_level!.levelId}'),
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.green.shade100,
                color: Colors.green.shade700,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress text
                      Text(
                        'Question ${_currentQuestionIndex + 1} of ${_level!.questionPool.length}',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
          
                      // Massive Question Card with Shake Animation
                      _buildCardShake(
                        Card(
                          elevation: 12,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
                            child: Column(
                              children: [
                                Text(
                                  _level!.storyIntro,
                                  style: const TextStyle(
                                    fontSize: 32, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                IconButton(
                                  icon: const Icon(Icons.volume_up_rounded, size: 56, color: Colors.blue),
                                  onPressed: () => _playStoryIntro(_level!.storyIntro),
                                  tooltip: 'गोष्ट ऐका', // Listen to story
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(),
          
                      // Scaffold Hint
                      if (_showScaffoldHint)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.shade300, width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb, color: Colors.orange, size: 36),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'मदत हवी आहे का? उत्तर: "${currentQuestion.targetAnswer}" हे असू शकते.',
                                  style: const TextStyle(fontSize: 20, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
          
                      // Interaction Widget
                      currentQuestion.type == 'voice_input'
                          ? VoiceInputWidget(
                              questionText: _level!.storyIntro,
                              expectedAnswer: currentQuestion.targetAnswer,
                              onCorrect: () => _handleAnswer(true),
                              onIncorrect: () => _handleAnswer(false),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _tapAnswerController,
                                  decoration: InputDecoration(
                                    labelText: 'तुमचे उत्तर लिहा (Type your answer)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    final input = _tapAnswerController.text.trim();
                                    bool isCorrect = input == currentQuestion.targetAnswer;
                                    _handleAnswer(isCorrect);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    minimumSize: const Size.fromHeight(60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 6,
                                  ),
                                  child: const Text('तपासा (Check)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Full-screen Success Overlay
        if (_showSuccessOverlay)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: Container(
                color: Colors.green.withValues(alpha: 0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle, size: 160, color: Colors.white),
                    SizedBox(height: 24),
                    Text(
                      'खूप छान!',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
