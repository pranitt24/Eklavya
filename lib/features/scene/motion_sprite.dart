import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One image with contract motions applied as transforms (no rigging, no extra art).
/// - [enter]: walk_in_left, walk_in_right, slide_in, fade_in, pop_in_staggered
/// - [loop]: idle_bounce
/// - one-shot [playMotion] (jump, head_tilt, shake, wave, point_at) runs whenever [playToken] changes
/// Changing [assetPath] cross-fades to the new pose. Unknown motion names are ignored.
class MotionSprite extends StatefulWidget {
  const MotionSprite({
    super.key,
    required this.assetPath,
    required this.height,
    this.enter,
    this.loop,
    this.playMotion,
    this.playToken = 0,
    this.enterDelay = Duration.zero,
  });

  final String assetPath;
  final double height;
  final String? enter;
  final String? loop;
  final String? playMotion;
  final int playToken;
  final Duration enterDelay;

  @override
  State<MotionSprite> createState() => _MotionSpriteState();
}

class _MotionSpriteState extends State<MotionSprite> with TickerProviderStateMixin {
  late final AnimationController _enter =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final AnimationController _play =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  Timer? _delay;
  String? _activeMotion;

  @override
  void initState() {
    super.initState();
    if (widget.enter == null) {
      _enter.value = 1;
    } else if (widget.enterDelay == Duration.zero) {
      _enter.forward();
    } else {
      _delay = Timer(widget.enterDelay, () {
        if (mounted) _enter.forward();
      });
    }
    if (widget.loop == 'idle_bounce') _loop.repeat();
  }

  @override
  void didUpdateWidget(covariant MotionSprite old) {
    super.didUpdateWidget(old);
    if (widget.playToken != old.playToken && widget.playMotion != null) {
      _activeMotion = widget.playMotion;
      _play.forward(from: 0);
    }
    if (widget.loop != old.loop) {
      if (widget.loop == 'idle_bounce') {
        _loop.repeat();
      } else {
        _loop.stop();
      }
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _enter.dispose();
    _play.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sprite = SizedBox(
      height: widget.height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[...previous, ?current],
        ),
        child: Image.asset(
          widget.assetPath,
          key: ValueKey<String>(widget.assetPath),
          height: widget.height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stack) => SizedBox(height: widget.height),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_enter, _play, _loop]),
      child: sprite,
      builder: (context, child) {
        final ev = _enter.value;
        final e = Curves.easeOutCubic.transform(ev);
        var fx = 0.0, fy = 0.0, rot = 0.0, scale = 1.0, opacity = 1.0;

        switch (widget.enter) {
          case 'walk_in_left':
            fx = -(1 - e) * 3.0;
            fy -= math.sin(ev * math.pi * 6).abs() * 0.03 * (1 - ev);
            break;
          case 'walk_in_right':
            fx = (1 - e) * 3.0;
            fy -= math.sin(ev * math.pi * 6).abs() * 0.03 * (1 - ev);
            break;
          case 'slide_in':
            fy = (1 - e) * 1.6;
            opacity = e;
            break;
          case 'fade_in':
            opacity = e;
            break;
          case 'pop_in_staggered':
            scale = math.max(0.0, Curves.elasticOut.transform(ev));
            opacity = math.min(1.0, ev * 10);
            break;
          default:
            break;
        }

        final p = _play.value;
        switch (_activeMotion) {
          case 'jump':
            fy -= math.sin(math.pi * p) * 0.35;
            break;
          case 'head_tilt':
            rot += math.sin(2 * math.pi * p) * 0.15;
            break;
          case 'shake':
            fx += math.sin(p * math.pi * 6) * 0.06 * (1 - p);
            break;
          case 'wave':
            rot += math.sin(p * math.pi * 4) * 0.12;
            break;
          case 'point_at':
            scale *= 1 + 0.12 * math.sin(math.pi * p);
            break;
          default:
            break;
        }

        if (widget.loop == 'idle_bounce') {
          fy -= (math.sin(_loop.value * 2 * math.pi) * 0.5 + 0.5) * 0.03;
        }

        Widget w = FractionalTranslation(translation: Offset(fx, fy), child: child);
        w = Transform.rotate(angle: rot, alignment: Alignment.bottomCenter, child: w);
        w = Transform.scale(scale: scale, alignment: Alignment.bottomCenter, child: w);
        return Opacity(opacity: opacity.clamp(0.0, 1.0).toDouble(), child: w);
      },
    );
  }
}
