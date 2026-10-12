import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_routes.dart';

/// Screen 4 Popular Services row section with See All
class PopularServicesSection extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const PopularServicesSection({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRoyal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCategoryIconItem(
              context: context,
              icon: Icons.palette_outlined,
              label: 'Design',
              bgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              categoryKey: 'design',
            ),
            _buildCategoryIconItem(
              context: context,
              icon: Icons.code_rounded,
              label: 'Development',
              bgColor: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF16A34A),
              categoryKey: 'development',
            ),
            _buildCategoryIconItem(
              context: context,
              icon: Icons.campaign_outlined,
              label: 'Marketing',
              bgColor: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFEF4444),
              categoryKey: 'marketing',
            ),
            _buildCategoryIconItem(
              context: context,
              icon: Icons.edit_note_rounded,
              label: 'Writing',
              bgColor: const Color(0xFFFAF5FF),
              iconColor: const Color(0xFF9333EA),
              categoryKey: 'writing',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryIconItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required String categoryKey,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.categoryCatalog,
          arguments: {'categoryId': 'cat_it_creative', 'searchQuery': label},
        );
      },
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
