import type { DistributionInfo } from '@/features/public-website/public-site-data';
import { getServerEnvConfig } from '@/server/config/env';
import { getAdminRepository } from '@/server/db/store-factory';

export async function getPublicDistributionSnapshot(
  origin: string
): Promise<DistributionInfo> {
  let androidRelease = null;
  try {
    const repo = getAdminRepository();
    androidRelease = await repo.getCurrentPublishedRelease({
      platform: 'android',
      channel: 'stable',
    });
  } catch {
    androidRelease = null;
  }

  let envCfg: ReturnType<typeof getServerEnvConfig> | null = null;
  try {
    envCfg = getServerEnvConfig();
  } catch {
    envCfg = null;
  }

  const iosUrl =
    envCfg?.iosAppStoreUrl ||
    process.env.NEXT_PUBLIC_IOS_APP_STORE_URL?.trim() ||
    null;

  if (androidRelease) {
    return {
      android: {
        published: true,
        releaseId: androidRelease.release_id,
        apkUrl: `${origin}/api/public/releases/${androidRelease.release_id}/download`,
        version: androidRelease.version_name,
        buildNumber: androidRelease.build_number,
        minSupportedBuild: androidRelease.min_supported_build,
        minSdkVersion: androidRelease.min_sdk_version,
        fileName: androidRelease.file_name,
        fileSizeBytes: androidRelease.file_size_bytes,
        sha256Checksum: androidRelease.sha256_checksum,
        signingCertSha256: androidRelease.signing_cert_sha256,
        releaseNotes: androidRelease.release_notes,
        isMandatory: androidRelease.is_mandatory,
        publishedAt: androidRelease.published_at,
        channel: androidRelease.channel,
        distributionMethod: 'Official Signed APK Distribution',
      },
      ios: {
        published: Boolean(iosUrl),
        storeUrl: iosUrl,
        distributionMethod: iosUrl
          ? 'Official Apple App Store'
          : 'Planned / Pending App Store Release',
      },
    };
  }

  const fallbackApkUrl =
    envCfg?.androidApkUrl ||
    process.env.NEXT_PUBLIC_ANDROID_APK_URL?.trim() ||
    null;
  const fallbackVersion =
    envCfg?.androidVersion ||
    process.env.NEXT_PUBLIC_ANDROID_VERSION?.trim() ||
    null;

  return {
    android: {
      published: Boolean(fallbackApkUrl),
      releaseId: null,
      apkUrl: fallbackApkUrl,
      version: fallbackVersion,
      buildNumber: null,
      minSupportedBuild: null,
      minSdkVersion: null,
      fileName: null,
      fileSizeBytes: null,
      sha256Checksum: null,
      signingCertSha256: null,
      releaseNotes: null,
      isMandatory: false,
      publishedAt: null,
      channel: 'stable',
      distributionMethod: fallbackApkUrl
        ? 'Official Signed APK Distribution'
        : 'Pending Official Release Build',
    },
    ios: {
      published: Boolean(iosUrl),
      storeUrl: iosUrl,
      distributionMethod: iosUrl
        ? 'Official Apple App Store'
        : 'Planned / Pending App Store Release',
    },
  };
}

