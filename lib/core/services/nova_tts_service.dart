import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Centralized Marathi & Devanagari Text-To-Speech service.
/// - Sets speech rate ~0.4 and awaitSpeakCompletion(true)
/// - Checks if 'mr-IN' is available
/// - If not, prompts child/parent to install Marathi voice data and falls back to 'hi-IN'
/// - Logs engines & languages for device diagnostics
class NovaTtsService {
  NovaTtsService._internal();
  static final NovaTtsService instance = NovaTtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _initialized = false;
  bool _hasMarathi = false;
  bool _dialogShown = false;
  String _activeLanguage = 'mr-IN';
  List<dynamic> _engines = [];
  List<dynamic> _languages = [];

  bool get hasMarathi => _hasMarathi;
  String get activeLanguage => _activeLanguage;
  List<dynamic> get engines => _engines;
  List<dynamic> get languages => _languages;
  FlutterTts get tts => _flutterTts;

  Future<void> init([BuildContext? context]) async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.setSpeechRate(0.40);
      await _flutterTts.setVolume(1.0);

      // Query and log available engines & languages
      try {
        final dynamic rawEngines = await _flutterTts.getEngines;
        if (rawEngines is List) {
          _engines = rawEngines;
        }
        debugPrint('🔊 TTS Available Engines: $_engines');
      } catch (e) {
        debugPrint('TTS getEngines note: $e');
      }

      try {
        final dynamic rawLangs = await _flutterTts.getLanguages;
        if (rawLangs is List) {
          _languages = rawLangs;
        }
        debugPrint('🔊 TTS Available Languages count: ${_languages.length}');
      } catch (e) {
        debugPrint('TTS getLanguages note: $e');
      }

      // Check Marathi (mr-IN) availability
      try {
        final dynamic mrAvail = await _flutterTts.isLanguageAvailable('mr-IN');
        _hasMarathi = (mrAvail == true || mrAvail == 1);
        debugPrint('🔊 TTS Marathi (mr-IN) available: $_hasMarathi');
      } catch (e) {
        debugPrint('TTS isLanguageAvailable error: $e');
        _hasMarathi = false;
      }

      if (_hasMarathi) {
        _activeLanguage = 'mr-IN';
        await _flutterTts.setLanguage('mr-IN');
        debugPrint('🔊 TTS language set to: mr-IN');
      } else {
        // Fall back to Hindi (hi-IN) which reads Devanagari script natively
        _activeLanguage = 'hi-IN';
        await _flutterTts.setLanguage('hi-IN');
        debugPrint('🔊 TTS mr-IN not available; falling back to hi-IN');

        if (context != null && !_dialogShown) {
          _dialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showInstallMarathiDialog(context);
          });
        }
      }
    } catch (e) {
      debugPrint('NovaTtsService init failure: $e');
    }
  }

  void _showInstallMarathiDialog(BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.record_voice_over_rounded, color: Color(0xFF6C47FF), size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'मराठी आवाज स्थापित करा',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Install Marathi voice:\n\n'
          'Settings > System > Languages > Text-to-speech output > Google > Install voice data > Marathi\n\n'
          '(अॅप आता हिंदी आवाजाचा वापर करेल)',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C47FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ठीक आहे (OK)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await stop();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }
}
