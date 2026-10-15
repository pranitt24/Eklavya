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
  String _preferredMarathiLocale = 'mr-IN';

  bool get isMuted => _isMuted;
  bool get isPlaying => _isPlaying;
  String get preferredMarathiLocale => _preferredMarathiLocale;

  Future<void> _initTts() async {
    try {
      // Globally disable awaitSpeakCompletion to never block the UI gesture callback
      await _tts.awaitSpeakCompletion(false);

      // Inspect available voice engines and locales:
      // Prefer 'mr-IN' (Marathi India), falling back to 'hi-IN' (Hindi India, which
      // shares identical Devanagari phonetics so Marathi reads naturally),
      // and only use 'en-IN' if neither is available.
      try {
        final dynamic rawLangs = await _tts.getLanguages;
        if (rawLangs is List) {
          final List<String> langs = rawLangs
              .map((e) => e.toString().toLowerCase().replaceAll('_', '-'))
              .toList();
          if (langs.any((l) => l == 'mr-in' || l.startsWith('mr'))) {
            _preferredMarathiLocale = 'mr-IN';
          } else if (langs.any((l) => l == 'hi-in' || l.startsWith('hi'))) {
            _preferredMarathiLocale = 'hi-IN';
          } else {
            _preferredMarathiLocale = 'en-IN';
          }
        }
      } catch (e) {
        debugPrint("NovaAudioService getLanguages fallback: $e");
        _preferredMarathiLocale = 'mr-IN';
      }

      await _tts.setLanguage(_preferredMarathiLocale);
      // Natural child-friendly slow storytelling voice parameters (0.32 rate, 1.0 pitch)
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.32);

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

  /// Sanitizes raw input strings so the TTS engine speaks crystal-clear vernacular speech:
  /// - Strips parenthetical English translations (e.g., '(Which item is bigger?)')
  /// - Strips emojis and Unicode pictographs
  /// - Strips arrows (->, ✓), bullets (•, ●), stars (★), and punctuation artifacts
  /// - If Devanagari text is present, strips trailing/inline English words so the engine
  ///   doesn't attempt to spell Latin words using Marathi phonetics!
  /// - Adds gentle natural pauses (', ') between sentences so 6-year-olds can absorb every word.
  static String sanitizeText(String rawText) {
    if (rawText.trim().isEmpty) return '';

    String cleaned = rawText;

    // 0. Remove any accidental dollar sign or literal $1 tokens
    cleaned = cleaned.replaceAll('\$1', '');
    cleaned = cleaned.replaceAll('\$', '');

    // 1. Remove parenthetical English translations or explanatory hints
    cleaned = cleaned.replaceAll(RegExp(r'\([^)]*\)'), ' ');

    // 2. Remove emojis and Unicode symbols
    cleaned = cleaned.replaceAll(
      RegExp(
        r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE00}-\u{FE0F}\u{1F1E6}-\u{1F1FF}]',
        unicode: true,
      ),
      ' ',
    );

    // 3. Remove arrows, bullets, stars, checkmarks, divider symbols
    cleaned = cleaned.replaceAll('->', ', ');
    cleaned = cleaned.replaceAll('•', ', ');
    cleaned = cleaned.replaceAll('✓', '');
    cleaned = cleaned.replaceAll(
      RegExp(r'(→|←|⇒|✔|★|☆|●|·|\||~|_|\^)'),
      ' ',
    );

    // 4. If string contains Devanagari script, strip any remaining Latin/English characters and symbols
    final bool hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(cleaned);
    if (hasDevanagari) {
      cleaned = cleaned.replaceAll(RegExp(r'[A-Za-z0-9_/]+'), ' ');
    }

    // 5. Add gentle natural pauses between sentences (pure punctuation, ZERO $ symbols)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'([.?!।])\s*'),
      (match) => '${match.group(1)} , ',
    );

    // 6. Absolute safety guard: ensure no dollar tokens remain
    cleaned = cleaned.replaceAll('\$1', '').replaceAll('\$', '');

    // 7. Normalize whitespace and clean dangling boundary punctuation
    cleaned = cleaned.replaceAll(RegExp(r'[\s\t\n]+'), ' ').trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+,\s+'), ' , ');
    cleaned = cleaned.replaceAll(RegExp(r'^[,\-.:;!?\s]+|[,\-.:;\s]+$'), '').trim();

    return cleaned;
  }

  /// Speaks sanitized text with child-friendly rate (0.32) and pitch (1.0).
  /// Dynamically sets the TTS language to Marathi/Hindi for Devanagari,
  /// or en-IN for purely English strings.
  /// Always calls stop() before speaking to prevent overlapping or audio channel locking.
  Future<void> speakCleanText(
    String rawText, {
    String? dedicatedMarathiText,
  }) async {
    if (_isMuted) return;

    final String textToSanitize = (dedicatedMarathiText != null &&
            dedicatedMarathiText.trim().isNotEmpty)
        ? dedicatedMarathiText
        : rawText;

    final String cleaned = sanitizeText(textToSanitize);
    if (cleaned.isEmpty) return;

    try {
      // Ensure speak completion never blocks any UI thread or button press
      await _tts.awaitSpeakCompletion(false);
      // Always stop active speech before starting a new utterance to prevent overlapping voices
      await _tts.stop();

      final bool hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(cleaned);
      if (hasDevanagari) {
        await _tts.setLanguage(_preferredMarathiLocale);
      } else {
        await _tts.setLanguage('en-IN');
      }

      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.32);

      _isPlaying = true;
      isPlayingNotifier.value = true;
      await _tts.speak(cleaned);
    } catch (e) {
      debugPrint("NovaAudioService speakCleanText error: $e");
      _isPlaying = false;
      isPlayingNotifier.value = false;
    }
  }

  /// Default speak method delegating to sanitized speakCleanText.
  Future<void> speak(String text) async {
    await speakCleanText(text);
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
