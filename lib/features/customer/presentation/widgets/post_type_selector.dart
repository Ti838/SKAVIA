import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';

/// Reusable pill selector for choosing post type: 'Job', 'Service Request', or 'Professional Update'.
class PostTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const PostTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBn ? 'পোস্টের ধরন' : 'Post Type',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTypeChip(context, 'Job', isBn ? 'কাজের অফার' : 'Job Post'),
            const SizedBox(width: 8),
            _buildTypeChip(
              context,
              'Service Request',
              isBn ? 'সার্ভিস রিকোয়েস্ট' : 'Service Request',
            ),
            const SizedBox(width: 8),
            _buildTypeChip(
              context,
              'Professional Update',
              isBn ? 'আপডেট' : 'Update',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, String type, String label) {
    final isSelected = selectedType == type;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryRoyal
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryRoyal
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
