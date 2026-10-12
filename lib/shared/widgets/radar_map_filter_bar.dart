import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.sheetSurfaceSubtle,
      child: Row(
        children: [
          // Radius Chips
          _buildRadiusChip(3, '3 km'),
          const SizedBox(width: 6),
          _buildRadiusChip(5, '5 km'),
          const SizedBox(width: 6),
          _buildRadiusChip(10, isBn ? '১০+ কিমি' : '10+ km'),
          const Spacer(),
          // Trade Filter Popup/Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedTradeFilter,
                isDense: true,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRoyal,
                ),
                icon: const Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: AppColors.primaryRoyal,
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Trades')),
                  DropdownMenuItem(
                    value: 'Electrical',
                    child: Text('Electrician'),
                  ),
                  DropdownMenuItem(value: 'HVAC', child: Text('AC / HVAC')),
                  DropdownMenuItem(value: 'Plumbing', child: Text('Plumber')),
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

  Widget _buildRadiusChip(int km, String label) {
    final isSelected = selectedRadiusKm == km;
    return GestureDetector(
      onTap: () => onRadiusChanged(km),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
