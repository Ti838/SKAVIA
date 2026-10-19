import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../../shared/dialogs/notification_permission_sheet.dart';

/// Real-Time Notifications sheet for Dashboard Notification Bell
/// Fully backed by Supabase `notifications` table persistence (SRS 3.1.N).
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
  bool _isLoading = true;
  bool _hasNotificationPermission = true;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await NotificationService.instance.checkPermissionStatus();
    if (mounted) {
      setState(() {
        _hasNotificationPermission = status.isGranted;
      });
    }
  }

  String get _currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  Future<void> _fetchNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    final client = Supabase.instance.client;

    try {
      final res = await client
          .from(DatabaseTables.notifications)
          .select(
            'notification_id, user_id, title, body, type, is_read, created_at',
          )
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(20);

      final list = List<Map<String, dynamic>>.from(res as List);

      // If user has no notifications in DB yet, seed real onboarding records for them
      if (list.isEmpty && _currentUserId != 'guest_user') {
        final now = DateTime.now().toIso8601String();
        final defaults = [
          {
            'notification_id': UuidUtil.generateV4(),
            'user_id': _currentUserId,
            'title': 'SKAVIA Escrow Shield Active',
            'body': 'Your payments and bookings are protected by 100% Escrow and OTP release.',
            'type': 'escrow',
            'is_read': false,
            'created_at': now,
          },
          {
            'notification_id': UuidUtil.generateV4(),
            'user_id': _currentUserId,
            'title': 'Dhaka Vector Radar Online',
            'body':
                'GPS radar is actively tracking verified specialists in ${widget.locationZone}.',
            'type': 'radar',
            'is_read': false,
            'created_at': now,
          },
          {
            'notification_id': UuidUtil.generateV4(),
            'user_id': _currentUserId,
            'title': 'Welcome to SKAVIA Verified',
            'body': 'Your account is active. Connect with certified trades or build enterprise teams.',
            'type': 'system',
            'is_read': false,
            'created_at': now,
          },
        ];

        try {
          await client.from(DatabaseTables.notifications).insert(defaults);
          list.addAll(defaults);
        } catch (e) {
          debugPrint('[Notifications insert defaults notice]: $e');
          list.addAll(defaults);
        }
      }

      if (mounted) {
        setState(() {
          _notifications = list;
          _unreadCount = list.where((n) => n['is_read'] != true).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Notifications fetch notice]: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (final n in _notifications) {
        n['is_read'] = true;
      }
      _unreadCount = 0;
    });

    widget.onMarkAllRead();

    // Persist real update to Supabase
    try {
      await Supabase.instance.client
          .from(DatabaseTables.notifications)
          .update({'is_read': true})
          .eq('user_id', _currentUserId);
    } catch (e) {
      debugPrint('[Notifications markAllAsRead Supabase notice]: $e');
    }
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'escrow':
        return Icons.shield_rounded;
      case 'radar':
        return Icons.radar_rounded;
      case 'job':
        return Icons.work_outline_rounded;
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.verified_user_rounded;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'escrow':
        return AppColors.primaryRoyal;
      case 'radar':
        return AppColors.successGreen;
      case 'job':
        return AppColors.accentCoral;
      case 'chat':
        return AppColors.primarySky;
      default:
        return AppColors.accentPeach;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                  color: colorScheme.outlineVariant,
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
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$_unreadCount New',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                      tooltip: 'Test Alert Chime',
                      onPressed: () async {
                        await NotificationService.instance.playInAppNotificationSound();
                      },
                    ),
                    if (_unreadCount > 0)
                      TextButton(
                        onPressed: _markAllAsRead,
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
              ],
            ),
            if (!_hasNotificationPermission) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  await NotificationPermissionSheet.show(context);
                  _checkPermission();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentPeachSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentPeach.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 18, color: AppColors.accentCoral),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Alerts & sounds disabled. Tap to enable notifications.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_notifications.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 36,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updates on jobs, radar, and security will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._notifications.map((n) {
                final isRead = n['is_read'] == true;
                final type = n['type'] as String?;
                final color = _getColorForType(type);
                final icon = _getIconForType(type);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRead
                        ? colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          )
                        : colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isRead
                          ? colorScheme.outlineVariant
                          : AppColors.primarySky.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    n['title'] as String? ?? 'Notification',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isRead
                                          ? FontWeight.w700
                                          : FontWeight.w800,
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 7,
                                    height: 7,
                                    margin: const EdgeInsets.only(left: 6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primarySky,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              n['body'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colorScheme.onSurfaceVariant,
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
