import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Reusable horizontal filter tabs for the live social and job feed.
class FeedFilterTabs extends StatelessWidget {
  final String selectedPostType;
  final ValueChanged<String> onSelected;
  final bool isBn;

  const FeedFilterTabs({
    super.key,
    required this.selectedPostType,
    required this.onSelected,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final tabs = [
      {'key': 'All', 'label': isBn ? 'সকল পোস্ট' : 'All Posts'},
      {'key': 'Jobs', 'label': isBn ? 'চাকরি/কাজ' : 'Jobs'},
      {'key': 'Requests', 'label': isBn ? 'সেবা অনুরোধ' : 'Service Requests'},
      {'key': 'Updates', 'label': isBn ? 'পেশাদার আপডেট' : 'Updates'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = selectedPostType == tab['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                tab['label']!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? colorScheme.onSurface : AppColors.textDark),
                ),
              ),
              selected: isSelected,
              selectedColor: isDark
                  ? colorScheme.primary
                  : AppColors.primaryRoyal,
              backgroundColor: isDark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.white,
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : colorScheme.outlineVariant,
              ),
              onSelected: (_) => onSelected(tab['key']!),
            ),
          );
        }).toList(),
      ),
    );
  }
}
