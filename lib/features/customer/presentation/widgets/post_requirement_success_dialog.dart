import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../screens/candidate_matches_screen.dart';

class PostRequirementSuccessDialog extends StatelessWidget {
  final String? requirementId;
  final String title;
  final double budget;
  final String selectedLocation;
  final String requirementType;

  const PostRequirementSuccessDialog({
    super.key,
    this.requirementId,
    required this.title,
    required this.budget,
    required this.selectedLocation,
    required this.requirementType,
  });

  static Future<void> show(
    BuildContext context, {
    String? requirementId,
    required String title,
    required double budget,
    required String selectedLocation,
    required String requirementType,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PostRequirementSuccessDialog(
        requirementId: requirementId,
        title: title,
        budget: budget,
        selectedLocation: selectedLocation,
        requirementType: requirementType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return AlertDialog(
      scrollable: true,
      backgroundColor: tokens.cardBg,
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
          Expanded(
            child: Text(
              'Job Posted Successfully',
              style: TextStyle(
                fontFamily: AppTypography.headingFont,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
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
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tokens.softBlueBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: tokens.brandAccent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Algorithmic match engine is calculating top-rated technicians in your area...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: tokens.brandAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowButtonSpacing: 8,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Text(
            'Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primarySky,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: const StadiumBorder(),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CandidateMatchesScreen(
                  requirementId:
                      (requirementId != null && requirementId!.isNotEmpty)
                          ? requirementId!
                          : 'req_${DateTime.now().millisecondsSinceEpoch}',
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
