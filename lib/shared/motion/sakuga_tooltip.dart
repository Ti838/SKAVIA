// SKAVIA Sakuga Tooltip (Crisp Spring Pop Speech Bubble)
// Inspired by Sakuga VFX Tooltip (MIT License, Copyright (c) 2026 Justin Finkelman).

import 'package:flutter/material.dart';

import 'sakuga_physics.dart';

/// Accessible tooltip with snappy spring-like visual styling matching SKAVIA tokens.
class SakugaTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const SakugaTooltip({super.key, required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduced = SakugaMotion.isReduced(context);

    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 350),
      showDuration: const Duration(seconds: 2),
      preferBelow: false,
      verticalOffset: 14,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: TextStyle(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      enableFeedback: !reduced,
      child: child,
    );
  }
}
