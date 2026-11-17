// SKAVIA Sakuga Tabs (Spring-Sliding Indicator + Subtle Landing Accent)
// Inspired by Sakuga VFX Tabs (MIT License, Copyright (c) 2026 Justin Finkelman).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import 'sakuga_physics.dart';

/// Segmented tab bar with crisp spring-eased sliding active pill and subtle tactile feedback.
class SakugaTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? activeColor;

  const SakugaTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduced = SakugaMotion.isReduced(context);
    final accent = activeColor ?? AppColors.primaryRoyal;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / tabs.length;
          final clampedIndex = selectedIndex.clamp(0, tabs.length - 1);

          return Stack(
            children: [
              AnimatedPositioned(
                duration: reduced
                    ? Duration.zero
                    : const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                left: clampedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: isDark ? 0.25 : 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(tabs.length, (i) {
                  final isSelected = i == clampedIndex;
                  return Expanded(
                    child: Semantics(
                      selected: isSelected,
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i != clampedIndex) {
                            HapticFeedback.selectionClick();
                            onChanged(i);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          child: AnimatedDefaultTextStyle(
                            duration: reduced
                                ? Duration.zero
                                : const Duration(milliseconds: 180),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? Colors.white : accent)
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            child: Text(
                              tabs[i],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
