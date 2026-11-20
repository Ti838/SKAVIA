import type { Metadata } from 'next';
import { ServicesCatalogScreen } from '@/features/public-website/screens/ServicesCatalogScreen';

export const metadata: Metadata = {
  title: 'Services Directory — Transparent Trade Solutions & Pricing | SKAVIA',
  description:
    'Browse SKAVIA’s full catalog of accountable trade services across residential maintenance, HVAC, electrical, plumbing, IT security, and commercial renovations with transparent BDT pricing and 4-digit arrival OTP.',
};

export default function ServicesCatalogPage() {
  return <ServicesCatalogScreen />;
}
