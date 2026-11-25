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
    const rawPath = androidRelease.storage_path;
    const isDirectStatic =
      rawPath.includes('/downloads/') ||
      rawPath.endsWith('.apk') ||
      rawPath.startsWith('/downloads') ||
      rawPath.startsWith('downloads');

    const downloadPath = isDirectStatic
      ? `/downloads/${androidRelease.file_name || 'skavia-latest.apk'}`
      : `${origin}/api/public/releases/${androidRelease.release_id}/download`;

    return {
      android: {
        published: true,
        releaseId: androidRelease.release_id,
        apkUrl: downloadPath,
        armv7Url: '/downloads/skavia-v1.0.0-armeabi-v7a.apk',
        version: androidRelease.version_name,
        buildNumber: androidRelease.build_number,
        minSupportedBuild: androidRelease.min_supported_build,
        minSdkVersion: androidRelease.min_sdk_version,
        fileName: androidRelease.file_name || 'skavia-latest.apk',
        fileSizeBytes: androidRelease.file_size_bytes,
        sha256Checksum: androidRelease.sha256_checksum,
        signingCertSha256: androidRelease.signing_cert_sha256,
        releaseNotes: androidRelease.release_notes,
        isMandatory: androidRelease.is_mandatory,
        publishedAt: androidRelease.published_at,
        channel: androidRelease.channel,
        distributionMethod: 'Official Universal Signed Production APK',
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
    `${origin}/downloads/skavia-v1.0.0-arm64-v8a.apk`;
  const fallbackVersion =
    envCfg?.androidVersion ||
    process.env.NEXT_PUBLIC_ANDROID_VERSION?.trim() ||
    '1.0.0';

  return {
    android: {
      published: true,
      releaseId: 'skavia-v1-0-0-prod',
      apkUrl: fallbackApkUrl,
      version: fallbackVersion,
      buildNumber: 1,
      minSupportedBuild: 1,
      minSdkVersion: 24,
      fileName: 'skavia-v1.0.0-arm64-v8a.apk',
      fileSizeBytes: 26277260,
      sha256Checksum: '68d327a13aaa3ffc73b12e9bbdcf9716e0ed9edc08aae96cb61ef9d8909cab45',
      signingCertSha256: '8ae8d16712e610e8a69dc832f961388e93c2dbb214159db290be466593c9b83f',
      releaseNotes:
        'SKAVIA v1.0.0 official production release. Verified BITA STUDIO platform, Bangladesh Cloud Phone OTP & NID verification, real-time Google Maps street tiles, and dark mode splash support.',
      isMandatory: false,
      publishedAt: '2026-11-25T07:10:30.000Z',
      channel: 'stable',
      distributionMethod: 'Official Signed Production APK (ARM64 & ARMv7)',
      armv7Url: `${origin}/downloads/skavia-v1.0.0-armeabi-v7a.apk`,
      armv7SizeBytes: 24177505,
      armv7Sha256Checksum: '0c0edb89db09b74142e6eed2c815f6b6a068332ccd778d3348d4e571105dab87',
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

