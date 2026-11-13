import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../matching/domain/entities/match_result_entity.dart';
import '../../../reviews/presentation/screens/worker_reputation_screen.dart';
import '../screens/booking_confirmation_screen.dart';

class CandidateMatchCard extends StatelessWidget {
  final MatchResultEntity candidate;
  final String requirementTitle;
  final String requirementZone;

  const CandidateMatchCard({
    super.key,
    required this.candidate,
    required this.requirementTitle,
    required this.requirementZone,
  });

  @override
  Widget build(BuildContext context) {
    final isTopMatch = candidate.rankPosition == 1;
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: isTopMatch ? AppColors.accent : tokens.border,
          width: isTopMatch ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Rank & Match Score Badge
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isTopMatch
                      ? AppColors.accent
                      : tokens.softBlueBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTopMatch
                          ? Icons.workspace_premium_rounded
                          : Icons.star_rounded,
                      size: 13,
                      color: isTopMatch ? AppColors.textDark : tokens.brandAccent,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        isTopMatch
                            ? 'Top Match #${candidate.rankPosition}'
                            : 'Rank #${candidate.rankPosition}',
                        style: AppTypography.caption.copyWith(
                          color: isTopMatch
                              ? AppColors.textDark
                              : tokens.brandAccent,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '${candidate.matchScore.toStringAsFixed(0)}% Match',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Worker Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: tokens.softBlueBg,
                child: Icon(
                  Icons.person,
                  color: tokens.brandAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.workerName,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (candidate.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified_rounded,
                            color: tokens.brandAccent,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      candidate.tradeTitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          candidate.location,
                          style: AppTypography.caption.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: AppColors.accentPeach,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                '${candidate.rating.toStringAsFixed(1)} (${candidate.completedJobs} jobs)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Algorithmic Metric Chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMetricChip(
                context,
                'Skill Match',
                '${candidate.skillScore.toStringAsFixed(0)}%',
              ),
              _buildMetricChip(
                context,
                'Proximity',
                '${candidate.distanceScore.toStringAsFixed(0)}%',
              ),
              _buildMetricChip(
                context,
                'Hourly Rate',
                '৳ ${candidate.hourlyRate.toStringAsFixed(0)}/hr',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Direct Actions: Reputation & Booking CTA
          LayoutBuilder(
            builder: (context, constraints) {
              final stackActions =
                  constraints.maxWidth < 330 || textScale > 1.35;

              final scorecardBtn = OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkerReputationScreen(
                        workerProfileId: candidate.workerProfileId,
                        workerName: candidate.workerName,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 10,
                  ),
                  side: BorderSide(color: tokens.brandAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusRound,
                    ),
                  ),
                ),
                child: Text(
                  'Scorecard',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: tokens.brandAccent,
                  ),
                ),
              );

              final bookBtn = AppButton(
                text: 'Book Specialist',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingConfirmationScreen(
                        requirementId: candidate.requirementId,
                        workerProfileId: candidate.workerProfileId,
                        workerName: candidate.workerName,
                        tradeTitle: candidate.tradeTitle,
                        hourlyRate: candidate.hourlyRate,
                        jobTitle: requirementTitle,
                        location: requirementZone,
                      ),
                    ),
                  );
                },
              );

              if (stackActions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    bookBtn,
                    const SizedBox(height: 8),
                    scorecardBtn,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: scorecardBtn),
                  const SizedBox(width: 8),
                  Expanded(flex: 5, child: bookBtn),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(BuildContext context, String label, String value) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.subtleCardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tokens.subtleBorder),
      ),
      child: Text(
        '$label: $value',
        style: AppTypography.caption.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
