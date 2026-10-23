import 'dart:async';

import 'package:flutter/material.dart';

import 'level_models.dart';
import 'nova_assets.dart';
import 'question_panel.dart';
import 'scene_stage.dart';

/// Plays a validated level v2 JSON: scene by scene, running each scene's timeline,
/// showing its question, applying on_correct / on_wrong reactions, then moving on.
///
/// Integration hooks (all optional, nothing here talks to the network):
///  - [onNarrate]: speak the scene text (wire NovaAudioService / flutter_tts here)
///  - [onSfx]: play a sound effect id (ignore unknown ids; no sfx files exist yet)
///  - [onAnswer]: log each answered question (feeds local BKT + the sync queue)
///  - [onFinished]: level complete
///  - [voiceBuilder]: replace the tap fallback for `voice_input` with the real voice matcher
class LevelPlayer extends StatefulWidget {
  const LevelPlayer({
    super.key,
    required this.level,
    required this.assets,
    this.language = 'mr',
    this.onNarrate,
    this.onSfx,
    this.onAnswer,
    this.onFinished,
    this.voiceBuilder,
  });

  final LevelSpec level;
  final NovaAssets assets;
  final String language; // 'mr' or 'en'
  final void Function(String text)? onNarrate;
  final void Function(String sfxId)? onSfx;
  final void Function(String questionId, bool correct, int responseMs)? onAnswer;
  final VoidCallback? onFinished;
  final Widget Function(QuestionSpec q, String lang, void Function(bool correct) submit)? voiceBuilder;

  @override
  State<LevelPlayer> createState() => _LevelPlayerState();
}

class _LevelPlayerState extends State<LevelPlayer> {
  static const int _maxWrong = 2;

  int _i = 0;
  bool _finished = false;
  bool _showQuestion = false;
  bool _answered = false;
  bool _revealed = false;
  int _wrong = 0;
  int _token = 0;
  DateTime? _questionShownAt;
  final List<Timer> _timers = <Timer>[];
  Map<String, String> _expressions = <String, String>{};
  final Map<String, PlayRequest> _plays = <String, PlayRequest>{};

  SceneSpec get _scene => widget.level.scenes[_i];
  QuestionSpec? get _question => widget.level.questionFor(_scene);
  String get _lang => widget.language;

  @override
  void initState() {
    super.initState();
    if (widget.level.scenes.isEmpty) {
      _finished = true;
    } else {
      _enterScene();
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  void _later(int ms, VoidCallback fn) {
    _timers.add(Timer(Duration(milliseconds: ms), () {
      if (mounted) fn();
    }));
  }

  void _enterScene() {
    _cancelTimers();
    _plays.clear();
    _showQuestion = false;
    _answered = false;
    _revealed = false;
    _wrong = 0;
    _questionShownAt = null;
    _expressions = <String, String>{for (final a in _scene.actors) a.id: a.expression};

    var hasShow = false;
    for (final ev in _scene.timeline) {
      if (ev.action == 'show_question') hasShow = true;
      _later((ev.at * 1000).round(), () => _run(ev));
    }
    // Safety net: a question must always appear, even if the timeline forgot it.
    if (_question != null && !hasShow) {
      _later(1500, () => _run(const TimelineEvent(at: 0, action: 'show_question')));
    }
    // Scenes with no narrate event still speak their text once.
    if (!_scene.timeline.any((e) => e.action == 'narrate')) {
      _later(0, () => widget.onNarrate?.call(_scene.text.of(_lang)));
    }
  }

  void _run(TimelineEvent ev) {
    switch (ev.action) {
      case 'narrate':
        widget.onNarrate?.call(_scene.text.of(_lang));
        break;
      case 'show_question':
        if (_question != null) {
          setState(() {
            _showQuestion = true;
            _questionShownAt = DateTime.now();
          });
        }
        break;
      case 'set_expression':
        final id = ev.actor ?? (_scene.actors.isNotEmpty ? _scene.actors.first.id : null);
        if (id != null && ev.expression != null) setState(() => _expressions[id] = ev.expression!);
        break;
      case 'point_at':
      case 'play':
        _play(ev.actor, ev.play ?? (ev.action == 'point_at' ? 'point_at' : null));
        break;
      default:
        break; // unknown actions are ignored by design
    }
  }

  void _play(String? actorId, String? motion) {
    if (motion == null) return;
    final id = actorId ?? (_scene.actors.isNotEmpty ? _scene.actors.first.id : null);
    if (id == null) return;
    setState(() => _plays[id] = PlayRequest(motion, ++_token));
  }

  void _applyReaction(Reaction? r) {
    if (r == null) return;
    setState(() {
      if (r.expression != null) _expressions[r.actor] = r.expression!;
    });
    _play(r.actor, r.play);
    if (r.sfx != null) widget.onSfx?.call(r.sfx!);
  }

  void _submit(bool correct) {
    final q = _question;
    if (q == null || _answered) return;
    final ms = _questionShownAt == null ? 0 : DateTime.now().difference(_questionShownAt!).inMilliseconds;
    if (correct) {
      widget.onAnswer?.call(q.id, true, ms);
      setState(() => _answered = true);
      _applyReaction(_scene.onCorrect);
      _later(1600, _next);
    } else {
      widget.onAnswer?.call(q.id, false, ms);
      _wrong++;
      _applyReaction(_scene.onWrong);
      if (_wrong >= _maxWrong) {
        setState(() {
          _answered = true;
          _revealed = true;
        });
        _later(2600, _next);
      }
    }
  }

  void _next() {
    if (_i + 1 >= widget.level.scenes.length) {
      _cancelTimers();
      setState(() => _finished = true);
      widget.onFinished?.call();
    } else {
      setState(() {
        _i++;
        _enterScene();
      });
    }
  }

  void _restart() {
    setState(() {
      _i = 0;
      _finished = false;
      _enterScene();
    });
  }

  String _t(String mr, String en) => _lang == 'mr' ? mr : en;

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text(_t('छान!', 'Well done!'),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, fontFamilyFallback: kNovaFontFallback)),
          const SizedBox(height: 16),
          AnswerButton(label: _t('पुन्हा खेळा', 'Play again'), onTap: _restart),
        ]),
      );
    }

    final scene = _scene;
    final q = _question;
    return Column(
      children: <Widget>[
        Expanded(
          flex: 11,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SceneStage(
              key: ValueKey<int>(_i),
              scene: scene,
              assets: widget.assets,
              expressions: _expressions,
              plays: _plays,
            ),
          ),
        ),
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    localizeDigits(scene.text.of(_lang), _lang),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamilyFallback: kNovaFontFallback),
                  ),
                  const SizedBox(height: 12),
                  if (q == null)
                    AnswerButton(label: _t('पुढे', 'Next'), onTap: _next)
                  else if (_showQuestion && !_answered)
                    (q.type == 'voice_input' && widget.voiceBuilder != null)
                        ? widget.voiceBuilder!(q, _lang, _submit)
                        : QuestionPanel(question: q, lang: _lang, onResult: _submit)
                  else if (_revealed && q.answer != null)
                    Text(
                      '${_t('उत्तर', 'Answer')}: ${localizeDigits(q.answer.toString(), _lang)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamilyFallback: kNovaFontFallback),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
