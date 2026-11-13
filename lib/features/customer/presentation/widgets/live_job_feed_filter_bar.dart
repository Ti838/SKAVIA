import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';

/// Reusable filter and search header bar for the Live Job Feed screen.
class LiveJobFeedFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final bool onlyEmergency;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onToggleEmergency;
  final VoidCallback onSearchChanged;

  const LiveJobFeedFilterBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.onlyEmergency,
    required this.onCategoryChanged,
    required this.onToggleEmergency,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: tokens.subtleCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tokens.border),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (_) => onSearchChanged(),
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: isBn
                    ? 'কাজের নাম বা এলাকা দিয়ে খুঁজুন...'
                    : 'Search jobs by trade, area or keyword...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: tokens.brandAccent,
                  size: 20,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal Category Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'All', isBn ? 'সব কাজ' : 'All Jobs'),
                const SizedBox(width: 6),
                _buildFilterChip(
                  context,
                  'Electrical',
                  isBn ? 'ইলেকট্রিক্যাল' : 'Electrical',
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  context,
                  'HVAC',
                  isBn ? 'এসি / HVAC' : 'AC & HVAC',
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  context,
                  'Plumbing',
                  isBn ? 'প্লাম্বিং' : 'Plumbing',
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  context,
                  'Carpentry',
                  isBn ? 'কার্পেন্ট্রি' : 'Carpentry',
                ),
                const SizedBox(width: 8),

                // Emergency Only Toggle
                Material(
                  color: onlyEmergency ? AppColors.accentCoral : tokens.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onToggleEmergency,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: onlyEmergency
                              ? AppColors.accentCoral
                              : tokens.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: onlyEmergency
                                ? Colors.white
                                : AppColors.accentCoral,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isBn ? 'জরুরি (2h)' : 'Urgent Only',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String filterVal,
    String label,
  ) {
    final isSelected = selectedCategory == filterVal;
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Material(
      color: isSelected ? tokens.brandAccent : tokens.cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onCategoryChanged(filterVal),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? tokens.brandAccent : tokens.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? tokens.onBrandAccent : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
