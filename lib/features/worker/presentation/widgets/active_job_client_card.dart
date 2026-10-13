import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';

/// Card showing client info, location, and communication buttons on the active job dispatch screen
class ActiveJobClientCard extends StatelessWidget {
  final String jobTitle;
  final String clientName;
  final String location;
  final VoidCallback onCallClient;
  final VoidCallback onChatClient;

  const ActiveJobClientCard({
    super.key,
    required this.jobTitle,
    required this.clientName,
    required this.location,
    required this.onCallClient,
    required this.onChatClient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jobTitle,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Client: $clientName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.accent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Communication action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCallClient,
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call Client'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onChatClient,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('In-App Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
