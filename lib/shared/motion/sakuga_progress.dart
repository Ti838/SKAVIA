// SKAVIA Sakuga Progress Indicator (Smooth Spring Fill + Completion Burst)
// Inspired by Sakuga VFX Progress (MIT License, Copyright (c) 2026 Justin Finkelman).

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'sakuga_physics.dart';
import 'sakuga_vfx_overlay.dart';

/// Smooth animated progress bar driven strictly by genuine progress values (0.0..1.0).
/// Emits a single clean completion burst only when reaching 1.0 from an incomplete state.
class SakugaProgress extends StatefulWidget {
  final double value;
  final String? label;
  final double height;
  final Color? color;
  final bool celebrateOnComplete;

  const SakugaProgress({
    super.key,
    required this.value,
    this.label,
    this.height = 8,
    this.color,
    this.celebrateOnComplete = true,
  });

  @override
  State<SakugaProgress> createState() => _SakugaProgressState();
}

class _SakugaProgressState extends State<SakugaProgress> {
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    _celebrated = widget.value >= 1.0;
  }

  @override
  void didUpdateWidget(covariant SakugaProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value < 1.0) {
      _celebrated = false;
    } else if (!_celebrated && widget.value >= 1.0) {
      _celebrated = true;
      if (widget.celebrateOnComplete && !SakugaMotion.isReduced(context)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          SakugaFx.kira(context, radius: 11, color: AppColors.successGreen);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clamped = widget.value.clamp(0.0, 1.0);
    final reduced = SakugaMotion.isReduced(context);
    final isComplete = clamped >= 1.0;
    final fillColor = isComplete
        ? AppColors.successGreen
        : (widget.color ?? AppColors.primaryRoyal);
    final trackColor = fillColor.withValues(alpha: 0.14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isComplete) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.successGreen,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    '${(clamped * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: fillColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.height),
          child: Container(
            height: widget.height,
            width: double.infinity,
            color: trackColor,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: reduced
                    ? Duration.zero
                    : const Duration(milliseconds: 340),
                curve: Curves.easeOutCubic,
                widthFactor: clamped,
                child: Container(
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(widget.height),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
