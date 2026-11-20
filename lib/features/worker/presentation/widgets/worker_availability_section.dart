import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Active dispatch status toggle switch for worker profile.
class WorkerAvailabilitySection extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onAvailabilityChanged;

  const WorkerAvailabilitySection({
    super.key,
    required this.isAvailable,
    required this.onAvailabilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.subtleCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Dispatch Status',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  isAvailable
                      ? 'Ready for immediate job alerts'
                      : 'Currently off-duty',
                  style: TextStyle(fontSize: 12, color: tokens.secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: isAvailable,
            activeTrackColor: tokens.brandAccent,
            onChanged: onAvailabilityChanged,
          ),
        ],
      ),
    );
  }
}
