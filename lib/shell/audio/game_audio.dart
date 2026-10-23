import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// GameAudio provides centralized, ultra-responsive sound effects
/// for the Majhe Gaon educational game.
class GameAudio {
  GameAudio._();
  static final GameAudio instance = GameAudio._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;
    try {
      // AudioCache default prefix is 'assets/'
      AudioCache.instance.prefix = 'assets/';
    } catch (e) {
      debugPrint('GameAudio init warning: $e');
    }
  }

  /// Plays the squishy pop click sound for button taps
  static Future<void> playPop() async {
    try {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.play(AssetSource('audio/pop_click.mp3'));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      debugPrint('Error playing pop_click: $e');
    }
  }

  /// Plays the cinematic Netflix-style whoosh boom for splash logo
  static Future<void> playWhooshBoom() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/whoosh_boom.mp3'));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      debugPrint('Error playing whoosh_boom: $e');
    }
  }

  /// Plays the happy ding chime for correct answers
  static Future<void> playDingChime() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/ding_chime.mp3'));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      debugPrint('Error playing ding_chime: $e');
    }
  }

  /// Plays the gentle boing bloop for wrong answers
  static Future<void> playBoingBloop() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/boing_bloop.mp3'));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      debugPrint('Error playing boing_bloop: $e');
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _bgmPlayer.dispose();
  }
}
