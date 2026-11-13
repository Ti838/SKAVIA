import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

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
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(id),
          borderRadius: AppDimensions.roundedPill,
          child: Container(
            constraints: const BoxConstraints(minHeight: 38),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? tokens.brandAccent : tokens.cardBg,
              borderRadius: AppDimensions.roundedPill,
              border: Border.all(
                color: isSelected ? tokens.brandAccent : tokens.border,
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: tokens.brandAccent.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? tokens.onBrandAccent
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

