import { LegalDocumentScreen } from '@/features/public-website/LegalDocumentScreen';

export default function TermsAndConditionsPage() {
  return (
    <LegalDocumentScreen
      title="SKAVIA Terms & Conditions"
      subtitle="Service Engagement & Accountability Governance"
      sections={[
        {
          heading: '1. Platform Usage',
          body: 'All client bookings, project coordination, worker dispatch, and payments must occur through the official SKAVIA Mobile Application. Off-platform circumvention removes SKAVIA escrow protection, arrival OTP guarantees, and dispute coverage.',
        },
        {
          heading: '2. Internal Administrative Governance',
          body: 'Administrative portal access is strictly invitation-only and restricted to authorized SKAVIA personnel within assigned specialization branches and permission boundaries. All sensitive actions are logged in immutable audit trails.',
        },
      ]}
    />
  );
}

