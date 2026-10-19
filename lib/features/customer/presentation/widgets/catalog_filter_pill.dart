import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';

/// Horizontal category filter pill used in the catalog browser.
class CatalogFilterPill extends StatelessWidget {
  final String id;
  final String label;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  const CatalogFilterPill({
    super.key,
    required this.id,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final unselectedBg = isDark
        ? colorScheme.surfaceContainerHighest
        : Colors.white;
    final unselectedBorder = colorScheme.outlineVariant;
    final unselectedText = colorScheme.onSurface;

    return GestureDetector(
      onTap: () => onSelected(id),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRoyal : unselectedBg,
          borderRadius: AppDimensions.roundedPill,
          border: Border.all(
            color: isSelected ? AppColors.primaryRoyal : unselectedBorder,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryRoyal.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : unselectedText,
            ),
          ),
        ),
      ),
    );
  }
}

