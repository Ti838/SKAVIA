import 'package:flutter/foundation.dart';

import '../../../../core/utils/formatters.dart';

enum AppUpdateAvailability {
  upToDate,
  noPublishedRelease,
  optionalUpdate,
  mandatoryUpdate,
  unsupportedInstalledBuild,
  suspendedInstalledBuild,
  networkUnavailable,
  unconfigured,
  invalidMetadata,
}

@immutable
class AppReleaseInfo {
  final String releaseId;
  final String packageName;
  final String versionName;
  final int buildNumber;
  final int minSupportedBuild;
  final int? minSdkVersion;
  final int? targetSdkVersion;
  final String releaseNotes;
  final bool isMandatory;
  final String fileName;
  final int fileSizeBytes;
  final String sha256Checksum;
  final String? signingCertSha256;
  final String downloadUrl;
  final DateTime? publishedAt;

  const AppReleaseInfo({
    required this.releaseId,
    required this.packageName,
    required this.versionName,
    required this.buildNumber,
    required this.minSupportedBuild,
    this.minSdkVersion,
    this.targetSdkVersion,
    required this.releaseNotes,
    required this.isMandatory,
    required this.fileName,
    required this.fileSizeBytes,
    required this.sha256Checksum,
    this.signingCertSha256,
    required this.downloadUrl,
    this.publishedAt,
  });

  static final RegExp _sha256Pattern = RegExp(r'^[a-fA-F0-9]{64}$');

  static AppReleaseInfo? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final releaseId = json['releaseId']?.toString().trim() ?? '';
    final packageName = json['packageName']?.toString().trim() ?? '';
    final versionName = json['versionName']?.toString().trim() ?? '';
    final buildNumber = (json['buildNumber'] as num?)?.toInt() ?? 0;
    final minSupportedBuild = (json['minSupportedBuild'] as num?)?.toInt() ?? 1;
    final fileName = json['fileName']?.toString().trim() ?? 'skavia-release.apk';
    final fileSizeBytes = (json['fileSizeBytes'] as num?)?.toInt() ?? 0;
    final sha256Checksum =
        json['sha256Checksum']?.toString().trim().toLowerCase() ?? '';
    final downloadUrl = json['downloadUrl']?.toString().trim() ?? '';

    final uri = Uri.tryParse(downloadUrl);
    final validScheme = uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;

    if (releaseId.isEmpty ||
        packageName.isEmpty ||
        versionName.isEmpty ||
        buildNumber <= 0 ||
        fileSizeBytes <= 0 ||
        !_sha256Pattern.hasMatch(sha256Checksum) ||
        !validScheme) {
      return null;
    }

    return AppReleaseInfo(
      releaseId: releaseId,
      packageName: packageName,
      versionName: versionName,
      buildNumber: buildNumber,
      minSupportedBuild: minSupportedBuild < 1 ? 1 : minSupportedBuild,
      minSdkVersion: (json['minSdkVersion'] as num?)?.toInt(),
      targetSdkVersion: (json['targetSdkVersion'] as num?)?.toInt(),
      releaseNotes: json['releaseNotes']?.toString() ?? '',
      isMandatory: json['isMandatory'] as bool? ?? false,
      fileName: fileName.isEmpty ? 'skavia-release.apk' : fileName,
      fileSizeBytes: fileSizeBytes,
      sha256Checksum: sha256Checksum,
      signingCertSha256: json['signingCertSha256']?.toString().trim().toLowerCase(),
      downloadUrl: downloadUrl,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'releaseId': releaseId,
        'packageName': packageName,
        'versionName': versionName,
        'buildNumber': buildNumber,
        'minSupportedBuild': minSupportedBuild,
        'minSdkVersion': minSdkVersion,
        'targetSdkVersion': targetSdkVersion,
        'releaseNotes': releaseNotes,
        'isMandatory': isMandatory,
        'fileName': fileName,
        'fileSizeBytes': fileSizeBytes,
        'sha256Checksum': sha256Checksum,
        'signingCertSha256': signingCertSha256,
        'downloadUrl': downloadUrl,
        'publishedAt': publishedAt?.toIso8601String(),
      };

  String get formattedSize => Formatters.formatFileSize(fileSizeBytes);
}

@immutable
class AppUpdateSupportInfo {
  final String? websiteDownloadUrl;
  final String helpline;
  final String supportEmail;

  const AppUpdateSupportInfo({
    this.websiteDownloadUrl,
    this.helpline = '16524',
    this.supportEmail = 'support@skavia.com',
  });

  factory AppUpdateSupportInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AppUpdateSupportInfo();
    return AppUpdateSupportInfo(
      websiteDownloadUrl: json['websiteDownloadUrl']?.toString(),
      helpline: json['helpline']?.toString().isNotEmpty == true
          ? json['helpline'].toString()
          : '16524',
      supportEmail: json['supportEmail']?.toString().isNotEmpty == true
          ? json['supportEmail'].toString()
          : 'support@skavia.com',
    );
  }

  Map<String, dynamic> toJson() => {
        'websiteDownloadUrl': websiteDownloadUrl,
        'helpline': helpline,
        'supportEmail': supportEmail,
      };
}

@immutable
class AppUpdateEvaluation {
  final AppUpdateAvailability status;
  final String channel;
  final String installedVersion;
  final int installedBuild;
  final bool installedBuildSuspended;
  final String? installedSuspensionReason;
  final AppReleaseInfo? latestRelease;
  final AppUpdateSupportInfo supportInfo;
  final String? errorMessage;
  final DateTime checkedAt;
  final bool isFromCache;

  const AppUpdateEvaluation({
    required this.status,
    required this.channel,
    required this.installedVersion,
    required this.installedBuild,
    this.installedBuildSuspended = false,
    this.installedSuspensionReason,
    this.latestRelease,
    this.supportInfo = const AppUpdateSupportInfo(),
    this.errorMessage,
    required this.checkedAt,
    this.isFromCache = false,
  });

  bool get updateAvailable =>
      status == AppUpdateAvailability.optionalUpdate ||
      status == AppUpdateAvailability.mandatoryUpdate ||
      status == AppUpdateAvailability.unsupportedInstalledBuild ||
      (status == AppUpdateAvailability.suspendedInstalledBuild &&
          latestRelease != null &&
          latestRelease!.buildNumber > installedBuild);

  bool get requiresImmediateBlockingUpdate =>
      status == AppUpdateAvailability.mandatoryUpdate ||
      status == AppUpdateAvailability.unsupportedInstalledBuild ||
      (status == AppUpdateAvailability.suspendedInstalledBuild &&
          latestRelease != null);

  bool get isOptional => status == AppUpdateAvailability.optionalUpdate;

  factory AppUpdateEvaluation.fromServerJson(
    Map<String, dynamic> json, {
    required String installedVersion,
    required int installedBuild,
    required String channel,
    bool isFromCache = false,
  }) {
    final rawStatus = json['updateStatus']?.toString() ?? '';
    final latestMap = json['latestRelease'] is Map<String, dynamic>
        ? json['latestRelease'] as Map<String, dynamic>
        : (json['latestRelease'] is Map
            ? Map<String, dynamic>.from(json['latestRelease'] as Map)
            : null);

    AppReleaseInfo? parsedRelease;
    if (latestMap != null) {
      parsedRelease = AppReleaseInfo.tryFromJson(latestMap);
      if (parsedRelease == null) {
        return AppUpdateEvaluation(
          status: AppUpdateAvailability.invalidMetadata,
          channel: channel,
          installedVersion: installedVersion,
          installedBuild: installedBuild,
          supportInfo: AppUpdateSupportInfo.fromJson(
            json['supportInfo'] is Map
                ? Map<String, dynamic>.from(json['supportInfo'] as Map)
                : null,
          ),
          errorMessage: 'Release metadata failed safety validation.',
          checkedAt: DateTime.now(),
          isFromCache: isFromCache,
        );
      }
    }

    final status = switch (rawStatus) {
      'up_to_date' => AppUpdateAvailability.upToDate,
      'no_published_release' => AppUpdateAvailability.noPublishedRelease,
      'optional_update' => parsedRelease != null
          ? AppUpdateAvailability.optionalUpdate
          : AppUpdateAvailability.invalidMetadata,
      'mandatory_update' => parsedRelease != null
          ? AppUpdateAvailability.mandatoryUpdate
          : AppUpdateAvailability.invalidMetadata,
      'unsupported_installed_build' => parsedRelease != null
          ? AppUpdateAvailability.unsupportedInstalledBuild
          : AppUpdateAvailability.invalidMetadata,
      'suspended_installed_build' => AppUpdateAvailability.suspendedInstalledBuild,
      _ => AppUpdateAvailability.invalidMetadata,
    };

    return AppUpdateEvaluation(
      status: status,
      channel: json['channel']?.toString() ?? channel,
      installedVersion: installedVersion,
      installedBuild: installedBuild,
      installedBuildSuspended: json['installedBuildSuspended'] as bool? ?? false,
      installedSuspensionReason: json['installedSuspensionReason']?.toString(),
      latestRelease: parsedRelease,
      supportInfo: AppUpdateSupportInfo.fromJson(
        json['supportInfo'] is Map
            ? Map<String, dynamic>.from(json['supportInfo'] as Map)
            : null,
      ),
      errorMessage: status == AppUpdateAvailability.invalidMetadata
          ? 'Received malformed update metadata from server.'
          : null,
      checkedAt: json['checkedAt'] != null
          ? (DateTime.tryParse(json['checkedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      isFromCache: isFromCache,
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'updateStatus': switch (status) {
          AppUpdateAvailability.upToDate => 'up_to_date',
          AppUpdateAvailability.noPublishedRelease => 'no_published_release',
          AppUpdateAvailability.optionalUpdate => 'optional_update',
          AppUpdateAvailability.mandatoryUpdate => 'mandatory_update',
          AppUpdateAvailability.unsupportedInstalledBuild =>
            'unsupported_installed_build',
          AppUpdateAvailability.suspendedInstalledBuild =>
            'suspended_installed_build',
          _ => 'invalid_metadata',
        },
        'channel': channel,
        'installedVersion': installedVersion,
        'installedBuild': installedBuild,
        'installedBuildSuspended': installedBuildSuspended,
        'installedSuspensionReason': installedSuspensionReason,
        'latestRelease': latestRelease?.toJson(),
        'supportInfo': supportInfo.toJson(),
        'checkedAt': checkedAt.toIso8601String(),
      };
}

