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
      fileSizeBytes: 23668477,
      sha256Checksum: 'c2ff57a1c6c6b64f1f52ecff435419bb63353486e4940cdb853b04b64ec365e3',
      signingCertSha256: '9920bf0cfdf2b5dc988be08044709d7936a18d9ef6f272c72b226f95fec1b4a0',
      releaseNotes:
        'SKAVIA v1.0.0 official production release. Ultra-compact 22.6 MB optimized release APK with dual Client & Worker modes, live geolocation dispatch, 4-digit arrival OTP, and protected escrow settlement.',
      isMandatory: false,
      publishedAt: '2026-11-19T02:30:00.000Z',
      channel: 'stable',
      distributionMethod: 'Official Signed Production APK (ARM64 & ARMv7)',
      armv7Url: `${origin}/downloads/skavia-v1.0.0-armeabi-v7a.apk`,
      armv7SizeBytes: 21257429,
      armv7Sha256Checksum: '3c0603f6178b31fd307cc6b97e46678f6115b2a0e4f4204277735237d40d593e',
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

