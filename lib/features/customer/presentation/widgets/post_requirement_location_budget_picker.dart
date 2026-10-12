import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

class PostRequirementLocationBudgetPicker extends StatelessWidget {
  final String selectedBudgetRange;
  final List<String> budgetRangeOptions;
  final ValueChanged<String> onBudgetRangeChanged;
  final String selectedLocation;
  final List<String> dhakaZones;
  final ValueChanged<String> onLocationChanged;

  const PostRequirementLocationBudgetPicker({
    super.key,
    required this.selectedBudgetRange,
    required this.budgetRangeOptions,
    required this.onBudgetRangeChanged,
    required this.selectedLocation,
    required this.dhakaZones,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Budget Range
        const Text(
          'Budget Range',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.sheetSurfaceSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedBudgetRange,
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.textMedium,
              ),
              items: budgetRangeOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(
                    opt,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onBudgetRangeChanged(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Service Location in Dhaka
        const Text(
          'Service Location',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.sheetSurfaceSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLocation,
              isExpanded: true,
              icon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primarySky,
                size: 20,
              ),
              items: dhakaZones.map((loc) {
                return DropdownMenuItem<String>(
                  value: loc,
                  child: Text(
                    loc,
                    style: const TextStyle(
                      fontFamily: AppTypography.bodyFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onLocationChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
