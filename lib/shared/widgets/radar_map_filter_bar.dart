import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';

class RadarMapFilterBar extends StatelessWidget {
  final int selectedRadiusKm;
  final ValueChanged<int> onRadiusChanged;
  final String selectedTradeFilter;
  final ValueChanged<String> onTradeFilterChanged;
  final bool isBn;

  const RadarMapFilterBar({
    super.key,
    required this.selectedRadiusKm,
    required this.onRadiusChanged,
    required this.selectedTradeFilter,
    required this.onTradeFilterChanged,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: tokens.subtleCardBg,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          // Radius Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildRadiusChip(context, 3, '3 km'),
              _buildRadiusChip(context, 5, '5 km'),
              _buildRadiusChip(context, 10, isBn ? '১০+ কিমি' : '10+ km'),
            ],
          ),
          // Trade Filter Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tokens.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedTradeFilter,
                dropdownColor: colorScheme.surface,
                isDense: true,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: tokens.brandAccent,
                ),
                icon: Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: tokens.brandAccent,
                ),
                  items: const [
                    DropdownMenuItem(
                      value: 'All',
                      child: Text('All Trades', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Electrical',
                      child: Text(
                        'Electrician',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'HVAC',
                      child: Text('AC / HVAC', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Plumbing',
                      child: Text('Plumber', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                onChanged: (val) {
                  if (val != null) onTradeFilterChanged(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusChip(BuildContext context, int km, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final isSelected = selectedRadiusKm == km;
    return GestureDetector(
      onTap: () => onRadiusChanged(km),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRoyal : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryRoyal : tokens.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
