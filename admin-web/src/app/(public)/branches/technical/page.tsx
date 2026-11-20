import type { Metadata } from 'next';
import { BranchTechnicalScreen } from '@/features/public-website/screens/BranchTechnicalScreen';

export const metadata: Metadata = {
  title: 'SKAVIA Technical — HVAC, Industrial Electrical & Security Systems | SKAVIA',
  description:
    'Commercial and industrial HVAC, inverter AC master chemical servicing, refrigerant leak diagnostics, electrical main DB board load balancing, and IP CCTV surveillance engineering.',
};

export default function BranchTechnicalPage() {
  return <BranchTechnicalScreen />;
}
