// SKAVIA Sakuga Radio Button (Spring Pop Dot + Subtle Radial Ticks)
// Inspired by Sakuga VFX Radio (MIT License, Copyright (c) 2026 Justin Finkelman).

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import 'sakuga_physics.dart';
import 'sakuga_vfx_overlay.dart';

/// Expressive native radio control with spring-popping inner dot and subtle ticks.
class SakugaRadio<T> extends StatefulWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final Color? activeColor;
  final String? semanticLabel;

  const SakugaRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.activeColor,
    this.semanticLabel,
  });

  bool get isSelected => value == groupValue;

  @override
  State<SakugaRadio<T>> createState() => _SakugaRadioState<T>();
}

class _SakugaRadioState<T> extends State<SakugaRadio<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController.unbounded(
      vsync: this,
      value: widget.isSelected ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant SakugaRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (SakugaMotion.isReduced(context)) {
        _dotController.value = widget.isSelected ? 1.0 : 0.0;
      } else {
        _dotController.animateWith(
          SpringSimulation(
            SakugaMotion.popSpring,
            _dotController.value,
            widget.isSelected ? 1.0 : 0.0,
            widget.isSelected ? 3.5 : -1.5,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final cb = widget.onChanged;
    if (cb == null || widget.isSelected) return;
    HapticFeedback.selectionClick();
    if (!SakugaMotion.isReduced(context)) {
      SakugaFx.ticks(
        context,
        count: 4,
        radius: 12,
        length: 7,
        fan: 1.4,
        color: widget.activeColor ?? AppColors.primarySky,
      );
    }
    cb(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = widget.activeColor ?? AppColors.primaryRoyal;
    final enabled = widget.onChanged != null;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: widget.isSelected,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: enabled ? _handleTap : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedBuilder(
            animation: _dotController,
            builder: (context, _) {
              final t = _dotController.value.clamp(0.0, 1.25);
              return Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color.lerp(
                      colorScheme.outline,
                      active,
                      t.clamp(0.0, 1.0),
                    )!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Transform.scale(
                    scale: t,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: active,
                        shape: BoxShape.circle,
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
