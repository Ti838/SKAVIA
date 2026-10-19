import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Tag chips selection section for highlighting specific strengths in a review.
class ReviewComplimentsSection extends StatelessWidget {
  final List<String> availableTags;
  final Set<String> selectedTags;
  final ValueChanged<String> onTagToggled;

  const ReviewComplimentsSection({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onTagToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'What stood out the most?',
            style: TextStyle(
              fontFamily: AppTypography.headingFont,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => onTagToggled(tag),
              selectedColor: AppColors.cardBlueTint,
              checkmarkColor: AppColors.primarySky,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primarySky : AppColors.textDark,
              ),
              backgroundColor: AppColors.sheetSurfaceSubtle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      isSelected ? AppColors.primarySky : AppColors.borderLight,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

