import 'package:flutter/material.dart';

import 'level_models.dart';

const List<String> kNovaFontFallback = <String>['Noto Sans Devanagari', 'Mukta', 'Noto Sans', 'sans-serif'];

String localizeDigits(String s, String lang) {
  if (lang != 'mr') return s;
  const dev = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
  return s.replaceAllMapped(RegExp(r'[0-9]'), (m) => dev[int.parse(m[0]!)]);
}

List<int> _numberChoices(int answer) {
  final set = <int>{answer};
  var d = 1;
  while (set.length < 4 && d < 20) {
    set.add(answer + d);
    if (answer - d >= 0 && set.length < 4) set.add(answer - d);
    d++;
  }
  final list = set.toList()..sort();
  return list;
}

/// Renders a question and reports tapped results. Voice input has a tap fallback
/// (the handover requires one); plug the real voice matcher via LevelPlayer.voiceBuilder.
class QuestionPanel extends StatelessWidget {
  const QuestionPanel({super.key, required this.question, required this.lang, required this.onResult});

  final QuestionSpec question;
  final String lang;
  final void Function(bool correct) onResult;

  @override
  Widget build(BuildContext context) {
    final q = question;
    final prompt = Text(
      localizeDigits(q.prompt.of(lang), lang),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamilyFallback: kNovaFontFallback),
    );

    Widget body;
    switch (q.type) {
      case 'voice_input':
        final ans = (q.answer is num) ? (q.answer as num).round() : 0;
        body = _options(
          _numberChoices(ans).map((n) => n.toString()).toList(),
          (label) => onResult(label == ans.toString()),
        );
        break;
      case 'spot_item':
      case 'fill_blanks':
        body = _options(
          q.options.map((o) => o.toString()).toList(),
          (label) => onResult(label == q.answer.toString()),
        );
        break;
      case 'match_following':
        body = MatchPanel(pairs: q.pairs, lang: lang, onResult: onResult);
        break;
      default:
        body = const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[prompt, const SizedBox(height: 12), body],
    );
  }

  Widget _options(List<String> labels, void Function(String) onTap) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final l in labels) AnswerButton(label: localizeDigits(l, lang), onTap: () => onTap(l)),
      ],
    );
  }
}

class AnswerButton extends StatelessWidget {
  const AnswerButton({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72, minHeight: 56),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(label, style: const TextStyle(fontSize: 22, fontFamilyFallback: kNovaFontFallback)),
      ),
    );
  }
}

/// Tap a left item, then its partner on the right. A wrong tap reports false; finishing all pairs reports true.
class MatchPanel extends StatefulWidget {
  const MatchPanel({super.key, required this.pairs, required this.lang, required this.onResult});
  final List<Map<String, dynamic>> pairs;
  final String lang;
  final void Function(bool correct) onResult;

  @override
  State<MatchPanel> createState() => _MatchPanelState();
}

class _MatchPanelState extends State<MatchPanel> {
  late final List<String> _left = widget.pairs.map((p) => p['left'].toString()).toList();
  late final List<String> _right = (widget.pairs.map((p) => p['right'].toString()).toList()..sort());
  final Set<String> _done = <String>{};
  String? _selected;

  void _tapRight(String r) {
    if (_selected == null || _done.contains(r)) return;
    final pair = widget.pairs.firstWhere((p) => p['left'].toString() == _selected,
        orElse: () => <String, dynamic>{});
    if (pair['right']?.toString() == r) {
      setState(() {
        _done.add(r);
        _selected = null;
      });
      if (_done.length == widget.pairs.length) widget.onResult(true);
    } else {
      setState(() => _selected = null);
      widget.onResult(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, bool selected, bool done, VoidCallback? onTap) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: OutlinedButton(
            onPressed: done ? null : onTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(110, 48),
              backgroundColor: selected ? const Color(0x33FFC107) : null,
            ),
            child: Text(localizeDigits(label, widget.lang),
                style: const TextStyle(fontSize: 18, fontFamilyFallback: kNovaFontFallback)),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(children: <Widget>[
          for (final l in _left)
            chip(l, _selected == l, widget.pairs.any((p) => p['left'].toString() == l && _done.contains(p['right'].toString())),
                () => setState(() => _selected = l)),
        ]),
        Column(children: <Widget>[
          for (final r in _right) chip(r, false, _done.contains(r), () => _tapRight(r)),
        ]),
      ],
    );
  }
}
