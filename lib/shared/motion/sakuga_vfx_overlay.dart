// SKAVIA Sakuga VFX Native Overlay Engine
// Particle drawing primitives adapted from Sakuga VFX (core.js)
// (https://github.com/finktheartist/sakuga-vfx) under the MIT License:
// Copyright (c) 2026 Justin Finkelman.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'sakuga_physics.dart';

/// Native Flutter single-burst VFX emitter painted on a non-blocking Overlay.
/// Every effect automatically disposes its AnimationController & OverlayEntry
/// on completion, and exits immediately if reduced motion is enabled.
abstract class SakugaFx {
  static final math.Random _rng = math.Random();

  /// Computes global center of a widget's BuildContext safely.
  static Offset? globalCenterOf(BuildContext context) {
    final renderObj = context.findRenderObject();
    if (renderObj is! RenderBox || !renderObj.hasSize || !renderObj.attached) {
      return null;
    }
    return renderObj.localToGlobal(renderObj.size.center(Offset.zero));
  }

  /// SUBTLE/MEDIUM: Kinetic accent wedges fanning outward from an interaction point.
  static void ticks(
    BuildContext context, {
    Offset? origin,
    int count = 3,
    double radius = 14,
    double length = 11,
    double direction = -math.pi / 2,
    double fan = 0.48,
    Color? color,
    Duration duration = const Duration(milliseconds: 320),
  }) {
    if (SakugaMotion.isReduced(context)) return;
    final pos = origin ?? globalCenterOf(context);
    if (pos == null) return;
    final palette = SakugaPalette.of(context);
    final accent = color ?? palette.accent;

    _spawn(
      context,
      duration: duration,
      painterBuilder: (progress) => _TicksPainter(
        origin: pos,
        progress: progress,
        count: count,
        radius: radius,
        length: length,
        direction: direction,
        fan: fan,
        color: accent,
      ),
    );
  }

  /// SUBTLE/MEDIUM: Clean expanding shockwave ring (toggles, tabs, confirms).
  static void ring(
    BuildContext context, {
    Offset? origin,
    double radius = 26,
    double strokeWidth = 3.0,
    Color? color,
    Duration duration = const Duration(milliseconds: 340),
  }) {
    if (SakugaMotion.isReduced(context)) return;
    final pos = origin ?? globalCenterOf(context);
    if (pos == null) return;
    final palette = SakugaPalette.of(context);

    _spawn(
      context,
      duration: duration,
      painterBuilder: (progress) => _RingPainter(
        origin: pos,
        progress: progress,
        radius: radius,
        strokeWidth: strokeWidth,
        lineColor: color ?? palette.line,
        fillColor: palette.fill,
      ),
    );
  }

  /// MEDIUM: 4-pointed sparkle glint (ratings, verified badges, save actions).
  static void kira(
    BuildContext context, {
    Offset? origin,
    double radius = 10,
    Color? color,
    Duration duration = const Duration(milliseconds: 420),
  }) {
    if (SakugaMotion.isReduced(context)) return;
    final pos = origin ?? globalCenterOf(context);
    if (pos == null) return;
    final palette = SakugaPalette.of(context);

    _spawn(
      context,
      duration: duration,
      painterBuilder: (progress) => _KiraPainter(
        origin: pos,
        progress: progress,
        radius: radius,
        fillColor: palette.fill,
        strokeColor: color ?? palette.accent,
      ),
    );
  }

  /// STRONG BUT SHORT: Crisp two-tone radial burst + crystalline shards + glints.
  /// Reserved strictly for genuine completed actions (verified payment, booking confirmed, 5-star review).
  static void celebrate(
    BuildContext context, {
    Offset? origin,
    double radius = 52,
    Color? accentColor,
    Duration duration = const Duration(milliseconds: 520),
  }) {
    if (SakugaMotion.isReduced(context)) return;
    final pos = origin ?? globalCenterOf(context);
    if (pos == null) return;
    final palette = SakugaPalette.of(context);
    final accent = accentColor ?? palette.success;

    final spikes = List<double>.generate(
      24,
      (i) => i.isOdd
          ? 0.38 + _rng.nextDouble() * 0.14
          : 0.8 + _rng.nextDouble() * 0.28,
    );
    final rot = _rng.nextDouble() * math.pi * 2;
    final shards = List<_ShardParticle>.generate(8, (i) {
      final angle = (i / 8) * math.pi * 2 + (_rng.nextDouble() - 0.5) * 0.45;
      return _ShardParticle(
        angle: angle,
        speed: 95 + _rng.nextDouble() * 85,
        size: 3.5 + _rng.nextDouble() * 3.0,
        spin: (_rng.nextDouble() - 0.5) * 9,
      );
    });

    _spawn(
      context,
      duration: duration,
      painterBuilder: (progress) => _CelebratePainter(
        origin: pos,
        progress: progress,
        radius: radius,
        spikes: spikes,
        rotation: rot,
        shards: shards,
        palette: palette,
        accentColor: accent,
      ),
    );
  }

  static void _spawn(
    BuildContext context, {
    required Duration duration,
    required CustomPainter Function(double progress) painterBuilder,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SakugaOneShotLayer(
        duration: duration,
        painterBuilder: painterBuilder,
        onComplete: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _SakugaOneShotLayer extends StatefulWidget {
  final Duration duration;
  final CustomPainter Function(double progress) painterBuilder;
  final VoidCallback onComplete;

  const _SakugaOneShotLayer({
    required this.duration,
    required this.painterBuilder,
    required this.onComplete,
  });

  @override
  State<_SakugaOneShotLayer> createState() => _SakugaOneShotLayerState();
}

class _SakugaOneShotLayerState extends State<_SakugaOneShotLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, _) =>
                CustomPaint(painter: widget.painterBuilder(_controller.value)),
          ),
        ),
      ),
    );
  }
}

class _TicksPainter extends CustomPainter {
  final Offset origin;
  final double progress;
  final int count;
  final double radius;
  final double length;
  final double direction;
  final double fan;
  final Color color;

  _TicksPainter({
    required this.origin,
    required this.progress,
    required this.count,
    required this.radius,
    required this.length,
    required this.direction,
    required this.fan,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final a = SakugaMotion.easeOutCubic((progress / 0.5).clamp(0.0, 1.0));
    final b = SakugaMotion.easeInCubic(
      ((progress - 0.4) / 0.6).clamp(0.0, 1.0),
    );
    final opacity = (1.0 - b * 0.85).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final an = direction + (i - (count - 1) / 2.0) * fan;
      final r0 = radius + length * b * 1.25;
      final r1 = radius + length * a * 1.25;
      if (r1 - r0 < 0.8) continue;
      final hw = 0.065 + 1.8 / (r1 + 8.0);

      final path = Path()
        ..moveTo(origin.dx + math.cos(an) * r0, origin.dy + math.sin(an) * r0)
        ..lineTo(
          origin.dx + math.cos(an - hw) * r1,
          origin.dy + math.sin(an - hw) * r1,
        )
        ..lineTo(
          origin.dx + math.cos(an + hw) * r1,
          origin.dy + math.sin(an + hw) * r1,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TicksPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _RingPainter extends CustomPainter {
  final Offset origin;
  final double progress;
  final double radius;
  final double strokeWidth;
  final Color lineColor;
  final Color fillColor;

  _RingPainter({
    required this.origin,
    required this.progress,
    required this.radius,
    required this.strokeWidth,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = SakugaMotion.easeOutCubic(progress);
    final lw = strokeWidth * (1.0 - progress);
    if (lw <= 0.25) return;

    final r = radius * (0.35 + s * 0.85);
    final outer = Paint()
      ..color = lineColor.withValues(alpha: (1.0 - progress) * 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lw + 1.4;
    canvas.drawCircle(origin, r, outer);

    final inner = Paint()
      ..color = fillColor.withValues(alpha: (1.0 - progress) * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lw * 0.6;
    canvas.drawCircle(origin, r, inner);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _KiraPainter extends CustomPainter {
  final Offset origin;
  final double progress;
  final double radius;
  final Color fillColor;
  final Color strokeColor;

  _KiraPainter({
    required this.origin,
    required this.progress,
    required this.radius,
    required this.fillColor,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = radius * math.pow(math.sin(progress * math.pi), 0.6).toDouble();
    if (s < 0.8) return;
    final q = s * 0.18;

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(math.sin(progress * math.pi * 2) * 0.18);

    final path = Path()
      ..moveTo(0, -s)
      ..quadraticBezierTo(q, -q, s * 0.75, 0)
      ..quadraticBezierTo(q, q, 0, s)
      ..quadraticBezierTo(-q, q, -s * 0.75, 0)
      ..quadraticBezierTo(-q, -q, 0, -s)
      ..close();

    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KiraPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ShardParticle {
  final double angle;
  final double speed;
  final double size;
  final double spin;

  const _ShardParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
  });
}

class _CelebratePainter extends CustomPainter {
  final Offset origin;
  final double progress;
  final double radius;
  final List<double> spikes;
  final double rotation;
  final List<_ShardParticle> shards;
  final SakugaPalette palette;
  final Color accentColor;

  _CelebratePainter({
    required this.origin,
    required this.progress,
    required this.radius,
    required this.spikes,
    required this.rotation,
    required this.shards,
    required this.palette,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Short radial burst (0.0 -> 0.68)
    if (progress < 0.72) {
      final bk = (progress / 0.72).clamp(0.0, 1.0);
      final r = radius * SakugaMotion.easeOutCubic((bk / 0.34).clamp(0.0, 1.0));
      final fade =
          1.0 - SakugaMotion.easeInCubic(((bk - 0.38) / 0.62).clamp(0.0, 1.0));
      final hollow =
          1.0 +
          SakugaMotion.easeInCubic(((bk - 0.35) / 0.65).clamp(0.0, 1.0)) * 0.85;

      final starPath = Path();
      for (var i = 0; i < spikes.length; i++) {
        final a = rotation + (i / spikes.length) * math.pi * 2;
        final rr = r * (i.isOdd ? spikes[i] * hollow : spikes[i]);
        final pt = Offset(
          origin.dx + math.cos(a) * rr,
          origin.dy + math.sin(a) * rr,
        );
        if (i == 0) {
          starPath.moveTo(pt.dx, pt.dy);
        } else {
          starPath.lineTo(pt.dx, pt.dy);
        }
      }
      starPath.close();

      canvas.drawPath(
        starPath,
        Paint()..color = palette.shade.withValues(alpha: fade * 0.45),
      );
      canvas.drawPath(
        starPath,
        Paint()
          ..color = accentColor.withValues(alpha: fade * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // 2. Expanding clean ring
    final ringFade = (1.0 - progress).clamp(0.0, 1.0);
    if (ringFade > 0.05) {
      final ringR = radius * (0.4 + SakugaMotion.easeOutCubic(progress) * 1.15);
      canvas.drawCircle(
        origin,
        ringR,
        Paint()
          ..color = accentColor.withValues(alpha: ringFade * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6 * ringFade,
      );
    }

    // 3. Crystalline shards with light gravity
    final t = progress * 0.52;
    for (final shard in shards) {
      final shrink =
          1.0 -
          SakugaMotion.easeInCubic(((progress - 0.55) / 0.45).clamp(0.0, 1.0));
      final sc = shard.size * shrink;
      if (sc < 0.7) continue;

      final px = origin.dx + math.cos(shard.angle) * shard.speed * t;
      final py =
          origin.dy + math.sin(shard.angle) * shard.speed * t + 210 * t * t;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(shard.spin * t + shard.angle);
      final p = Path()
        ..moveTo(-sc * 1.3, 0)
        ..lineTo(0, -sc * 0.65)
        ..lineTo(sc * 1.3, 0)
        ..lineTo(0, sc * 0.65)
        ..close();
      canvas.drawPath(p, Paint()..color = palette.fill);
      canvas.drawPath(
        p,
        Paint()
          ..color = accentColor.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebratePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
