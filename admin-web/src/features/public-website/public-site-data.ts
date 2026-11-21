import {
  BadgeCheck,
  Briefcase,
  CalendarClock,
  Cpu,
  HardHat,
  Home,
  KeyRound,
  Sparkles,
  Sprout,
  Truck,
  Users,
  Zap,
} from 'lucide-react';

export type WorkflowTab = 'requirement' | 'assembly' | 'delivery';

export interface SpecializationBranch {
  code: string;
  name: string;
  tagline: string;
  scope: string;
  examples: string[];
  accent: string;
  icon: typeof Zap;
}

export interface DistributionInfo {
  android: {
    published: boolean;
    releaseId?: string | null;
    apkUrl: string | null;
    version: string | null;
    buildNumber?: number | null;
    minSupportedBuild?: number | null;
    minSdkVersion?: number | null;
    fileName?: string | null;
    fileSizeBytes?: number | null;
    sha256Checksum?: string | null;
    signingCertSha256?: string | null;
    releaseNotes?: string | null;
    isMandatory?: boolean;
    publishedAt?: string | null;
    channel?: string | null;
    distributionMethod: string;
    armv7Url?: string | null;
    armv7SizeBytes?: number | null;
    armv7Sha256Checksum?: string | null;
  };
  ios: {
    published: boolean;
    storeUrl: string | null;
    distributionMethod: string;
  };
}

export interface PublicThemeTokens {
  dark: boolean;
  railBorder: string;
  surfaceBg: string;
  cardBg: string;
  subtleCardBg: string;
  textPrimary: string;
  textSecondary: string;
  textMuted: string;
  hairlineBg: string;
}

export function getPublicThemeTokens(dark: boolean): PublicThemeTokens {
  return {
    dark,
    railBorder: dark ? 'border-white/[0.1]' : 'border-slate-200',
    surfaceBg: dark ? 'bg-[#05080F]' : 'bg-white',
    cardBg: dark ? 'bg-[#0A0F1C]' : 'bg-slate-50',
    subtleCardBg: dark ? 'bg-[#070B14]' : 'bg-slate-50/70',
    textPrimary: dark ? 'text-white' : 'text-slate-950',
    textSecondary: dark ? 'text-slate-400' : 'text-slate-600',
    textMuted: 'text-slate-500',
    hairlineBg: dark ? 'bg-white/[0.1]' : 'bg-slate-200',
  };
}

export const INITIAL_DISTRIBUTION: DistributionInfo = {
  android: {
    published: true,
    releaseId: 'skavia-v1-0-3-prod',
    apkUrl: '/downloads/skavia-latest.apk',
    version: '1.0.3',
    buildNumber: 4,
    minSupportedBuild: 1,
    minSdkVersion: 24,
    fileName: 'skavia-latest.apk',
    fileSizeBytes: 69728100,
    sha256Checksum: '87eb8abe7fde09a06e32e794d1157a89fb290faef1db2f68003725e2d5a12768',
    signingCertSha256: '9920bf0cfdf2b5dc988be08044709d7936a18d9ef6f272c72b226f95fec1b4a0',
    releaseNotes:
      'SKAVIA v1.0.3 production release. Refined luxury onboarding experience with collision-free dual-track service ecosystem, zero-layout-shift auth screens, real-time OpenStreetMap integration, and multi-host network connectivity.',
    isMandatory: false,
    publishedAt: '2026-11-21T11:20:00.000Z',
    channel: 'stable',
    distributionMethod: 'Official Universal Signed Production APK',
    armv7Url: '/downloads/skavia-v1.0.0-armeabi-v7a.apk',
    armv7SizeBytes: 23594035,
    armv7Sha256Checksum: '3c0603f6178b31fd307cc6b97e46678f6115b2a0e4f4204277735237d40d593e',
  },
  ios: {
    published: false,
    storeUrl: null,
    distributionMethod: 'Planned / Pending App Store Release',
  },
};

export function getSpecializationBranches(isBengali = false): SpecializationBranch[] {
  return [
    {
      code: 'HOME',
      name: isBengali ? 'স্ক্যাভিয়া হোম' : 'SKAVIA Home',
      tagline: isBengali ? 'আবাসিক সমাধান ও নির্ভরযোগ্য মেরামত' : 'Residential Solutions & Maintenance',
      scope: isBengali
        ? 'প্লাম্বিং, ওয়াটারপ্রুফিং, ইন্টেরিয়র ফিনিশিং, কাঠমিস্ত্রি ও হোম অ্যাপ্লায়েন্স মেরামতের জন্য যাচাইকৃত টেকনিশিয়ান।'
        : 'Verified technicians for plumbing, waterproofing, interior finishes, carpentry & appliance care.',
      examples: isBengali
        ? ['স্যানিটারি ডায়াগনস্টিকস', 'হোম ওয়্যারিং ও ইনভার্টার', 'কার্পেন্ট্রি ও ফিনিশিং']
        : ['Sanitary Diagnostics', 'Home Wiring & Inverter', 'Carpentry & Finishing'],
      accent: '#15E7CA',
      icon: Home,
    },
    {
      code: 'AGRI',
      name: isBengali ? 'স্ক্যাভিয়া এগ্রিকালচার' : 'SKAVIA Agriculture',
      tagline: isBengali ? 'কৃষি অবকাঠামো ও কৃষি-প্রযুক্তি পরিচালনা' : 'Farm Infrastructure & Agri-Tech Ops',
      scope: isBengali
        ? 'সেচ ব্যবস্থা স্থাপন, কৃষি যন্ত্রপাতি সার্ভিসিং, কোল্ড-চেইন সহায়তা ও মাঠ পর্যায়ের অপারেশন।'
        : 'Irrigation setups, agricultural machinery servicing, cold-chain support & seasonal field execution.',
      examples: isBengali
        ? ['পাম্প ও সেচ ব্যবস্থা', 'কৃষি যন্ত্রপাতি মেরামত', 'সংরক্ষণাগার ও ইউটিলিটি']
        : ['Pump & Irrigation Systems', 'Agri-Machinery Repair', 'Storage & Utility Ops'],
      accent: '#22C55E',
      icon: Sprout,
    },
    {
      code: 'TECH',
      name: isBengali ? 'স্ক্যাভিয়া টেকনিক্যাল' : 'SKAVIA Technical',
      tagline: isBengali ? 'ইলেকট্রিক্যাল, এইচভিএসি ও সিকিউরিটি সিস্টেম' : 'Electrical, HVAC & Security Systems',
      scope: isBengali
        ? 'শিল্প ও আবাসিক এইচভিএসি/এসি সার্ভিসিং, পাওয়ার বোর্ড, সিসিটিভি গ্রিড ও স্ট্রাকচার্ড ক্যাবলিং।'
        : 'Industrial & residential HVAC servicing, industrial power boards, CCTV grids & structured cabling.',
      examples: isBengali
        ? ['চিলার ও ভিআরএফ এইচভিএসি', 'সিসিটিভি ও অ্যাক্সেস সিকিউরিটি', 'ইলেক্ট্রোমেকানিক্যাল ডায়াগনস্টিকস']
        : ['Chiller & VRF HVAC', 'CCTV & Access Security', 'Electromechanical Diagnostics'],
      accent: '#3898EC',
      icon: Zap,
    },
    {
      code: 'LOGI',
      name: isBengali ? 'স্ক্যাভিয়া লজিস্টিকস' : 'SKAVIA Logistics',
      tagline: isBengali ? 'টেকনিক্যাল ডিসপ্যাচ ও ফিল্ড সরঞ্জাম সরবরাহ' : 'Technical Dispatch & Field Supply',
      scope: isBengali
        ? 'যন্ত্রপাতি স্থানান্তর, ওয়্যারহাউস সেটআপ লজিস্টিকস, সাইট মেটেরিয়াল পরিবহন ও অপারেশনাল সমন্বয়।'
        : 'Equipment shifting, warehouse setup logistics, field material movement & operational coordination.',
      examples: isBengali
        ? ['সাইট সরঞ্জাম স্থানান্তর', 'ওয়্যারহাউস কমিশনিং', 'ফিল্ড মেটেরিয়াল সরবরাহ']
        : ['Site Equipment Shifting', 'Warehouse Commissioning', 'Field Material Runner Ops'],
      accent: '#F59E0B',
      icon: Truck,
    },
    {
      code: 'DIGI',
      name: isBengali ? 'স্ক্যাভিয়া ডিজিটাল' : 'SKAVIA Digital',
      tagline: isBengali ? 'আইটি সিস্টেম, পিওএস ও স্মার্ট নেটওয়ার্ক' : 'IT Systems, POS & Smart Deployment',
      scope: isBengali
        ? 'অফিস নেটওয়ার্ক সেটআপ, পিওএস হার্ডওয়্যার রোলআউট, সার্ভার র্যাক ক্যাবলিং ও ওয়ার্কস্টেশন প্রস্তুতি।'
        : 'Office network deployments, POS hardware rollouts, server rack cabling & workstation readiness.',
      examples: isBengali
        ? ['পিওএস ও টার্মিনাল সেটআপ', 'ল্যান ও ওয়াই-ফাই মেশ', 'স্মার্ট অটোমেশন হার্ডওয়্যার']
        : ['POS & Terminal Rollout', 'LAN / Wi-Fi Mesh', 'Smart Automation Hardware'],
      accent: '#8B5CF6',
      icon: Cpu,
    },
    {
      code: 'BIZ',
      name: isBengali ? 'স্ক্যাভিয়া বিজনেস' : 'SKAVIA Business',
      tagline: isBengali ? 'এসএমই কর্মক্ষেত্র ও বাণিজ্যিক রক্ষণাবেক্ষণ' : 'SME Workspaces & Commercial Upkeep',
      scope: isBengali
        ? 'নিয়মিত ফ্যাসিলিটি সার্ভিসিং, রিটেইল শপ মেইনটেন্যান্স ও সমন্বিত বাণিজ্যিক প্রকল্প পরিচালনা।'
        : 'Recurring facility servicing, retail store maintenance & coordinated commercial project operations.',
      examples: isBengali
        ? ['রিটেইল ফিট-আউট সাপোর্ট', 'প্রতিরোধমূলক মেইনটেন্যান্স এসএলএ', 'মাল্টি-সাইট বাণিজ্যিক অপারেশন']
        : ['Retail Fit-Out Support', 'Preventive Maintenance SLA', 'Multi-Site Commercial Ops'],
      accent: '#EC4899',
      icon: Briefcase,
    },
    {
      code: 'CONS',
      name: isBengali ? 'স্ক্যাভিয়া কনস্ট্রাকশন' : 'SKAVIA Construction',
      tagline: isBengali ? 'সিভিল সংস্কার, রাজমিস্ত্রি ও মেটাল ফ্যাব্রিকেশন' : 'Civil Renovation, Masonry & Fabrication',
      scope: isBengali
        ? 'টিম লিডারের প্রত্যক্ষ তত্ত্বাবধানে স্ট্রাকচারাল মেরামত, স্টিল ওয়ার্ক ও ফিনিশিংয়ের সাইট টিম।'
        : 'Managed site teams led by an assigned Team Leader for structural repair, steel work & finishes.',
      examples: isBengali
        ? ['টার্নকি ইন্টেরিয়র ফিট-আউট', 'স্টিল ও মেটাল ফ্যাব্রিকেশন', 'সিভিল ও স্ট্রাকচারাল মেরামত']
        : ['Turnkey Interior Fit-Out', 'Steel & Metal Fabrication', 'Civil & Structural Repair'],
      accent: '#F97316',
      icon: HardHat,
    },
    {
      code: 'EVNT',
      name: isBengali ? 'স্ক্যাভিয়া ইভেন্টস' : 'SKAVIA Events',
      tagline: isBengali ? 'স্টেজ রিগিং, অডিও-ভিজ্যুয়াল ও টেকনিক্যাল অপারেশন' : 'Stage Rigging, AV & Technical Ops',
      scope: isBengali
        ? 'সাউন্ড ইঞ্জিনিয়ারিং, এলইডি ও লাইটিং গ্রিড, পাওয়ার ব্যাকআপ ও ভেন্যু প্রস্তুতির জন্য সমন্বিত দল।'
        : 'Coordinated crews for sound engineering, LED/lighting grids, power backup & venue readiness.',
      examples: isBengali
        ? ['স্টেজ ও ট্রাস রিগিং', 'লাইভ এভি ও লাইটিং কন্ট্রোল', 'ডেডিকেটেড অন-সাইট ক্রু']
        : ['Stage & Truss Rigging', 'Live AV & Lighting Ops', 'Dedicated On-Site Crew'],
      accent: '#06B6D4',
      icon: Sparkles,
    },
  ];
}

export const SPECIALIZATION_BRANCHES = getSpecializationBranches(false);

export function getWorkflowTabs(isBengali = false): Array<{
  id: WorkflowTab;
  step: string;
  title: string;
  subtitle: string;
}> {
  return [
    {
      id: 'requirement',
      step: isBengali ? '০১ · অনুধাবন' : '01 · Understand',
      title: isBengali ? 'আপনার প্রয়োজন একবার জানান' : 'Explain Your Requirement Once',
      subtitle: isBengali
        ? 'ব্যক্তিগত গ্রাহক বা প্রতিষ্ঠান তাদের কাঙ্ক্ষিত ফলাফল মোবাইল অ্যাপে সরাসরি উল্লেখ করুন — অযাচিত নম্বরে ফোন করার ঝামেলা ছাড়াই।'
        : 'Individuals and organizations describe what outcome they need in the SKAVIA mobile app — without hunting unverified listings.',
    },
    {
      id: 'assembly',
      step: isBengali ? '০২ · সমাবেশ' : '02 · Assemble',
      title: isBengali ? 'সঠিক দক্ষ ব্যক্তি বা টিম লিডারসহ দল' : 'Right Individual or Team + Leader',
      subtitle: isBengali
        ? 'স্ক্যাভিয়া দক্ষতার মাত্রা বিশ্লেষণ করে অভ্যন্তরীণ উপযুক্ত শাখা সক্রিয় করে এবং একক স্পেশালিস্ট কিংবা টিম লিডারসহ সমন্বিত দল বরাদ্দ করে।'
        : 'SKAVIA identifies required skills, activates the appropriate internal specialization branch, and assigns either a verified specialist or a structured team with a Team Leader.',
    },
    {
      id: 'delivery',
      step: isBengali ? '০৩ · ডেলিভারি' : '03 · Deliver',
      title: isBengali ? 'ট্র্যাকড বাস্তবায়ন, নিরাপদ এসক্রো ও রেপুটেশন' : 'Tracked Execution, Settlement & Reputation',
      subtitle: isBengali
        ? 'শারীরিক আগমন নিশ্চিতকরণ (৪-সংখ্যার ওটিপি), স্বচ্ছ কাজের অগ্রগতি, সুরক্ষিত এসক্রো পেমেন্ট ও স্থায়ী রেপুটেশন রেকর্ড।'
        : 'Physical arrival verification, transparent progress coordination, protected escrow settlement, confirmed completion, and permanent review history.',
    },
  ];
}

export const WORKFLOW_TABS = getWorkflowTabs(false);

export function getLifecycleSteps(isBengali = false): Array<{
  n: string;
  title: string;
  desc: string;
}> {
  return [
    {
      n: isBengali ? '১' : '1',
      title: isBengali ? 'রিকোয়ারমেন্ট গ্রহণ' : 'Requirement Capture',
      desc: isBengali
        ? 'গ্রাহক বা প্রতিষ্ঠান কাজের বিবরণ, লোকেশন ও কাঙ্ক্ষিত ফলাফল স্ক্যাভিয়া অ্যাপে প্রদান করেন।'
        : 'Client or business describes the task, site location, and outcome inside the SKAVIA app.',
    },
    {
      n: isBengali ? '২' : '2',
      title: isBengali ? 'দক্ষতা ও শাখা ম্যাপিং' : 'Skill & Branch Mapping',
      desc: isBengali
        ? 'স্ক্যাভিয়ার কোর ইঞ্জিন সঠিক অভ্যন্তরীণ শাখা ও অভিজ্ঞ স্পেশালিস্ট ম্যাপিং সম্পন্ন করে।'
        : 'SKAVIA routes the request to the right internal specialization branch and skill set.',
    },
    {
      n: isBengali ? '৩' : '3',
      title: isBengali ? 'স্পেশালিস্ট বা টিম + লিডার' : 'Worker or Team + Leader',
      desc: isBengali
        ? 'নির্দিষ্ট কাজের জন্য একক কর্মী এবং বড় প্রকল্পের জন্য টিম লিডারসহ বহু-দক্ষ দল গঠিত হয়।'
        : 'Single specialist assigned for focused jobs, or multi-skill team with a Team Leader for projects.',
    },
    {
      n: isBengali ? '৪' : '4',
      title: isBengali ? 'তত্ত্বাবধানে বাস্তবায়ন ও আগমন ওটিপি' : 'Supervised Execution & OTP',
      desc: isBengali
        ? '৪-সংখ্যার গোপন আগমন ওটিপির মাধ্যমে কর্মীর উপস্থিতি নিশ্চিত করে কাজের সূচনা ও অগ্রগতি পর্যবেক্ষণ।'
        : 'Physical arrival verification, live progress updates, and quality oversight.',
    },
    {
      n: isBengali ? '৫' : '5',
      title: isBengali ? 'নিরাপদ এসক্রো সেটেলমেন্ট' : 'Protected Escrow Settlement',
      desc: isBengali
        ? 'গ্রাহকের সন্তুষ্টি ও কাজ সমাপ্তি নিশ্চিত হওয়ার পর স্বয়ংক্রিয়ভাবে স্বচ্ছ এসক্রো ফান্ড রিলিজ।'
        : 'Transparent commission split and protected payouts once completion is confirmed.',
    },
    {
      n: isBengali ? '৬' : '6',
      title: isBengali ? 'রেটিং ও পেশাদার সুনাম' : 'Ratings & Reputation',
      desc: isBengali
        ? 'প্রকৃত কাজের যাচাইকৃত রেটিং কর্মীর স্থায়ী সুনাম গড়ে তোলে এবং ভবিষ্যতের কাজ প্রাপ্তিতে অগ্রাধিকার দেয়।'
        : 'Verified reviews strengthen worker reputation scores across future dispatches.',
    },
  ];
}

export const LIFECYCLE_STEPS = getLifecycleSteps(false);

export function getIndividualHighlights(isBengali = false): string[] {
  return isBengali
    ? [
        'জাতীয় পরিচয়পত্র ও দক্ষতা যাচাইকৃত কর্মী নিকটবর্তী দূরত্ব বিবেচনায় বরাদ্দ',
        'কাজ শুরুর পূর্বে ৪-সংখ্যার গোপন আগমন হ্যান্ডশেক ওটিপি',
        'স্বচ্ছ নির্ধারিত সেবামূল্য এবং সুস্পষ্ট বিরোধ নিষ্পত্তি গ্যারান্টি',
      ]
    : [
        'Identity-checked & skill-verified workers matched by proximity',
        '4-digit physical arrival handshake OTP before work starts',
        'Transparent service rates and clear dispute protection',
      ];
}

export const INDIVIDUAL_HIGHLIGHTS = getIndividualHighlights(false);

export function getBusinessHighlights(isBengali = false): string[] {
  return isBengali
    ? [
        'একক প্রাতিষ্ঠানিক দায়িত্বে একাধিক শাখার সমন্বয়ে মাল্টি-ট্রেড টিম গঠন',
        'দায়িত্বপ্রাপ্ত টিম লিডারের প্রত্যক্ষ তত্ত্বাবধান, সময়সূচি ও মান নিয়ন্ত্রণ',
        'ধাপভিত্তিক মাইলস্টোন অগ্রগতি, প্রাতিষ্ঠানিক ইনভয়েস ও লিখিত সাইন-অফ',
      ]
    : [
        'Team assembly across multiple branches under single accountability',
        'Designated Team Leader coordinates schedules & quality checkpoints',
        'Structured milestone progress, invoices & documented completion sign-off',
      ];
}

export const BUSINESS_HIGHLIGHTS = getBusinessHighlights(false);

export function getWorkerOnboardingSteps(isBengali = false): Array<{
  step: string;
  detail: string;
}> {
  return [
    {
      step: isBengali ? 'ধাপ ১ · অ্যাপ ইনস্টল ও সাইন আপ' : 'Step 1 · Install & Sign Up',
      detail: isBengali
        ? 'স্ক্যাভিয়া অ্যাপটি ডাউনলোড করুন এবং গুগল, ফোন ওটিপি অথবা ইমেইল দিয়ে সাইন আপ করুন।'
        : 'Download the SKAVIA app and sign up with Google, Phone OTP, or Email.',
    },
    {
      step: isBengali ? 'ধাপ ২ · ওয়ার্কার মোডে যান ও কেওয়াইসি জমা দিন' : 'Step 2 · Switch to Worker Mode & Verify KYC',
      detail: isBengali
        ? 'আপনার জাতীয় পরিচয়পত্র (NID), অভিজ্ঞতার ক্ষেত্র ও ভৌগোলিক লোকেশন তথ্য প্রশাসনিক পর্যালোচনার জন্য জমা দিন।'
        : 'Submit National ID (NID), specialization skills, and location details for review.',
    },
    {
      step: isBengali ? 'ধাপ ৩ · কাজ গ্রহণ করুন ও টিম লিডার হোন' : 'Step 3 · Receive Assignments & Lead Teams',
      detail: isBengali
        ? 'অনুমোদনের পর একক কাজের অর্ডার গ্রহণ করুন, দলগত প্রকল্পে অংশ নিন বা টিম লিডার পদে পদোন্নতি পান।'
        : 'Once approved, accept individual jobs, collaborate inside teams, or advance to Team Leader.',
    },
    {
      step: isBengali ? 'ধাপ ৪ · ৯০% সরাসরি আয় ও সাপ্তাহিক পেমেন্ট' : 'Step 4 · 90% Direct Payout & Settlements',
      detail: isBengali
        ? 'প্রতিটি কাজের মোট মূল্যের ৯০% সরাসরি আপনার অ্যাকাউন্টে জমা হবে এবং সাপ্তাহিক নিরাপদ ব্যাংক বা এমএফএস উইথড্রয়াল পাবেন।'
        : 'Earn 90% direct payout on every customer booking with guaranteed weekly bank or MFS settlements upon completion.',
    },
  ];
}

export const WORKER_ONBOARDING_STEPS = getWorkerOnboardingSteps(false);

export function getMobileFeatures(isBengali = false): Array<{
  icon: typeof Users;
  title: string;
  desc: string;
}> {
  return [
    {
      icon: Users,
      title: isBengali ? 'সমন্বিত ক্লায়েন্ট ও ওয়ার্কার মোড' : 'Unified Client & Worker Mode',
      desc: isBengali
        ? 'একটি অ্যাপেই কোনো অতিরিক্ত একাউন্ট ছাড়াই ক্লায়েন্ট ও কর্মী মোডে সহজে স্যুইচ করুন।'
        : 'Switch seamlessly inside your verified mobile profile without duplicate accounts.',
    },
    {
      icon: KeyRound,
      title: isBengali ? '৪-সংখ্যার কাজ শুরুর ওটিপি' : '4-Digit Job Start OTP',
      desc: isBengali
        ? 'আপনার ঠিকানায় কর্মীর শারীরিক আগমন নিশ্চিত না হওয়া পর্যন্ত কোনো বিলিং গণনা শুরু হয় না।'
        : 'Confirms physical worker arrival at your site before billing timers begin.',
    },
    {
      icon: CalendarClock,
      title: isBengali ? 'প্রকল্প ও টিম পরিচালনা' : 'Project & Team Coordination',
      desc: isBengali
        ? 'রিয়েল-টাইম যোগাযোগ, কাজের অগ্রগতি পর্যবেক্ষণ এবং টিম লিডারের তত্ত্বাবধান টুলস।'
        : 'Real-time communication, task progress tracking, and Team Leader leadership tools.',
    },
    {
      icon: BadgeCheck,
      title: isBengali ? 'রেপুটেশন ও এসক্রো রেকর্ড' : 'Reputation & Escrow History',
      desc: isBengali
        ? 'শতভাগ স্বচ্ছ পেমেন্ট হিস্ট্রি, স্পষ্ট কমিশন এবং যাচাইকৃত কাজের রেটিং ব্যবস্থাপনা।'
        : 'Full payment transparency, commission clarity, and verified work ratings.',
    },
  ];
}

export const MOBILE_FEATURES = getMobileFeatures(false);

export function getFaqItems(isBengali = false): Array<{
  q: string;
  a: string;
}> {
  return [
    {
      q: isBengali
        ? 'স্ক্যাভিয়া কি একটি উন্মুক্ত ফ্রিল্যান্স মার্কেটপ্লেস নাকি সরাসরি পরিচালিত সেবা প্ল্যাটফর্ম?'
        : 'Is SKAVIA an open freelance marketplace or a managed service platform?',
      a: isBengali
        ? 'স্ক্যাভিয়া কোনো উন্মুক্ত বিজ্ঞাপনী সাইট বা মধ্যস্বত্বভোগী ফ্রিল্যান্স মার্কেটপ্লেস নয়। এটি ৮টি বিশেষায়িত শাখার সমন্বয়ে একক প্রতিষ্ঠান হিসেবে পরিচালিত। ক্লায়েন্টকে নম্বর দিয়ে ছেড়ে না দিয়ে, স্ক্যাভিয়া প্রয়োজন বিশ্লেষণ করে, যাচাইকৃত কর্মী বা টিম লিডারসহ দল পাঠায় এবং কাজের সন্তোষজনক সমাপ্তি পর্যন্ত পূর্ণ দায়িত্ব নেয়।'
        : 'SKAVIA is a unified solution-oriented service and workforce platform operated by one company through specialized internal branches. Instead of leaving clients alone with unverified profiles, SKAVIA understands the requirement, selects verified workers or forms a coordinated team with a Team Leader, and governs delivery through completion.',
    },
    {
      q: isBengali
        ? 'গ্রাহক ও কর্মীরা কীভাবে স্ক্যাভিয়ায় নিবন্ধন বা সেবা গ্রহণ শুরু করবেন?'
        : 'How do clients and workers register or start using SKAVIA?',
      a: isBengali
        ? 'সকল গ্রাহক সেবা অর্ডার, প্রজেক্ট সমন্বয় এবং কর্মীদের নিবন্ধন সম্পূর্ণভাবে অফিসিয়াল স্ক্যাভিয়া মোবাইল অ্যাপের মাধ্যমে সম্পন্ন হয় (একটি অ্যাপেই ক্লায়েন্ট মোড এবং কেওয়াইসি যাচাইকৃত ওয়ার্কার মোড অন্তর্ভুক্ত)। ওয়েবসাইটে কোনো উন্মুক্ত পাবলিক অ্যাকাউন্ট খোলার প্রয়োজন নেই।'
        : 'All customer requests, service orders, project coordination, and worker onboarding take place exclusively through the official SKAVIA Mobile Application (one app supporting unified Client Mode and Worker Mode after KYC verification). There is no separate public web app account signup.',
    },
    {
      q: isBengali
        ? 'স্ক্যাভিয়ার ৮টি বিশেষায়িত অপারেশনাল শাখা কী কী?'
        : 'What are the 8 SKAVIA Specialization Branches?',
      a: isBengali
        ? 'স্ক্যাভিয়ার ৮টি অভ্যন্তরীণ শাখা হলো: হোম, এগ্রিকালচার, টেকনিক্যাল, লজিস্টিকস, ডিজিটাল, বিজনেস, কনস্ট্রাকশন এবং ইভেন্টস। এগুলো পৃথক কোনো বাইরের কোম্পানি নয়, বরং স্ক্যাভিয়ার কেন্দ্রীয় তত্ত্বাবধানে পরিচালিত অপারেশনাল ইউনিট।'
        : 'SKAVIA operates specialized internal branches under one accountable organization: Home, Agriculture, Technical, Logistics, Digital, Business, Construction, and Events. These are operational specialization units, not independent third-party companies.',
    },
    {
      q: isBengali
        ? 'দক্ষ পেশাজীবী ও কারিগররা কীভাবে স্ক্যাভিয়ায় কর্মী হিসেবে যুক্ত হবেন?'
        : 'How can skilled professionals join as a SKAVIA Worker?',
      a: isBengali
        ? 'অফিসিয়াল স্ক্যাভিয়া অ্যান্ড্রয়েড অ্যাপ ডাউনলোড করুন, গুগল/ফোন নম্বর/ইমেইল দিয়ে অ্যাকাউন্ট তৈরি করে ওয়ার্কার মোডে আপনার জাতীয় পরিচয়পত্র (NID) ও দক্ষতার প্রমাণপত্র জমা দিন। এডমিন ভেরিফিকেশন সম্পন্ন হলেই আপনি কাজ গ্রহণ ও টিম লিডার হওয়ার যোগ্যতা অর্জন করবেন।'
        : 'Download the official SKAVIA Mobile App, create your mobile account using Google, Phone OTP, or Email, complete identity (NID) and skill verification in Worker Mode, and await administrative verification approval before receiving assignments or Team Leader roles.',
    },
  ];
}

export const FAQ_ITEMS = getFaqItems(false);
