import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:majhe_gaon/features/scene/level_models.dart';
import 'package:majhe_gaon/features/scene/nova_assets.dart';

// Run from the repo root so assets/nova/... resolves. (Package name `majhe_gaon` per the handover; adjust if pubspec differs.)
void main() {
  final manifest = File('assets/nova/manifest.json').readAsStringSync();
  final assets = NovaAssets.fromJsonString(manifest);

  test('expression maps to a pose file', () {
    expect(assets.actorPath('char_girl', 'happy'), 'assets/nova/characters/char_girl_jumping.webp');
    expect(assets.actorPath('char_boy', 'idle'), 'assets/nova/characters/char_boy_standing.webp');
  });

  test('unknown expression falls back to standing/first pose, unknown actor to null', () {
    expect(assets.actorPath('char_boy', 'grumpy'), isNotNull);
    expect(assets.actorPath('char_dragon', 'idle'), isNull);
  });

  test('unknown backdrop falls back to a real backdrop', () {
    expect(assets.backdropPath('bg_moon'), isNotNull);
  });

  test('every actor pose and backdrop in the manifest exists on disk', () {
    final m = jsonDecode(manifest) as Map<String, dynamic>;
    for (final a in (m['assets'] as List)) {
      expect(File('assets/nova/${a['file']}').existsSync(), isTrue, reason: a['file'] as String);
    }
  });

  test('demo levels parse and every scene references real assets', () {
    final idx = jsonDecode(File('assets/nova/demo/index.json').readAsStringSync()) as List;
    for (final f in idx) {
      final level = LevelSpec.fromJsonString(File('assets/nova/demo/$f').readAsStringSync());
      expect(level.scenes, isNotEmpty);
      for (final s in level.scenes) {
        expect(assets.backdropPath(s.backdrop), isNotNull);
        for (final a in s.actors) {
          expect(assets.actorPath(a.id, a.expression), isNotNull, reason: a.id);
        }
        for (final p in s.props) {
          expect(assets.propPath(p.id), isNotNull, reason: p.id);
        }
        if (s.questionRef != null) expect(level.questions.containsKey(s.questionRef), isTrue);
      }
    }
  });
}
