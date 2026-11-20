import type { Metadata } from 'next';
import { ContactScreen } from '@/features/public-website/screens/ContactScreen';

export const metadata: Metadata = {
  title: 'Contact SKAVIA — Central Operations Desk & Headquarters | SKAVIA',
  description:
    'Contact SKAVIA’s central operations command desk in Gulshan-2, Dhaka. Phone dispatch helpline, verified operational emails, emergency escalation channels, and enterprise inquiries.',
};

export default function ContactPage() {
  return <ContactScreen />;
}
