import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

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
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Budget Range
        Text(
          'Budget Range',
          style: TextStyle(
            fontSize: 14,
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
              value: budgetRangeOptions.contains(selectedBudgetRange)
                  ? selectedBudgetRange
                  : budgetRangeOptions.first,
              isExpanded: true,
              dropdownColor: tokens.cardBg,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              items: budgetRangeOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(
                    opt,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
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
        Text(
          'Service Location',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 14,
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
              value: dhakaZones.contains(selectedLocation)
                  ? selectedLocation
                  : dhakaZones.first,
              isExpanded: true,
              dropdownColor: tokens.cardBg,
              icon: Icon(
                Icons.location_on_outlined,
                color: tokens.brandAccent,
                size: 20,
              ),
              items: dhakaZones.map((loc) {
                return DropdownMenuItem<String>(
                  value: loc,
                  child: Text(
                    loc,
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
                if (val != null) onLocationChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
