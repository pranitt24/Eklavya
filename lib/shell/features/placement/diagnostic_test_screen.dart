import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/level_api.dart';
import '../../../core/services/nova_tts_service.dart';
import '../../core/audio/sound_service.dart';
import '../../core/models/level_progress.dart';
import '../../core/models/user_profile.dart';
import '../../core/widgets/celebration_overlay.dart';
import '../../core/widgets/squishy_button.dart';
import '../../theme.dart';

/// DiagnosticTestScreen (Placement Test):
/// 1. Fetches 5 questions from GET /duel/questions
/// 2. Nova asks each question (spoken in Marathi TTS).
/// 3. Child taps an option card, tracking correct answers.
/// 4. On finish, calls POST /students/:id/placement {correct, total}.
/// 5. Shows celebration popup and assigned starting level, then opens /saga-map.
class DiagnosticTestScreen extends StatefulWidget {
  const DiagnosticTestScreen({super.key});

  @override
  State<DiagnosticTestScreen> createState() => _DiagnosticTestScreenState();
}

class _DiagnosticTestScreenState extends State<DiagnosticTestScreen> {
  final LevelApi _levelApi = LevelApi();

  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  dynamic _selectedOption;
  int _correctCount = 0;

  bool _showPlacementModal = false;
  int _assignedLevel = 1;
  int _assignedGrade = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) NovaTtsService.instance.init(context);
    });
    _loadQuestions();
  }

  @override
  void dispose() {
    NovaTtsService.instance.stop();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final age = prefs.getInt('student_age') ?? UserProfile.instance.age;
    final grade = (age - 5).clamp(1, 4);
    final seed = Random().nextInt(10000) + 1;

    List<Map<String, dynamic>> questions = [];
    try {
      questions = await _levelApi.getDuelQuestions(
        seed: seed,
        n: 5,
        grade: grade,
        timeout: const Duration(seconds: 4),
      );
    } catch (_) {}

    if (questions.isEmpty) {
      questions = _generateFallbackQuestions(grade, seed);
    }

    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
        _currentQuestionIndex = 0;
        _correctCount = 0;
        _selectedOption = null;
      });
      _speakCurrentQuestion();
    }
  }

  List<Map<String, dynamic>> _generateFallbackQuestions(int grade, int seed) {
    final rng = Random(seed);
    final out = <Map<String, dynamic>>[];
    for (int i = 0; i < 5; i++) {
      final a = rng.nextInt(grade * 5) + 2;
      final b = rng.nextInt(grade * 4) + 1;
      final isSub = (grade >= 2 && rng.nextBool() && a >= b);
      final ans = isSub ? a - b : a + b;
      final sym = isSub ? '-' : '+';
      final expr = '$a $sym $b = ?';
      final opts = <int>{ans};
      while (opts.length < 4) {
        final delta = rng.nextInt(7) - 3;
        if (delta != 0 && ans + delta >= 0) opts.add(ans + delta);
      }
      final optList = opts.toList()..shuffle(rng);
      out.add({
        'id': 'd${i + 1}',
        'type': 'fill_blanks',
        'prompt': {'mr': expr, 'en': expr},
        'options': optList,
        'answer': ans,
      });
    }
    return out;
  }

  String _toMarathiDigits(String input) {
    const map = {
      '0': '०', '1': '१', '2': '२', '3': '३', '4': '४',
      '5': '५', '6': '६', '7': '७', '8': '८', '9': '९',
    };
    var res = input;
    map.forEach((en, mr) {
      res = res.replaceAll(en, mr);
    });
    return res;
  }

  String _toMarathiSpokenMath(String expr) {
    var spoken = expr
        .replaceAll('+', ' अधिक ')
        .replaceAll('-', ' वजा ')
        .replaceAll('×', ' गुणिले ')
        .replaceAll('*', ' गुणिले ')
        .replaceAll('=', ' बरोबर ')
        .replaceAll('?', ' किती ');
    return _toMarathiDigits(spoken);
  }

  void _speakCurrentQuestion() {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return;
    final q = _questions[_currentQuestionIndex];
    final prompt = (q['prompt'] is Map ? q['prompt']['mr'] : q['prompt']).toString();
    final spoken = _toMarathiSpokenMath(prompt);
    NovaTtsService.instance.speak(spoken);
  }

  Future<void> _handleOptionSelected(dynamic option) async {
    if (_selectedOption != null) return; // Prevent double tap

    NovaTtsService.instance.stop();

    final q = _questions[_currentQuestionIndex];
    final correctAnswer = q['answer'];
    final isCorrect = option.toString() == correctAnswer.toString();

    setState(() {
      _selectedOption = option;
      if (isCorrect) _correctCount++;
    });

    if (isCorrect) {
      CelebrationOverlay.show(context, type: CelebrationType.correctAnswer);
      GameState.instance.addCoins(10);
    } else {
      SoundService.instance.playBoingBloop();
    }

    Future.delayed(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOption = null;
        });
        _speakCurrentQuestion();
      } else {
        await _completePlacementTest();
      }
    });
  }

  Future<void> _completePlacementTest() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('current_student_id') ?? UserProfile.instance.studentId;

    int grade = 1;
    int tier = 1;

    if (studentId != null) {
      try {
        final res = await _levelApi.recordPlacement(
          studentId,
          correct: _correctCount,
          total: _questions.length,
        );
        if (res != null) {
          grade = (res['grade'] as int?) ?? 1;
          tier = (res['tier'] as int?) ?? 1;
        }
      } catch (e) {
        debugPrint('Placement record network fallback: $e');
      }
    } else {
      // Local placement logic
      final age = prefs.getInt('student_age') ?? UserProfile.instance.age;
      final base = (age - 5).clamp(1, 4);
      final ratio = _correctCount / _questions.length;
      grade = ratio < 0.4 ? (base - 1).clamp(1, 4) : ratio >= 0.75 ? (base + 1).clamp(1, 4) : base;
      tier = ratio >= 0.75 ? 2 : 1;
    }

    final startingLevel = ((grade - 1) * 2 + tier).clamp(1, 7);

    await prefs.setInt('student_grade', grade);
    await prefs.setInt('student_tier', tier);
    await prefs.setInt('assigned_starting_level', startingLevel);

    UserProfile.instance.setGrade(grade);
    GameState.instance.completeDiagnosticPlacement(startingLevel: startingLevel);

    if (mounted) {
      CelebrationOverlay.show(context, type: CelebrationType.placementComplete);
      setState(() {
        _assignedGrade = grade;
        _assignedLevel = startingLevel;
        _showPlacementModal = true;
      });
    }
  }

  void _proceedToSagaMap() {
    SoundService.instance.playPopClick();
    context.go('/saga-map');
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
              const SizedBox(height: 16),
              Text(
                'चाचणी तयार होत आहे... ✨\nLoading Placement Questions...',
                textAlign: TextAlign.center,
                style: GameTypography.marathiHeadingLarge(color: Colors.white).copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_currentQuestionIndex];
    final rawPrompt = (q['prompt'] is Map ? q['prompt']['mr'] : q['prompt']).toString();
    final promptMarathi = _toMarathiDigits(rawPrompt);
    final options = (q['options'] as List<dynamic>?) ?? [];
    final correctAnswer = q['answer'];

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
                        // Exit Button
                        GestureDetector(
                          onTap: () => context.go('/profile-picker'),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: GameColors.cardBorderLavender, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                              ],
                            ),
                            child: const Icon(Icons.close_rounded, color: GameColors.electricPurple, size: 24),
                          ),
                        ),

                        // Question Progress Tracker
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: GameColors.activeGoldDark, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'प्रश्न ${_toMarathiDigits('${_currentQuestionIndex + 1}')} / ${_toMarathiDigits('${_questions.length}')}',
                                style: GameTypography.headline(color: GameColors.inkGrape).copyWith(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              const Text('⭐', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 4),
                              Text(
                                '$_correctCount',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: GameColors.inkGrape),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // Nova Question Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: GameColors.cardBorderLavender, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: GameColors.electricPurple.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Nova Thinking Mascot
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE0F2FE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Image.asset(
                                        'assets/nova/characters/char_nova_thinking.webp',
                                        fit: BoxFit.contain,
                                        errorBuilder: (c, e, s) => const Center(
                                          child: Text('🤖', style: TextStyle(fontSize: 32)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Question Prompt Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        promptMarathi,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: GameColors.electricPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'उत्तर शोधा आणि योग्य पर्याय निवडा',
                                        style: GameTypography.buttonSublabel(color: GameColors.inkMuted),
                                      ),
                                    ],
                                  ),
                                ),

                                // Speaker Button to re-listen
                                IconButton(
                                  onPressed: () {
                                    SoundService.instance.playPopClick();
                                    _speakCurrentQuestion();
                                  },
                                  icon: const Icon(Icons.volume_up_rounded, color: GameColors.electricPurple, size: 28),
                                  tooltip: 'पुन्हा ऐका (Listen again)',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 4 Tap-friendly Options
                          Expanded(
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.25,
                              ),
                              itemCount: options.length,
                              itemBuilder: (context, idx) {
                                final opt = options[idx];
                                final isSelected = _selectedOption == opt;
                                final isCorrect = opt.toString() == correctAnswer.toString();

                                Color bgColor = Colors.white;
                                Color borderColor = GameColors.cardBorderLavender;
                                if (isSelected) {
                                  bgColor = isCorrect ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
                                  borderColor = isCorrect ? GameColors.emeraldGrass : GameColors.coralRed;
                                }

                                return GestureDetector(
                                  onTap: () => _handleOptionSelected(opt),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: borderColor, width: isSelected ? 3.5 : 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: GameColors.inkGrape.withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _toMarathiDigits(opt.toString()),
                                            style: const TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.bold,
                                              color: GameColors.inkGrape,
                                            ),
                                          ),
                                          if (isSelected)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Icon(
                                                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                                color: isCorrect ? GameColors.emeraldGrass : GameColors.coralRed,
                                                size: 24,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Placement Result Modal Overlay
            if (_showPlacementModal) _buildPlacementModal(context),
          ],
        ),
      ),
    );
  }

  /// Placement completion modal showing assigned starting level
  Widget _buildPlacementModal(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: GameColors.activeGold, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nova Cheering Avatar
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/nova/characters/char_nova_happy.webp',
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Center(
                          child: Text('🤖', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('🎉 🚀 🏆', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),

                Text(
                  'शाब्बास! छान खेळलास!',
                  style: GameTypography.displayHero(color: GameColors.inkGrape).copyWith(fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'इयत्ता $_assignedGrade • तुझा प्रवास टप्पा $_assignedLevel पासून सुरू होत आहे!\n(Grade $_assignedGrade • Level $_assignedLevel Unlocked!)',
                  style: GameTypography.headline(color: GameColors.electricPurple).copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Score pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: GameColors.canvasCream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GameColors.cardBorderAmber, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐⭐⭐', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        '+${_correctCount * 10} 🪙 नाणी!',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Primary CTA to Saga Map
                Squishy3DButton(
                  height: 62,
                  backgroundColor: GameColors.emeraldGrass,
                  bevelColor: GameColors.emeraldGrassDark,
                  label: 'नकाशावर चला! ➔',
                  sublabel: 'EXPLORE VILLAGE SAGA MAP',
                  onPressed: _proceedToSagaMap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
