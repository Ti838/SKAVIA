import type { Metadata } from 'next';
import { HowItWorksScreen } from '@/features/public-website/screens/HowItWorksScreen';

export const metadata: Metadata = {
  title: 'How SKAVIA Works — 4-Step Accountable Service Lifecycle | SKAVIA',
  description:
    'From natural language requirement scoping to verified dispatch, 4-digit physical arrival handshake OTP, and atomic escrow payment release upon completed work.',
};

export default function HowItWorksPage() {
  return <HowItWorksScreen />;
}
