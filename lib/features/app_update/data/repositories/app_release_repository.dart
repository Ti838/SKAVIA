import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../app/config/app_config.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../models/app_release_model.dart';

class AppReleaseRepository {
  static const String _cachedEvalKey = 'skavia_app_update_last_eval_v1';

  final http.Client _client;
  final String _baseOrigin;

  AppReleaseRepository({
    http.Client? client,
    String? baseOrigin,
  })  : _client = client ?? http.Client(),
        _baseOrigin = (baseOrigin ?? AppConfig.releaseApiBaseUrl)
            .trim()
            .replaceAll(RegExp(r'/+$'), '');

  String get configuredOrigin => _baseOrigin;
  bool get isConfigured => _baseOrigin.isNotEmpty && _isValidOrigin(_baseOrigin);

  static bool _isValidOrigin(String origin) {
    final uri = Uri.tryParse(origin);
    if (uri == null || uri.host.isEmpty) return false;
    return uri.scheme == 'https' || uri.scheme == 'http';
  }

  Future<AppUpdateEvaluation> checkLatestRelease({
    required String installedVersion,
    required int installedBuild,
    String channel = AppConfig.releaseChannel,
    int? androidApiLevel,
    String? deviceFingerprintHash,
  }) async {
    if (!isConfigured) {
      return AppUpdateEvaluation(
        status: AppUpdateAvailability.unconfigured,
        channel: channel,
        installedVersion: installedVersion,
        installedBuild: installedBuild,
        errorMessage:
            'Release server origin is not configured in this build.',
        checkedAt: DateTime.now(),
      );
    }

    final query = <String, String>{
      'platform': 'android',
      'channel': channel,
      'build': installedBuild.toString(),
      'version': installedVersion,
      if (androidApiLevel != null) 'apiLevel': androidApiLevel.toString(),
      if (deviceFingerprintHash != null && deviceFingerprintHash.isNotEmpty)
        'deviceId': deviceFingerprintHash,
    };

    final uri = Uri.parse('$_baseOrigin/api/public/app-update')
        .replace(queryParameters: query);

    try {
      final response = await _client
          .get(
            uri,
            headers: const {'Accept': 'application/json'},
          )
          .timeout(AppConfig.connectTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AppUpdateEvaluation(
          status: AppUpdateAvailability.networkUnavailable,
          channel: channel,
          installedVersion: installedVersion,
          installedBuild: installedBuild,
          errorMessage:
              'Update server returned HTTP ${response.statusCode}.',
          checkedAt: DateTime.now(),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return AppUpdateEvaluation(
          status: AppUpdateAvailability.invalidMetadata,
          channel: channel,
          installedVersion: installedVersion,
          installedBuild: installedBuild,
          errorMessage: 'Unexpected response payload from update endpoint.',
          checkedAt: DateTime.now(),
        );
      }

      final evaluation = AppUpdateEvaluation.fromServerJson(
        Map<String, dynamic>.from(decoded),
        installedVersion: installedVersion,
        installedBuild: installedBuild,
        channel: channel,
      );

      if (evaluation.status != AppUpdateAvailability.invalidMetadata) {
        LocalCacheService.instance.put(
          _cachedEvalKey,
          evaluation.toCacheJson(),
          ttl: const Duration(hours: 24),
        );
      }

      return evaluation;
    } on SocketException catch (e) {
      return AppUpdateEvaluation(
        status: AppUpdateAvailability.networkUnavailable,
        channel: channel,
        installedVersion: installedVersion,
        installedBuild: installedBuild,
        errorMessage: 'Network unavailable (${e.message}).',
        checkedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[AppReleaseRepository] Update check error: $e');
      return AppUpdateEvaluation(
        status: AppUpdateAvailability.networkUnavailable,
        channel: channel,
        installedVersion: installedVersion,
        installedBuild: installedBuild,
        errorMessage: 'Unable to reach update service.',
        checkedAt: DateTime.now(),
      );
    }
  }

  AppUpdateEvaluation? readCachedEvaluation({
    required String installedVersion,
    required int installedBuild,
  }) {
    try {
      final raw = LocalCacheService.instance.get(_cachedEvalKey);
      if (raw is! Map) return null;
      final cachedBuild = (raw['installedBuild'] as num?)?.toInt();
      if (cachedBuild != installedBuild) {
        // App binary was already upgraded locally; cached decision is stale.
        LocalCacheService.instance.remove(_cachedEvalKey);
        return null;
      }
      return AppUpdateEvaluation.fromServerJson(
        Map<String, dynamic>.from(raw),
        installedVersion: installedVersion,
        installedBuild: installedBuild,
        channel: raw['channel']?.toString() ?? AppConfig.releaseChannel,
        isFromCache: true,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> reportTelemetry({
    required String eventType,
    required String channel,
    required int installedBuild,
    required String installedVersion,
    String? releaseId,
    int? targetBuild,
    int? androidApiLevel,
    Map<String, dynamic>? metadata,
  }) async {
    if (!isConfigured) return;
    try {
      final uri = Uri.parse('$_baseOrigin/api/public/app-update');
      await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'releaseId': ?releaseId,
              'platform': 'android',
              'channel': channel,
              'installedBuild': installedBuild,
              'installedVersion': installedVersion,
              'targetBuild': ?targetBuild,
              'eventType': eventType,
              'androidApiLevel': ?androidApiLevel,
              'metadata': ?metadata,
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Telemetry failures must never block install/update flows
    }
  }

  http.Client get httpClient => _client;
}
