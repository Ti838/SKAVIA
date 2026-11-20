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
    releaseId: 'skavia-v1-0-0-prod',
    apkUrl: '/downloads/skavia-v1.0.0-arm64-v8a.apk',
    version: '1.0.0',
    buildNumber: 1,
    minSupportedBuild: 1,
    minSdkVersion: 24,
    fileName: 'skavia-v1.0.0-arm64-v8a.apk',
    fileSizeBytes: 23668477, // 22.57 MB - verified release build
    sha256Checksum: 'c2ff57a1c6c6b64f1f52ecff435419bb63353486e4940cdb853b04b64ec365e3',
    signingCertSha256: '9920bf0cfdf2b5dc988be08044709d7936a18d9ef6f272c72b226f95fec1b4a0',
    releaseNotes: 'SKAVIA v1.0.0 official production release. Ultra-compact 22.6 MB optimized release APK with dual Client & Worker modes, live geolocation dispatch, 4-digit arrival OTP, and protected escrow settlement.',
    isMandatory: false,
    publishedAt: '2026-11-19T02:30:00.000Z',
    channel: 'stable',
    distributionMethod: 'Official Signed Production APK (ARM64 & ARMv7)',
    armv7Url: '/downloads/skavia-v1.0.0-armeabi-v7a.apk',
    armv7SizeBytes: 21257429, // 20.27 MB
    armv7Sha256Checksum: '3c0603f6178b31fd307cc6b97e46678f6115b2a0e4f4204277735237d40d593e',
  },
  ios: {
    published: false,
    storeUrl: null,
    distributionMethod: 'Planned / Pending App Store Release',
  },
};

export const SPECIALIZATION_BRANCHES: SpecializationBranch[] = [
  {
    code: 'HOME',
    name: 'SKAVIA Home',
    tagline: 'Residential Solutions & Maintenance',
    scope: 'Verified technicians for plumbing, waterproofing, interior finishes, carpentry & appliance care.',
    examples: ['Sanitary Diagnostics', 'Home Wiring & Inverter', 'Carpentry & Finishing'],
    accent: '#15E7CA',
    icon: Home,
  },
  {
    code: 'AGRI',
    name: 'SKAVIA Agriculture',
    tagline: 'Farm Infrastructure & Agri-Tech Ops',
    scope: 'Irrigation setups, agricultural machinery servicing, cold-chain support & seasonal field execution.',
    examples: ['Pump & Irrigation Systems', 'Agri-Machinery Repair', 'Storage & Utility Ops'],
    accent: '#22C55E',
    icon: Sprout,
  },
  {
    code: 'TECH',
    name: 'SKAVIA Technical',
    tagline: 'Electrical, HVAC & Security Systems',
    scope: 'Industrial & residential HVAC servicing, industrial power boards, CCTV grids & structured cabling.',
    examples: ['Chiller & VRF HVAC', 'CCTV & Access Security', 'Electromechanical Diagnostics'],
    accent: '#3898EC',
    icon: Zap,
  },
  {
    code: 'LOGI',
    name: 'SKAVIA Logistics',
    tagline: 'Technical Dispatch & Field Supply',
    scope: 'Equipment shifting, warehouse setup logistics, field material movement & operational coordination.',
    examples: ['Site Equipment Shifting', 'Warehouse Commissioning', 'Field Material Runner Ops'],
    accent: '#F59E0B',
    icon: Truck,
  },
  {
    code: 'DIGI',
    name: 'SKAVIA Digital',
    tagline: 'IT Systems, POS & Smart Deployment',
    scope: 'Office network deployments, POS hardware rollouts, server rack cabling & workstation readiness.',
    examples: ['POS & Terminal Rollout', 'LAN / Wi-Fi Mesh', 'Smart Automation Hardware'],
    accent: '#8B5CF6',
    icon: Cpu,
  },
  {
    code: 'BIZ',
    name: 'SKAVIA Business',
    tagline: 'SME Workspaces & Commercial Upkeep',
    scope: 'Recurring facility servicing, retail store maintenance & coordinated commercial project operations.',
    examples: ['Retail Fit-Out Support', 'Preventive Maintenance SLA', 'Multi-Site Commercial Ops'],
    accent: '#EC4899',
    icon: Briefcase,
  },
  {
    code: 'CONS',
    name: 'SKAVIA Construction',
    tagline: 'Civil Renovation, Masonry & Fabrication',
    scope: 'Managed site teams led by an assigned Team Leader for structural repair, steel work & finishes.',
    examples: ['Turnkey Interior Fit-Out', 'Steel & Metal Fabrication', 'Civil & Structural Repair'],
    accent: '#F97316',
    icon: HardHat,
  },
  {
    code: 'EVNT',
    name: 'SKAVIA Events',
    tagline: 'Stage Rigging, AV & Technical Ops',
    scope: 'Coordinated crews for sound engineering, LED/lighting grids, power backup & venue readiness.',
    examples: ['Stage & Truss Rigging', 'Live AV & Lighting Ops', 'Dedicated On-Site Crew'],
    accent: '#06B6D4',
    icon: Sparkles,
  },
];

export const WORKFLOW_TABS: Array<{
  id: WorkflowTab;
  step: string;
  title: string;
  subtitle: string;
}> = [
  {
    id: 'requirement',
    step: '01 · Understand',
    title: 'Explain Your Requirement Once',
    subtitle: 'Individuals and organizations describe what outcome they need in the SKAVIA mobile app — without hunting unverified listings.',
  },
  {
    id: 'assembly',
    step: '02 · Assemble',
    title: 'Right Individual or Team + Leader',
    subtitle: 'SKAVIA identifies required skills, activates the appropriate internal specialization branch, and assigns either a verified specialist or a structured team with a Team Leader.',
  },
  {
    id: 'delivery',
    step: '03 · Deliver',
    title: 'Tracked Execution, Settlement & Reputation',
    subtitle: 'Physical arrival verification, transparent progress coordination, protected escrow settlement, confirmed completion, and permanent review history.',
  },
];

export const LIFECYCLE_STEPS = [
  {
    n: '1',
    title: 'Requirement Capture',
    desc: 'Client or business describes the task, site location, and outcome inside the SKAVIA app.',
  },
  {
    n: '2',
    title: 'Skill & Branch Mapping',
    desc: 'SKAVIA routes the request to the right internal specialization branch and skill set.',
  },
  {
    n: '3',
    title: 'Worker or Team + Leader',
    desc: 'Single specialist assigned for focused jobs, or multi-skill team with a Team Leader for projects.',
  },
  {
    n: '4',
    title: 'Supervised Execution & OTP',
    desc: 'Physical arrival verification, live progress updates, and quality oversight.',
  },
  {
    n: '5',
    title: 'Protected Escrow Settlement',
    desc: 'Transparent commission split and protected payouts once completion is confirmed.',
  },
  {
    n: '6',
    title: 'Ratings & Reputation',
    desc: 'Verified reviews strengthen worker reputation scores across future dispatches.',
  },
];

export const INDIVIDUAL_HIGHLIGHTS = [
  'Identity-checked & skill-verified workers matched by proximity',
  '4-digit physical arrival handshake OTP before work starts',
  'Transparent service rates and clear dispute protection',
];

export const BUSINESS_HIGHLIGHTS = [
  'Team assembly across multiple branches under single accountability',
  'Designated Team Leader coordinates schedules & quality checkpoints',
  'Structured milestone progress, invoices & documented completion sign-off',
];

export const WORKER_ONBOARDING_STEPS = [
  {
    step: 'Step 1 · Install & Sign Up',
    detail: 'Download the SKAVIA app and sign up with Google, Phone OTP, or Email.',
  },
  {
    step: 'Step 2 · Switch to Worker Mode & Verify KYC',
    detail: 'Submit National ID (NID), specialization skills, and location details for review.',
  },
  {
    step: 'Step 3 · Receive Assignments & Lead Teams',
    detail: 'Once approved, accept individual jobs, collaborate inside teams, or advance to Team Leader.',
  },
];

export const MOBILE_FEATURES = [
  {
    icon: Users,
    title: 'Unified Client & Worker Mode',
    desc: 'Switch seamlessly inside your verified mobile profile without duplicate accounts.',
  },
  {
    icon: KeyRound,
    title: '4-Digit Job Start OTP',
    desc: 'Confirms physical worker arrival at your site before billing timers begin.',
  },
  {
    icon: CalendarClock,
    title: 'Project & Team Coordination',
    desc: 'Real-time communication, task progress tracking, and Team Leader leadership tools.',
  },
  {
    icon: BadgeCheck,
    title: 'Reputation & Escrow History',
    desc: 'Full payment transparency, commission clarity, and verified work ratings.',
  },
];

export const FAQ_ITEMS = [
  {
    q: 'Is SKAVIA an open freelance marketplace or a managed service platform?',
    a: 'SKAVIA is a unified solution-oriented service and workforce platform operated by one company through specialized internal branches. Instead of leaving clients alone with unverified profiles, SKAVIA understands the requirement, selects verified workers or forms a coordinated team with a Team Leader, and governs delivery through completion.',
  },
  {
    q: 'How do clients and workers register or start using SKAVIA?',
    a: 'All customer requests, service orders, project coordination, and worker onboarding take place exclusively through the official SKAVIA Mobile Application (one app supporting unified Client Mode and Worker Mode after KYC verification). There is no separate public web app account signup.',
  },
  {
    q: 'What are the 8 SKAVIA Specialization Branches?',
    a: 'SKAVIA operates specialized internal branches under one accountable organization: Home, Agriculture, Technical, Logistics, Digital, Business, Construction, and Events. These are operational specialization units, not independent third-party companies.',
  },
  {
    q: 'How can skilled professionals join as a SKAVIA Worker?',
    a: 'Download the official SKAVIA Mobile App, create your mobile account using Google, Phone OTP, or Email, complete identity (NID) and skill verification in Worker Mode, and await administrative verification approval before receiving assignments or Team Leader roles.',
  },
];

