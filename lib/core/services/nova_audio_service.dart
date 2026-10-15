import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Offline TTS and voice prompt audio service for vernacular Marathi learning copy.
class NovaAudioService {
  static final NovaAudioService instance = NovaAudioService._internal();

  NovaAudioService._internal() {
    _initTts();
  }

  final FlutterTts _tts = FlutterTts();
  bool _isMuted = false;
  bool _isPlaying = false;
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);

  bool get isMuted => _isMuted;
  bool get isPlaying => _isPlaying;

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("mr-IN");
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.85); // Gentle, natural pace for young rural learners

      _tts.setStartHandler(() {
        _isPlaying = true;
        isPlayingNotifier.value = true;
      });

      _tts.setCompletionHandler(() {
        _isPlaying = false;
        isPlayingNotifier.value = false;
      });

      _tts.setErrorHandler((msg) {
        _isPlaying = false;
        isPlayingNotifier.value = false;
      });
    } catch (e) {
      debugPrint("NovaAudioService TTS init error: $e");
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    isMutedNotifier.value = _isMuted;
    if (_isMuted) {
      stop();
    }
  }

  Future<void> speak(String text) async {
    if (_isMuted || text.trim().isEmpty) return;
    try {
      await _tts.stop();
      _isPlaying = true;
      isPlayingNotifier.value = true;
      await _tts.speak(text);
    } catch (e) {
      debugPrint("NovaAudioService speak error: $e");
      _isPlaying = false;
      isPlayingNotifier.value = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      _isPlaying = false;
      isPlayingNotifier.value = false;
    } catch (e) {
      debugPrint("NovaAudioService stop error: $e");
    }
  }
}
