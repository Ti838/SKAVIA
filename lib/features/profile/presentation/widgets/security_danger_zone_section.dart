import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Danger Zone section for Account Deactivation and Erasure Requests.
class SecurityDangerZoneSection extends StatelessWidget {
  final VoidCallback onDeactivate;
  final VoidCallback onDelete;

  const SecurityDangerZoneSection({
    super.key,
    required this.onDeactivate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 36),
        Text(
          'Danger Zone',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.errorRed.withValues(alpha: 0.95),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Deactivating temporarily hides your account and pauses active notifications. Deleting requests irreversible erasure after a 30-day grace period.',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onDeactivate,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.warning),
              foregroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pause_circle_outline_rounded,
                  color: AppColors.warning,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Deactivate Account Temporarily',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onDelete,
            child: const Text(
              'Request Account Deletion',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
