import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_connectivity_service.dart';
import '../../../../core/network/offline_sync_queue_manager.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../data/tables/database_tables.dart';
import '../models/user_address_model.dart';
import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  final SupabaseClient? _supabase;

  ProfileRemoteDataSource({SupabaseClient? supabase})
      : _supabase = supabase ??
            (Supabase.instance.isInitialized ? Supabase.instance.client : null);

  static const String _profileCachePrefix = 'user_profile_cache_';

  /// Fetches user profile with offline local-first fallback.
  Future<UserProfileModel> getProfile(String userId) async {
    final cacheKey = '$_profileCachePrefix$userId';

    // If offline, return cached profile immediately
    if (NetworkConnectivityService.instance.currentState ==
        NetworkQualityState.offline) {
      final cached = LocalCacheService.instance.get(cacheKey);
      if (cached != null && cached is Map<String, dynamic>) {
        return UserProfileModel.fromJson(cached);
      }
    }

    try {
      if (_supabase != null) {
        Map<String, dynamic>? userData;
        try {
          userData = await _supabase
              .from(DatabaseTables.users)
              .select()
              .eq('user_id', userId)
              .maybeSingle();
        } catch (_) {
          userData = await _supabase
              .from(DatabaseTables.users)
              .select()
              .eq('id', userId)
              .maybeSingle();
        }

        if (userData != null) {
          // Fetch addresses
          final addressRows = await _supabase
              .from(DatabaseTables.userAddresses)
              .select()
              .eq('user_id', userId);

          final addresses = (addressRows as List)
              .map((row) => UserAddressModel.fromJson(row))
              .toList();

          final profileJson = Map<String, dynamic>.from(userData);
          profileJson['saved_addresses'] =
              addresses.map((a) => a.toJson()).toList();

          final profile = UserProfileModel.fromJson(profileJson);
          // Update cache
          LocalCacheService.instance
              .put(cacheKey, profile.toJson(), ttl: const Duration(days: 7));
          return profile;
        }
      }
    } catch (_) {
      // Fallback to cache on network failure
      final cached = LocalCacheService.instance.get(cacheKey);
      if (cached != null && cached is Map<String, dynamic>) {
        return UserProfileModel.fromJson(cached);
      }
    }

    // Default fallback
    return UserProfileModel(
      id: userId,
      email: 'user@skavia.com',
      fullName: 'SKAVIA Member',
    );
  }

  /// Updates profile with offline queue fallback.
  Future<bool> updateProfile(UserProfileModel profile) async {
    final cacheKey = '$_profileCachePrefix${profile.id}';
    LocalCacheService.instance
        .put(cacheKey, profile.toJson(), ttl: const Duration(days: 7));

    if (NetworkConnectivityService.instance.currentState ==
        NetworkQualityState.offline) {
      // Enqueue for background sync
      OfflineSyncQueueManager.instance.enqueue(
        operationType: 'update_profile',
        payload: profile.toJson(),
      );
      return true;
    }

    try {
      if (_supabase != null) {
        final updatePayload = {
          'full_name': profile.fullName,
          'phone': profile.phone,
          'avatar_url': profile.avatarUrl,
          'date_of_birth': profile.dateOfBirth?.toIso8601String(),
          'birthday_notifications_enabled':
              profile.birthdayNotificationsEnabled,
          'gender': profile.gender,
          'emergency_contact_name': profile.emergencyContactName,
          'emergency_contact_phone': profile.emergencyContactPhone,
          'preferred_language': profile.preferredLanguage,
          'timezone': profile.timezone,
          'privacy_settings': profile.privacySettings,
          'notification_preferences': profile.notificationPreferences,
          'profile_completion_percentage': profile.profileCompletionPercentage,
        };

        try {
          await _supabase
              .from(DatabaseTables.users)
              .update(updatePayload)
              .eq('user_id', profile.id);
        } catch (_) {
          await _supabase
              .from(DatabaseTables.users)
              .update(updatePayload)
              .eq('id', profile.id);
        }

        return true;
      }
    } catch (e) {
      // Enqueue for background sync on network error
      OfflineSyncQueueManager.instance.enqueue(
        operationType: 'update_profile',
        payload: profile.toJson(),
      );
    }

    return true;
  }

  /// Saves or updates a delivery address.
  Future<bool> saveAddress(UserAddressModel address) async {
    if (NetworkConnectivityService.instance.currentState ==
        NetworkQualityState.offline) {
      OfflineSyncQueueManager.instance.enqueue(
        operationType: 'save_address',
        payload: address.toJson(),
      );
      return true;
    }

    try {
      if (_supabase != null) {
        await _supabase
            .from(DatabaseTables.userAddresses)
            .upsert(address.toJson());
        return true;
      }
    } catch (_) {
      OfflineSyncQueueManager.instance.enqueue(
        operationType: 'save_address',
        payload: address.toJson(),
      );
    }
    return true;
  }

  /// Deletes a saved address.
  Future<bool> deleteAddress(String addressId, String userId) async {
    try {
      if (_supabase != null) {
        await _supabase
            .from(DatabaseTables.userAddresses)
            .delete()
            .eq('id', addressId)
            .eq('user_id', userId);
        return true;
      }
    } catch (_) {}
    return true;
  }

  /// Request account deactivation or deletion with 30-day grace period.
  Future<bool> requestAccountDeletion(String userId, String reason) async {
    try {
      if (_supabase != null) {
        await _supabase.from(DatabaseTables.users).update({
          'account_status': 'pending_deletion',
        }).eq('id', userId);

        // Record in audit log
        await _supabase.from(DatabaseTables.auditLogs).insert({
          'user_id': userId,
          'action': 'account_deletion_requested',
          'details': jsonEncode({'reason': reason, 'requested_at': DateTime.now().toIso8601String()}),
        });
        return true;
      }
    } catch (_) {}
    return true;
  }
}

