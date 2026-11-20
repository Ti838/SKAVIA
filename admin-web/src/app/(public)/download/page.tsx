import type { Metadata } from 'next';
import { DownloadHubScreen } from '@/features/public-website/screens/DownloadHubScreen';

export const metadata: Metadata = {
  title: 'Download Official SKAVIA Mobile App — Android APK | SKAVIA',
  description:
    'Download the official production-signed SKAVIA Android application for Client & Worker modes. Verified SHA-256 checksums, automated ARM64-v8a vs ARMv7 architecture detection, and direct high-speed download.',
};

export default function DownloadPage() {
  return <DownloadHubScreen />;
}
