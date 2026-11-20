import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/motion/sakuga_physics.dart';
import '../../../../shared/motion/sakuga_pressable.dart';
import '../screens/main_scaffold_screen.dart';

/// 5-Tab Bottom Navigation Bar for SKAVIA.
/// Uses Material 3 pill active indicator, WCAG-verified colors, single-tap
/// responsive press physics, and concise non-truncating labels at 320dp.
class DashboardBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final AppRoleMode currentMode;
  final ValueChanged<int> onTabSelected;

  const DashboardBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.currentMode,
    required this.onTabSelected,
  });

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final isSelected = currentIndex == index;

    return Expanded(
      child: Semantics(
        label: label,
        selected: isSelected,
        button: true,
        child: SakugaPressable(
          intensity: SakugaIntensity.subtle,
          emitVfx: false,
          child: InkWell(
            onTap: () => onTabSelected(index),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: AppDimensions.roundedPill,
                    ),
                    child: Icon(
                      isSelected ? activeIcon : inactiveIcon,
                      size: 22,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : tokens.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : tokens.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final l10n = context.l10n;

    return Material(
      color: colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _buildNavItem(
                context,
                index: 0,
                activeIcon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
                label: l10n.navHome,
              ),
              _buildNavItem(
                context,
                index: 1,
                activeIcon: currentMode == AppRoleMode.worker
                    ? Icons.work_rounded
                    : Icons.grid_view_rounded,
                inactiveIcon: currentMode == AppRoleMode.worker
                    ? Icons.work_outline_rounded
                    : Icons.grid_view_outlined,
                label: currentMode == AppRoleMode.worker
                    ? l10n.navRequests
                    : l10n.navServices,
              ),
              _buildNavItem(
                context,
                index: 2,
                activeIcon: Icons.chat_bubble_rounded,
                inactiveIcon: Icons.chat_bubble_outline_rounded,
                label: l10n.navMessages,
              ),
              _buildNavItem(
                context,
                index: 3,
                activeIcon: currentMode == AppRoleMode.customer
                    ? Icons.dynamic_feed_rounded
                    : Icons.folder_rounded,
                inactiveIcon: currentMode == AppRoleMode.customer
                    ? Icons.dynamic_feed_outlined
                    : Icons.folder_outlined,
                label: currentMode == AppRoleMode.customer
                    ? l10n.navFeed
                    : l10n.navProjects,
              ),
              _buildNavItem(
                context,
                index: 4,
                activeIcon: Icons.person_rounded,
                inactiveIcon: Icons.person_outline_rounded,
                label: l10n.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
