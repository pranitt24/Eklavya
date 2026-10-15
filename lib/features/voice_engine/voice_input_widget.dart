import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'voice_answer_matcher.dart';

class VoiceInputWidget extends StatefulWidget {
  final String questionText;
  final String expectedAnswer;
  final VoidCallback? onCorrect;
  final VoidCallback? onIncorrect;

  const VoiceInputWidget({
    super.key,
    required this.questionText,
    required this.expectedAnswer,
    this.onCorrect,
    this.onIncorrect,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("mr-IN");
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  void _openVoiceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => _BottomSheetContent(
        questionText: widget.questionText,
        expectedAnswer: widget.expectedAnswer,
        speech: _speech,
        tts: _flutterTts,
        pulseAnimation: _pulseAnimation,
        onResult: (isCorrect) {
          Navigator.pop(ctx);
          if (isCorrect) {
            widget.onCorrect?.call();
          } else {
            widget.onIncorrect?.call();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          backgroundColor: Colors.red.shade500,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          minimumSize: const Size.fromHeight(80),
        ),
        onPressed: _openVoiceBottomSheet,
        icon: const Icon(Icons.mic, size: 40),
        label: const Text(
          'उत्तर देण्यासाठी दाबा\n(Tap to Answer)',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _BottomSheetContent extends StatefulWidget {
  final String questionText;
  final String expectedAnswer;
  final stt.SpeechToText speech;
  final FlutterTts tts;
  final Animation<double> pulseAnimation;
  final Function(bool) onResult;

  const _BottomSheetContent({
    required this.questionText,
    required this.expectedAnswer,
    required this.speech,
    required this.tts,
    required this.pulseAnimation,
    required this.onResult,
  });

  @override
  State<_BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  bool _isListening = false;
  String _recognizedText = '';
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    // Read the question aloud
    await widget.tts.speak(widget.questionText);
    
    // Give a tiny delay in case TTS completes instantly due to engine specifics
    await Future.delayed(const Duration(milliseconds: 500));
    
    bool available = await widget.speech.initialize(
      onError: (val) {
        debugPrint('STT Error: ${val.errorMsg}');
        if (mounted) {
          widget.speech.stop();
          Navigator.pop(context);
        }
      },
    );

    if (available && mounted) {
      setState(() => _isListening = true);
      widget.speech.listen(
        onResult: (val) {
          if (mounted) {
            setState(() {
              _recognizedText = val.recognizedWords;
            });
            if (val.finalResult) {
              _processResult(val.recognizedWords);
            }
          }
        },
        onSoundLevelChange: (level) {
          if (mounted) {
            setState(() {
              _soundLevel = level;
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } else if (!available && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _processResult(String spoken) async {
    if (!_isListening) return; // Prevent double submission
    setState(() => _isListening = false);
    await widget.speech.stop();
    
    bool isCorrect = VoiceAnswerMatcher.evaluateAnswer(spoken, widget.expectedAnswer);
    if (!isCorrect) {
      // Correct sound is handled by LevelPlayScreen directly 
      // but incorrect feedback is spoken here for context
      await widget.tts.speak("पुन्हा प्रयत्न करा");
    }
    if (mounted) {
      widget.onResult(isCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 1.0 + (_soundLevel.clamp(0.0, 50.0) / 100.0), // Grow based on volume
            child: ScaleTransition(
              scale: widget.pulseAnimation,
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.mic, size: 72, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _isListening ? "ऐकत आहे... (Listening...)" : "प्रक्रिया करत आहे... (Processing...)",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          if (_recognizedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Text(
                '"$_recognizedText"',
                style: const TextStyle(fontSize: 28, fontStyle: FontStyle.italic, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          else if (_isListening)
            const Text(
              'मोठ्याने बोला... (Speak loudly...)',
              style: TextStyle(fontSize: 22, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              widget.speech.stop();
              _processResult(_recognizedText);
            },
            icon: const Icon(Icons.stop_circle),
            label: const Text(
              'थांबा (Stop & Submit)',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              widget.speech.stop();
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(fontSize: 20, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
