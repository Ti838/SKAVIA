import type {
  AppReleaseChannel,
  AppReleasePlatform,
} from '@/lib/contracts';
import type {
  AppReleaseDto,
  ReleaseSigningPolicyDto,
} from '@/lib/types';
import type { InspectedApkMetadata } from './apk-inspector';

export class ReleaseValidationError extends Error {
  public readonly statusCode: number;
  public readonly code: string;

  constructor(code: string, message: string, statusCode = 400) {
    super(message);
    this.name = 'ReleaseValidationError';
    this.code = code;
    this.statusCode = statusCode;
  }
}

export const DEFAULT_SKAVIA_PACKAGE_NAME = 'com.example.skavia';

export function assertReleaseMatchesApkAndPolicy(params: {
  inspected: InspectedApkMetadata;
  input: {
    versionName: string;
    buildNumber: number;
    channel: AppReleaseChannel;
    allowInitialSigningPin?: boolean;
  };
  existingReleases: AppReleaseDto[];
  signingPolicy: ReleaseSigningPolicyDto;
}): void {
  const { inspected, input, existingReleases, signingPolicy } = params;
  const expectedPkg = signingPolicy.expectedPackageName || DEFAULT_SKAVIA_PACKAGE_NAME;

  if (inspected.packageName !== expectedPkg) {
    throw new ReleaseValidationError(
      'WRONG_PACKAGE_ID',
      `Package mismatch: uploaded APK has applicationId "${inspected.packageName}", expected "${expectedPkg}". Wrong-app APK uploads are blocked to protect user updates.`,
      422
    );
  }

  if (inspected.buildNumber !== input.buildNumber) {
    throw new ReleaseValidationError(
      'BUILD_NUMBER_MISMATCH',
      `Build number mismatch: APK manifest declares versionCode ${inspected.buildNumber}, but submission specified ${input.buildNumber}.`,
      422
    );
  }

  if (inspected.versionName !== input.versionName) {
    throw new ReleaseValidationError(
      'VERSION_NAME_MISMATCH',
      `Version name mismatch: APK manifest declares versionName "${inspected.versionName}", but submission specified "${input.versionName}".`,
      422
    );
  }

  if (!inspected.signingCertSha256) {
    throw new ReleaseValidationError(
      'UNSIGNED_OR_INVALID_APK',
      'APK signature could not be verified (missing APK Signature Scheme v2/v3 signing certificate). Unsigned APKs cannot be published.',
      422
    );
  }

  const envPinned = process.env.SKAVIA_APK_SIGNING_CERT_SHA256?.trim().toLowerCase() || null;
  const effectivePin = signingPolicy.pinnedSigningCertSha256?.toLowerCase() || envPinned;

  if (effectivePin && inspected.signingCertSha256 !== effectivePin) {
    throw new ReleaseValidationError(
      'SIGNING_CERT_MISMATCH',
      `APK signing certificate mismatch! Expected SHA-256 ${effectivePin.slice(0, 12)}..., received ${inspected.signingCertSha256.slice(0, 12)}.... Installing a differently signed APK fails Android in-place upgrades and breaks user sessions.`,
      422
    );
  }

  if (!effectivePin && !input.allowInitialSigningPin) {
    throw new ReleaseValidationError(
      'SIGNING_PIN_CONFIRMATION_REQUIRED',
      `No SKAVIA APK signing certificate fingerprint is pinned yet. Confirm pinning certificate ${inspected.signingCertSha256.slice(0, 16)}... before validating this release.`,
      422
    );
  }

  const sameChannel = existingReleases.filter(
    (r) => r.platform === 'android' && r.channel === input.channel
  );

  const dup = sameChannel.find((r) => r.build_number === input.buildNumber);
  if (dup) {
    throw new ReleaseValidationError(
      'DUPLICATE_BUILD_NUMBER',
      `Build #${input.buildNumber} already exists in channel "${input.channel}" (release ${dup.release_id.slice(0, 8)}, status ${dup.status}). Historical releases cannot be overwritten.`,
      409
    );
  }

  const highestPublished = sameChannel
    .filter((r) => r.status === 'published' || r.status === 'archived')
    .reduce((max, r) => Math.max(max, r.build_number), 0);

  if (highestPublished > 0 && input.buildNumber <= highestPublished) {
    throw new ReleaseValidationError(
      'INVALID_VERSION_SEQUENCE',
      `Invalid version sequence: channel "${input.channel}" already reached build #${highestPublished}. New releases must advance strictly above #${highestPublished} (use Rollback to reactivate a prior release).`,
      422
    );
  }
}

export function assertPublishSequenceAllowed(params: {
  target: AppReleaseDto;
  existingReleases: AppReleaseDto[];
  signingPolicy: ReleaseSigningPolicyDto;
}): void {
  const { target, existingReleases, signingPolicy } = params;

  if (target.status !== 'validated' && target.status !== 'published') {
    throw new ReleaseValidationError(
      'RELEASE_NOT_VALIDATED',
      `Release must be in "validated" state before publishing (current state: "${target.status}").`,
      422
    );
  }

  const expectedPkg = signingPolicy.expectedPackageName || DEFAULT_SKAVIA_PACKAGE_NAME;
  if (target.package_name !== expectedPkg) {
    throw new ReleaseValidationError(
      'WRONG_PACKAGE_ID',
      `Release package "${target.package_name}" does not match expected "${expectedPkg}".`,
      422
    );
  }

  const effectivePin =
    signingPolicy.pinnedSigningCertSha256?.toLowerCase() ||
    process.env.SKAVIA_APK_SIGNING_CERT_SHA256?.trim().toLowerCase() ||
    null;

  if (!target.signing_cert_sha256) {
    throw new ReleaseValidationError(
      'UNSIGNED_OR_INVALID_APK',
      'Cannot publish release without a verified signing certificate fingerprint.',
      422
    );
  }

  if (effectivePin && target.signing_cert_sha256.toLowerCase() !== effectivePin) {
    throw new ReleaseValidationError(
      'SIGNING_CERT_MISMATCH',
      'Release signing certificate does not match the pinned SKAVIA signing certificate.',
      422
    );
  }

  const activeCurrent = existingReleases.find(
    (r) =>
      r.platform === target.platform &&
      r.channel === target.channel &&
      r.is_current &&
      r.status === 'published' &&
      r.release_id !== target.release_id
  );

  if (activeCurrent && target.build_number < activeCurrent.build_number) {
    throw new ReleaseValidationError(
      'INVALID_VERSION_SEQUENCE',
      `Normal publish cannot lower build number from #${activeCurrent.build_number} to #${target.build_number}. Use the explicit Rollback action instead.`,
      422
    );
  }
}

export type PublicUpdateStatus =
  | 'no_published_release'
  | 'up_to_date'
  | 'optional_update'
  | 'mandatory_update'
  | 'unsupported_installed_build'
  | 'suspended_installed_build';

export interface PublicAppUpdatePayload {
  platform: AppReleasePlatform;
  channel: AppReleaseChannel;
  updateStatus: PublicUpdateStatus;
  updateAvailable: boolean;
  isMandatory: boolean;
  installedBuild: number | null;
  installedBuildSuspended: boolean;
  installedSuspensionReason: string | null;
  latestRelease: {
    releaseId: string;
    packageName: string;
    versionName: string;
    buildNumber: number;
    minSupportedBuild: number;
    minSdkVersion: number | null;
    targetSdkVersion: number | null;
    releaseNotes: string;
    isMandatory: boolean;
    fileName: string;
    fileSizeBytes: number;
    sha256Checksum: string;
    signingCertSha256: string | null;
    downloadUrl: string;
    publishedAt: string | null;
  } | null;
  supportInfo: {
    websiteDownloadUrl: string;
    helpline: string;
    supportEmail: string;
  };
  checkedAt: string;
}

export function evaluatePublicUpdateState(params: {
  platform: AppReleasePlatform;
  channel: AppReleaseChannel;
  installedBuild: number | null;
  currentRelease: AppReleaseDto | null;
  allChannelReleases: AppReleaseDto[];
  originBaseUrl: string;
}): PublicAppUpdatePayload {
  const { platform, channel, installedBuild, currentRelease, allChannelReleases, originBaseUrl } =
    params;

  const installedRecord =
    installedBuild != null
      ? allChannelReleases.find((r) => r.build_number === installedBuild) ?? null
      : null;

  const installedBuildSuspended = installedRecord?.status === 'suspended';
  const installedSuspensionReason = installedBuildSuspended
    ? installedRecord?.suspension_reason || 'This release was suspended by SKAVIA engineering.'
    : null;

  const normalizedOrigin = originBaseUrl.replace(/\/+$/, '');
  const websiteDownloadUrl = normalizedOrigin ? `${normalizedOrigin}/#download` : '/#download';

  if (!currentRelease) {
    const status: PublicUpdateStatus = installedBuildSuspended
      ? 'suspended_installed_build'
      : 'no_published_release';
    return {
      platform,
      channel,
      updateStatus: status,
      updateAvailable: false,
      isMandatory: false,
      installedBuild,
      installedBuildSuspended,
      installedSuspensionReason,
      latestRelease: null,
      supportInfo: {
        websiteDownloadUrl,
        helpline: '16524',
        supportEmail: 'support@skavia.com',
      },
      checkedAt: new Date().toISOString(),
    };
  }

  const downloadPath = `/api/public/releases/${currentRelease.release_id}/download`;
  const downloadUrl = normalizedOrigin ? `${normalizedOrigin}${downloadPath}` : downloadPath;

  let updateStatus: PublicUpdateStatus = 'up_to_date';
  let updateAvailable = false;
  let isMandatory = false;

  if (installedBuild == null) {
    updateStatus = currentRelease.is_mandatory ? 'mandatory_update' : 'optional_update';
    updateAvailable = true;
    isMandatory = currentRelease.is_mandatory;
  } else if (installedBuild < currentRelease.min_supported_build) {
    updateStatus = 'unsupported_installed_build';
    updateAvailable = true;
    isMandatory = true;
  } else if (installedBuild < currentRelease.build_number) {
    updateStatus = currentRelease.is_mandatory ? 'mandatory_update' : 'optional_update';
    updateAvailable = true;
    isMandatory = currentRelease.is_mandatory;
  } else if (installedBuildSuspended) {
    updateStatus = 'suspended_installed_build';
    updateAvailable = currentRelease.build_number !== installedBuild;
    isMandatory = false;
  }

  return {
    platform,
    channel,
    updateStatus,
    updateAvailable,
    isMandatory,
    installedBuild,
    installedBuildSuspended,
    installedSuspensionReason,
    latestRelease: {
      releaseId: currentRelease.release_id,
      packageName: currentRelease.package_name,
      versionName: currentRelease.version_name,
      buildNumber: currentRelease.build_number,
      minSupportedBuild: currentRelease.min_supported_build,
      minSdkVersion: currentRelease.min_sdk_version,
      targetSdkVersion: currentRelease.target_sdk_version,
      releaseNotes: currentRelease.release_notes,
      isMandatory: currentRelease.is_mandatory,
      fileName: currentRelease.file_name,
      fileSizeBytes: currentRelease.file_size_bytes,
      sha256Checksum: currentRelease.sha256_checksum,
      signingCertSha256: currentRelease.signing_cert_sha256,
      downloadUrl,
      publishedAt: currentRelease.published_at,
    },
    supportInfo: {
      websiteDownloadUrl,
      helpline: '16524',
      supportEmail: 'support@skavia.com',
    },
    checkedAt: new Date().toISOString(),
  };
}

