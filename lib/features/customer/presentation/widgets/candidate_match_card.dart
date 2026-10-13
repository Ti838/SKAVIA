import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: isTopMatch
              ? AppColors.accent
              : colorScheme.outlineVariant,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isTopMatch
                        ? AppColors.accent
                        : AppColors.primary.withValues(alpha: 0.1),
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
                        color: isTopMatch ? Colors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          isTopMatch
                              ? 'Top Match #${candidate.rankPosition}'
                              : 'Rank #${candidate.rankPosition}',
                          style: AppTypography.caption.copyWith(
                            color: isTopMatch ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
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
                    Text(
                      '${candidate.matchScore.toStringAsFixed(0)}% Match',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
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
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
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
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.primary,
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
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.location,
                            style: AppTypography.caption.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.accentPeach,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${candidate.rating.toStringAsFixed(1)} (${candidate.completedJobs} jobs)',
                          style: AppTypography.caption.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
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
          Row(
            children: [
              Expanded(
                flex: 3,
                child: OutlinedButton(
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
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                    side: const BorderSide(color: AppColors.primarySky),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusRound,
                      ),
                    ),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Scorecard',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primarySky,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: AppButton(
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
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
