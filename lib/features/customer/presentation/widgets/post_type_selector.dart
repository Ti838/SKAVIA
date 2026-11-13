import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
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
    final colorScheme = context.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBn ? 'পোস্টের ধরন' : 'Post Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final useWrap = constraints.maxWidth < 330 || textScale > 1.35;
            if (useWrap) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeChip(
                    context,
                    'Job',
                    isBn ? 'কাজের অফার' : 'Job Post',
                    expanded: false,
                  ),
                  _buildTypeChip(
                    context,
                    'Service Request',
                    isBn ? 'সার্ভিস রিকোয়েস্ট' : 'Service Request',
                    expanded: false,
                  ),
                  _buildTypeChip(
                    context,
                    'Professional Update',
                    isBn ? 'আপডেট' : 'Update',
                    expanded: false,
                  ),
                ],
              );
            }
            return Row(
              children: [
                _buildTypeChip(
                  context,
                  'Job',
                  isBn ? 'কাজের অফার' : 'Job Post',
                ),
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    BuildContext context,
    String type,
    String label, {
    bool expanded = true,
  }) {
    final isSelected = selectedType == type;
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    final chip = Material(
      color: isSelected ? tokens.brandAccent : tokens.subtleCardBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => onTypeChanged(type),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? tokens.brandAccent : tokens.border,
            ),
          ),
          child: Center(
            widthFactor: expanded ? null : 1,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? tokens.onBrandAccent : colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );

    return expanded ? Expanded(child: chip) : chip;
  }
}
