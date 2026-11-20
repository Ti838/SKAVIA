import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';

/// Phase-specific progression action button or completion badge for ActiveJobScreen.
class ActiveJobActionButton extends StatelessWidget {
  final int jobPhase;
  final VoidCallback onNextPhase;

  const ActiveJobActionButton({
    super.key,
    required this.jobPhase,
    required this.onNextPhase,
  });

  @override
  Widget build(BuildContext context) {
    if (jobPhase == 0) {
      return SizedBox(
        width: double.infinity,
        child: AppButton(
          text: 'Heading to Location',
          onPressed: onNextPhase,
        ),
      );
    }

    if (jobPhase == 1) {
      return SizedBox(
        width: double.infinity,
        child: AppButton(
          text: 'Arrived at Site & Start Work',
          onPressed: onNextPhase,
        ),
      );
    }

    if (jobPhase == 2) {
      return SizedBox(
        width: double.infinity,
        child: AppButton(
          text: 'Complete Work (Enter Job OTP)',
          onPressed: onNextPhase,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Job Finished & Verified',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.success,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
