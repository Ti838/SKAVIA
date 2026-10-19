import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../profile/domain/services/profile_completion_engine.dart';
import '../../data/models/app_notification_model.dart';

class NotificationCenterController extends ChangeNotifier {
  static final NotificationCenterController instance =
      NotificationCenterController._internal();
  factory NotificationCenterController() => instance;
  NotificationCenterController._internal();

  static const String _cacheKey = 'skavia_user_notifications_cache';

  final List<AppNotificationModel> _notifications = [];
  final Set<String> _seenDedupKeys = {};
  final bool _isLoading = false;

  List<AppNotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;

  void initialize(String userId) {
    _loadFromCache();
    if (_notifications.isEmpty) {
      _seedDefaultNotifications(userId);
    }
  }

  void _loadFromCache() {
    final raw = LocalCacheService.instance.get(_cacheKey);
    if (raw != null && raw is List) {
      _notifications.clear();
      _seenDedupKeys.clear();
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          final notif = AppNotificationModel.fromJson(item);
          _notifications.add(notif);
          if (notif.dedupKey != null) {
            _seenDedupKeys.add(notif.dedupKey!);
          }
        }
      }
      notifyListeners();
    }
  }

  void _saveToCache() {
    final list = _notifications.map((e) => e.toJson()).toList();
    LocalCacheService.instance.put(_cacheKey, jsonEncode(list));
  }

  /// Adds a notification with duplicate prevention.
  bool addNotification(AppNotificationModel notification) {
    if (notification.dedupKey != null &&
        _seenDedupKeys.contains(notification.dedupKey)) {
      return false; // Prevent duplicates
    }

    if (notification.dedupKey != null) {
      _seenDedupKeys.add(notification.dedupKey!);
    }
    _notifications.insert(0, notification);
    _saveToCache();
    notifyListeners();
    return true;
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _saveToCache();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _saveToCache();
    notifyListeners();
  }

  void dismiss(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _saveToCache();
    notifyListeners();
  }

  /// Checks if today is the user's birthday and triggers a celebratory notification.
  void checkAndTriggerBirthdayGift(UserProfileModel profile) {
    if (!profile.birthdayNotificationsEnabled || profile.dateOfBirth == null) {
      return;
    }

    final now = DateTime.now();
    final dob = profile.dateOfBirth!;
    if (dob.month == now.month && dob.day == now.day) {
      final dedupKey = 'birthday_${profile.id}_${now.year}';
      addNotification(AppNotificationModel(
        id: UuidUtil.generateUuidV4(),
        userId: profile.id,
        dedupKey: dedupKey,
        title: '🎂 Happy Birthday from SKAVIA!',
        body:
            'Wishing you a fantastic day! Enjoy a 20% discount on any SKAVIA Technical or Home repair this week. Promo code: BDAY${now.year}.',
        category: 'birthday',
        createdAt: now,
      ));
    }
  }

  /// Checks if profile is incomplete and generates a contextual nudge.
  void checkAndTriggerProfileReminder(
    UserProfileModel profile,
    ProfileCompletionResult result,
  ) {
    if (result.isComplete || result.nextRecommendedAction == null) return;

    final action = result.nextRecommendedAction!;
    final dedupKey = 'profile_reminder_${profile.id}_${action.key}';

    addNotification(AppNotificationModel(
      id: UuidUtil.generateUuidV4(),
      userId: profile.id,
      dedupKey: dedupKey,
      title: 'Complete Profile: Add ${action.label}',
      body:
          'Your profile is ${result.percentage}% complete. ${action.reason}.',
      category: 'profile',
      actionRoute: action.actionRoute,
      createdAt: DateTime.now(),
    ));
  }

  void _seedDefaultNotifications(String userId) {
    addNotification(AppNotificationModel(
      id: UuidUtil.generateUuidV4(),
      userId: userId,
      dedupKey: 'welcome_skavia_$userId',
      title: 'Welcome to SKAVIA Enterprise Platform',
      body:
          'Every Skill. Every Opportunity. All your home repairs and corporate turnkey projects are guaranteed with single-company accountability.',
      category: 'general',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ));
  }
}
