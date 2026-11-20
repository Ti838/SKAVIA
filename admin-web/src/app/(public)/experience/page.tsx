import type { Metadata } from 'next';
import { ExperienceScreen } from '@/features/public-website/screens/ExperienceScreen';

export const metadata: Metadata = {
  title: 'Customer Experience & Trust Guarantees — Safety, OTP & Escrow | SKAVIA',
  description:
    'Discover how SKAVIA protects households and commercial clients across Bangladesh with verified identity, 4-digit arrival handshake OTP, atomic escrow financial protection, and zero broker exploitation.',
};

export default function ExperiencePage() {
  return <ExperienceScreen />;
}
