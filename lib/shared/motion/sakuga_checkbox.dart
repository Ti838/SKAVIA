// SKAVIA Sakuga Checkbox (Spring Squash + Self-Drawing Checkmark + Subtle Ticks)
// Inspired by Sakuga VFX Checkbox (MIT License, Copyright (c) 2026 Justin Finkelman).

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import 'sakuga_physics.dart';
import 'sakuga_vfx_overlay.dart';

/// Expressive native Flutter checkbox with spring squash on toggle,
/// self-drawing vector checkmark stroke, and subtle kinetic accent ticks.
class SakugaCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final String? semanticLabel;

  const SakugaCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.semanticLabel,
  });

  @override
  State<SakugaCheckbox> createState() => _SakugaCheckboxState();
}

class _SakugaCheckboxState extends State<SakugaCheckbox>
    with TickerProviderStateMixin {
  late final AnimationController _checkController;
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.value ? 1.0 : 0.0,
    );
    _scaleController = AnimationController.unbounded(
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(covariant SakugaCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (SakugaMotion.isReduced(context)) {
        _checkController.value = widget.value ? 1.0 : 0.0;
        _scaleController.value = 1.0;
      } else {
        if (widget.value) {
          _checkController.forward();
          _scaleController.animateWith(
            SpringSimulation(SakugaMotion.popSpring, 0.82, 1.0, 3.2),
          );
        } else {
          _checkController.reverse();
          _scaleController.animateWith(
            SpringSimulation(SakugaMotion.subtleSpring, 0.92, 1.0, 1.2),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final cb = widget.onChanged;
    if (cb == null) return;
    HapticFeedback.selectionClick();
    final next = !widget.value;
    if (next && !SakugaMotion.isReduced(context)) {
      SakugaFx.ticks(
        context,
        count: 3,
        radius: 12,
        length: 8,
        direction: -math.pi / 4,
        color: widget.activeColor ?? AppColors.primarySky,
      );
    }
    cb(next);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = widget.activeColor ?? AppColors.primaryRoyal;
    final enabled = widget.onChanged != null;

    return Semantics(
      checked: widget.value,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: enabled ? _handleTap : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedBuilder(
            animation: Listenable.merge([_checkController, _scaleController]),
            builder: (context, _) {
              final t = _checkController.value;
              final sc = _scaleController.value.clamp(0.75, 1.18);
              return Transform.scale(
                scale: sc,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Color.lerp(Colors.transparent, active, t),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Color.lerp(colorScheme.outline, active, t)!,
                      width: 2,
                    ),
                  ),
                  child: t > 0.02
                      ? CustomPaint(
                          painter: _CheckmarkPainter(progress: t),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;

  const _CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final p1 = Offset(size.width * 0.22, size.height * 0.52);
    final p2 = Offset(size.width * 0.43, size.height * 0.72);
    final p3 = Offset(size.width * 0.78, size.height * 0.30);

    final path = Path()..moveTo(p1.dx, p1.dy);
    if (progress <= 0.45) {
      final seg = progress / 0.45;
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * seg,
        p1.dy + (p2.dy - p1.dy) * seg,
      );
    } else {
      path.lineTo(p2.dx, p2.dy);
      final seg = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * seg,
        p2.dy + (p3.dy - p2.dy) * seg,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
