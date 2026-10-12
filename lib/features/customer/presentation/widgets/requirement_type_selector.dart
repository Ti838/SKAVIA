import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Scope & Type selector for posting service requirements (Individual vs Team Project)
class RequirementTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const RequirementTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  Widget _buildCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primarySky.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primarySky : AppColors.borderLight,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primarySky : AppColors.textMedium,
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.primaryRoyal
                      : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Scope',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildCard(
              type: 'Individual',
              title: 'Single Specialist',
              subtitle: 'Individual technician',
              icon: Icons.person_rounded,
            ),
            const SizedBox(width: 12),
            _buildCard(
              type: 'Team Project',
              title: 'Team Project',
              subtitle: 'Multi-discipline team',
              icon: Icons.groups_rounded,
            ),
          ],
        ),
      ],
    );
  }
}
