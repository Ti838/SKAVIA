import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';

/// Single visual step indicator along the service lifecycle progress track.
class BookingTimelineStep extends StatelessWidget {
  final int stepIndex;
  final int currentStep;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLast;

  const BookingTimelineStep({
    super.key,
    required this.stepIndex,
    required this.currentStep,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = currentStep >= stepIndex;
    final isCurrent = currentStep == stepIndex;

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
                    : Colors.black.withValues(alpha: 0.05),
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
                height: 48,
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
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    color: isDone
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: isDone
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
