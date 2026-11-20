import type { Metadata } from 'next';
import { BusinessSolutionsScreen } from '@/features/public-website/screens/BusinessSolutionsScreen';

export const metadata: Metadata = {
  title: 'Business & Enterprise Solutions — Turnkey Commercial Facilities | SKAVIA',
  description:
    'Commercial facility maintenance, turnkey office renovations, multi-site retail fit-outs, and dedicated on-site Team Leaders under single-enterprise corporate contracts across Bangladesh.',
};

export default function BusinessSolutionsPage() {
  return <BusinessSolutionsScreen />;
}
