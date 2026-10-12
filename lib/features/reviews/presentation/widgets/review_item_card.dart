import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skavia/app/theme/app_colors.dart';
import 'package:skavia/app/theme/app_typography.dart';

import '../../data/models/review_model.dart';

/// Reusable card component for rendering a single verified worker review.
class ReviewItemCard extends StatelessWidget {
  final ReviewModel review;
  final DateFormat? dateFormat;

  const ReviewItemCard({super.key, required this.review, this.dateFormat});

  @override
  Widget build(BuildContext context) {
    final formatter = dateFormat ?? DateFormat('MMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sheetSurfaceSubtle,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primarySky.withValues(
                      alpha: 0.15,
                    ),
                    backgroundImage: review.clientAvatar != null
                        ? NetworkImage(review.clientAvatar!)
                        : null,
                    child: review.clientAvatar == null
                        ? Text(
                            (review.clientName?.isNotEmpty ?? false)
                                ? review.clientName![0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              color: AppColors.primaryRoyal,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.clientName ?? 'Verified Client',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        formatter.format(review.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (starIdx) {
                  return Icon(
                    starIdx < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: starIdx < review.rating
                        ? AppColors.warningAmber
                        : AppColors.textMuted,
                  );
                }),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMedium,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Honest empty state widget when a worker has zero verified reviews.
class EmptyReviewsState extends StatelessWidget {
  const EmptyReviewsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.sheetSurfaceSubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardBlueTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              size: 40,
              color: AppColors.primarySky,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Client Reviews Yet',
            style: TextStyle(
              fontFamily: AppTypography.headingFont,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'When clients rate completed jobs and emergency dispatches, feedback and ratings will be recorded here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
