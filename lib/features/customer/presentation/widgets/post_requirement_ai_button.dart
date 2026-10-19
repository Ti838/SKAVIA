import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Auto-diagnose with SKAVIA AI action button with loading spinner.
class PostRequirementAiButton extends StatelessWidget {
  final bool isDiagnosing;
  final VoidCallback onDiagnose;

  const PostRequirementAiButton({
    super.key,
    required this.isDiagnosing,
    required this.onDiagnose,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: isDiagnosing ? null : onDiagnose,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryRoyal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primarySky.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDiagnosing)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              else
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryRoyal,
                  size: 14,
                ),
              const SizedBox(width: 6),
              const Text(
                'Auto-Diagnose with SKAVIA AI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRoyal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

