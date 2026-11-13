import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

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
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

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
            child: Material(
              color: isSelected ? AppColors.primarySky : tokens.subtleCardBg,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onSelected(cat['key']!),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : tokens.border,
                    ),
                  ),
                  child: Text(
                    cat['label']!,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
