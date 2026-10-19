import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Interactive 5-star rating selector with descriptive feedback labels.
class ReviewRatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;

  const ReviewRatingSelector({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  String _getRatingLabel(int r) {
    switch (r) {
      case 5:
        return 'Outstanding & Flawless';
      case 4:
        return 'Very Good & Professional';
      case 3:
        return 'Satisfactory Work';
      case 2:
        return 'Needs Improvement';
      case 1:
        return 'Unsatisfactory Experience';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'How was your service experience?',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return GestureDetector(
              onTap: () => onRatingChanged(starValue),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  starValue <= rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 42,
                  color: starValue <= rating
                      ? AppColors.warningAmber
                      : AppColors.textMuted,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _getRatingLabel(rating),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primarySky,
          ),
        ),
      ],
    );
  }
}

