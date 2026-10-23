import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/widgets/nova/mascot_widget.dart';
import '../../../core/widgets/confetti_overlay.dart';
import '../../../nova_main/services/app_state.dart';
import '../../../nova_main/theme/app_colors.dart';
import '../../../nova_main/models/story_beat.dart';

// Mock/wrapper for vosk_flutter_service to provide offline speech recognition
class VoskFlutterService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<bool> initialize() async {
    return await _speech.initialize();
  }

  void listen({required Function(String) onResult}) {
    _speech.listen(
      onResult: (val) {
        if (val.finalResult) {
          onResult(val.recognizedWords);
        }
      },
    );
  }

  void stop() {
    _speech.stop();
  }
}

class Std1Level1StoryScreen extends StatefulWidget {
  const Std1Level1StoryScreen({super.key});

  @override
  State<Std1Level1StoryScreen> createState() => _Std1Level1StoryScreenState();
}

class _Std1Level1StoryScreenState extends State<Std1Level1StoryScreen> {
  int _currentStep = 1;
  final FlutterTts _flutterTts = FlutterTts();
  final VoskFlutterService _voskService = VoskFlutterService();

  bool _isTtsPlaying = false;
  bool _showAction = false; 
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _initServices();
    _playStep(_currentStep);
  }

  Future<void> _initServices() async {
    await _flutterTts.setLanguage("mr-IN");
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isTtsPlaying = false;
          _showAction = true;
        });
      }
    });
    await _voskService.initialize();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _flutterTts.stop();
    _voskService.stop();
    super.dispose();
  }

  String _getStepText(int step) {
    switch (step) {
      case 1:
        return "नमस्कार! आज आपण एका नवीन प्रवासाला जाणार आहोत. आपण चिंटूच्या गावी जाऊन 'Good Morning' म्हणायला, आणि 'मोठं-छोटं', 'वर-खाली' ओळखायला शिकणार आहोत. चला सुरू करूया!";
      case 2:
        return "शुभ सकाळ, चिंटू! सूर्य उगवला आहे आणि सकाळ झाली आहे. जेव्हा आपण सकाळी उठतो, तेव्हा आपण 'Good Morning' म्हणतो.";
      case 3:
        return "वर बघ चिंटू! छतावर चिऊताई बसली आहे. आणि खाली बघ, जमिनीवर गण्या वासरू झोपले आहे. छताच्या वर कोण बसले आहे ते निवडा.";
      case 4:
        return "शेतात एक मोठा ट्रॅक्टर उभा आहे, आणि त्याजवळ एक छोटी बादली ठेवली आहे. आता, स्क्रीनवर दिसणाऱ्या मोठ्या वाहनावर टॅप करा.";
      case 5:
        return "जेव्हा सूर्य उगवतो, तेव्हा आपण काय म्हणतो? योग्य पर्याय निवडा.";
      case 6:
        return "शाब्बास मित्रा! तू खूप छान उत्तरे दिलीस. आज आपण शिकलो: सकाळी उठल्यावर आपण 'Good Morning' म्हणतो. आपण 'वर' आणि 'खाली' पाहिलं. आणि ट्रॅक्टर 'मोठा' असतो हे ओळखलं. पुढच्या खेळात आपण मोजायला शिकूया!";
      default:
        return "";
    }
  }

  String? _getImageForStep(int step) {
    switch (step) {
      case 2: return 'assets/images/frame1story1.png';
      case 3: return 'assets/images/frame2story1.png';
      case 4: return 'assets/images/frame3story1.png';
      case 5: return 'assets/images/frame3story1.png'; // Step 5 re-uses frame3
      case 6: return 'assets/images/frame4story1.png';
      default: return null;
    }
  }

  Future<void> _playStep(int step) async {
    setState(() {
      _currentStep = step;
      _isTtsPlaying = true;
      _showAction = false;
      _isListening = false;
    });
    
    await _flutterTts.speak(_getStepText(step));
  }

  void _onIncorrectAnswer(String feedback) async {
    setState(() {
      _isTtsPlaying = true;
      _showAction = false;
    });
    await _flutterTts.speak(feedback);
  }

  void _onCorrectAnswer() {
    _playStep(_currentStep + 1);
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });
    _voskService.listen(onResult: (text) {
      if (text.toLowerCase().contains("good morning") || text.toLowerCase().contains("morning")) {
        _stopListening();
        _onCorrectAnswer();
      } else {
        _stopListening();
        _onIncorrectAnswer("नाही, पुन्हा प्रयत्न कर");
      }
    });
  }

  void _stopListening() {
    _voskService.stop();
    setState(() {
      _isListening = false;
    });
  }

  Widget _buildMcqCard(String label, bool isCorrect) {
    return GestureDetector(
      onTap: () {
        if (isCorrect) {
          _onCorrectAnswer();
        } else {
          _onIncorrectAnswer("नाही, पुन्हा प्रयत्न कर");
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.indigo, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
      ),
    );
  }

  Widget _buildActionArea() {
    switch (_currentStep) {
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _isListening ? Colors.redAccent : AppColors.indigo,
                child: Icon(_isListening ? Icons.mic_off : Icons.mic, size: 40, color: Colors.white),
              ),
            ),
            if (_isListening)
              Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("ऐकत आहे... (Listening...)", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
          ],
        );
      case 3:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMcqCard("चिऊताई (Sparrow)", true),
            _buildMcqCard("गण्या वासरू (Calf)", false),
          ],
        );
      case 4:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)),
          child: const Text("प्रतिमेतील मोठ्या वाहनावर टॅप करा (Tap the large vehicle)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
        );
      case 5:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMcqCard("Good Night", false),
            _buildMcqCard("Good Morning", true),
          ],
        );
      case 6:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coral,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {
            final appState = AppStateScope.of(context);
            appState.completeLevel();
            Navigator.pop(context);
          },
          child: const Text("Finish Level", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1Intro(String currentText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MascotWidget(
            mood: NovaMood.excited,
            size: 150,
            speaking: _isTtsPlaying,
            showGlow: true,
          ),
          const SizedBox(height: 40),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: !_showAction
                ? Container(
                    key: const ValueKey('intro_text'),
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 60),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      currentText,
                      style: const TextStyle(fontSize: 26, color: AppColors.navy, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ElevatedButton(
                    key: const ValueKey('start_btn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mint,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                    ),
                    onPressed: () => _playStep(2),
                    child: const Text(
                      "प्रवास सुरू करूया (Start Journey)", 
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryOverlay(String currentText) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Invisible Tap Area for step 4 (Tap the big vehicle/tractor)
          if (_currentStep == 4 && _showAction)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_showAction) _onIncorrectAnswer("नाही, मोठ्या वाहनावर टॅप करा");
                },
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: GestureDetector(
                        onTap: _onCorrectAnswer,
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Spacer(),

          // Bottom Captions and Actions
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MascotWidget(
                      mood: _currentStep == 6 ? NovaMood.celebrating : NovaMood.happy,
                      size: 90,
                      speaking: _isTtsPlaying,
                      showGlow: true,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.navy, width: 2),
                        ),
                        child: Text(
                          currentText,
                          style: const TextStyle(fontSize: 20, color: AppColors.navy, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showAction) ...[
                  const SizedBox(height: 20),
                  _buildActionArea(),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentText = _getStepText(_currentStep);
    String? currentImagePath = _getImageForStep(_currentStep);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image for story frames
          if (currentImagePath != null)
            Image.asset(
              currentImagePath,
              fit: BoxFit.cover,
            ),

          // Intro or Story Overlay
          if (_currentStep == 1) 
            _buildStep1Intro(currentText)
          else 
            _buildStoryOverlay(currentText),

          // Skip Button
          if (!_showAction)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    _flutterTts.stop();
                    setState(() {
                      _isTtsPlaying = false;
                      _showAction = true;
                    });
                  },
                  icon: const Icon(Icons.skip_next_rounded, size: 20),
                  label: const Text("Skip", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),

          if (_currentStep == 6)
            const ConfettiOverlay(play: true),
        ],
      ),
    );
  }
}
