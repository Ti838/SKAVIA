import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../data/models/review_model.dart';

/// Reusable card component for rendering a single verified worker review.
class ReviewItemCard extends StatelessWidget {
  final ReviewModel review;
  final DateFormat? dateFormat;

  const ReviewItemCard({super.key, required this.review, this.dateFormat});

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final formatter = dateFormat ?? DateFormat('MMM d, yyyy');
    final clientName = review.clientName ?? 'Verified Client';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UserAvatar(
                      imageUrl: review.clientAvatar,
                      name: clientName,
                      radius: 18,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clientName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            formatter.format(review.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: tokens.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (starIdx) {
                    return Icon(
                      starIdx < review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: starIdx < review.rating
                          ? AppColors.warningAmber
                          : tokens.mutedText,
                    );
                  }),
                ),
              ],
            ),
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 13,
                color: tokens.secondaryText,
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
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tokens.subtleCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: tokens.softBlueBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_outline_rounded,
              size: 40,
              color: tokens.brandAccent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Client Reviews Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.headingFont,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'When clients rate completed jobs and emergency dispatches, feedback and ratings will be recorded here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: tokens.mutedText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
