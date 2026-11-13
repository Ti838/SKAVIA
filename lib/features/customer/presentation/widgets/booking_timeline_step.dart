import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

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
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

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
                    ? (isCurrent ? AppColors.accent : tokens.brandAccent)
                    : tokens.subtleCardBg,
                shape: BoxShape.circle,
                border: isDone ? null : Border.all(color: tokens.border),
              ),
              child: Icon(
                icon,
                color: isDone
                    ? (isCurrent ? AppColors.textDark : tokens.onBrandAccent)
                    : tokens.mutedText,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isDone ? tokens.brandAccent : tokens.border,
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
                    color: isDone ? colorScheme.onSurface : tokens.mutedText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: isDone
                        ? colorScheme.onSurfaceVariant
                        : tokens.mutedText,
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
