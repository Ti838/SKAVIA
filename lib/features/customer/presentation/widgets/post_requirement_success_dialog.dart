import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../screens/candidate_matches_screen.dart';

class PostRequirementSuccessDialog extends StatelessWidget {
  final String title;
  final double budget;
  final String selectedLocation;
  final String requirementType;

  const PostRequirementSuccessDialog({
    super.key,
    required this.title,
    required this.budget,
    required this.selectedLocation,
    required this.requirementType,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required double budget,
    required String selectedLocation,
    required String requirementType,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PostRequirementSuccessDialog(
        title: title,
        budget: budget,
        selectedLocation: selectedLocation,
        requirementType: requirementType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.statusActive.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.statusActive,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Job Posted Successfully',
            style: TextStyle(
              fontFamily: AppTypography.headingFont,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your requirement for "$title" has been posted across the SKAVIA network.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBlueTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryRoyal,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Algorithmic match engine is calculating top-rated technicians in your area...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryRoyal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text(
            'Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primarySky,
            shape: const StadiumBorder(),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CandidateMatchesScreen(
                  requirementId: 'req_${DateTime.now().millisecondsSinceEpoch}',
                  requirementTitle: title,
                  requirementZone: selectedLocation,
                  budget: budget,
                  isComplexProject: requirementType == 'Complex',
                ),
              ),
            );
          },
          child: const Text(
            'View Top Matches',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
