import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';

/// Progress Lifecycle Stepper for the Active Job Screen
class ActiveJobLifecycleStepper extends StatelessWidget {
  final int currentPhase;

  const ActiveJobLifecycleStepper({super.key, required this.currentPhase});

  Widget _buildPhaseTile({
    required int phaseIndex,
    required String title,
    required String subtitle,
    required IconData icon,
    bool isLast = false,
  }) {
    final isDone = currentPhase >= phaseIndex;
    final isCurrent = currentPhase == phaseIndex;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone
                    ? (isCurrent ? AppColors.accent : AppColors.primary)
                    : Colors.black.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDone ? Colors.white : AppColors.textDisabled,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: isDone
                    ? AppColors.primary
                    : Colors.black.withValues(alpha: 0.1),
              ),
          ],
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDone
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDone
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dispatch Status',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        _buildPhaseTile(
          phaseIndex: 0,
          title: 'Job Accepted',
          subtitle: 'Preparing tools & materials',
          icon: Icons.check_circle_outline_rounded,
        ),
        _buildPhaseTile(
          phaseIndex: 1,
          title: 'Heading to Location',
          subtitle: 'En route to customer site',
          icon: Icons.two_wheeler_rounded,
        ),
        _buildPhaseTile(
          phaseIndex: 2,
          title: 'Work In Progress',
          subtitle: 'Executing service tasks on site',
          icon: Icons.build_rounded,
        ),
        _buildPhaseTile(
          phaseIndex: 3,
          title: 'Completed & OTP Verified',
          subtitle: 'Escrow payment released to your account',
          icon: Icons.task_alt_rounded,
          isLast: true,
        ),
      ],
    );
  }
}
