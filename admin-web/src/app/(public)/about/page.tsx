import type { Metadata } from 'next';
import { AboutScreen } from '@/features/public-website/screens/AboutScreen';

export const metadata: Metadata = {
  title: 'About SKAVIA — Accountable Service & Workforce Enterprise in Bangladesh',
  description:
    'Learn about SKAVIA: Bangladesh’s single-enterprise accountable workforce and services company operating across 8 specialization branches with verified technicians, 4-digit arrival handshake OTP, and 90/10 escrow protection.',
};

export default function AboutPage() {
  return <AboutScreen />;
}
