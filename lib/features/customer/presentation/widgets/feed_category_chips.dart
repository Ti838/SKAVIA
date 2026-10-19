import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Reusable horizontal trade/category filter chips for the live job feed.
class FeedCategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;
  final bool isBn;

  const FeedCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final categories = [
      {'key': 'All', 'label': isBn ? 'সকল ট্রেড' : 'All Trades'},
      {'key': 'Electrical', 'label': isBn ? 'ইলেকট্রিক্যাল' : 'Electrical'},
      {'key': 'HVAC', 'label': isBn ? 'এসি / HVAC' : 'AC & HVAC'},
      {'key': 'Plumbing', 'label': isBn ? 'প্লাম্বিং' : 'Plumbing'},
      {'key': 'Carpentry', 'label': isBn ? 'কার্পেন্ট্রি' : 'Carpentry'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                cat['label']!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              selectedColor: isDark
                  ? colorScheme.primary
                  : AppColors.primarySky,
              backgroundColor: isDark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.white,
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : colorScheme.outlineVariant,
              ),
              onSelected: (_) => onSelected(cat['key']!),
            ),
          );
        }).toList(),
      ),
    );
  }
}
