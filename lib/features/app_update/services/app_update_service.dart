import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../notifications/data/models/app_notification_model.dart';
import '../../notifications/presentation/controllers/notification_center_controller.dart';
import '../data/models/app_release_model.dart';
import '../data/repositories/app_release_repository.dart';
import 'android_installer_bridge.dart';

typedef InstalledPackageReader = Future<({String version, int buildNumber})>
    Function();

enum AppUpdateDownloadResultStatus {
  installerLaunched,
  awaitingInstallPermission,
  cancelled,
}

class AppUpdateDownloadResult {
  final AppUpdateDownloadResultStatus status;
  final String filePath;
  final String verifiedSha256;

  const AppUpdateDownloadResult({
    required this.status,
    required this.filePath,
    required this.verifiedSha256,
  });
}

class AppUpdateService {
  static const Duration autoCheckThrottle = Duration(minutes: 30);
  static const Duration optionalDeferDuration = Duration(hours: 24);
  static const String _deferKeyPrefix = 'skavia_update_deferred_build_';
  static const String _notifiedReleasePrefix = 'skavia_update_notified_rel_';

  final AppReleaseRepository _repository;
  final AndroidInstallerPlatform _installer;
  final InstalledPackageReader _packageReader;
  final String Function()? currentUserIdReader;
  final void Function(AppReleaseInfo release, {required bool mandatory})?
      onNewReleaseNotifier;

  DateTime? _lastNetworkCheckAt;

  AppUpdateService({
    AppReleaseRepository? repository,
    AndroidInstallerPlatform? installer,
    InstalledPackageReader? packageReader,
    this.currentUserIdReader,
    this.onNewReleaseNotifier,
  })  : _repository = repository ?? AppReleaseRepository(),
        _installer = installer ?? MethodChannelAndroidInstaller(),
        _packageReader = packageReader ?? _defaultReadInstalledPackage;

  static Future<({String version, int buildNumber})>
      _defaultReadInstalledPackage() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final build = int.tryParse(info.buildNumber.trim()) ?? 1;
      final version =
          info.version.trim().isNotEmpty ? info.version.trim() : AppConfig.appVersion;
      return (version: version, buildNumber: build > 0 ? build : 1);
    } catch (_) {
      return (version: AppConfig.appVersion, buildNumber: 1);
    }
  }

  Future<({String version, int buildNumber})> readInstalledPackage() {
    return _packageReader();
  }

  bool get isConfigured => _repository.isConfigured;
  String get configuredOrigin => _repository.configuredOrigin;

  Future<AppUpdateEvaluation> checkForUpdates({
    required String trigger,
    bool force = false,
  }) async {
    final pkg = await _packageReader();

    if (!force &&
        _lastNetworkCheckAt != null &&
        DateTime.now().difference(_lastNetworkCheckAt!) < autoCheckThrottle) {
      final cached = _repository.readCachedEvaluation(
        installedVersion: pkg.version,
        installedBuild: pkg.buildNumber,
      );
      if (cached != null) return cached;
    }

    int? apiLevel;
    try {
      apiLevel = await _installer.getAndroidSdkInt();
    } catch (_) {}

    final eval = await _repository.checkLatestRelease(
      installedVersion: pkg.version,
      installedBuild: pkg.buildNumber,
      channel: AppConfig.releaseChannel,
      androidApiLevel: apiLevel,
    );

    if (eval.status != AppUpdateAvailability.networkUnavailable &&
        eval.status != AppUpdateAvailability.unconfigured) {
      _lastNetworkCheckAt = DateTime.now();
    }

    if (eval.updateAvailable && eval.latestRelease != null) {
      _dispatchUpdateNotifications(
        eval.latestRelease!,
        mandatory: eval.requiresImmediateBlockingUpdate,
      );
    }

    debugPrint(
      '[AppUpdateService] trigger=$trigger status=${eval.status.name} installed=${pkg.version}+${pkg.buildNumber} latest=${eval.latestRelease?.versionName}+${eval.latestRelease?.buildNumber}',
    );

    return eval;
  }

  bool isOptionalPromptDeferred(int buildNumber) {
    return LocalCacheService.instance.has('$_deferKeyPrefix$buildNumber');
  }

  void deferOptionalPrompt(int buildNumber) {
    LocalCacheService.instance.put(
      '$_deferKeyPrefix$buildNumber',
      DateTime.now().toIso8601String(),
      ttl: optionalDeferDuration,
    );
  }

  void _dispatchUpdateNotifications(
    AppReleaseInfo release, {
    required bool mandatory,
  }) {
    if (onNewReleaseNotifier != null) {
      onNewReleaseNotifier!(release, mandatory: mandatory);
      return;
    }

    final notifiedKey = '$_notifiedReleasePrefix${release.releaseId}';
    if (LocalCacheService.instance.has(notifiedKey)) {
      return;
    }
    LocalCacheService.instance.put(
      notifiedKey,
      DateTime.now().toIso8601String(),
      ttl: const Duration(days: 7),
    );

    String? uid;
    try {
      uid = currentUserIdReader?.call() ?? FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      uid = null;
    }

    if (uid != null && uid.isNotEmpty) {
      NotificationCenterController.instance.addNotification(
        AppNotificationModel(
          id: UuidUtil.generateUuidV4(),
          userId: uid,
          dedupKey: 'app_update_${release.releaseId}_$uid',
          title: mandatory
              ? 'Required SKAVIA Update v${release.versionName}'
              : 'SKAVIA v${release.versionName} Available',
          body: release.releaseNotes.isNotEmpty
              ? release.releaseNotes
              : 'Tap to download and verify the latest SKAVIA Android update.',
          category: mandatory ? 'urgent' : 'app_update',
          actionRoute: AppRoutes.appUpdate,
          metadata: {
            'releaseId': release.releaseId,
            'buildNumber': release.buildNumber,
            'versionName': release.versionName,
          },
          createdAt: DateTime.now(),
        ),
      );
    }

    if (!kIsWeb) {
      unawaited(
        NotificationService.instance.showNotification(
          id: release.releaseId.hashCode & 0x7fffffff,
          title: mandatory
              ? 'Important SKAVIA Update Required'
              : 'SKAVIA Update v${release.versionName} Ready',
          body: mandatory
              ? 'Please upgrade to v${release.versionName} to continue using SKAVIA safely.'
              : 'Tap to download v${release.versionName} (${release.formattedSize}).',
          payload: AppRoutes.appUpdate,
          isUrgent: mandatory,
          triggerInAppChime: false,
        ),
      );
    }
  }

  Future<AppUpdateDownloadResult> downloadVerifyAndInstall({
    required AppReleaseInfo release,
    required bool Function() isCancelled,
    required void Function(int receivedBytes, int totalBytes) onProgress,
    required VoidCallback onVerifyingChecksum,
  }) async {
    final pkg = await _packageReader();
    int? apiLevel;
    try {
      apiLevel = await _installer.getAndroidSdkInt();
    } catch (_) {}

    final updatesDirPath = await _installer.getUpdatesDirectoryPath();
    if (updatesDirPath == null || updatesDirPath.isEmpty) {
      throw AndroidInstallerException(
        'NO_CACHE_DIR',
        'Android update cache directory is unavailable on this platform.',
      );
    }

    final updatesDir = Directory(updatesDirPath);
    if (!await updatesDir.exists()) {
      await updatesDir.create(recursive: true);
    }

    // Clean stale APK/part files before starting new download
    try {
      await for (final entity in updatesDir.list()) {
        if (entity is File && entity.path != '') {
          await entity.delete();
        }
      }
    } catch (_) {}

    final safeBaseName =
        'skavia-${release.releaseId}-${release.buildNumber}.apk'
            .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final finalFile = File('${updatesDir.path}${Platform.pathSeparator}$safeBaseName');
    final partFile = File('${finalFile.path}.part');

    unawaited(
      _repository.reportTelemetry(
        eventType: 'download_started',
        channel: AppConfig.releaseChannel,
        installedBuild: pkg.buildNumber,
        installedVersion: pkg.version,
        releaseId: release.releaseId,
        targetBuild: release.buildNumber,
        androidApiLevel: apiLevel,
      ),
    );

    IOSink? sink;
    try {
      final request = http.Request('GET', Uri.parse(release.downloadUrl));
      request.followRedirects = true;
      request.maxRedirects = 5;

      final streamedResponse = await _repository.httpClient
          .send(request)
          .timeout(const Duration(seconds: 30));

      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode >= 300) {
        throw HttpException(
          'APK download returned HTTP ${streamedResponse.statusCode}.',
        );
      }

      final expectedTotal = streamedResponse.contentLength ?? release.fileSizeBytes;
      final activeSink = partFile.openWrite();
      sink = activeSink;
      int received = 0;

      await for (final chunk in streamedResponse.stream) {
        if (isCancelled()) {
          await activeSink.flush();
          await activeSink.close();
          sink = null;
          if (await partFile.exists()) {
            await partFile.delete();
          }
          return AppUpdateDownloadResult(
            status: AppUpdateDownloadResultStatus.cancelled,
            filePath: finalFile.path,
            verifiedSha256: '',
          );
        }
        activeSink.add(chunk);
        received += chunk.length;
        onProgress(received, expectedTotal > 0 ? expectedTotal : release.fileSizeBytes);
      }

      await activeSink.flush();
      await activeSink.close();
      sink = null;

      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await partFile.rename(finalFile.path);

      unawaited(
        _repository.reportTelemetry(
          eventType: 'download_completed',
          channel: AppConfig.releaseChannel,
          installedBuild: pkg.buildNumber,
          installedVersion: pkg.version,
          releaseId: release.releaseId,
          targetBuild: release.buildNumber,
          androidApiLevel: apiLevel,
          metadata: {'receivedBytes': received},
        ),
      );

      onVerifyingChecksum();

      final actualSize = await finalFile.length();
      if (release.fileSizeBytes > 0 && actualSize != release.fileSizeBytes) {
        await finalFile.delete();
        unawaited(
          _repository.reportTelemetry(
            eventType: 'checksum_failed',
            channel: AppConfig.releaseChannel,
            installedBuild: pkg.buildNumber,
            installedVersion: pkg.version,
            releaseId: release.releaseId,
            targetBuild: release.buildNumber,
            androidApiLevel: apiLevel,
            metadata: {
              'reason': 'size_mismatch',
              'expected': release.fileSizeBytes,
              'actual': actualSize,
            },
          ),
        );
        throw AndroidInstallerException(
          'SIZE_MISMATCH',
          'Downloaded APK size ($actualSize bytes) does not match expected size (${release.fileSizeBytes} bytes).',
        );
      }

      final computedSha = await _installer.computeFileSha256(finalFile.path);
      if (computedSha.toLowerCase() != release.sha256Checksum.toLowerCase()) {
        await finalFile.delete();
        unawaited(
          _repository.reportTelemetry(
            eventType: 'checksum_failed',
            channel: AppConfig.releaseChannel,
            installedBuild: pkg.buildNumber,
            installedVersion: pkg.version,
            releaseId: release.releaseId,
            targetBuild: release.buildNumber,
            androidApiLevel: apiLevel,
            metadata: {'reason': 'sha256_mismatch'},
          ),
        );
        throw AndroidInstallerException(
          'CHECKSUM_MISMATCH',
          'APK SHA-256 verification failed. The download was discarded for your safety.',
        );
      }

      unawaited(
        _repository.reportTelemetry(
          eventType: 'checksum_verified',
          channel: AppConfig.releaseChannel,
          installedBuild: pkg.buildNumber,
          installedVersion: pkg.version,
          releaseId: release.releaseId,
          targetBuild: release.buildNumber,
          androidApiLevel: apiLevel,
        ),
      );

      return await launchInstallerForVerifiedApk(
        filePath: finalFile.path,
        verifiedSha256: computedSha,
        release: release,
      );
    } catch (e) {
      if (sink != null) {
        try {
          await sink.close();
        } catch (_) {}
      }
      if (await partFile.exists()) {
        try {
          await partFile.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<AppUpdateDownloadResult> launchInstallerForVerifiedApk({
    required String filePath,
    required String verifiedSha256,
    required AppReleaseInfo release,
  }) async {
    final pkg = await _packageReader();
    int? apiLevel;
    try {
      apiLevel = await _installer.getAndroidSdkInt();
    } catch (_) {}

    final canInstall = await _installer.canRequestPackageInstalls();
    if (!canInstall) {
      return AppUpdateDownloadResult(
        status: AppUpdateDownloadResultStatus.awaitingInstallPermission,
        filePath: filePath,
        verifiedSha256: verifiedSha256,
      );
    }

    try {
      final launched = await _installer.installApk(filePath);
      if (!launched) {
        throw AndroidInstallerException(
          'INSTALL_NOT_LAUNCHED',
          'Android Package Installer did not open.',
        );
      }
      unawaited(
        _repository.reportTelemetry(
          eventType: 'installer_launched',
          channel: AppConfig.releaseChannel,
          installedBuild: pkg.buildNumber,
          installedVersion: pkg.version,
          releaseId: release.releaseId,
          targetBuild: release.buildNumber,
          androidApiLevel: apiLevel,
        ),
      );
      return AppUpdateDownloadResult(
        status: AppUpdateDownloadResultStatus.installerLaunched,
        filePath: filePath,
        verifiedSha256: verifiedSha256,
      );
    } catch (e) {
      unawaited(
        _repository.reportTelemetry(
          eventType: 'install_failed',
          channel: AppConfig.releaseChannel,
          installedBuild: pkg.buildNumber,
          installedVersion: pkg.version,
          releaseId: release.releaseId,
          targetBuild: release.buildNumber,
          androidApiLevel: apiLevel,
          metadata: {'error': e.toString()},
        ),
      );
      rethrow;
    }
  }

  Future<bool> canRequestPackageInstalls() =>
      _installer.canRequestPackageInstalls();

  Future<bool> openUnknownAppSourcesSettings() =>
      _installer.openUnknownAppSourcesSettings();
}
