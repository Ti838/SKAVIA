import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../profile/domain/services/profile_completion_engine.dart';
import '../../data/models/app_notification_model.dart';

class NotificationCenterController extends ChangeNotifier {
  static final NotificationCenterController instance =
      NotificationCenterController._internal();
  factory NotificationCenterController() => instance;
  NotificationCenterController._internal();

  static const String _cachePrefix = 'skavia_user_notifications_cache_';

  final List<AppNotificationModel> _notifications = [];
  final Set<String> _seenDedupKeys = {};
  String? _activeUserId;
  bool _isLoading = false;

  List<AppNotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get activeUserId => _activeUserId;

  String get _cacheKey => '$_cachePrefix${_activeUserId ?? 'guest'}';

  void initialize(String userId, {bool forceRefresh = false}) {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) return;
    if (!forceRefresh && _activeUserId == trimmed && _notifications.isNotEmpty) {
      return;
    }

    _activeUserId = trimmed;
    _notifications.clear();
    _seenDedupKeys.clear();
    _loadFromCache();
    if (_notifications.isEmpty) {
      _seedDefaultNotifications(trimmed);
    }
    syncFromBackend(trimmed);
  }

  /// Resets in-memory notification state when signing out or switching accounts.
  void clearSession() {
    _activeUserId = null;
    _notifications.clear();
    _seenDedupKeys.clear();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> syncFromBackend([String? userId]) async {
    final targetUserId = userId ?? _activeUserId;
    if (targetUserId == null || targetUserId.isEmpty) return;
    final client = tryGetSupabaseClient();
    if (client == null) return;
    try {
      if (FirebaseAuth.instance.currentUser == null &&
          client.auth.currentUser == null) {
        return;
      }
    } catch (_) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      Future<List<AppNotificationModel>> fetchPrimary() async {
        try {
          final rows = await client
              .from(DatabaseTables.userNotifications)
              .select()
              .eq('user_id', targetUserId)
              .order('created_at', ascending: false)
              .limit(40);
          return (rows as List)
              .map((row) =>
                  AppNotificationModel.fromJson(Map<String, dynamic>.from(row)))
              .toList();
        } catch (_) {
          return const [];
        }
      }

      Future<List<AppNotificationModel>> fetchLegacy() async {
        try {
          final legacyRows = await client
              .from(DatabaseTables.notifications)
              .select()
              .eq('user_id', targetUserId)
              .order('created_at', ascending: false)
              .limit(30);
          return (legacyRows as List).map((row) {
            final map = Map<String, dynamic>.from(row);
            return AppNotificationModel(
              id: map['notification_id']?.toString() ?? UuidUtil.generateUuidV4(),
              userId: map['user_id']?.toString() ?? targetUserId,
              dedupKey: map['notification_id'] != null
                  ? 'legacy_${map['notification_id']}'
                  : null,
              title: map['title']?.toString() ?? 'Notification',
              body: map['body']?.toString() ?? '',
              category: map['type']?.toString() ?? 'general',
              isRead: map['is_read'] as bool? ?? false,
              createdAt: map['created_at'] != null
                  ? DateTime.tryParse(map['created_at'].toString()) ??
                      DateTime.now()
                  : DateTime.now(),
            );
          }).toList();
        } catch (_) {
          return const [];
        }
      }

      final results = await Future.wait([fetchPrimary(), fetchLegacy()]);
      final fetched = [...results[0], ...results[1]];

      if (fetched.isNotEmpty) {
        final existingIds = _notifications.map((n) => n.id).toSet();
        bool added = false;
        for (final item in fetched) {
          final existsByKey = item.dedupKey != null &&
              _seenDedupKeys.contains(item.dedupKey);
          if (!existingIds.contains(item.id) && !existsByKey) {
            existingIds.add(item.id);
            if (item.dedupKey != null) {
              _seenDedupKeys.add(item.dedupKey!);
            }
            _notifications.add(item);
            added = true;
          }
        }
        if (added) {
          _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _saveToCache();
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadFromCache() {
    final raw = LocalCacheService.instance.get(_cacheKey);
    final List<dynamic>? list = raw is List
        ? raw
        : (raw is String ? _tryDecodeList(raw) : null);
    if (list != null) {
      _notifications.clear();
      _seenDedupKeys.clear();
      for (final item in list) {
        if (item is Map) {
          final notif = AppNotificationModel.fromJson(
            Map<String, dynamic>.from(item),
          );
          _notifications.add(notif);
          if (notif.dedupKey != null) {
            _seenDedupKeys.add(notif.dedupKey!);
          }
        }
      }
      notifyListeners();
    }
  }

  List<dynamic>? _tryDecodeList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  void _saveToCache() {
    final list = _notifications.map((e) => e.toJson()).toList();
    LocalCacheService.instance.put(_cacheKey, list);
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
      _syncReadStatusRemote(id);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _saveToCache();
    notifyListeners();
    _syncAllReadRemote();
  }

  void dismiss(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _saveToCache();
    notifyListeners();
  }

  Future<void> _syncReadStatusRemote(String id) async {
    final client = tryGetSupabaseClient();
    if (client == null || _activeUserId == null) return;
    try {
      await client
          .from(DatabaseTables.userNotifications)
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .eq('user_id', _activeUserId!);
    } catch (_) {}
    try {
      await client
          .from(DatabaseTables.notifications)
          .update({'is_read': true})
          .eq('notification_id', id)
          .eq('user_id', _activeUserId!);
    } catch (_) {}
  }

  Future<void> _syncAllReadRemote() async {
    final client = tryGetSupabaseClient();
    if (client == null || _activeUserId == null) return;
    try {
      await client
          .from(DatabaseTables.userNotifications)
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', _activeUserId!);
    } catch (_) {}
    try {
      await client
          .from(DatabaseTables.notifications)
          .update({'is_read': true})
          .eq('user_id', _activeUserId!);
    } catch (_) {}
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
