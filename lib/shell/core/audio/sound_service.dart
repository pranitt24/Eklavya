import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// SoundService is a lightweight, high-performance singleton audio controller
/// providing low-latency sound effects for Majhe Gaon.
class SoundService {
  SoundService._internal();
  static final SoundService instance = SoundService._internal();

  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;
    try {
      AudioCache.instance.prefix = 'assets/';
    } catch (e) {
      debugPrint('SoundService init note: $e');
    }
  }

  /// Plays Netflix-style cinematic intro sound
  Future<void> playIntroWhoosh() async {
    await _playAssetWithFallback(
      primaryAssetPath: 'audio/whoosh_boom.mp3',
      fallbackAssetPath: 'audio/A deep WhooshBoom for the Netflix-style logo intro.mp3',
    );
  }

  /// Plays squishy pop click sound on button taps
  Future<void> playPopClick() async {
    await _playAssetWithFallback(
      primaryAssetPath: 'audio/pop_click.mp3',
      fallbackAssetPath: 'audio/A squishy PopClick for general button taps.mp3',
      lowLatency: true,
    );
  }

  /// Plays happy ding chime on correct answer or celebration
  Future<void> playDingChime() async {
    await _playAssetWithFallback(
      primaryAssetPath: 'audio/ding_chime.mp3',
      fallbackAssetPath: 'audio/A happy DingChime for correct answers.mp3',
    );
  }

  /// Plays gentle boing bloop on wrong answer
  Future<void> playBoingBloop() async {
    await _playAssetWithFallback(
      primaryAssetPath: 'audio/boing_bloop.mp3',
      fallbackAssetPath: 'audio/A gentle BoingBloop for wrong answers.mp3',
    );
  }

  Future<void> _playAssetWithFallback({
    required String primaryAssetPath,
    required String fallbackAssetPath,
    bool lowLatency = false,
  }) async {
    try {
      final player = AudioPlayer();
      if (lowLatency) {
        await player.setPlayerMode(PlayerMode.lowLatency);
      }
      try {
        await player.play(AssetSource(primaryAssetPath));
      } catch (_) {
        await player.play(AssetSource(fallbackAssetPath));
      }
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      debugPrint('SoundService audio playback error ($primaryAssetPath): $e');
    }
  }
}
