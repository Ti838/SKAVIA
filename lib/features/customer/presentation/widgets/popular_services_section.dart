import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/services/app_language_service.dart';

/// Screen 4 Popular Services row section aligned with SKAVIA SRS Section 3.1.C trade categories
class PopularServicesSection extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const PopularServicesSection({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isBn ? 'জনপ্রিয় সার্ভিসসমূহ' : 'Popular Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                AppLanguageService.tr('see_all'),
                style: const TextStyle(
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
              icon: Icons.electric_bolt_rounded,
              label: isBn ? 'ইলেকট্রিক্যাল' : 'Electrical',
              bgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              categoryId: 'cat_electrical',
            ),
            _buildCategoryIconItem(
              context: context,
              icon: Icons.plumbing_rounded,
              label: isBn ? 'প্লাম্বিং' : 'Plumbing',
              bgColor: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF16A34A),
              categoryId: 'cat_plumbing',
            ),
            _buildCategoryIconItem(
              context: context,
              icon: Icons.ac_unit_rounded,
              label: isBn ? 'এসি কুলিং' : 'AC Cooling',
              bgColor: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFEF4444),
              categoryId: 'cat_ac_hvac',
            ),
            _buildCategoryIconItem(
              context: context,
              icon: Icons.carpenter_rounded,
              label: isBn ? 'কার্পেন্ট্রি' : 'Carpentry',
              bgColor: const Color(0xFFFAF5FF),
              iconColor: const Color(0xFF9333EA),
              categoryId: 'cat_civil_carpentry',
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
    required String categoryId,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final itemBg = isDark ? iconColor.withValues(alpha: 0.15) : bgColor;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.categoryCatalog,
          arguments: {'categoryId': categoryId},
        );
      },
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: itemBg,
              borderRadius: BorderRadius.circular(16),
              border: isDark
                  ? Border.all(color: iconColor.withValues(alpha: 0.25))
                  : null,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
