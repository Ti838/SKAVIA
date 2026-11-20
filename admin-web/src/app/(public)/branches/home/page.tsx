import type { Metadata } from 'next';
import { BranchHomeScreen } from '@/features/public-website/screens/BranchHomeScreen';

export const metadata: Metadata = {
  title: 'SKAVIA Home — Residential Maintenance & Sanitary Engineering | SKAVIA',
  description:
    'Verified residential plumbing, concealed water leak detection, sanitary diagnostics, electrical short-circuit emergency care, and home carpentry with 4-digit arrival handshake OTP.',
};

export default function BranchHomePage() {
  return <BranchHomeScreen />;
}
