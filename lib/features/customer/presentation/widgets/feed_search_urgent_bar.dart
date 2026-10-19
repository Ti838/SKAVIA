import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Search input field and emergency filter toggle button for the live feed.
class FeedSearchUrgentBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool onlyEmergency;
  final VoidCallback onToggleEmergency;
  final bool isBn;

  const FeedSearchUrgentBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onlyEmergency,
    required this.onToggleEmergency,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: isBn
                      ? 'কাজের নাম বা এলাকা খুঁজুন...'
                      : 'Search feed by keyword...',
                  hintStyle: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: isDark ? colorScheme.primary : AppColors.primarySky,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Emergency Filter Toggle
          GestureDetector(
            onTap: onToggleEmergency,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: onlyEmergency
                    ? AppColors.accentCoral
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: onlyEmergency
                      ? AppColors.accentCoral
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 14,
                    color: onlyEmergency ? Colors.white : AppColors.accentCoral,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isBn ? 'জরুরি' : 'Urgent',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: onlyEmergency
                          ? Colors.white
                          : AppColors.accentCoral,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
