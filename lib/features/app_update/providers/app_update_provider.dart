import 'package:flutter/foundation.dart';

import '../data/models/app_release_model.dart';
import '../services/android_installer_bridge.dart';
import '../services/app_update_service.dart';

enum AppUpdatePhase {
  idle,
  checking,
  downloading,
  verifying,
  awaitingInstallPermission,
  installerOpened,
  error,
}

class AppUpdateProvider extends ChangeNotifier {
  static final AppUpdateProvider instance = AppUpdateProvider();

  AppUpdateService _service;

  AppUpdateProvider({AppUpdateService? service})
      : _service = service ?? AppUpdateService();

  void configureService(AppUpdateService service) {
    _service = service;
  }

  AppUpdatePhase _phase = AppUpdatePhase.idle;
  AppUpdateEvaluation? _evaluation;
  int _downloadedBytes = 0;
  int _totalBytes = 0;
  String? _errorMessage;
  String? _verifiedApkPath;
  String? _verifiedSha256;
  bool _cancelled = false;
  bool _dialogShownForCurrentCheck = false;

  AppUpdatePhase get phase => _phase;
  AppUpdateEvaluation? get evaluation => _evaluation;
  AppReleaseInfo? get latestRelease => _evaluation?.latestRelease;
  int get downloadedBytes => _downloadedBytes;
  int get totalBytes => _totalBytes;
  double get progress =>
      _totalBytes > 0 ? (_downloadedBytes / _totalBytes).clamp(0.0, 1.0) : 0.0;
  String? get errorMessage => _errorMessage;
  String? get verifiedApkPath => _verifiedApkPath;
  bool get isBusy =>
      _phase == AppUpdatePhase.checking ||
      _phase == AppUpdatePhase.downloading ||
      _phase == AppUpdatePhase.verifying;
  bool get isConfigured => _service.isConfigured;

  bool get shouldShowAutomaticDialog {
    final eval = _evaluation;
    if (eval == null || !eval.updateAvailable || eval.latestRelease == null) {
      return false;
    }
    if (eval.requiresImmediateBlockingUpdate) {
      return true;
    }
    if (_dialogShownForCurrentCheck) {
      return false;
    }
    return !_service.isOptionalPromptDeferred(eval.latestRelease!.buildNumber);
  }

  bool get shouldShowDeferredBanner {
    final eval = _evaluation;
    if (eval == null) return false;
    if (eval.status == AppUpdateAvailability.suspendedInstalledBuild &&
        eval.installedBuildSuspended) {
      return true;
    }
    if (!eval.isOptional || eval.latestRelease == null) {
      return false;
    }
    return _service.isOptionalPromptDeferred(eval.latestRelease!.buildNumber);
  }

  Future<({String version, int buildNumber})> getInstalledVersionInfo() {
    return _service.readInstalledPackage();
  }

  Future<AppUpdateEvaluation> checkForUpdates({
    required String trigger,
    bool force = false,
  }) async {
    if (_phase == AppUpdatePhase.downloading ||
        _phase == AppUpdatePhase.verifying) {
      return _evaluation ??
          AppUpdateEvaluation(
            status: AppUpdateAvailability.networkUnavailable,
            channel: 'stable',
            installedVersion: '',
            installedBuild: 0,
            checkedAt: DateTime.now(),
          );
    }

    _phase = AppUpdatePhase.checking;
    _errorMessage = null;
    notifyListeners();

    try {
      final eval = await _service.checkForUpdates(
        trigger: trigger,
        force: force,
      );
      _evaluation = eval;
      if (force) {
        _dialogShownForCurrentCheck = false;
      }
      _phase = AppUpdatePhase.idle;
      notifyListeners();
      return eval;
    } catch (e) {
      _phase = AppUpdatePhase.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void markDialogPresented() {
    _dialogShownForCurrentCheck = true;
  }

  void deferOptionalUpdate() {
    final release = _evaluation?.latestRelease;
    if (release != null) {
      _service.deferOptionalPrompt(release.buildNumber);
    }
    _dialogShownForCurrentCheck = true;
    notifyListeners();
  }

  Future<void> startDownloadAndInstall() async {
    final release = _evaluation?.latestRelease;
    if (release == null) {
      _errorMessage = 'No downloadable update release is available.';
      _phase = AppUpdatePhase.error;
      notifyListeners();
      return;
    }

    _cancelled = false;
    _errorMessage = null;
    _downloadedBytes = 0;
    _totalBytes = release.fileSizeBytes;
    _verifiedApkPath = null;
    _verifiedSha256 = null;
    _phase = AppUpdatePhase.downloading;
    notifyListeners();

    try {
      final result = await _service.downloadVerifyAndInstall(
        release: release,
        isCancelled: () => _cancelled,
        onProgress: (received, total) {
          _downloadedBytes = received;
          _totalBytes = total;
          notifyListeners();
        },
        onVerifyingChecksum: () {
          _phase = AppUpdatePhase.verifying;
          notifyListeners();
        },
      );

      switch (result.status) {
        case AppUpdateDownloadResultStatus.cancelled:
          _phase = AppUpdatePhase.idle;
          _downloadedBytes = 0;
          break;
        case AppUpdateDownloadResultStatus.awaitingInstallPermission:
          _verifiedApkPath = result.filePath;
          _verifiedSha256 = result.verifiedSha256;
          _phase = AppUpdatePhase.awaitingInstallPermission;
          break;
        case AppUpdateDownloadResultStatus.installerLaunched:
          _verifiedApkPath = result.filePath;
          _verifiedSha256 = result.verifiedSha256;
          _phase = AppUpdatePhase.installerOpened;
          break;
      }
      notifyListeners();
    } on AndroidInstallerException catch (e) {
      _phase = AppUpdatePhase.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _phase = AppUpdatePhase.error;
      _errorMessage = 'Failed downloading or verifying update: $e';
      notifyListeners();
    }
  }

  void cancelDownload() {
    if (_phase == AppUpdatePhase.downloading) {
      _cancelled = true;
      _phase = AppUpdatePhase.idle;
      notifyListeners();
    }
  }

  Future<void> openInstallPermissionSettings() async {
    await _service.openUnknownAppSourcesSettings();
  }

  Future<void> resumePendingInstallIfPermitted() async {
    if (_phase != AppUpdatePhase.awaitingInstallPermission) return;
    final path = _verifiedApkPath;
    final sha = _verifiedSha256;
    final release = _evaluation?.latestRelease;
    if (path == null || sha == null || release == null) return;

    final permitted = await _service.canRequestPackageInstalls();
    if (!permitted) return;

    try {
      final result = await _service.launchInstallerForVerifiedApk(
        filePath: path,
        verifiedSha256: sha,
        release: release,
      );
      _phase = result.status == AppUpdateDownloadResultStatus.installerLaunched
          ? AppUpdatePhase.installerOpened
          : AppUpdatePhase.awaitingInstallPermission;
      notifyListeners();
    } catch (e) {
      _phase = AppUpdatePhase.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_phase == AppUpdatePhase.error) {
      _phase = AppUpdatePhase.idle;
    }
    notifyListeners();
  }
}

