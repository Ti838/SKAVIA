import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../data/models/category_model.dart';

/// Row tile for a trade category in the Services catalog.
/// Maps both Supabase short icon names (`bolt`, `ac_unit`, `water_drop`, etc.)
/// and Material icon names cleanly, with zero fabricated service counts.
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
    switch (iconName.trim().toLowerCase()) {
      case 'bolt':
      case 'electric_bolt_rounded':
        return Icons.electric_bolt_rounded;
      case 'water_drop':
      case 'plumbing':
      case 'plumbing_rounded':
        return Icons.plumbing_rounded;
      case 'ac_unit':
      case 'ac_unit_rounded':
        return Icons.ac_unit_rounded;
      case 'security':
      case 'code_rounded':
        return Icons.security_rounded;
      case 'format_paint':
      case 'paint':
        return Icons.format_paint_rounded;
      case 'carpenter_rounded':
      case 'carpentry':
        return Icons.carpenter_rounded;
      case 'directions_car_rounded':
      case 'automotive':
        return Icons.directions_car_rounded;
      case 'precision_manufacturing_rounded':
      case 'industrial':
        return Icons.precision_manufacturing_rounded;
      case 'home_repair_service_rounded':
      case 'appliances':
        return Icons.home_repair_service_rounded;
      default:
        return Icons.handyman_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final isBn = AppLanguageService.isBengali;
    final subtitleText = category.description.trim().isNotEmpty
        ? category.description.trim()
        : (isBn ? 'ট্রেড ক্যাটাগরি সার্ভিস' : 'SKAVIA trade category');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : tokens.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide(
            color: isSelected ? colorScheme.primary : tokens.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    resolveCategoryIcon(category.iconName),
                    size: 21,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguageService.getCategoryName(
                          category.slug,
                          category.name,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: tokens.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
