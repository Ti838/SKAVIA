'use client';

import { LegalDocumentScreen } from '@/features/public-website/LegalDocumentScreen';

export default function PrivacyPolicyPage() {
  return (
    <LegalDocumentScreen
      title="SKAVIA Privacy Policy"
      titleBn="স্ক্যাভিয়া গোপনীয়তা নীতি"
      subtitle="Data Protection & Verification Standards"
      subtitleBn="তথ্য সুরক্ষা ও যাচাইকরণ নীতিমালা"
      sections={[
        {
          heading: '1. Account & Verification Data',
          headingBn: '১. অ্যাকাউন্ট ও ভেরিফিকেশন তথ্য',
          body: 'SKAVIA collects essential identity details (such as name, contact number, service location, and worker KYC verification documents) solely to coordinate verified service delivery, safety accountability, and lawful escrow settlements within the SKAVIA mobile ecosystem.',
          bodyBn: 'স্ক্যাভিয়া শুধুমাত্র যাচাইকৃত সেবা ডেলিভারি, নিরাপত্তা জবাবদিহিতা ও আইনসম্মত এসক্রো সেটেলমেন্ট নিশ্চিত করার উদ্দেশ্যে প্রয়োজনীয় তথ্য (যেমন নাম, ফোন নম্বর, সেবার অবস্থান এবং কর্মীদের কেওয়াইসি ভেরিফিকেশন নথিপত্র) সংগ্রহ করে থাকে।',
        },
        {
          heading: '2. Biometric & Passkey Privacy',
          headingBn: '২. বায়োমেট্রিক ও পাসকি গোপনীয়তা',
          body: 'Administrative hardware/OS biometric authentication relies strictly on standard WebAuthn/FIDO2 public-key cryptography. SKAVIA never captures, transmits, or stores raw fingerprint images, facial scans, or biometric templates on its servers.',
          bodyBn: 'প্রশাসনিক হার্ডওয়্যার বা ওএস বায়োমেট্রিক অথেন্টিকেশন সম্পূর্ণরূপে স্ট্যান্ডার্ড WebAuthn/FIDO2 পাবলিক-কি ক্রিপ্টোগ্রাফির মাধ্যমে পরিচালিত হয়। স্ক্যাভিয়া সার্ভারে কোনো অবস্থাতেই ফিঙ্গারপ্রিন্ট বা ফেসিয়াল স্ক্যান সংরক্ষণ বা প্রেরণ করা হয় না।',
        },
        {
          heading: '3. Support & Inquiries',
          headingBn: '৩. সহায়তা ও জিজ্ঞাসা',
          body: 'For privacy inquiries, data subject requests, or account deletion, contact support@skavia.com.',
          bodyBn: 'যেকোনো গোপনীয়তা সংক্রান্ত জিজ্ঞাসা বা ডেটা মুছে ফেলার অনুরোধের জন্য support@skavia.com এ যোগাযোগ করুন।',
        },
      ]}
    />
  );
}
