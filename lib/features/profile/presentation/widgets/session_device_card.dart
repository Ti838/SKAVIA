import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/user_session_model.dart';

class SessionDeviceCard extends StatelessWidget {
  final UserSessionModel session;
  final VoidCallback? onRevoke;

  const SessionDeviceCard({
    super.key,
    required this.session,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final isCurrent = session.isCurrentDevice;
    final isRevoked = session.isRevoked;

    final statusColor = isRevoked
        ? AppColors.errorRed
        : (isCurrent ? AppColors.success : AppColors.primarySky);
    final statusLabel = isRevoked
        ? 'REVOKED'
        : (isCurrent ? 'ACTIVE NOW' : 'SIGNED IN');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.success.withValues(alpha: 0.5)
              : tokens.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              session.deviceOs.toLowerCase() == 'web'
                  ? Icons.laptop_mac_rounded
                  : Icons.smartphone_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      isCurrent
                          ? '${session.deviceName} (This Device)'
                          : session.deviceName,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'OS: ${session.deviceOs} • v${session.appVersion} • ${Formatters.timeAgo(session.lastActiveAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!isCurrent && !isRevoked && onRevoke != null) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 30),
                        foregroundColor: AppColors.errorRed,
                      ),
                      onPressed: onRevoke,
                      child: const Text('Revoke Session'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

