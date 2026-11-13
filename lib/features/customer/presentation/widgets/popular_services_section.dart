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
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    final items = [
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
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                isBn ? 'জনপ্রিয় সার্ভিসসমূহ' : 'Popular Services',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                AppLanguageService.tr('see_all'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorScheme.primary
                      : AppColors.primaryRoyal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 330 || textScale > 1.3) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: items[0]),
                      const SizedBox(width: 8),
                      Expanded(child: items[1]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: items[2]),
                      const SizedBox(width: 8),
                      Expanded(child: items[3]),
                    ],
                  ),
                ],
              );
            }
            return Row(
              children: items
                  .map((item) => Expanded(child: item))
                  .toList(),
            );
          },
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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
