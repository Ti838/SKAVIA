// SKAVIA Sakuga Pressable (Volume-Preserving Squash & Stretch Spring Wrapper)
// Inspired by Sakuga VFX `squashy()` (MIT License, Copyright (c) 2026 Justin Finkelman).

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import 'sakuga_physics.dart';
import 'sakuga_vfx_overlay.dart';

/// Wraps any interactive widget (buttons, cards, CTAs) with Sakuga volume-preserving
/// squash & stretch spring physics on press/release plus optional kinetic particles.
class SakugaPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final SakugaIntensity intensity;
  final bool enabled;
  final bool emitVfx;
  final bool enableHaptics;
  final Color? vfxColor;

  const SakugaPressable({
    super.key,
    required this.child,
    this.onTap,
    this.intensity = SakugaIntensity.medium,
    this.enabled = true,
    this.emitVfx = true,
    this.enableHaptics = true,
    this.vfxColor,
  });

  @override
  State<SakugaPressable> createState() => _SakugaPressableState();
}

class _SakugaPressableState extends State<SakugaPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springController;

  double get _pressScaleY => switch (widget.intensity) {
    SakugaIntensity.subtle => 0.96,
    SakugaIntensity.medium => 0.91,
    SakugaIntensity.strong => 0.86,
  };

  double get _wideFactor => switch (widget.intensity) {
    SakugaIntensity.subtle => 0.16,
    SakugaIntensity.medium => 0.24,
    SakugaIntensity.strong => 0.30,
  };

  @override
  void initState() {
    super.initState();
    _springController = AnimationController.unbounded(
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _animateTo(double target, {double velocity = 0.0}) {
    if (!mounted) return;
    if (SakugaMotion.isReduced(context)) {
      _springController.value = 1.0;
      return;
    }
    final sim = SpringSimulation(
      widget.intensity == SakugaIntensity.subtle
          ? SakugaMotion.subtleSpring
          : SakugaMotion.squashSpring,
      _springController.value,
      target,
      velocity,
    );
    _springController.animateWith(sim);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled) return;
    _animateTo(_pressScaleY);
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!widget.enabled) return;
    final impulse = switch (widget.intensity) {
      SakugaIntensity.subtle => 1.6,
      SakugaIntensity.medium => 2.8,
      SakugaIntensity.strong => 4.2,
    };
    _animateTo(1.0, velocity: impulse);

    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    if (widget.emitVfx && !SakugaMotion.isReduced(context)) {
      final pos = event.position;
      switch (widget.intensity) {
        case SakugaIntensity.subtle:
          SakugaFx.ticks(
            context,
            origin: pos,
            count: 3,
            radius: 10,
            length: 7,
            direction: -math.pi / 2,
            color: widget.vfxColor,
          );
          break;
        case SakugaIntensity.medium:
          SakugaFx.ticks(
            context,
            origin: pos,
            count: 4,
            radius: 14,
            length: 11,
            direction: -math.pi / 2,
            fan: 0.65,
            color: widget.vfxColor,
          );
          break;
        case SakugaIntensity.strong:
          SakugaFx.celebrate(
            context,
            origin: pos,
            radius: 44,
            accentColor: widget.vfxColor,
          );
          break;
      }
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _animateTo(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.onTap != null
        ? GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.enabled ? widget.onTap : null,
            child: widget.child,
          )
        : widget.child;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: AnimatedBuilder(
        animation: _springController,
        builder: (_, childWidget) {
          final y = _springController.value.clamp(0.75, 1.15);
          final isRest = (y - 1.0).abs() < 0.001;
          final x = isRest
              ? 1.0
              : (1.0 + (1.0 - y) * _wideFactor).clamp(0.88, 1.12);
          return Transform(
            alignment: Alignment.center,
            transformHitTests: false,
            transform: isRest
                ? Matrix4.identity()
                : Matrix4.diagonal3Values(x, y, 1.0),
            child: childWidget,
          );
        },
        child: child,
      ),
    );
  }
}
