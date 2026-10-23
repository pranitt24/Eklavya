import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'level_models.dart';
import 'motion_sprite.dart';
import 'nova_assets.dart';

class PlayRequest {
  const PlayRequest(this.motion, this.token);
  final String motion;
  final int token;
}

/// Draws one scene: full-bleed backdrop, props in named slots, actors in left/center/right slots.
/// Key this widget by scene id so entrance animations replay for each scene.
/// Holds no game logic: [expressions] and [plays] are driven by the parent (LevelPlayer).
class SceneStage extends StatelessWidget {
  const SceneStage({
    super.key,
    required this.scene,
    required this.assets,
    required this.expressions,
    required this.plays,
  });

  final SceneSpec scene;
  final NovaAssets assets;
  final Map<String, String> expressions; // actorId -> current expression
  final Map<String, PlayRequest> plays; // actorId -> one-shot motion

  static Alignment _actorAlign(String slot) {
    switch (slot) {
      case 'left':
        return const Alignment(-0.62, 1);
      case 'right':
        return const Alignment(0.62, 1);
      default:
        return const Alignment(0, 1);
    }
  }

  static Alignment _propAlign(String slot) {
    switch (slot) {
      case 'ground_left':
        return const Alignment(-0.55, 0.92);
      case 'ground_right':
        return const Alignment(0.55, 0.92);
      case 'sky':
        return const Alignment(0, -0.6);
      case 'hand':
        return const Alignment(0.2, 0.55);
      default:
        return const Alignment(0, 0.95);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth.isFinite ? c.maxWidth : 360.0;
      final h = c.maxHeight.isFinite ? c.maxHeight : 360.0;
      final backdrop = assets.backdropPath(scene.backdrop);
      const fallback = ColoredBox(color: Color(0xFFDCEBD2));

      final children = <Widget>[
        if (backdrop != null)
          Image.asset(backdrop, fit: BoxFit.cover, errorBuilder: (context, e, s) => fallback)
        else
          fallback,
      ];

      // Props first (behind actors).
      for (final p in scene.props) {
        final path = assets.propPath(p.id);
        if (path == null) continue;
        var size = math.min(h * 0.14, w * 0.12);
        if (p.count > 10) size *= 0.75;
        children.add(Positioned.fill(
          child: Align(
            alignment: _propAlign(p.slot),
            child: PropGroup(
              key: ValueKey<String>('prop_${p.id}_${p.slot}_${p.count}'),
              assetPath: path,
              count: p.count,
              itemSize: size,
              enter: p.enter,
            ),
          ),
        ));
      }

      // Actors (max 3 by contract; extra ones are still drawn safely).
      for (var i = 0; i < scene.actors.length; i++) {
        final a = scene.actors[i];
        final expr = expressions[a.id] ?? a.expression;
        final path = assets.actorPath(a.id, expr);
        if (path == null) continue; // unknown actor: skip, never crash
        final play = plays[a.id];
        children.add(Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(bottom: h * 0.05),
            child: Align(
              alignment: _actorAlign(a.slot),
              child: MotionSprite(
                key: ValueKey<String>('actor_${a.id}_${a.slot}'),
                assetPath: path,
                height: h * 0.5,
                enter: a.enter,
                loop: a.loop,
                playMotion: play?.motion,
                playToken: play?.token ?? 0,
                enterDelay: Duration(milliseconds: 250 * i),
              ),
            ),
          ),
        ));
      }

      return Stack(fit: StackFit.expand, children: children);
    });
  }
}

/// A group of identical props (count 1..20) laid out in rows, popping in one by one.
class PropGroup extends StatefulWidget {
  const PropGroup({
    super.key,
    required this.assetPath,
    required this.count,
    required this.itemSize,
    this.enter,
  });

  final String assetPath;
  final int count;
  final double itemSize;
  final String? enter;

  @override
  State<PropGroup> createState() => _PropGroupState();
}

class _PropGroupState extends State<PropGroup> with SingleTickerProviderStateMixin {
  late final int _totalMs = 500 + widget.count * 100;
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Duration(milliseconds: _totalMs));

  @override
  void initState() {
    super.initState();
    if (widget.enter == null) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _item(int i) {
    final start = (i * 100) / _totalMs;
    final end = math.min(1.0, start + 500 / _totalMs);
    final t = Interval(start, end).transform(_c.value);
    final scale = widget.enter == 'pop_in_staggered' ? math.max(0.0, Curves.elasticOut.transform(t)) : 1.0;
    return Opacity(
      opacity: math.min(1.0, t * 4),
      child: Transform.scale(
        scale: scale,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Image.asset(
            widget.assetPath,
            height: widget.itemSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, e, s) => SizedBox(height: widget.itemSize, width: widget.itemSize),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perRow = widget.count <= 5 ? widget.count : (widget.count <= 10 ? 5 : 7);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final rows = <Widget>[];
        for (var start = 0; start < widget.count; start += perRow) {
          final end = math.min(widget.count, start + perRow);
          rows.add(Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[for (var i = start; i < end; i++) _item(i)],
          ));
        }
        return Column(mainAxisSize: MainAxisSize.min, children: rows);
      },
    );
  }
}
