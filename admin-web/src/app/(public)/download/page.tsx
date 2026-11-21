import type { Metadata } from 'next';
import { headers } from 'next/headers';
import { DownloadHubScreen } from '@/features/public-website/screens/DownloadHubScreen';
import { resolveHeaderOrigin } from '@/server/http/origin';
import { getPublicDistributionSnapshot } from '@/server/releases/distribution-snapshot';

export const dynamic = 'force-dynamic';

export const metadata: Metadata = {
  title: 'Download Official SKAVIA Mobile App — Android APK | SKAVIA',
  description:
    'Download the official production-signed SKAVIA Android application for Client & Worker modes. Verified SHA-256 checksums, automated ARM64-v8a vs ARMv7 architecture detection, and direct high-speed download.',
};

export default async function DownloadPage() {
  const reqHeaders = await headers();
  const origin = resolveHeaderOrigin(reqHeaders);
  const initialDistribution = await getPublicDistributionSnapshot(origin);
  return <DownloadHubScreen initialDistribution={initialDistribution} />;
}
