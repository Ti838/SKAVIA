import { LegalDocumentScreen } from '@/features/public-website/LegalDocumentScreen';

export default function PrivacyPolicyPage() {
  return (
    <LegalDocumentScreen
      title="SKAVIA Privacy Policy"
      subtitle="Data Protection & Verification Standards"
      sections={[
        {
          heading: '1. Account & Verification Data',
          body: 'SKAVIA collects essential identity details (such as name, contact number, service location, and worker KYC verification documents) solely to coordinate verified service delivery, safety accountability, and lawful escrow settlements within the SKAVIA mobile ecosystem.',
        },
        {
          heading: '2. Biometric & Passkey Privacy',
          body: 'Administrative hardware/OS biometric authentication relies strictly on standard WebAuthn/FIDO2 public-key cryptography. SKAVIA never captures, transmits, or stores raw fingerprint images, facial scans, or biometric templates on its servers.',
        },
        {
          heading: '3. Support & Inquiries',
          body: 'For privacy or data deletion inquiries, contact support@skavia.com.',
        },
      ]}
    />
  );
}

