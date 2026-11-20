import type { Metadata } from 'next';
import { SpecialistsScreen } from '@/features/public-website/screens/SpecialistsScreen';

export const metadata: Metadata = {
  title: 'For Skilled Specialists — 90% Direct Pay & Dignity of Labor | SKAVIA',
  description:
    'Join SKAVIA as a verified field trade specialist across Bangladesh. Enjoy 90% direct earnings share, zero broker cuts, weekly bank and bKash/Nagad settlements, and professional equipment support.',
};

export default function SpecialistsPage() {
  return <SpecialistsScreen />;
}
