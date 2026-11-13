import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skavia/app/theme/app_theme.dart';
import 'package:skavia/core/storage/local_cache_service.dart';
import 'package:skavia/features/app_update/data/models/app_release_model.dart';
import 'package:skavia/features/app_update/data/repositories/app_release_repository.dart';
import 'package:skavia/features/app_update/presentation/screens/app_update_screen.dart';
import 'package:skavia/features/app_update/presentation/widgets/app_update_dialog.dart';
import 'package:skavia/features/app_update/providers/app_update_provider.dart';
import 'package:skavia/features/app_update/services/android_installer_bridge.dart';
import 'package:skavia/features/app_update/services/app_update_service.dart';
import 'package:skavia/features/profile/presentation/screens/about_skavia_screen.dart';

class _FakeAndroidInstaller implements AndroidInstallerPlatform {
  final String updatesDir;
  bool canInstall;
  String sha256ToReturn;
  final List<String> installedPaths = [];
  int openSettingsCalls = 0;

  _FakeAndroidInstaller({
    required this.updatesDir,
    this.canInstall = true,
    required this.sha256ToReturn,
  });

  @override
  Future<bool> canRequestPackageInstalls() async => canInstall;

  @override
  Future<String> computeFileSha256(String filePath) async => sha256ToReturn;

  @override
  Future<int?> getAndroidSdkInt() async => 34;

  @override
  Future<String?> getUpdatesDirectoryPath() async => updatesDir;

  @override
  Future<bool> installApk(String filePath) async {
    if (!canInstall) {
      throw AndroidInstallerException(
        'INSTALL_PERMISSION_REQUIRED',
        'Permission required',
      );
    }
    installedPaths.add(filePath);
    return true;
  }

  @override
  Future<bool> openUnknownAppSourcesSettings() async {
    openSettingsCalls += 1;
    return true;
  }
}

Map<String, dynamic> _buildReleaseJson({
  String releaseId = 'rel_2',
  String versionName = '1.2.0',
  int buildNumber = 5,
  int minSupportedBuild = 2,
  bool isMandatory = false,
  int fileSizeBytes = 12,
  String sha256 =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  String downloadUrl = 'https://releases.skavia.example/api/public/releases/rel_2/download',
}) {
  return {
    'releaseId': releaseId,
    'packageName': 'com.example.skavia',
    'versionName': versionName,
    'buildNumber': buildNumber,
    'minSupportedBuild': minSupportedBuild,
    'minSdkVersion': 24,
    'targetSdkVersion': 35,
    'releaseNotes': '- Improved dispatch matching\n- Faster escrow receipt loading',
    'isMandatory': isMandatory,
    'fileName': 'skavia-$versionName.apk',
    'fileSizeBytes': fileSizeBytes,
    'sha256Checksum': sha256,
    'signingCertSha256':
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
    'downloadUrl': downloadUrl,
    'publishedAt': '2026-11-12T10:00:00.000Z',
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.instance.init();
    LocalCacheService.instance.clear();
  });

  group('AppReleaseModel validation & evaluation', () {
    test('rejects invalid SHA-256 or unsafe download URLs cleanly', () {
      final invalidShaEval = AppUpdateEvaluation.fromServerJson(
        {
          'updateStatus': 'optional_update',
          'channel': 'stable',
          'latestRelease': _buildReleaseJson(sha256: 'not-a-valid-sha256'),
        },
        installedVersion: '1.0.0',
        installedBuild: 1,
        channel: 'stable',
      );
      expect(invalidShaEval.status, AppUpdateAvailability.invalidMetadata);
      expect(invalidShaEval.updateAvailable, isFalse);

      final badUrlEval = AppUpdateEvaluation.fromServerJson(
        {
          'updateStatus': 'mandatory_update',
          'channel': 'stable',
          'latestRelease': _buildReleaseJson(downloadUrl: 'file:///sdcard/evil.apk'),
        },
        installedVersion: '1.0.0',
        installedBuild: 1,
        channel: 'stable',
      );
      expect(badUrlEval.status, AppUpdateAvailability.invalidMetadata);
      expect(badUrlEval.requiresImmediateBlockingUpdate, isFalse);
    });

    test('identifies optional, mandatory, unsupported, and suspended states', () {
      final optionalEval = AppUpdateEvaluation.fromServerJson(
        {
          'updateStatus': 'optional_update',
          'channel': 'stable',
          'latestRelease': _buildReleaseJson(buildNumber: 5, isMandatory: false),
        },
        installedVersion: '1.0.0',
        installedBuild: 4,
        channel: 'stable',
      );
      expect(optionalEval.status, AppUpdateAvailability.optionalUpdate);
      expect(optionalEval.updateAvailable, isTrue);
      expect(optionalEval.requiresImmediateBlockingUpdate, isFalse);

      final unsupportedEval = AppUpdateEvaluation.fromServerJson(
        {
          'updateStatus': 'unsupported_installed_build',
          'channel': 'stable',
          'latestRelease':
              _buildReleaseJson(buildNumber: 5, minSupportedBuild: 3),
        },
        installedVersion: '1.0.0',
        installedBuild: 1,
        channel: 'stable',
      );
      expect(
        unsupportedEval.status,
        AppUpdateAvailability.unsupportedInstalledBuild,
      );
      expect(unsupportedEval.requiresImmediateBlockingUpdate, isTrue);

      final suspendedEval = AppUpdateEvaluation.fromServerJson(
        {
          'updateStatus': 'suspended_installed_build',
          'installedBuildSuspended': true,
          'installedSuspensionReason': 'Critical bug fixed in 1.2.0',
          'channel': 'stable',
          'latestRelease': _buildReleaseJson(buildNumber: 5),
        },
        installedVersion: '1.1.0',
        installedBuild: 4,
        channel: 'stable',
      );
      expect(
        suspendedEval.status,
        AppUpdateAvailability.suspendedInstalledBuild,
      );
      expect(suspendedEval.installedBuildSuspended, isTrue);
      expect(suspendedEval.requiresImmediateBlockingUpdate, isTrue);
    });
  });

  group('AppUpdateService & AppUpdateProvider lifecycle', () {
    test('returns unconfigured gracefully without blocking when SKAVIA_WEB_ORIGIN is empty', () async {
      final repo = AppReleaseRepository(baseOrigin: '');
      final service = AppUpdateService(
        repository: repo,
        packageReader: () async => (version: '1.0.0', buildNumber: 1),
      );
      final provider = AppUpdateProvider(service: service);

      final eval = await provider.checkForUpdates(trigger: 'startup');
      expect(eval.status, AppUpdateAvailability.unconfigured);
      expect(provider.shouldShowAutomaticDialog, isFalse);
    });

    test('handles network error gracefully and respects check throttling', () async {
      int getCalls = 0;
      final client = MockClient((req) async {
        if (req.method == 'GET') {
          getCalls += 1;
          if (getCalls == 1) {
            throw const SocketException('No route to host');
          }
          return http.Response(
            jsonEncode({
              'updateStatus': 'optional_update',
              'channel': 'stable',
              'latestRelease': _buildReleaseJson(buildNumber: 5),
            }),
            200,
          );
        }
        return http.Response('{"ok":true}', 200);
      });

      final repo = AppReleaseRepository(
        client: client,
        baseOrigin: 'https://releases.skavia.example',
      );
      final service = AppUpdateService(
        repository: repo,
        packageReader: () async => (version: '1.0.0', buildNumber: 2),
        onNewReleaseNotifier: (_, {required bool mandatory}) {},
      );
      final provider = AppUpdateProvider(service: service);

      // First offline attempt returns networkUnavailable cleanly
      final offlineEval = await provider.checkForUpdates(trigger: 'startup');
      expect(offlineEval.status, AppUpdateAvailability.networkUnavailable);

      // Next online check succeeds (offline failure didn't populate throttle timestamp)
      final onlineEval = await provider.checkForUpdates(trigger: 'foreground_resume');
      expect(onlineEval.status, AppUpdateAvailability.optionalUpdate);
      expect(getCalls, 2);

      // Throttled check without force skips network and returns cached result
      final throttledEval = await provider.checkForUpdates(trigger: 'foreground_resume');
      expect(throttledEval.isFromCache, isTrue);
      expect(getCalls, 2);

      // Deferring optional update suppresses modal while activating banner
      provider.deferOptionalUpdate();
      expect(provider.shouldShowAutomaticDialog, isFalse);
      expect(provider.shouldShowDeferredBanner, isTrue);

      // Force refresh hits backend again
      await provider.checkForUpdates(trigger: 'manual', force: true);
      expect(getCalls, 3);
    });

    test('verifies SHA-256 checksum, rejects tampered binary, and handles install permission handoff', () async {
      final tempDir = await Directory.systemTemp.createTemp('skavia_apk_test_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final apkBytes = utf8.encode('FAKE_SIGNED_APK_PAYLOAD_BYTES_1234');
      const expectedSha =
          'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
      final telemetryEvents = <String>[];

      final client = MockClient((req) async {
        if (req.url.path == '/api/public/app-update' && req.method == 'GET') {
          return http.Response(
            jsonEncode({
              'updateStatus': 'mandatory_update',
              'channel': 'stable',
              'latestRelease': _buildReleaseJson(
                buildNumber: 8,
                isMandatory: true,
                fileSizeBytes: apkBytes.length,
                sha256: expectedSha,
                downloadUrl:
                    'https://releases.skavia.example/api/public/releases/rel_2/download',
              ),
            }),
            200,
          );
        }
        if (req.url.path == '/api/public/app-update' && req.method == 'POST') {
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          telemetryEvents.add(body['eventType'].toString());
          return http.Response('{"ok":true}', 200);
        }
        if (req.url.path == '/api/public/releases/rel_2/download') {
          return http.Response.bytes(apkBytes, 200);
        }
        return http.Response('Not Found', 404);
      });

      // 1. Tampered checksum causes deletion & checksum_failed telemetry
      final badInstaller = _FakeAndroidInstaller(
        updatesDir: tempDir.path,
        canInstall: true,
        sha256ToReturn:
            'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd',
      );
      final badProvider = AppUpdateProvider(
        service: AppUpdateService(
          repository: AppReleaseRepository(
            client: client,
            baseOrigin: 'https://releases.skavia.example',
          ),
          installer: badInstaller,
          packageReader: () async => (version: '1.0.0', buildNumber: 1),
          onNewReleaseNotifier: (_, {required bool mandatory}) {},
        ),
      );
      await badProvider.checkForUpdates(trigger: 'startup');
      await badProvider.startDownloadAndInstall();

      expect(badProvider.phase, AppUpdatePhase.error);
      expect(badProvider.errorMessage, contains('SHA-256 verification failed'));
      expect(telemetryEvents, contains('checksum_failed'));
      expect(badInstaller.installedPaths, isEmpty);
      expect(tempDir.listSync(), isEmpty);

      // 2. Valid checksum with missing permission pauses at awaitingInstallPermission, then resumes!
      final goodInstaller = _FakeAndroidInstaller(
        updatesDir: tempDir.path,
        canInstall: false,
        sha256ToReturn: expectedSha,
      );
      final goodProvider = AppUpdateProvider(
        service: AppUpdateService(
          repository: AppReleaseRepository(
            client: client,
            baseOrigin: 'https://releases.skavia.example',
          ),
          installer: goodInstaller,
          packageReader: () async => (version: '1.0.0', buildNumber: 1),
          onNewReleaseNotifier: (_, {required bool mandatory}) {},
        ),
      );

      await goodProvider.checkForUpdates(trigger: 'startup');
      await goodProvider.startDownloadAndInstall();

      expect(goodProvider.phase, AppUpdatePhase.awaitingInstallPermission);
      expect(goodInstaller.installedPaths, isEmpty);
      expect(telemetryEvents, contains('checksum_verified'));

      // Simulate user enabling permission in Android Settings & returning to app
      await goodProvider.openInstallPermissionSettings();
      expect(goodInstaller.openSettingsCalls, 1);

      goodInstaller.canInstall = true;
      await goodProvider.resumePendingInstallIfPermitted();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(goodProvider.phase, AppUpdatePhase.installerOpened);
      expect(goodInstaller.installedPaths.length, 1);
      expect(telemetryEvents, contains('installer_launched'));
    });
  });

  group('Flutter Update UI widgets', () {
    testWidgets('AppUpdateDialog shows Later on optional update and hides Later on mandatory update',
        (tester) async {
      final optionalEval = AppUpdateEvaluation.fromServerJson(
        {
          'updateStatus': 'optional_update',
          'channel': 'stable',
          'latestRelease': _buildReleaseJson(isMandatory: false),
        },
        installedVersion: '1.0.0',
        installedBuild: 1,
        channel: 'stable',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppUpdateDialog(
              evaluation: optionalEval,
              onUpdateNow: () {},
              onLater: () {},
            ),
          ),
        ),
      );

      expect(find.text('SKAVIA Update Ready'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);

      final mandatoryEval = AppUpdateEvaluation.fromServerJson(
        {
          'updateStatus': 'mandatory_update',
          'channel': 'stable',
          'latestRelease': _buildReleaseJson(isMandatory: true),
        },
        installedVersion: '1.0.0',
        installedBuild: 1,
        channel: 'stable',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppUpdateDialog(
              evaluation: mandatoryEval,
              onUpdateNow: () {},
              onLater: null,
            ),
          ),
        ),
      );

      expect(find.text('Required App Update'), findsOneWidget);
      expect(find.text('Later'), findsNothing);
      expect(find.text('Update Now'), findsOneWidget);
    });

    testWidgets('AboutSkaviaScreen triggers manual update check and AppUpdateScreen displays support paths',
        (tester) async {
      final client = MockClient((req) async {
        return http.Response(
          jsonEncode({
            'updateStatus': 'optional_update',
            'channel': 'stable',
            'latestRelease': _buildReleaseJson(versionName: '2.0.0', buildNumber: 10),
            'supportInfo': {
              'websiteDownloadUrl': 'https://releases.skavia.example/#download',
              'helpline': '16524',
              'supportEmail': 'support@skavia.com',
            },
          }),
          200,
        );
      });

      final fakeInstaller = _FakeAndroidInstaller(
        updatesDir: '',
        canInstall: true,
        sha256ToReturn: 'a' * 64,
      );
      final provider = AppUpdateProvider(
        service: AppUpdateService(
          repository: AppReleaseRepository(
            client: client,
            baseOrigin: 'https://releases.skavia.example',
          ),
          installer: fakeInstaller,
          packageReader: () async => (version: '1.0.0', buildNumber: 1),
          onNewReleaseNotifier: (_, {required bool mandatory}) {},
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AboutSkaviaScreen(updateProvider: provider),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Check for Updates'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.textContaining('Update Available: v2.0.0'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AppUpdateScreen(provider: provider),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Available Release: v2.0.0'), findsOneWidget);
      expect(find.text('Helpline 16524'), findsOneWidget);
      expect(find.text('Open Website Download'), findsOneWidget);
    });
  });
}

