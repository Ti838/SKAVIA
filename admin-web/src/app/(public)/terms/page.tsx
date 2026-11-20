'use client';

import { LegalDocumentScreen } from '@/features/public-website/LegalDocumentScreen';

export default function TermsAndConditionsPage() {
  return (
    <LegalDocumentScreen
      title="SKAVIA Terms & Conditions"
      titleBn="স্ক্যাভিয়া ব্যবহারের শর্তাবলী"
      subtitle="Service Engagement & Accountability Governance"
      subtitleBn="সেবা গ্রহণ ও দায়বদ্ধতা পরিচালনা বিধিমালা"
      sections={[
        {
          heading: '1. Platform Usage & Escrow Guarantee',
          headingBn: '১. প্ল্যাটফর্ম ব্যবহার ও এসক্রো নিশ্চয়তা',
          body: 'All client bookings, project coordination, worker dispatch, and payments must occur through the official SKAVIA Mobile Application. Off-platform circumvention removes SKAVIA escrow protection, arrival OTP guarantees, and dispute coverage.',
          bodyBn: 'সকল গ্রাহক বুকিং, প্রজেক্ট সমন্বয়, কর্মী বরাদ্দ ও পেমেন্ট অবশ্যই অফিসিয়াল স্ক্যাভিয়া মোবাইল অ্যাপের মাধ্যমে সম্পন্ন হতে হবে। প্ল্যাটফর্মের বাইরে যেকোনো অননুমোদিত লেনদেনে স্ক্যাভিয়া এসক্রো নিরাপত্তা ও বিরোধ নিষ্পত্তির দায়ভার বহন করে না।',
        },
        {
          heading: '2. 4-Digit Physical Arrival Handshake OTP',
          headingBn: '২. ৪-সংখ্যার শারীরিক আগমন হ্যান্ডশেক ওটিপি',
          body: 'Specialist billing timers and official job execution begin exclusively after the client securely provides the 4-digit physical arrival handshake OTP generated inside their mobile app upon verifying the worker’s in-person arrival.',
          bodyBn: 'কর্মীর কাজের সময় এবং বিলিং শুধুমাত্র তখনই শুরু হয় যখন গ্রাহক তার প্রাঙ্গণে কর্মীর সশরীরে উপস্থিতি নিশ্চিত করে অ্যাপে প্রদর্শিত ৪-সংখ্যার গোপন আগমন ওটিপি কর্মীকে প্রদান করেন।',
        },
        {
          heading: '3. Internal Administrative Governance',
          headingBn: '৩. অভ্যন্তরীণ প্রশাসনিক নীতিমালা',
          body: 'Administrative portal access is strictly invitation-only and restricted to authorized SKAVIA personnel within assigned specialization branches and permission boundaries. All sensitive actions are logged in immutable audit trails.',
          bodyBn: 'প্রশাসনিক পোর্টাল শুধুমাত্র আমন্ত্রিত এবং অনুমোদিত কর্মকর্তাদের জন্য উন্মুক্ত। প্রতিটি কার্যকলাপ অপরিবর্তনীয় অডিট ট্রেইলে সংরক্ষিত থাকে এবং কঠোর আরব্যাক নীতি দ্বারা নিয়ন্ত্রিত।',
        },
      ]}
    />
  );
}
