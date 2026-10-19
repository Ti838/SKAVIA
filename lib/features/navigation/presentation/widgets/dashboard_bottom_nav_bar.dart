import 'package:flutter/material.dart';

import '../../../../core/services/app_language_service.dart';
import '../screens/main_scaffold_screen.dart';

/// 5-Tab Bottom Navigation Bar matching the SKAVIA Reference Design
/// Features pixel-perfect selected/unselected icon pairs, touch targets, and accessibility semantics.
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
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = currentIndex == index;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    return Expanded(
      child: Semantics(
        label: label,
        selected: isSelected,
        button: true,
        child: InkWell(
          onTap: () => onTabSelected(index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    key: ValueKey<bool>(isSelected),
                    size: 22,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _buildNavItem(
                context,
                index: 0,
                activeIcon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
                label: AppLanguageService.tr('home'),
              ),
              _buildNavItem(
                context,
                index: 1,
                activeIcon: Icons.grid_view_rounded,
                inactiveIcon: Icons.grid_view_outlined,
                label: currentMode == AppRoleMode.customer
                    ? AppLanguageService.tr('services')
                    : AppLanguageService.tr('incoming_requests'),
              ),
              _buildNavItem(
                context,
                index: 2,
                activeIcon: Icons.chat_bubble_rounded,
                inactiveIcon: Icons.chat_bubble_outline_rounded,
                label: AppLanguageService.tr('messages'),
              ),
              _buildNavItem(
                context,
                index: 3,
                activeIcon: Icons.folder_rounded,
                inactiveIcon: Icons.folder_outlined,
                label: AppLanguageService.tr('projects'),
              ),
              _buildNavItem(
                context,
                index: 4,
                activeIcon: Icons.person_rounded,
                inactiveIcon: Icons.person_outline_rounded,
                label: currentMode == AppRoleMode.customer
                    ? AppLanguageService.tr('profile')
                    : AppLanguageService.tr('review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
