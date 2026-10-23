// Standalone demo entry so the scene renderer can be shown without touching the app shell:
//   flutter run -t lib/scene_demo_main.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/scene/level_models.dart';
import 'features/scene/level_player.dart';
import 'features/scene/nova_assets.dart';
import 'features/scene/question_panel.dart';

void main() => runApp(const SceneDemoApp());

class SceneDemoApp extends StatelessWidget {
  const SceneDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOVA scene demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF2E7D5B), useMaterial3: true),
      home: const _DemoHome(),
    );
  }
}

class _DemoHome extends StatefulWidget {
  const _DemoHome();
  @override
  State<_DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<_DemoHome> {
  NovaAssets? _assets;
  final List<LevelSpec> _levels = <LevelSpec>[];
  LevelSpec? _active;
  String _lang = 'mr';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final assets = await NovaAssets.load();
      final idx = jsonDecode(await rootBundle.loadString('assets/nova/demo/index.json')) as List;
      final levels = <LevelSpec>[];
      for (final f in idx) {
        levels.add(LevelSpec.fromJsonString(await rootBundle.loadString('assets/nova/demo/$f')));
      }
      setState(() {
        _assets = assets;
        _levels
          ..clear()
          ..addAll(levels);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return Scaffold(body: Center(child: Text('Load error: $_error')));
    if (_assets == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_active != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_active!.title.of(_lang), style: const TextStyle(fontFamilyFallback: kNovaFontFallback)),
          leading: BackButton(onPressed: () => setState(() => _active = null)),
        ),
        body: SafeArea(
          child: LevelPlayer(
            key: ValueKey<String>('${_active!.levelId}_$_lang'),
            level: _active!,
            assets: _assets!,
            language: _lang,
            onNarrate: (t) => debugPrint('NARRATE: $t'),
            onSfx: (s) => debugPrint('SFX: $s'),
            onAnswer: (q, ok, ms) => debugPrint('ANSWER $q correct=$ok ${ms}ms'),
            onFinished: () => debugPrint('LEVEL DONE'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('NOVA scene demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(children: <Widget>[
            ChoiceChip(label: const Text('मराठी'), selected: _lang == 'mr', onSelected: (_) => setState(() => _lang = 'mr')),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('English'), selected: _lang == 'en', onSelected: (_) => setState(() => _lang = 'en')),
          ]),
          const SizedBox(height: 16),
          for (final l in _levels)
            Card(
              child: ListTile(
                title: Text(l.title.of(_lang), style: const TextStyle(fontSize: 20, fontFamilyFallback: kNovaFontFallback)),
                subtitle: Text('${l.skillId}  |  tier ${l.tier}'),
                onTap: () => setState(() => _active = l),
              ),
            ),
        ],
      ),
    );
  }
}
