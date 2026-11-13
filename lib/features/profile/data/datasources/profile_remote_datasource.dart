import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_connectivity_service.dart';
import '../../../../core/network/offline_sync_queue_manager.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';
import '../models/profile_stats_model.dart';
import '../models/user_address_model.dart';
import '../models/user_profile_model.dart';
import '../models/user_session_model.dart';
import 'profile_session_datasource.dart';

class ProfileRemoteDataSource {
  final SupabaseClient? _supabase;
  late final ProfileSessionDataSource _sessionDataSource;

  ProfileRemoteDataSource({SupabaseClient? supabase})
    : _supabase = supabase ?? tryGetSupabaseClient() {
    _sessionDataSource = ProfileSessionDataSource(supabase: _supabase);
  }

  static const String _profileCachePrefix = 'user_profile_cache_';
  static const String _statsCachePrefix = 'user_stats_cache_';

  /// Fetches user profile with offline local-first fallback and parallel customer/address hydration.
  Future<UserProfileModel> getProfile(
    String userId, {
    String? fallbackEmail,
    String? fallbackName,
    String? fallbackPhone,
    String? fallbackAvatarUrl,
  }) async {
    final cacheKey = '$_profileCachePrefix$userId';

    if (NetworkConnectivityService.instance.currentState ==
        NetworkQualityState.offline) {
      final cached = LocalCacheService.instance.get(cacheKey);
      if (cached is Map) {
        return UserProfileModel.fromJson(Map<String, dynamic>.from(cached));
      }
    }

    try {
      final client = _supabase;
      if (client != null) {
        Map<String, dynamic>? userData;
        try {
          userData = await client
              .from(DatabaseTables.users)
              .select()
              .eq('user_id', userId)
              .maybeSingle();
        } catch (_) {
          userData = await client
              .from(DatabaseTables.users)
              .select()
              .eq('id', userId)
              .maybeSingle();
        }

        if (userData != null) {
          final profileJson = Map<String, dynamic>.from(userData);

          final addressFuture = () async {
            try {
              final addressRows = await client
                  .from(DatabaseTables.userAddresses)
                  .select()
                  .eq('user_id', userId)
                  .order('is_default', ascending: false);
              return (addressRows as List)
                  .whereType<Map>()
                  .map(
                    (row) => UserAddressModel.fromJson(
                      Map<String, dynamic>.from(row),
                    ),
                  )
                  .map((a) => a.toJson())
                  .toList();
            } catch (_) {
              return <Map<String, dynamic>>[];
            }
          }();

          final customerFuture = () async {
            try {
              return await client
                  .from(DatabaseTables.customerProfiles)
                  .select(
                    'customer_type, company_name, trade_license, billing_address',
                  )
                  .eq('user_id', userId)
                  .maybeSingle();
            } catch (_) {
              return null;
            }
          }();

          final results = await Future.wait<dynamic>([
            addressFuture,
            customerFuture,
          ]);
          final addresses = results[0] as List<Map<String, dynamic>>;
          profileJson['saved_addresses'] = addresses;

          final custData = results[1] as Map<String, dynamic>?;
          if (custData != null) {
            profileJson['customer_type'] = custData['customer_type'];
            profileJson['company_name'] = custData['company_name'];
            profileJson['trade_license'] = custData['trade_license'];
            profileJson['billing_address'] = custData['billing_address'];
          }

          final profile = UserProfileModel.fromJson(profileJson);
          LocalCacheService.instance.put(
            cacheKey,
            profile.toJson(),
            ttl: const Duration(days: 7),
          );
          return profile;
        }
      }
    } catch (_) {
      final cached = LocalCacheService.instance.get(cacheKey);
      if (cached is Map) {
        return UserProfileModel.fromJson(Map<String, dynamic>.from(cached));
      }
    }

    final cached = LocalCacheService.instance.get(cacheKey);
    if (cached is Map) {
      return UserProfileModel.fromJson(Map<String, dynamic>.from(cached));
    }

    return UserProfileModel(
      id: userId,
      email: (fallbackEmail != null && fallbackEmail.isNotEmpty)
          ? fallbackEmail
          : 'user@skavia.com',
      phone: fallbackPhone,
      avatarUrl: fallbackAvatarUrl,
      fullName: (fallbackName != null && fallbackName.isNotEmpty)
          ? fallbackName
          : 'SKAVIA Member',
    );
  }

  /// Fetches real profile activity stats in parallel across requests, projects, and worker profile.
  Future<ProfileStatsModel> getProfileStats(String userId) async {
    final cacheKey = '$_statsCachePrefix$userId';
    if (NetworkConnectivityService.instance.currentState ==
        NetworkQualityState.offline) {
      final cached = LocalCacheService.instance.get(cacheKey);
      if (cached is Map) {
        return ProfileStatsModel.fromJson(Map<String, dynamic>.from(cached));
      }
    }

    try {
      final client = _supabase;
      if (client == null) {
        final cached = LocalCacheService.instance.get(cacheKey);
        if (cached is Map) {
          return ProfileStatsModel.fromJson(Map<String, dynamic>.from(cached));
        }
        return const ProfileStatsModel();
      }

      final clientReqFuture = () async {
        try {
          final rows = await client
              .from(DatabaseTables.serviceRequests)
              .select('service_request_id')
              .eq('client_id', userId);
          return (rows as List).length;
        } catch (_) {
          return 0;
        }
      }();

      final projFuture = () async {
        try {
          final rows = await client
              .from(DatabaseTables.projects)
              .select('project_id')
              .eq('client_id', userId);
          return (rows as List).length;
        } catch (_) {
          return 0;
        }
      }();

      final workerFuture = () async {
        try {
          final wp = await client
              .from(DatabaseTables.workerProfiles)
              .select('worker_profile_id, rating_average, completed_jobs')
              .eq('user_id', userId)
              .maybeSingle();
          if (wp == null) return null;
          int workerServices = 0;
          final wpId = wp['worker_profile_id']?.toString();
          if (wpId != null && wpId.isNotEmpty) {
            final workerReqs = await client
                .from(DatabaseTables.serviceRequests)
                .select('service_request_id')
                .eq('worker_profile_id', wpId);
            workerServices = (workerReqs as List).length;
          }
          return (
            ratingAverage:
                (wp['rating_average'] as num?)?.toDouble() ?? 5.0,
            completedJobs: (wp['completed_jobs'] as num?)?.toInt() ?? 0,
            workerServices: workerServices,
          );
        } catch (_) {
          return null;
        }
      }();

      final results = await Future.wait<dynamic>([
        clientReqFuture,
        projFuture,
        workerFuture,
      ]);

      int servicesCount = results[0] as int;
      final projectsCount = results[1] as int;
      double ratingAverage = 5.0;
      int completedJobs = 0;

      final workerMetrics =
          results[2]
              as ({
                double ratingAverage,
                int completedJobs,
                int workerServices,
              })?;
      if (workerMetrics != null) {
        ratingAverage = workerMetrics.ratingAverage;
        completedJobs = workerMetrics.completedJobs;
        if (workerMetrics.workerServices > servicesCount) {
          servicesCount = workerMetrics.workerServices;
        }
      }

      final stats = ProfileStatsModel(
        servicesCount: servicesCount,
        projectsCount: projectsCount,
        ratingAverage: ratingAverage,
        completedJobs: completedJobs,
      );
      LocalCacheService.instance.put(
        cacheKey,
        stats.toJson(),
        ttl: const Duration(days: 3),
      );
      return stats;
    } catch (_) {
      final cached = LocalCacheService.instance.get(cacheKey);
      if (cached is Map) {
        return ProfileStatsModel.fromJson(Map<String, dynamic>.from(cached));
      }
      return const ProfileStatsModel();
    }
  }

  /// Updates profile with offline queue fallback and syncs `customer_profiles`.
  Future<bool> updateProfile(UserProfileModel profile) async {
    final cacheKey = '$_profileCachePrefix${profile.id}';
    LocalCacheService.instance.put(
      cacheKey,
      profile.toJson(),
      ttl: const Duration(days: 7),
    );

    if (NetworkConnectivityService.instance.currentState ==
        NetworkQualityState.offline) {
      OfflineSyncQueueManager.instance.enqueue(
        operationType: 'update_profile',
        payload: profile.toJson(),
      );
      return true;
    }

    try {
      final client = _supabase;
      if (client != null) {
        final mergedPrivacy = Map<String, dynamic>.from(profile.privacySettings);
        final trimmedCover = profile.coverUrl?.trim();
        if (trimmedCover == null || trimmedCover.isEmpty) {
          mergedPrivacy.remove('cover_url');
        } else {
          mergedPrivacy['cover_url'] = trimmedCover;
        }

        final updatePayload = {
          'full_name': profile.fullName,
          'phone': profile.phone,
          'avatar_url': profile.avatarUrl,
          'cover_url': trimmedCover == null || trimmedCover.isEmpty ? null : trimmedCover,
          'date_of_birth': profile.dateOfBirth?.toIso8601String().split('T').first,
          'birthday_notifications_enabled':
              profile.birthdayNotificationsEnabled,
          'gender': profile.gender,
          'emergency_contact_name': profile.emergencyContactName,
          'emergency_contact_phone': profile.emergencyContactPhone,
          'preferred_language': profile.preferredLanguage,
          'timezone': profile.timezone,
          'privacy_settings': mergedPrivacy,
          'notification_preferences': profile.notificationPreferences,
          'profile_completion_percentage': profile.profileCompletionPercentage,
          'updated_at': DateTime.now().toIso8601String(),
        };

        try {
          await client
              .from(DatabaseTables.users)
              .update(updatePayload)
              .eq('user_id', profile.id);
        } catch (_) {
          // Graceful fallback if cover_url SQL migration has not yet been applied
          final fallbackPayload = Map<String, dynamic>.from(updatePayload)
            ..remove('cover_url');
          await client
              .from(DatabaseTables.users)
              .update(fallbackPayload)
              .eq('user_id', profile.id);
        }

        try {
          await client.from(DatabaseTables.customerProfiles).upsert({
            'user_id': profile.id,
            'customer_type': profile.customerType,
            'company_name': profile.companyName,
            'trade_license': profile.tradeLicense,
            'billing_address': profile.billingAddress,
          }, onConflict: 'user_id');
        } catch (custErr) {
          debugPrint('[ProfileRemoteDataSource] Customer profile sync: $custErr');
        }

        return true;
      }
    } catch (_) {
      OfflineSyncQueueManager.instance.enqueue(
        operationType: 'update_profile',
        payload: profile.toJson(),
      );
    }

    return true;
  }

  /// Saves or updates a delivery address and guarantees single default flag.
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
      final client = _supabase;
      if (client != null) {
        if (address.isDefault && address.userId.isNotEmpty) {
          await client
              .from(DatabaseTables.userAddresses)
              .update({'is_default': false})
              .eq('user_id', address.userId)
              .neq('id', address.id);
        }

        final payload = Map<String, dynamic>.from(address.toJson())
          ..removeWhere((key, value) => key == 'created_at' && value == null);
        payload['updated_at'] = DateTime.now().toIso8601String();

        await client.from(DatabaseTables.userAddresses).upsert(payload);
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
      final client = _supabase;
      if (client != null) {
        await client
            .from(DatabaseTables.userAddresses)
            .delete()
            .eq('id', addressId)
            .eq('user_id', userId);
        return true;
      }
    } catch (_) {}
    return true;
  }

  Future<String> getOrCreateDeviceId() =>
      _sessionDataSource.getOrCreateDeviceId();

  Future<UserSessionModel> registerCurrentSession(String userId) =>
      _sessionDataSource.registerCurrentSession(userId);

  Future<List<UserSessionModel>> getUserSessions(String userId) =>
      _sessionDataSource.getUserSessions(userId);

  Future<bool> revokeSession(String sessionId, String userId) =>
      _sessionDataSource.revokeSession(sessionId, userId);

  Future<bool> revokeOtherSessions(String userId, String currentDeviceId) =>
      _sessionDataSource.revokeOtherSessions(userId, currentDeviceId);

  /// Temporarily deactivates the user's account (`status = 'Deactivated'`).
  Future<bool> deactivateAccount(String userId, String reason) async {
    try {
      final client = _supabase;
      if (client != null) {
        await client
            .from(DatabaseTables.users)
            .update({
              'status': 'Deactivated',
              'account_status': 'deactivated',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId);

        await client.from(DatabaseTables.auditLogs).insert({
          'user_id': userId,
          'action': 'account_deactivated',
          'entity_type': 'user',
          'entity_id': userId,
          'details': {
            'reason': reason,
            'deactivated_at': DateTime.now().toIso8601String(),
          },
        });
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Request account deletion with 30-day grace period.
  Future<bool> requestAccountDeletion(String userId, String reason) async {
    try {
      final client = _supabase;
      if (client != null) {
        await client
            .from(DatabaseTables.users)
            .update({
              'account_status': 'pending_deletion',
              'status': 'Deactivated',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId);

        await client.from(DatabaseTables.auditLogs).insert({
          'user_id': userId,
          'action': 'account_deletion_requested',
          'entity_type': 'user',
          'entity_id': userId,
          'details': {
            'reason': reason,
            'requested_at': DateTime.now().toIso8601String(),
          },
        });
        return true;
      }
    } catch (_) {}
    return true;
  }
}
