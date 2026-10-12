import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Horizontal stepper indicator for the Request Service flow aligned with Screen 6
class PostRequirementStepper extends StatelessWidget {
  final int activeStep;

  const PostRequirementStepper({super.key, this.activeStep = 1});

  Widget _buildStepItem(int stepNumber, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryRoyal : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primaryRoyal : AppColors.borderLight,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isActive ? Colors.white : AppColors.textMedium,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primaryRoyal : AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 28,
      height: 1.5,
      color: AppColors.borderLight,
      margin: const EdgeInsets.only(bottom: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(1, 'Details', activeStep >= 1),
          _buildStepDivider(),
          _buildStepItem(2, 'Skills', activeStep >= 2),
          _buildStepDivider(),
          _buildStepItem(3, 'Budget', activeStep >= 3),
          _buildStepDivider(),
          _buildStepItem(4, 'Review', activeStep >= 4),
        ],
      ),
    );
  }
}
