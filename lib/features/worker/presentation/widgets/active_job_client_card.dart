import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

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
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jobTitle,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: tokens.brandAccent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Client: $clientName',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: tokens.brandAccent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Divider(height: 24, color: tokens.border),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackButtons =
                  constraints.maxWidth < 290 || textScale > 1.3;

              final callBtn = OutlinedButton.icon(
                onPressed: onCallClient,
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('Call Client'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.brandAccent,
                  side: BorderSide(color: tokens.brandAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );

              final chatBtn = OutlinedButton.icon(
                onPressed: onChatClient,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('In-App Chat'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.brandAccent,
                  side: BorderSide(color: tokens.brandAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );

              if (stackButtons) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [callBtn, const SizedBox(height: 8), chatBtn],
                );
              }
              return Row(
                children: [
                  Expanded(child: callBtn),
                  const SizedBox(width: 12),
                  Expanded(child: chatBtn),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
