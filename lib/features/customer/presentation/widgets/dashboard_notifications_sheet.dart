import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Notifications sheet for the Dashboard Notification Bell
class DashboardNotificationsSheet extends StatefulWidget {
  final String locationZone;
  final bool hasUnread;
  final VoidCallback onMarkAllRead;

  const DashboardNotificationsSheet({
    super.key,
    required this.locationZone,
    required this.hasUnread,
    required this.onMarkAllRead,
  });

  static void show(
    BuildContext context, {
    required String locationZone,
    required bool hasUnread,
    required VoidCallback onMarkAllRead,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DashboardNotificationsSheet(
        locationZone: locationZone,
        hasUnread: hasUnread,
        onMarkAllRead: onMarkAllRead,
      ),
    );
  }

  @override
  State<DashboardNotificationsSheet> createState() =>
      _DashboardNotificationsSheetState();
}

class _DashboardNotificationsSheetState
    extends State<DashboardNotificationsSheet> {
  late bool _unread;

  @override
  void initState() {
    super.initState();
    _unread = widget.hasUnread;
  }

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'id': 'notif_1',
        'title': 'SKAVIA Escrow Shield Active',
        'body': 'Your transactions and bookings are protected by 100% Escrow and OTP release.',
        'time': 'Just now',
        'icon': Icons.shield_rounded,
        'color': AppColors.primaryRoyal,
      },
      {
        'id': 'notif_2',
        'title': 'Dhaka Vector Radar Online',
        'body':
            'GPS radar is actively tracking 18+ verified technicians in ${widget.locationZone}.',
        'time': '1h ago',
        'icon': Icons.radar_rounded,
        'color': AppColors.successGreen,
      },
      {
        'id': 'notif_3',
        'title': 'Welcome to SKAVIA Platform',
        'body': 'Your account is verified. You can book skilled trades or turnkey business teams.',
        'time': 'Yesterday',
        'icon': Icons.verified_user_rounded,
        'color': AppColors.accentPeach,
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_unread)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '3 New',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_unread)
                  TextButton(
                    onPressed: () {
                      setState(() => _unread = false);
                      widget.onMarkAllRead();
                    },
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryRoyal,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ...notifications.map((n) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sheetSurfaceSubtle,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (n['color'] as Color).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        n['icon'] as IconData,
                        color: n['color'] as Color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                n['title'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                n['time'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            n['body'] as String,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMedium,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
