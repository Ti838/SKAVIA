import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_connectivity_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../data/tables/database_tables.dart';
import '../models/user_session_model.dart';

/// Handles device ID persistence, session registration, listing, and revocation.
class ProfileSessionDataSource {
  final SupabaseClient? supabase;

  ProfileSessionDataSource({this.supabase});

  static const String _sessionsCachePrefix = 'user_sessions_cache_';
  static const String _deviceIdStorageKey = 'skavia_device_id';

  Future<String> getOrCreateDeviceId() async {
    final storage = SecureStorageService();
    final existing = await storage.read(key: _deviceIdStorageKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final created = UuidUtil.generateUuidV4();
    await storage.write(key: _deviceIdStorageKey, value: created);
    return created;
  }

  Future<UserSessionModel> _buildCurrentDeviceSession(
    String userId,
    String deviceId,
  ) async {
    String version = '1.0.0+1';
    try {
      final info = await PackageInfo.fromPlatform();
      version = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    final os = kIsWeb ? 'web' : Platform.operatingSystem;
    final devName = kIsWeb
        ? 'SKAVIA Web Browser'
        : 'SKAVIA ${os[0].toUpperCase()}${os.substring(1)} Device';

    return UserSessionModel(
      id: UuidUtil.generateUuidV4(),
      userId: userId,
      deviceId: deviceId,
      deviceName: devName,
      deviceOs: os,
      appVersion: version,
      lastActiveAt: DateTime.now(),
      isRevoked: false,
      isCurrentDevice: true,
    );
  }

  Future<UserSessionModel> registerCurrentSession(String userId) async {
    final deviceId = await getOrCreateDeviceId();
    final current = await _buildCurrentDeviceSession(userId, deviceId);

    try {
      final client = supabase;
      if (client != null &&
          NetworkConnectivityService.instance.currentState !=
              NetworkQualityState.offline) {
        final existing = await client
            .from(DatabaseTables.userSessions)
            .select()
            .eq('user_id', userId)
            .eq('device_id', deviceId)
            .maybeSingle();

        if (existing != null) {
          await client
              .from(DatabaseTables.userSessions)
              .update({
                'device_name': current.deviceName,
                'device_os': current.deviceOs,
                'app_version': current.appVersion,
                'last_active_at': DateTime.now().toIso8601String(),
                'is_revoked': false,
              })
              .eq('id', existing['id'].toString());
          return UserSessionModel.fromJson(
            Map<String, dynamic>.from(existing),
            currentDeviceId: deviceId,
          ).copyWith(lastActiveAt: DateTime.now(), isRevoked: false);
        } else {
          final inserted = await client
              .from(DatabaseTables.userSessions)
              .insert(current.toJson())
              .select()
              .maybeSingle();
          if (inserted != null) {
            return UserSessionModel.fromJson(
              Map<String, dynamic>.from(inserted),
              currentDeviceId: deviceId,
            );
          }
        }
      }
    } catch (_) {}

    return current;
  }

  Future<List<UserSessionModel>> getUserSessions(String userId) async {
    final deviceId = await getOrCreateDeviceId();
    final cacheKey = '$_sessionsCachePrefix$userId';

    try {
      final client = supabase;
      if (client != null &&
          NetworkConnectivityService.instance.currentState !=
              NetworkQualityState.offline) {
        final rows = await client
            .from(DatabaseTables.userSessions)
            .select()
            .eq('user_id', userId)
            .order('last_active_at', ascending: false);

        final sessions = (rows as List)
            .whereType<Map>()
            .map(
              (r) => UserSessionModel.fromJson(
                Map<String, dynamic>.from(r),
                currentDeviceId: deviceId,
              ),
            )
            .toList();

        if (!sessions.any((s) => s.deviceId == deviceId)) {
          final registered = await registerCurrentSession(userId);
          sessions.insert(0, registered);
        }

        LocalCacheService.instance.put(
          cacheKey,
          sessions.map((s) => s.toJson()).toList(),
          ttl: const Duration(days: 7),
        );
        return sessions;
      }
    } catch (_) {}

    final cached = LocalCacheService.instance.get(cacheKey);
    if (cached is List && cached.isNotEmpty) {
      return cached
          .whereType<Map>()
          .map(
            (r) => UserSessionModel.fromJson(
              Map<String, dynamic>.from(r),
              currentDeviceId: deviceId,
            ),
          )
          .toList();
    }

    final fallback = await _buildCurrentDeviceSession(userId, deviceId);
    LocalCacheService.instance.put(
      cacheKey,
      [fallback.toJson()],
      ttl: const Duration(days: 7),
    );
    return [fallback];
  }

  Future<bool> revokeSession(String sessionId, String userId) async {
    try {
      final client = supabase;
      if (client != null) {
        await client
            .from(DatabaseTables.userSessions)
            .update({'is_revoked': true})
            .eq('id', sessionId)
            .eq('user_id', userId);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> revokeOtherSessions(
    String userId,
    String currentDeviceId,
  ) async {
    try {
      final client = supabase;
      if (client != null) {
        await client
            .from(DatabaseTables.userSessions)
            .update({'is_revoked': true})
            .eq('user_id', userId)
            .neq('device_id', currentDeviceId);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

