// SKAVIA Sakuga Slider (Spring-Lagged Thumb Stretch & Endpoint Ticks)
// Inspired by Sakuga VFX Slider (MIT License, Copyright (c) 2026 Justin Finkelman).

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import 'sakuga_physics.dart';
import 'sakuga_vfx_overlay.dart';

/// Responsive Material slider wrapped with Sakuga velocity-sensitive haptics
/// and subtle kinetic ticks at min/max endpoints or release.
class SakugaSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Color? activeColor;

  const SakugaSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    required this.onChanged,
    this.onChangeEnd,
    this.activeColor,
  });

  @override
  State<SakugaSlider> createState() => _SakugaSliderState();
}

class _SakugaSliderState extends State<SakugaSlider> {
  double _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;
  }

  void _handleChanged(double next) {
    final cb = widget.onChanged;
    if (cb == null) return;
    if (widget.divisions != null && next != _lastValue) {
      HapticFeedback.selectionClick();
    }
    _lastValue = next;
    cb(next);
  }

  void _handleChangeEnd(double finalVal) {
    if (!SakugaMotion.isReduced(context)) {
      final isEdge =
          (finalVal - widget.min).abs() < 0.001 ||
          (finalVal - widget.max).abs() < 0.001;
      if (isEdge) {
        HapticFeedback.lightImpact();
        SakugaFx.ticks(
          context,
          count: 3,
          radius: 12,
          length: 8,
          direction: finalVal >= widget.max ? 0 : math.pi,
          color: widget.activeColor ?? AppColors.primarySky,
        );
      }
    }
    widget.onChangeEnd?.call(finalVal);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.activeColor ?? AppColors.primaryRoyal;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: active,
        inactiveTrackColor: active.withValues(alpha: 0.18),
        thumbColor: active,
        overlayColor: active.withValues(alpha: 0.14),
        trackHeight: 5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        valueIndicatorColor: active,
      ),
      child: Slider(
        value: widget.value.clamp(widget.min, widget.max),
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        label: widget.label,
        onChanged: widget.onChanged == null ? null : _handleChanged,
        onChangeEnd: _handleChangeEnd,
      ),
    );
  }
}
