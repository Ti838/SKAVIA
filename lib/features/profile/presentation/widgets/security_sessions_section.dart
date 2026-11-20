import 'package:flutter/material.dart';

import '../controllers/profile_controller.dart';
import 'session_device_card.dart';

/// Active devices and sessions management section for PrivacySecurityScreen.
class SecuritySessionsSection extends StatelessWidget {
  final ProfileController controller;
  final bool isRevokingAll;
  final VoidCallback onRevokeAllOtherSessions;

  const SecuritySessionsSection({
    super.key,
    required this.controller,
    required this.isRevokingAll,
    required this.onRevokeAllOtherSessions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sessions = controller.sessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Active Devices & Sessions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: controller.isSessionsLoading
                  ? null
                  : () => controller.loadSessions(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (controller.isSessionsLoading && sessions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          ...sessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SessionDeviceCard(
                session: session,
                onRevoke: () => controller.revokeSession(session.id),
              ),
            ),
          ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isRevokingAll ? null : onRevokeAllOtherSessions,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isRevokingAll)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.logout, size: 16),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Log Out of All Other Devices',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
