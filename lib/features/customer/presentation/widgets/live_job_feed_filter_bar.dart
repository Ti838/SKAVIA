import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.sheetSurfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (_) => onSearchChanged(),
              decoration: InputDecoration(
                hintText: isBn
                    ? 'কাজের নাম বা এলাকা দিয়ে খুঁজুন...'
                    : 'Search jobs by trade, area or keyword...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primarySky,
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
                _buildFilterChip('All', isBn ? 'সব কাজ' : 'All Jobs'),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'Electrical',
                  isBn ? 'ইলেকট্রিক্যাল' : 'Electrical',
                ),
                const SizedBox(width: 6),
                _buildFilterChip('HVAC', isBn ? 'এসি / HVAC' : 'AC & HVAC'),
                const SizedBox(width: 6),
                _buildFilterChip('Plumbing', isBn ? 'প্লাম্বিং' : 'Plumbing'),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'Carpentry',
                  isBn ? 'কার্পেন্ট্রি' : 'Carpentry',
                ),
                const SizedBox(width: 8),

                // Emergency Only Toggle
                GestureDetector(
                  onTap: onToggleEmergency,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: onlyEmergency
                          ? AppColors.accentCoral
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: onlyEmergency
                            ? AppColors.accentCoral
                            : AppColors.borderLight,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterVal, String label) {
    final isSelected = selectedCategory == filterVal;
    return GestureDetector(
      onTap: () => onCategoryChanged(filterVal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRoyal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryRoyal : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
