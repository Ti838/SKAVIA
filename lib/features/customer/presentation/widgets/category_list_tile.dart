import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../data/models/category_model.dart';

/// Row tile for a category in the catalog list
class CategoryListTile extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryListTile({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  static IconData resolveCategoryIcon(String iconName) {
    switch (iconName) {
      case 'electric_bolt_rounded':
        return Icons.electric_bolt_rounded;
      case 'plumbing_rounded':
        return Icons.plumbing_rounded;
      case 'ac_unit_rounded':
        return Icons.ac_unit_rounded;
      case 'code_rounded':
        return Icons.code_rounded;
      case 'carpenter_rounded':
        return Icons.carpenter_rounded;
      case 'directions_car_rounded':
        return Icons.directions_car_rounded;
      case 'precision_manufacturing_rounded':
        return Icons.precision_manufacturing_rounded;
      case 'home_repair_service_rounded':
        return Icons.home_repair_service_rounded;
      default:
        return Icons.handyman_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryRoyal : AppColors.borderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySky.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                resolveCategoryIcon(category.iconName),
                size: 22,
                color: AppColors.primaryRoyal,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.serviceCount > 0 ? category.serviceCount : 80}+ services',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
