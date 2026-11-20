// SKAVIA Sakuga Star Rating (Staggered Pop-In + Kira Glints + 5-Star Burst)
// Inspired by Sakuga VFX Rating (MIT License, Copyright (c) 2026 Justin Finkelman).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sakuga_physics.dart';
import 'sakuga_vfx_overlay.dart';

/// Expressive interactive star rating control with staggered spring pop-in,
/// 4-pointed sparkle glints on selection, and a short burst on 5 stars.
class SakugaRating extends StatefulWidget {
  final int rating;
  final int maxRating;
  final double starSize;
  final ValueChanged<int>? onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const SakugaRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.starSize = 36,
    this.onChanged,
    this.activeColor = const Color(0xFFF59E0B),
    this.inactiveColor = const Color(0xFFCBD5E1),
  });

  @override
  State<SakugaRating> createState() => _SakugaRatingState();
}

class _SakugaRatingState extends State<SakugaRating> {
  final List<GlobalKey> _starKeys = [];

  @override
  void initState() {
    super.initState();
    _syncKeys();
  }

  @override
  void didUpdateWidget(covariant SakugaRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxRating != widget.maxRating) {
      _syncKeys();
    }
  }

  void _syncKeys() {
    _starKeys
      ..clear()
      ..addAll(List.generate(widget.maxRating, (_) => GlobalKey()));
  }

  void _handleStarTap(int starIndex) {
    final cb = widget.onChanged;
    if (cb == null) return;
    final selected = starIndex + 1;
    HapticFeedback.lightImpact();

    if (!SakugaMotion.isReduced(context)) {
      final starCtx = _starKeys[starIndex].currentContext;
      final origin = starCtx != null ? SakugaFx.globalCenterOf(starCtx) : null;
      if (origin != null) {
        if (selected == widget.maxRating) {
          SakugaFx.celebrate(
            context,
            origin: origin,
            radius: 36,
            accentColor: widget.activeColor,
            duration: const Duration(milliseconds: 440),
          );
        } else {
          SakugaFx.kira(
            context,
            origin: origin,
            radius: 12,
            color: widget.activeColor,
          );
        }
      }
    }
    cb(selected);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = SakugaMotion.isReduced(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final filled = index < widget.rating;
        return Semantics(
          label: 'Rate ${index + 1} out of ${widget.maxRating} stars',
          selected: filled,
          button: widget.onChanged != null,
          child: GestureDetector(
            key: _starKeys[index],
            onTap: widget.onChanged == null
                ? null
                : () => _handleStarTap(index),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: AnimatedScale(
                scale: filled ? 1.08 : 0.96,
                duration: reduced
                    ? Duration.zero
                    : Duration(milliseconds: 180 + (index * 30)),
                curve: Curves.easeOutBack,
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: widget.starSize,
                  color: filled ? widget.activeColor : widget.inactiveColor,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
