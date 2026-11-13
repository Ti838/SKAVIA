import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

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
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

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
            child: Material(
              color: isSelected ? tokens.brandAccent : tokens.cardBg,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onSelected(tab['key']!),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : tokens.border,
                    ),
                  ),
                  child: Text(
                    tab['label']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? tokens.onBrandAccent
                          : colorScheme.onSurface,
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
