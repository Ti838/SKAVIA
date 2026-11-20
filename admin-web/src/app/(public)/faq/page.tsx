import type { Metadata } from 'next';
import { FaqScreen } from '@/features/public-website/screens/FaqScreen';

export const metadata: Metadata = {
  title: 'Frequently Asked Questions (FAQ) — Services, OTP & Billing | SKAVIA',
  description:
    'Find answers to all questions regarding SKAVIA’s accountable workforce platform: 4-digit arrival handshake OTP, atomic escrow payments, 90/10 revenue share, and commercial contracts.',
};

export default function FaqPage() {
  return <FaqScreen />;
}
