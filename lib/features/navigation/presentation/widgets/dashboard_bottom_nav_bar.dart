import 'package:flutter/material.dart';

import '../../../../core/services/app_language_service.dart';
import '../screens/main_scaffold_screen.dart';

/// 5-Tab Bottom Navigation Bar matching the SKAVIA Reference Design
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

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = currentIndex == index;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
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
              _buildNavItem(context, 0, Icons.home_rounded, AppLanguageService.tr('home')),
              _buildNavItem(
                context,
                1,
                Icons.grid_view_rounded,
                currentMode == AppRoleMode.customer
                    ? AppLanguageService.tr('services')
                    : AppLanguageService.tr('incoming_requests'),
              ),
              _buildNavItem(
                context,
                2,
                Icons.chat_bubble_outline_rounded,
                AppLanguageService.tr('messages'),
              ),
              _buildNavItem(
                context,
                3,
                Icons.folder_outlined,
                AppLanguageService.tr('projects'),
              ),
              _buildNavItem(
                context,
                4,
                Icons.person_outline_rounded,
                currentMode == AppRoleMode.customer
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
