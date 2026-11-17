// SKAVIA Sakuga Toast Notification (Spring Slide-In + Landing Ticks + Shrink Exit)
// Inspired by Sakuga VFX Toast (MIT License, Copyright (c) 2026 Justin Finkelman).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import 'sakuga_physics.dart';
import 'sakuga_vfx_overlay.dart';

enum SakugaToastTone { success, error, info, warning }

/// Expressive non-blocking floating toast with spring slide-in landing,
/// subtle kinetic ticks on arrival, and smooth shrink exit.
class SakugaToast {
  static OverlayEntry? _activeEntry;

  static void show(
    BuildContext context, {
    required String message,
    SakugaToastTone tone = SakugaToastTone.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    dismiss();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _SakugaToastBanner(
        message: message,
        tone: tone,
        duration: duration,
        onDismissed: () {
          if (_activeEntry == entry) {
            _activeEntry = null;
          }
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );
    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    final current = _activeEntry;
    _activeEntry = null;
    if (current != null && current.mounted) {
      current.remove();
    }
  }
}

class _SakugaToastBanner extends StatefulWidget {
  final String message;
  final SakugaToastTone tone;
  final Duration duration;
  final VoidCallback onDismissed;

  const _SakugaToastBanner({
    required this.message,
    required this.tone,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_SakugaToastBanner> createState() => _SakugaToastBannerState();
}

class _SakugaToastBannerState extends State<_SakugaToastBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _autoHideTimer;
  bool _exiting = false;

  Color get _bgColor => switch (widget.tone) {
    SakugaToastTone.success => AppColors.successGreen,
    SakugaToastTone.error => AppColors.errorRed,
    SakugaToastTone.warning => AppColors.warningAmber,
    SakugaToastTone.info => AppColors.primaryRoyal,
  };

  IconData get _icon => switch (widget.tone) {
    SakugaToastTone.success => Icons.check_circle_rounded,
    SakugaToastTone.error => Icons.error_outline_rounded,
    SakugaToastTone.warning => Icons.warning_amber_rounded,
    SakugaToastTone.info => Icons.info_outline_rounded,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _controller.forward();

    if (widget.tone == SakugaToastTone.success) {
      HapticFeedback.lightImpact();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || SakugaMotion.isReduced(context)) return;
      if (widget.tone == SakugaToastTone.success) {
        final box = context.findRenderObject();
        if (box is RenderBox && box.hasSize) {
          final topCenter = box.localToGlobal(Offset(box.size.width / 2, 16));
          SakugaFx.ticks(
            context,
            origin: topCenter,
            count: 3,
            radius: 14,
            length: 9,
            color: AppColors.successGreen,
          );
        }
      }
    });

    _autoHideTimer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_exiting || !mounted) return;
    _exiting = true;
    _autoHideTimer?.cancel();
    if (!SakugaMotion.isReduced(context)) {
      await _controller.reverse();
    }
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = SakugaMotion.isReduced(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomInset + bottomPadding + 20,
      child: Semantics(
        liveRegion: true,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = reduced
                ? 1.0
                : Curves.easeOutBack.transform(_controller.value);
            final opacity = _controller.value.clamp(0.0, 1.0);
            final dy = reduced ? 0.0 : (1.0 - t) * 24.0;
            final scale = reduced ? 1.0 : (0.92 + 0.08 * t);
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, dy),
                child: Transform.scale(scale: scale, child: child),
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (_) => _dismiss(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(_icon, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
