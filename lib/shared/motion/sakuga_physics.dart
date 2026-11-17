// SKAVIA Sakuga Motion Physics & Palette
// Motion principles and spring equations adapted from Sakuga VFX
// (https://github.com/finktheartist/sakuga-vfx) under the MIT License:
// Copyright (c) 2026 Justin Finkelman.

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Semantic motion intensity levels enforced across SKAVIA.
enum SakugaIntensity {
  /// Input focus, checkbox, radio, tooltip, tabs, small navigation feedback.
  subtle,

  /// Primary buttons, toggle switches, toasts, filter chips, progress updates.
  medium,

  /// Verified payment confirmation, genuine booking confirmation, 5-star burst.
  strong,
}

/// Brand-aligned SKAVIA motion palette for canvas particles (never anime pink).
class SakugaPalette {
  final Color fill;
  final Color shade;
  final Color line;
  final Color accent;
  final Color success;

  const SakugaPalette({
    required this.fill,
    required this.shade,
    required this.line,
    required this.accent,
    required this.success,
  });

  static SakugaPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const SakugaPalette(
        fill: Color(0xFFEFF6FF),
        shade: Color(0xFF93C5FD),
        line: Color(0xFF3898EC),
        accent: Color(0xFF15E7CA),
        success: AppColors.successGreen,
      );
    }
    return const SakugaPalette(
      fill: Color(0xFFFFFFFF),
      shade: Color(0xFFBFDBFE),
      line: AppColors.primaryRoyal,
      accent: AppColors.primarySky,
      success: AppColors.successGreen,
    );
  }
}

/// Reusable spring descriptions & reduced-motion utilities modeled on Sakuga core.
abstract class SakugaMotion {
  /// Primary press/release spring (matches Sakuga squashy k=520, d=18 tuned for mobile).
  static const SpringDescription squashSpring = SpringDescription(
    mass: 1.0,
    stiffness: 520.0,
    damping: 22.0,
  );

  /// Expressive pop-in spring for badges, checkmarks, tooltips, and stars.
  static const SpringDescription popSpring = SpringDescription(
    mass: 1.0,
    stiffness: 380.0,
    damping: 18.0,
  );

  /// Snappy settle spring for tabs, toggles, and sliders.
  static const SpringDescription settleSpring = SpringDescription(
    mass: 1.0,
    stiffness: 440.0,
    damping: 26.0,
  );

  /// Fast subtle micro-spring for input focus and compact nav items.
  static const SpringDescription subtleSpring = SpringDescription(
    mass: 1.0,
    stiffness: 480.0,
    damping: 30.0,
  );

  /// Returns true when the OS or user accessibility preferences request reduced motion.
  static bool isReduced(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
  }

  /// Cubic ease-out matching Sakuga core `out(t) = 1 - (1 - t)^3`.
  static double easeOutCubic(double t) {
    final c = t.clamp(0.0, 1.0);
    final inv = 1.0 - c;
    return 1.0 - (inv * inv * inv);
  }

  /// Cubic ease-in matching Sakuga core `inn(t) = t^3`.
  static double easeInCubic(double t) {
    final c = t.clamp(0.0, 1.0);
    return c * c * c;
  }

  /// Overshoot ease-out matching Sakuga core `back(t)`.
  static double easeOutBack(double t) {
    final c = t.clamp(0.0, 1.0);
    const c1 = 1.70158;
    const c3 = c1 + 1.0;
    final x = c - 1.0;
    return 1.0 + c3 * x * x * x + c1 * x * x;
  }
}
