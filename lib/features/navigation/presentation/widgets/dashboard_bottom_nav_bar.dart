import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
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

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primarySky : AppColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppColors.primarySky : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, AppLanguageService.tr('home')),
          _buildNavItem(
            1,
            Icons.grid_view_rounded,
            currentMode == AppRoleMode.customer
                ? AppLanguageService.tr('services')
                : AppLanguageService.tr('incoming_requests'),
          ),
          _buildNavItem(
            2,
            Icons.chat_bubble_outline_rounded,
            AppLanguageService.tr('messages'),
          ),
          _buildNavItem(
            3,
            Icons.folder_outlined,
            AppLanguageService.tr('projects'),
          ),
          _buildNavItem(
            4,
            Icons.person_outline_rounded,
            currentMode == AppRoleMode.customer
                ? AppLanguageService.tr('profile')
                : AppLanguageService.tr('review'),
          ),
        ],
      ),
    );
  }
}
