import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
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
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = constraints.maxWidth < 310 || textScale > 1.3;

        final earningsCard = GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.workerEarnings),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.softPeachBg,
              borderRadius: BorderRadius.circular(AppDimensions.radius20),
              border: Border.all(
                color: context.isDarkMode
                    ? tokens.border
                    : AppColors.accentPeach.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLanguageService.tr('earnings'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tokens.secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
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
                        : tokens.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        );

        final jobsCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.softBlueBg,
            borderRadius: BorderRadius.circular(AppDimensions.radius20),
            border: Border.all(
              color: context.isDarkMode
                  ? tokens.border
                  : AppColors.primarySky.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLanguageService.tr('completed_jobs'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tokens.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.check_circle_outline,
                    color: tokens.brandAccent,
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
                  Flexible(
                    child: Text(
                      '${AppLanguageService.tr('rating')} ${workerRating.toStringAsFixed(1)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tokens.brandAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (stackVertically) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [earningsCard, const SizedBox(height: 12), jobsCard],
          );
        }

        return Row(
          children: [
            Expanded(child: earningsCard),
            const SizedBox(width: 12),
            Expanded(child: jobsCard),
          ],
        );
      },
    );
  }
}
