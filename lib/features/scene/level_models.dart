import 'dart:convert';

// Tolerant parsing helpers: unknown or malformed data never throws, it degrades to defaults.
String _str(dynamic v, [String d = '']) => v is String ? v : d;
int _int(dynamic v, [int d = 0]) => v is num ? v.toInt() : d;
double _dbl(dynamic v, [double d = 0]) => v is num ? v.toDouble() : d;
List<dynamic> _list(dynamic v) => v is List ? v : const <dynamic>[];
Map<String, dynamic> _map(dynamic v) =>
    v is Map ? v.map((k, val) => MapEntry(k.toString(), val)) : <String, dynamic>{};
String? _optStr(dynamic v) => (v is String && v.isNotEmpty) ? v : null;

class LocalizedText {
  const LocalizedText({this.mr = '', this.en = ''});
  final String mr;
  final String en;

  factory LocalizedText.fromJson(dynamic j) {
    final m = _map(j);
    return LocalizedText(mr: _str(m['mr']), en: _str(m['en']));
  }

  /// Text for [lang] ('mr' or 'en'); falls back to the other language if empty.
  String of(String lang) {
    final v = lang == 'mr' ? mr : en;
    if (v.isNotEmpty) return v;
    return mr.isNotEmpty ? mr : en;
  }
}

class ActorSpec {
  const ActorSpec({required this.id, required this.slot, this.expression = 'idle', this.enter, this.loop});
  final String id;
  final String slot;
  final String expression;
  final String? enter;
  final String? loop;

  factory ActorSpec.fromJson(dynamic j) {
    final m = _map(j);
    return ActorSpec(
      id: _str(m['id']),
      slot: _str(m['slot'], 'center'),
      expression: _str(m['expression'], 'idle'),
      enter: _optStr(m['enter']),
      loop: _optStr(m['loop']),
    );
  }
}

class PropSpec {
  const PropSpec({required this.id, required this.slot, this.count = 1, this.enter});
  final String id;
  final String slot;
  final int count;
  final String? enter;

  factory PropSpec.fromJson(dynamic j) {
    final m = _map(j);
    var c = _int(m['count'], 1);
    if (c < 1) c = 1;
    if (c > 20) c = 20;
    return PropSpec(id: _str(m['id']), slot: _str(m['slot'], 'ground_center'), count: c, enter: _optStr(m['enter']));
  }
}

class TimelineEvent {
  const TimelineEvent({required this.at, required this.action, this.actor, this.play, this.expression});
  final double at;
  final String action; // JSON key is "do" (a reserved word in Dart)
  final String? actor;
  final String? play;
  final String? expression;

  factory TimelineEvent.fromJson(dynamic j) {
    final m = _map(j);
    return TimelineEvent(
      at: _dbl(m['at']),
      action: _str(m['do']),
      actor: _optStr(m['actor']),
      play: _optStr(m['play']),
      expression: _optStr(m['expression']),
    );
  }
}

class Reaction {
  const Reaction({required this.actor, this.expression, this.play, this.sfx});
  final String actor;
  final String? expression;
  final String? play;
  final String? sfx;

  static Reaction? fromJson(dynamic j) {
    if (j is! Map) return null;
    final m = _map(j);
    return Reaction(
      actor: _str(m['actor']),
      expression: _optStr(m['expression']),
      play: _optStr(m['play']),
      sfx: _optStr(m['sfx']),
    );
  }
}

class QuestionSpec {
  const QuestionSpec({
    required this.id,
    required this.type,
    required this.prompt,
    this.answer,
    this.options = const <dynamic>[],
    this.pairs = const <Map<String, dynamic>>[],
    this.countsProp,
  });
  final String id;
  final String type; // voice_input | match_following | spot_item | fill_blanks
  final LocalizedText prompt;
  final dynamic answer;
  final List<dynamic> options;
  final List<Map<String, dynamic>> pairs;
  final String? countsProp;

  factory QuestionSpec.fromJson(dynamic j) {
    final m = _map(j);
    return QuestionSpec(
      id: _str(m['id']),
      type: _str(m['type']),
      prompt: LocalizedText.fromJson(m['prompt']),
      answer: m['answer'],
      options: List<dynamic>.from(_list(m['options'])),
      pairs: _list(m['pairs']).map((p) => _map(p)).toList(),
      countsProp: _optStr(m['counts_prop']),
    );
  }
}

class SceneSpec {
  const SceneSpec({
    required this.sceneId,
    required this.text,
    required this.backdrop,
    this.actors = const <ActorSpec>[],
    this.props = const <PropSpec>[],
    this.timeline = const <TimelineEvent>[],
    this.questionRef,
    this.onCorrect,
    this.onWrong,
  });
  final int sceneId;
  final LocalizedText text;
  final String backdrop;
  final List<ActorSpec> actors;
  final List<PropSpec> props;
  final List<TimelineEvent> timeline;
  final String? questionRef;
  final Reaction? onCorrect;
  final Reaction? onWrong;

  factory SceneSpec.fromJson(dynamic j) {
    final m = _map(j);
    final tl = _list(m['timeline']).map((e) => TimelineEvent.fromJson(e)).toList()
      ..sort((a, b) => a.at.compareTo(b.at));
    return SceneSpec(
      sceneId: _int(m['scene_id']),
      text: LocalizedText.fromJson(m['text']),
      backdrop: _str(m['backdrop']),
      actors: _list(m['actors']).map((e) => ActorSpec.fromJson(e)).toList(),
      props: _list(m['props']).map((e) => PropSpec.fromJson(e)).toList(),
      timeline: tl,
      questionRef: _optStr(m['question_ref']),
      onCorrect: Reaction.fromJson(m['on_correct']),
      onWrong: Reaction.fromJson(m['on_wrong']),
    );
  }
}

class LevelSpec {
  const LevelSpec({
    required this.levelId,
    required this.skillId,
    required this.grade,
    required this.tier,
    required this.title,
    required this.scenes,
    required this.questions,
  });
  final String levelId;
  final String skillId;
  final int grade;
  final int tier;
  final LocalizedText title;
  final List<SceneSpec> scenes;
  final Map<String, QuestionSpec> questions;

  QuestionSpec? questionFor(SceneSpec s) => s.questionRef == null ? null : questions[s.questionRef];

  factory LevelSpec.fromJson(Map<String, dynamic> m) {
    final qs = <String, QuestionSpec>{};
    for (final q in _list(m['questions'])) {
      final spec = QuestionSpec.fromJson(q);
      if (spec.id.isNotEmpty) qs[spec.id] = spec;
    }
    return LevelSpec(
      levelId: _str(m['level_id']),
      skillId: _str(m['skill_id']),
      grade: _int(m['grade'], 1),
      tier: _int(m['difficulty_tier'], 1),
      title: LocalizedText.fromJson(m['title']),
      scenes: _list(m['scenes']).map((e) => SceneSpec.fromJson(e)).toList(),
      questions: qs,
    );
  }

  factory LevelSpec.fromJsonString(String s) => LevelSpec.fromJson(_map(jsonDecode(s)));
}
