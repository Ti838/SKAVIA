// SKAVIA Sakuga Toggle Switch
// Inspired by Sakuga VFX Toggle smear & settle physics (MIT License, Copyright (c) 2026 Justin Finkelman).

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import 'sakuga_physics.dart';
import 'sakuga_vfx_overlay.dart';

/// Tactile spring-animated switch with velocity-driven knob stretch smear
/// and a clean settle ring when toggled.
class SakugaToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final String? semanticLabel;

  const SakugaToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.semanticLabel,
  });

  @override
  State<SakugaToggle> createState() => _SakugaToggleState();
}

class _SakugaToggleState extends State<SakugaToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant SakugaToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animateTo(widget.value ? 1.0 : 0.0);
    }
  }

  void _animateTo(double target) {
    if (!mounted) return;
    if (SakugaMotion.isReduced(context)) {
      _controller.value = target;
      return;
    }
    final sim = SpringSimulation(
      SakugaMotion.settleSpring,
      _controller.value,
      target,
      target > _controller.value ? 2.4 : -2.4,
    );
    _controller.animateWith(sim);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final cb = widget.onChanged;
    if (cb == null) return;
    HapticFeedback.selectionClick();
    final nextVal = !widget.value;
    if (!SakugaMotion.isReduced(context)) {
      final center = SakugaFx.globalCenterOf(context);
      if (center != null) {
        final offset = Offset(center.dx + (nextVal ? 10 : -10), center.dy);
        SakugaFx.ring(
          context,
          origin: offset,
          radius: 18,
          strokeWidth: 2.2,
          color: nextVal
              ? (widget.activeColor ?? AppColors.primaryRoyal)
              : null,
        );
      }
    }
    cb(nextVal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeTrack = widget.activeColor ?? AppColors.primaryRoyal;
    final inactiveTrack = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFCBD5E1);
    final enabled = widget.onChanged != null;

    return Semantics(
      toggled: widget.value,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: enabled ? _handleTap : null,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value.clamp(0.0, 1.0);
              final v = _controller.velocity.abs();
              final stretchX = (1.0 + (v * 0.035)).clamp(1.0, 1.32);
              final squashY = (1.0 / stretchX).clamp(0.82, 1.0);
              final trackColor = Color.lerp(inactiveTrack, activeTrack, t)!;

              return Container(
                width: 52,
                height: 30,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Align(
                  alignment: Alignment(t * 2.0 - 1.0, 0),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(stretchX, squashY, 1.0),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
