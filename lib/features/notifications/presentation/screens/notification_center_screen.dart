import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../controllers/notification_center_controller.dart';
import '../../data/models/app_notification_model.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _controller = NotificationCenterController.instance;
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final all = _controller.notifications;
        final filtered = all.where((n) {
          if (_selectedFilter == 'Unread') return !n.isRead;
          if (_selectedFilter == 'Bookings') {
            return n.category == 'booking' || n.category == 'urgent';
          }
          if (_selectedFilter == 'Gifts & Profile') {
            return n.category == 'birthday' || n.category == 'profile';
          }
          return true;
        }).toList();

        return Scaffold(
          appBar: AppAppBar(
            title: 'Notifications',
            actions: [
              if (_controller.unreadCount > 0)
                TextButton(
                  onPressed: () => _controller.markAllAsRead(),
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(
                      color: AppColors.primaryRoyal,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Filter chips bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      'All',
                      'Unread',
                      'Bookings',
                      'Gifts & Profile',
                    ].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      int? count;
                      if (filter == 'Unread') {
                        count = _controller.unreadCount;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            count != null && count > 0
                                ? '$filter ($count)'
                                : filter,
                          ),
                          selected: isSelected,
                          selectedColor:
                              AppColors.primaryRoyal.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primaryRoyal
                                : colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedFilter = filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 1),

                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 56,
                                color: colorScheme.outlineVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No Notifications',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You are all caught up!',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final notif = filtered[index];
                            return _buildNotificationCard(
                              context,
                              notif,
                              colorScheme,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotificationModel notif,
    ColorScheme colorScheme,
  ) {
    IconData icon = Icons.notifications_rounded;
    Color iconColor = AppColors.primaryRoyal;

    switch (notif.category) {
      case 'birthday':
        icon = Icons.cake_rounded;
        iconColor = Colors.pinkAccent;
        break;
      case 'profile':
        icon = Icons.person_pin_rounded;
        iconColor = AppColors.primarySky;
        break;
      case 'urgent':
        icon = Icons.warning_rounded;
        iconColor = AppColors.errorRed;
        break;
      case 'booking':
        icon = Icons.handyman_rounded;
        iconColor = AppColors.success;
        break;
      case 'security':
        icon = Icons.security_rounded;
        iconColor = AppColors.warning;
        break;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _controller.dismiss(notif.id),
      child: InkWell(
        onTap: () {
          _controller.markAsRead(notif.id);
          if (notif.actionRoute != null) {
            Navigator.pushNamed(context, notif.actionRoute!);
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead
                ? colorScheme.surface
                : AppColors.primaryRoyal.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notif.isRead
                  ? colorScheme.outlineVariant
                  : AppColors.primaryRoyal.withValues(alpha: 0.3),
              width: notif.isRead ? 1 : 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
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
                            notif.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notif.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryRoyal,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('dd MMM, hh:mm a').format(notif.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
