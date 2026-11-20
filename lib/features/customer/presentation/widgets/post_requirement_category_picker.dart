import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/models/category_model.dart';

/// Trade Category Dropdown Picker for PostRequirementScreen.
class PostRequirementCategoryPicker extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const PostRequirementCategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: tokens.subtleCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              dropdownColor: tokens.cardBg,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: tokens.brandAccent,
              ),
              items: CategoryModel.defaultCategories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat.categoryId,
                  child: Text(
                    cat.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  onCategoryChanged(val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
