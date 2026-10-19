import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/services/app_language_service.dart';

/// Dual stat cards showing worker earnings and completed jobs with rating.
class WorkerStatCards extends StatelessWidget {
  final double workerEarnings;
  final int workerCompletedJobs;
  final double workerRating;

  const WorkerStatCards({
    super.key,
    required this.workerEarnings,
    required this.workerCompletedJobs,
    required this.workerRating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Peach Earnings Card
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.workerEarnings),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest
                    : AppColors.cardPeachTint,
                borderRadius: BorderRadius.circular(AppDimensions.radius20),
                border: Border.all(
                  color: isDark
                      ? colorScheme.outlineVariant
                      : AppColors.accentPeach.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLanguageService.tr('earnings'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.accentCoral,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '৳ ${workerEarnings.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workerEarnings > 0
                        ? AppLanguageService.tr('verified_balance')
                        : AppLanguageService.tr('zero_balance'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: workerEarnings > 0
                          ? AppColors.successGreen
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Blue Jobs Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : AppColors.cardBlueTint,
              borderRadius: BorderRadius.circular(AppDimensions.radius20),
              border: Border.all(
                color: isDark
                    ? colorScheme.outlineVariant
                    : AppColors.primarySky.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLanguageService.tr('completed_jobs'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primarySky,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$workerCompletedJobs ${AppLanguageService.tr('jobs')}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.accentPeach,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${AppLanguageService.tr('rating')} ${workerRating.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? colorScheme.primary
                            : AppColors.primaryRoyal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
