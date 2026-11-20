'use client';

import { useState } from 'react';
import {
  ArrowRight,
  Building2,
  CheckCircle2,
  Cpu,
  HardHat,
  Home,
  KeyRound,
  Play,
  ShieldCheck,
  Smartphone,
  Sparkles,
  Sprout,
  Wrench,
  Zap,
} from 'lucide-react';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import { CinematicAtmosphereCanvas } from './CinematicAtmosphereCanvas';
import { CinematicStoryModal } from './CinematicStoryModal';
import {
  getBusinessHighlights,
  getIndividualHighlights,
  getLifecycleSteps,
  getSpecializationBranches,
  getWorkflowTabs,
  type PublicThemeTokens,
  type WorkflowTab,
} from './public-site-data';

interface ScopingSuggestion {
  queryEn: string;
  queryBn: string;
  branchCode: string;
  branchNameEn: string;
  branchNameBn: string;
  priceEn: string;
  priceBn: string;
  slaEn: string;
  slaBn: string;
  icon: typeof Zap;
  accent: string;
}

const SCOPING_SUGGESTIONS: ScopingSuggestion[] = [
  {
    queryEn: 'AC Cooling & Servicing',
    queryBn: 'এসি কুলিং ও সার্ভিসিং',
    branchCode: 'TECH',
    branchNameEn: 'SKAVIA Technical',
    branchNameBn: 'স্ক্যাভিয়া টেকনিক্যাল',
    priceEn: '৳ 1,200 – ৳ 2,500',
    priceBn: '৳ ১,২০০ – ৳ ২,৫০০',
    slaEn: 'Specialist dispatched in 45m',
    slaBn: '৪৫ মিনিটে স্পেশালিস্ট নিশ্চিতকরণ',
    icon: Zap,
    accent: '#3898EC',
  },
  {
    queryEn: 'Plumbing & Pipe Leakage',
    queryBn: 'প্লাম্বিং ও পাইপ লিকেজ মেরামত',
    branchCode: 'HOME',
    branchNameEn: 'SKAVIA Home',
    branchNameBn: 'স্ক্যাভিয়া হোম',
    priceEn: '৳ 600 – ৳ 1,500',
    priceBn: '৳ ৬০০ – ৳ ১,৫০০',
    slaEn: 'Urgent response available',
    slaBn: 'জরুরি সেবা উপলব্ধ',
    icon: Home,
    accent: '#15E7CA',
  },
  {
    queryEn: 'LAN Network & CCTV Setup',
    queryBn: 'অফিস নেটওয়ার্ক ও সিসিটিভি',
    branchCode: 'DIGI',
    branchNameEn: 'SKAVIA Digital',
    branchNameBn: 'স্ক্যাভিয়া ডিজিটাল',
    priceEn: '৳ 1,800 – ৳ 4,000',
    priceBn: '৳ ১,৮০০ – ৳ ৪,০০০',
    slaEn: 'Hardware diagnostics included',
    slaBn: 'হার্ডওয়্যার ডায়াগনস্টিকস অন্তর্ভুক্ত',
    icon: Cpu,
    accent: '#8B5CF6',
  },
  {
    queryEn: 'Office Civil & Interior Fit-Out',
    queryBn: 'অফিস রেনোভেশন ও ইন্টেরিয়র',
    branchCode: 'CONS',
    branchNameEn: 'SKAVIA Construction',
    branchNameBn: 'স্ক্যাভিয়া কনস্ট্রাকশন',
    priceEn: 'Milestone Escrow Contract',
    priceBn: 'ধাপভিত্তিক এসক্রো চুক্তি',
    slaEn: 'Led by designated Team Leader',
    slaBn: 'টিম লিডারের প্রত্যক্ষ তত্ত্বাবধান',
    icon: HardHat,
    accent: '#F97316',
  },
  {
    queryEn: 'Agri-Machinery & Irrigation Pump',
    queryBn: 'কৃষি যন্ত্রপাতি ও সেচ পাম্প',
    branchCode: 'AGRI',
    branchNameEn: 'SKAVIA Agriculture',
    branchNameBn: 'স্ক্যাভিয়া এগ্রিকালচার',
    priceEn: '৳ 1,500 – ৳ 3,500',
    priceBn: '৳ ১,৫০০ – ৳ ৩,৫০০',
    slaEn: 'Seasonal field specialists',
    slaBn: 'মাঠ পর্যায়ের অভিজ্ঞ মেকানিক',
    icon: Sprout,
    accent: '#22C55E',
  },
  {
    queryEn: 'Event Stage & Truss Rigging',
    queryBn: 'স্টেজ রিগিং ও অডিও-ভিজ্যুয়াল',
    branchCode: 'EVNT',
    branchNameEn: 'SKAVIA Events',
    branchNameBn: 'স্ক্যাভিয়া ইভেন্টস',
    priceEn: 'Managed Production Crew',
    priceBn: 'পূর্ণাঙ্গ প্রোডাকশন টিম',
    slaEn: 'Dedicated on-site crew',
    slaBn: 'সাইটে নিয়োজিত কারিগরি দল',
    icon: Sparkles,
    accent: '#06B6D4',
  },
];

export function HeroSection({ t: theme }: { t: PublicThemeTokens }) {
  const { isBengali } = useTranslation();
  const [activeSuggestionIdx, setActiveSuggestionIdx] = useState(0);
  const [isStoryOpen, setIsStoryOpen] = useState(false);
  const activeScoping = SCOPING_SUGGESTIONS[activeSuggestionIdx] ?? SCOPING_SUGGESTIONS[0]!;
  const ActiveIcon = activeScoping.icon;

  return (
    <section className="relative overflow-hidden pt-12 pb-20 sm:pt-20 sm:pb-28 transition-colors">
      {/* Background Cinematic Atmosphere */}
      <CinematicAtmosphereCanvas dark={theme.dark} />

      {/* Radiant Ambient Radial Glows */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[850px] h-[450px] bg-gradient-to-tr from-[#003399]/25 via-[#15E7CA]/15 to-transparent rounded-full blur-3xl pointer-events-none" />

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        {/* Glowing Badge */}
        <div className="inline-flex items-center gap-2 rounded-full border border-blue-500/30 bg-blue-500/10 px-4 py-1.5 text-xs font-semibold backdrop-blur-md mb-6 shadow-sm">
          <span className="h-2 w-2 rounded-full bg-[#15E7CA] animate-pulse" />
          <span className="text-slate-800 dark:text-cyan-200">
            {isBengali
              ? 'বাংলাদেশে সক্রিয় · ৮টি বিশেষায়িত অপারেশনাল শাখা · একক প্রাতিষ্ঠানিক দায়িত্ব'
              : 'Live in Bangladesh · 8 Specialization Branches · Single Corporate Accountability'}
          </span>
        </div>

        {/* Hero Title */}
        <h1 className="font-heading font-extrabold text-4xl sm:text-6xl md:text-7xl tracking-tight leading-[1.08] max-w-5xl mx-auto">
          {isBengali ? (
            <>
              আপনার প্রয়োজন জানান।
              <span className="block mt-2 bg-gradient-to-r from-[#003399] via-[#3898EC] to-[#15E7CA] bg-clip-text text-transparent">
                স্ক্যাভিয়া পৌঁছে দেবে সমাধান।
              </span>
            </>
          ) : (
            <>
              Every Skilled Service.
              <span className="block mt-2 bg-gradient-to-r from-[#003399] via-[#3898EC] to-[#15E7CA] bg-clip-text text-transparent">
                One Accountable Platform.
              </span>
            </>
          )}
        </h1>

        {/* Subtitle */}
        <p className="mt-6 max-w-3xl mx-auto text-base sm:text-lg leading-relaxed text-slate-600 dark:text-slate-300">
          {isBengali
            ? 'অযাচিত নম্বরে কল করার দিন শেষ। আবাসিক মেরামত, ইন্ডাস্ট্রিয়াল টেকনিক্যাল সার্ভিস ও করপোরেট প্রজেক্টের জন্য যাচাইকৃত দক্ষ কর্মী ও টিম লিডার সরাসরি পান স্ক্যাভিয়ায়।'
            : 'Say goodbye to unverified classifieds. SKAVIA understands your requirement, matches NID-verified specialists or structured teams with a Team Leader, and guarantees execution via 4-digit arrival OTP and protected escrow.'}
        </p>

        {/* Action CTAs */}
        <div className="mt-8 sm:mt-10 flex flex-wrap items-center justify-center gap-4">
          <a
            href="#download"
            className="sakuga-spring-tap inline-flex items-center gap-2.5 rounded-2xl px-7 py-4 text-sm font-bold text-white shadow-xl shadow-blue-900/30 bg-gradient-to-r from-[#003399] to-[#1D4ED8] hover:from-[#00287a] hover:to-[#1e40af] transition"
          >
            <Smartphone className="h-4 w-4" />
            <span>{isBengali ? 'অফিসিয়াল অ্যাপ ডাউনলোড' : 'Download Official APK'}</span>
            <ArrowRight className="h-4 w-4" />
          </a>

          <button
            type="button"
            onClick={() => setIsStoryOpen(true)}
            className="sakuga-spring-tap inline-flex items-center gap-2 rounded-2xl border px-6 py-4 text-sm font-semibold transition hover:border-[#3898EC] backdrop-blur-md"
            style={{
              borderColor: 'var(--border-subtle)',
              backgroundColor: 'var(--bg-surface)',
              color: 'var(--text-primary)',
            }}
          >
            <span className="flex h-5 w-5 items-center justify-center rounded-full bg-blue-500/10 text-blue-600 dark:text-blue-400">
              <Play className="h-3 w-3 fill-current ml-0.5" />
            </span>
            <span>{isBengali ? 'কার্যপ্রণালী দেখুন (ট্যুর)' : 'Watch How It Works'}</span>
          </button>

          <a
            href="#branches"
            className="sakuga-spring-tap inline-flex items-center gap-2 rounded-2xl border px-6 py-4 text-sm font-semibold transition hover:border-[#15E7CA]"
            style={{
              borderColor: 'var(--border-subtle)',
              backgroundColor: 'var(--bg-surface)',
              color: 'var(--text-primary)',
            }}
          >
            <span>{isBengali ? '৮টি শাখা দেখুন' : 'Explore 8 Branches'}</span>
          </a>
        </div>

        {/* Interactive Story Modal */}
        <CinematicStoryModal
          isOpen={isStoryOpen}
          onClose={() => setIsStoryOpen(false)}
          t={theme}
          apkUrl="#download"
        />

        {/* Interactive Requirement Scoping Engine */}
        <div className="mt-14 max-w-3xl mx-auto text-left">
          <div
            className="rounded-3xl border p-6 sm:p-8 shadow-2xl backdrop-blur-xl space-y-5 transition-all"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
            }}
          >
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b pb-4" style={{ borderColor: 'var(--border-subtle)' }}>
              <div>
                <p className="text-[11px] font-mono-code uppercase tracking-wider text-[#003399] dark:text-[#3898EC] font-bold">
                  {isBengali ? 'ইন্টারেক্টিভ সার্ভিস ব্লুপ্রিন্ট' : 'Interactive Service Blueprint'}
                </p>
                <h3 className="text-base sm:text-lg font-bold" style={{ color: 'var(--text-primary)' }}>
                  {isBengali ? 'আপনার কাজটি বেছে নিন বা ফলাফল পরীক্ষা করুন:' : 'Select a sample requirement to preview delivery:'}
                </h3>
              </div>
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20">
                <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                <span>{isBengali ? 'লাইভ এস্টিমেটর' : 'Live Estimator'}</span>
              </span>
            </div>

            {/* Quick Suggestion Chips */}
            <div className="flex flex-wrap gap-2">
              {SCOPING_SUGGESTIONS.map((item, idx) => {
                const isSelected = activeSuggestionIdx === idx;
                return (
                  <button
                    key={item.queryEn}
                    type="button"
                    onClick={() => setActiveSuggestionIdx(idx)}
                    className={`sakuga-spring-tap rounded-full px-3.5 py-1.5 text-xs transition font-semibold flex items-center gap-1.5 ${
                      isSelected
                        ? 'bg-[#003399] text-white shadow-md'
                        : 'border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 hover:border-slate-400'
                    }`}
                  >
                    <span>{isBengali ? item.queryBn : item.queryEn}</span>
                  </button>
                );
              })}
            </div>

            {/* Matched Delivery Blueprint Preview */}
            <div
              className="rounded-2xl border p-5 space-y-4 transition-all"
              style={{
                backgroundColor: 'var(--bg-surface-subtle)',
                borderColor: 'var(--border-subtle)',
              }}
            >
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div
                    className="h-10 w-10 rounded-xl flex items-center justify-center text-white shadow-sm"
                    style={{ backgroundColor: activeScoping.accent }}
                  >
                    <ActiveIcon className="h-5 w-5" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-sm" style={{ color: 'var(--text-primary)' }}>
                        {isBengali ? activeScoping.branchNameBn : activeScoping.branchNameEn}
                      </span>
                      <span className="text-[11px] font-mono-code px-2 py-0.5 rounded bg-slate-200 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
                        {activeScoping.branchCode}
                      </span>
                    </div>
                    <p className="text-xs text-slate-500 dark:text-slate-400">
                      {isBengali ? activeScoping.slaBn : activeScoping.slaEn}
                    </p>
                  </div>
                </div>

                <div className="text-right">
                  <p className="text-xs font-mono-code text-slate-500">{isBengali ? 'বেস এস্টিমেশন' : 'Base Estimate'}:</p>
                  <p className="text-base font-extrabold text-[#003399] dark:text-[#3898EC]">
                    {isBengali ? activeScoping.priceBn : activeScoping.priceEn}
                  </p>
                </div>
              </div>

              {/* Trust Signals */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs pt-3 border-t" style={{ borderColor: 'var(--border-subtle)' }}>
                <div className="flex items-center gap-2 text-slate-700 dark:text-slate-300 font-medium">
                  <KeyRound className="h-4 w-4 text-blue-600 shrink-0" />
                  <span>{isBengali ? '৪-সংখ্যার আগমন ওটিপি হ্যান্ডশেক' : '4-digit physical arrival handshake OTP'}</span>
                </div>
                <div className="flex items-center gap-2 text-slate-700 dark:text-slate-300 font-medium">
                  <ShieldCheck className="h-4 w-4 text-teal-600 shrink-0" />
                  <span>{isBengali ? 'এনআইডি ও দক্ষতা যাচাইকৃত কারিগর' : 'NID background-checked specialist'}</span>
                </div>
              </div>
            </div>

            {/* Direct Action Link */}
            <div className="flex flex-col sm:flex-row items-center justify-between gap-3 pt-1">
              <p className="text-xs text-slate-500">
                {isBengali
                  ? 'কোনো মধ্যস্বত্বভোগী নেই। সরাসরি মোবাইল অ্যাপে অর্ডার সম্পন্ন করুন।'
                  : 'Zero third-party brokers. Commission-protected order execution.'}
              </p>
              <a
                href="#download"
                className="sakuga-spring-tap w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-xl bg-[#003399] px-5 py-2.5 text-xs font-bold text-white hover:bg-[#00287a] transition shadow-md"
              >
                <span>{isBengali ? 'অ্যাপে সেবা নিন' : 'Request via Mobile App'}</span>
                <ArrowRight className="h-4 w-4" />
              </a>
            </div>
          </div>
        </div>

        {/* Linear / Stripe-style Trust Strip */}
        <div className="mt-16 pt-8 border-t border-slate-200 dark:border-white/10 grid grid-cols-2 lg:grid-cols-4 gap-6 text-center">
          <div className="space-y-1">
            <p className="font-heading font-extrabold text-2xl sm:text-3xl text-[#003399] dark:text-[#3898EC]">
              {isBengali ? '৮টি শাখা' : '8 Branches'}
            </p>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              {isBengali ? 'একক প্রাতিষ্ঠানিক দায়িত্ব' : 'One Accountable Enterprise'}
            </p>
          </div>
          <div className="space-y-1">
            <p className="font-heading font-extrabold text-2xl sm:text-3xl text-teal-600 dark:text-teal-400">
              {isBengali ? '৪-সংখ্যার ওটিপি' : '4-Digit OTP'}
            </p>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              {isBengali ? 'সশরীরে আগমন যাচাই' : 'Physical Arrival Handshake'}
            </p>
          </div>
          <div className="space-y-1">
            <p className="font-heading font-extrabold text-2xl sm:text-3xl text-amber-500 dark:text-amber-400">
              {isBengali ? '৯০/১০ এসক্রো' : '90/10 Escrow'}
            </p>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              {isBengali ? 'কাজে সন্তুষ্টির পর পেআউট' : 'Settlement on Sign-Off'}
            </p>
          </div>
          <div className="space-y-1">
            <p className="font-heading font-extrabold text-2xl sm:text-3xl text-indigo-600 dark:text-indigo-400">
              {isBengali ? '১০০% এনআইডি' : '100% NID'}
            </p>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              {isBengali ? 'যাচাইকৃত ব্যাকগ্রাউন্ড চেক' : 'Pre-Vetted Workforce'}
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}

export function BranchesSection({
  selectedBranchCode,
  onSelectBranch,
}: {
  t: PublicThemeTokens;
  selectedBranchCode: string;
  onSelectBranch: (code: string) => void;
}) {
  const { isBengali } = useTranslation();
  const branches = getSpecializationBranches(isBengali);

  return (
    <section id="branches" className="py-16 sm:py-24 border-t border-b transition-colors" style={{ borderColor: 'var(--border-subtle)', backgroundColor: 'var(--bg-surface-subtle)' }}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-12 sm:mb-16">
          <p className="text-xs font-mono-code uppercase tracking-widest text-[#003399] dark:text-[#3898EC] font-bold mb-3">
            {isBengali ? 'অভ্যন্তরীণ বিশেষায়িত শাখা' : 'Internal Specialization Branches'}
          </p>
          <h2 className="font-heading text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight" style={{ color: 'var(--text-primary)' }}>
            {isBengali
              ? '৮টি বিশেষায়িত শাখা। একটি মাত্র প্রতিষ্ঠান।'
              : 'Eight Specialization Branches. One Unified Company.'}
          </h2>
          <p className="mt-4 text-sm sm:text-base text-slate-600 dark:text-slate-300 leading-relaxed">
            {isBengali
              ? 'স্ক্যাভিয়ার প্রতিটি শাখা নিজস্ব অভিজ্ঞ কর্মী, সরঞ্জাম মান এবং একক প্রাতিষ্ঠানিক দায়িত্বে পরিচালিত হয়—বাইরের কোনো তৃতীয় পক্ষের ওপর দায় চাপানো হয় না।'
              : 'Every specialization operates as an internal SKAVIA operational unit with uniform equipment standards, verified background checks, and single-point corporate accountability.'}
          </p>
        </div>

        {/* Bento Grid of 8 Operational Branches */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
          {branches.map((branch) => {
            const Icon = branch.icon;
            const isSelected = branch.code === selectedBranchCode;
            return (
              <div
                key={branch.code}
                onClick={() => onSelectBranch(branch.code)}
                className={`sakuga-spring-tap rounded-3xl border p-6 flex flex-col justify-between transition-all cursor-pointer ${
                  isSelected
                    ? 'ring-2 ring-blue-500 shadow-xl'
                    : 'hover:shadow-lg'
                }`}
                style={{
                  backgroundColor: 'var(--bg-surface)',
                  borderColor: isSelected ? branch.accent : 'var(--border-subtle)',
                }}
              >
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div
                      className="h-11 w-11 rounded-2xl flex items-center justify-center"
                      style={{
                        backgroundColor: `${branch.accent}15`,
                        color: branch.accent,
                      }}
                    >
                      <Icon className="h-6 w-6" />
                    </div>
                    <span
                      className="text-xs font-mono-code font-bold px-2.5 py-1 rounded-full uppercase"
                      style={{
                        backgroundColor: `${branch.accent}15`,
                        color: branch.accent,
                      }}
                    >
                      {branch.code}
                    </span>
                  </div>

                  <div>
                    <h3 className="font-heading font-bold text-lg" style={{ color: 'var(--text-primary)' }}>
                      {branch.name}
                    </h3>
                    <p className="text-xs font-medium mt-1 text-slate-500 dark:text-slate-400">
                      {branch.tagline}
                    </p>
                  </div>

                  <p className="text-xs text-slate-600 dark:text-slate-300 leading-relaxed">
                    {branch.scope}
                  </p>
                </div>

                <div className="pt-5 mt-5 border-t space-y-2" style={{ borderColor: 'var(--border-subtle)' }}>
                  <p className="text-[10px] font-mono-code uppercase tracking-wider text-slate-400">
                    {isBengali ? 'সাধারণ সেবাসমূহ:' : 'Typical Solutions:'}
                  </p>
                  <div className="flex flex-wrap gap-1.5">
                    {branch.examples.map((ex) => (
                      <span
                        key={ex}
                        className="inline-flex items-center gap-1 text-[11px] font-medium px-2 py-0.5 rounded-md border"
                        style={{
                          backgroundColor: 'var(--bg-surface-subtle)',
                          borderColor: 'var(--border-subtle)',
                          color: 'var(--text-secondary)',
                        }}
                      >
                        <CheckCircle2 className="h-3 w-3 text-teal-500" />
                        <span>{ex}</span>
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}

export function WorkflowSection({
  activeTab,
  onSelectTab,
}: {
  t: PublicThemeTokens;
  activeTab: WorkflowTab;
  onSelectTab: (tab: WorkflowTab) => void;
}) {
  const { isBengali } = useTranslation();
  const workflowTabs = getWorkflowTabs(isBengali);
  const lifecycleSteps = getLifecycleSteps(isBengali);

  return (
    <section id="how-it-works" className="py-16 sm:py-24 transition-colors border-b" style={{ borderColor: 'var(--border-subtle)' }}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 items-start">
          {/* Left Column: Mission statement & interactive tab switcher */}
          <div className="lg:col-span-5 space-y-6">
            <div className="space-y-3">
              <p className="text-xs font-mono-code uppercase tracking-widest text-[#003399] dark:text-[#3898EC] font-bold">
                {isBengali ? 'কার্যপ্রণালী ও দায়বদ্ধতা' : 'Engine & Accountability'}
              </p>
              <h2 className="font-heading text-3xl sm:text-4xl font-extrabold tracking-tight" style={{ color: 'var(--text-primary)' }}>
                {isBengali
                  ? 'শুধু বিজ্ঞাপনী সাইট নয়। একক দায়িত্বশীল ডেলিভারি ইঞ্জিন।'
                  : 'Not just a directory. One accountable delivery engine.'}
              </h2>
              <p className="text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
                {isBengali
                  ? 'সাধারণ ক্লাসিফাইড সাইটগুলো নম্বর দিয়ে গ্রাহককে একাকী ছেড়ে দেয়। স্ক্যাভিয়া প্রয়োজন বিশ্লেষণ, কর্মী বরাদ্দ, টিম লিডারের তত্ত্বাবধান ও কাজের সন্তোষজনক সমাপ্তি পর্যন্ত সম্পূর্ণ দায়িত্ব বহন করে।'
                  : 'Generic freelancer boards abandon clients after sharing a phone number. SKAVIA remains responsible across requirement scoping, verified matching, Team Leader supervision, and protected escrow settlement.'}
              </p>
            </div>

            <div className="space-y-3 pt-2">
              {workflowTabs.map((tab) => {
                const active = activeTab === tab.id;
                return (
                  <button
                    key={tab.id}
                    type="button"
                    onClick={() => onSelectTab(tab.id)}
                    className={`sakuga-spring-tap w-full text-left rounded-2xl border p-4 sm:p-5 transition ${
                      active
                        ? 'border-[#003399] bg-[#003399]/10 text-[#003399] dark:border-[#3898EC] dark:text-[#3898EC] shadow-md'
                        : 'border-slate-200 dark:border-slate-800 hover:border-slate-400'
                    }`}
                    style={{
                      backgroundColor: active ? undefined : 'var(--bg-surface)',
                    }}
                  >
                    <p className="text-xs font-mono-code uppercase tracking-wider text-[#003399] dark:text-[#3898EC] font-bold">
                      {tab.step}
                    </p>
                    <p className="text-base font-bold mt-1" style={{ color: 'var(--text-primary)' }}>
                      {tab.title}
                    </p>
                    <p className="text-xs mt-1.5 text-slate-600 dark:text-slate-400 leading-relaxed">
                      {tab.subtitle}
                    </p>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Right Column: 6-Stage Order Lifecycle Stepper */}
          <div className="lg:col-span-7 space-y-4">
            <div className="flex items-center justify-between pb-2">
              <p className="text-xs font-mono-code uppercase tracking-widest text-teal-600 dark:text-teal-400 font-bold">
                {isBengali ? 'ধাপভিত্তিক পূর্ণাঙ্গ সেবা পরিচালনা' : 'End-to-End Delivery Lifecycle'}
              </p>
              <span className="text-xs text-slate-400 font-mono-code">6 Stages</span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {lifecycleSteps.map((step) => (
                <div
                  key={step.n}
                  className="rounded-2xl border p-5 space-y-2.5 transition hover:shadow-md"
                  style={{
                    backgroundColor: 'var(--bg-surface)',
                    borderColor: 'var(--border-subtle)',
                  }}
                >
                  <div className="flex items-center gap-3">
                    <span className="h-7 w-7 rounded-xl bg-gradient-to-r from-[#003399] to-[#1D4ED8] text-white text-xs font-bold flex items-center justify-center shadow-sm">
                      {step.n}
                    </span>
                    <h3 className="font-heading text-sm font-bold" style={{ color: 'var(--text-primary)' }}>
                      {step.title}
                    </h3>
                  </div>
                  <p className="text-xs text-slate-600 dark:text-slate-400 leading-relaxed">
                    {step.desc}
                  </p>
                </div>
              ))}
            </div>

            <div
              className="mt-6 rounded-2xl border p-5 flex flex-col sm:flex-row items-center justify-between gap-4"
              style={{
                backgroundColor: 'var(--bg-surface-subtle)',
                borderColor: 'var(--border-subtle)',
              }}
            >
              <div className="flex items-center gap-3 text-xs text-slate-700 dark:text-slate-300">
                <ShieldCheck className="h-5 w-5 text-teal-500 shrink-0" />
                <span>
                  {isBengali
                    ? 'সকল অর্ডার এনক্রিপ্টেড মোবাইল অ্যাপের মাধ্যমে পরিচালিত হয়।'
                    : 'All service coordination is securely governed via the official SKAVIA app.'}
                </span>
              </div>
              <a
                href="#download"
                className="sakuga-spring-tap text-xs font-bold text-[#003399] dark:text-[#3898EC] hover:underline shrink-0"
              >
                {isBengali ? 'অ্যাপ পান →' : 'Get App →'}
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export function SolutionsSection({}: { t: PublicThemeTokens }) {
  const { isBengali } = useTranslation();
  const individualHighlights = getIndividualHighlights(isBengali);
  const businessHighlights = getBusinessHighlights(isBengali);

  return (
    <section id="solutions" className="py-16 sm:py-24 transition-colors border-b" style={{ borderColor: 'var(--border-subtle)', backgroundColor: 'var(--bg-surface-subtle)' }}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-12 sm:mb-16">
          <p className="text-xs font-mono-code uppercase tracking-widest text-[#003399] dark:text-[#3898EC] font-bold mb-3">
            {isBengali ? 'দ্বিমুখী প্ল্যাটফর্ম সমাধান' : 'Tailored Solutions for Everyone'}
          </p>
          <h2 className="font-heading text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight" style={{ color: 'var(--text-primary)' }}>
            {isBengali
              ? 'ব্যক্তিগত গ্রাহক ও প্রাতিষ্ঠানিক ব্যবসা'
              : 'Built for Households & Enterprises Alike'}
          </h2>
          <p className="mt-4 text-sm sm:text-base text-slate-600 dark:text-slate-300 leading-relaxed">
            {isBengali
              ? 'দৈনন্দিন পারিবারিক সহায়তা থেকে শুরু করে বৃহৎ অফিসের টার্নকি প্রজেক্ট—স্ক্যাভিয়া উভয় ক্ষেত্রে দায়িত্বশীল সমাধান প্রদান করে।'
              : 'Whether an urgent household AC fix or a commercial office interior fit-out, SKAVIA provides the right scale of workforce.'}
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 sm:gap-8">
          {/* Card 1: Individuals & Households */}
          <div
            className="rounded-3xl border p-8 sm:p-10 space-y-6 shadow-sm hover:shadow-lg transition"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
            }}
          >
            <div className="inline-flex items-center gap-2 rounded-xl bg-teal-500/10 text-teal-700 dark:text-teal-300 px-3.5 py-1.5 text-xs font-bold">
              <Wrench className="h-4 w-4" />
              <span>{isBengali ? 'ব্যক্তিগত গ্রাহক সমাধান' : 'Individual Client Solutions'}</span>
            </div>

            <div className="space-y-2">
              <h3 className="font-heading text-2xl sm:text-3xl font-extrabold" style={{ color: 'var(--text-primary)' }}>
                {isBengali ? 'দৈনন্দিন ও জরুরি নির্ভরযোগ্য সেবা' : 'Reliable Everyday & Urgent Help'}
              </h3>
              <p className="text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
                {isBengali
                  ? 'বাসাবাড়ির প্লাম্বিং, ইলেকট্রিক্যাল, এসি ও ফার্নিচার মেরামতে যাচাইকৃত টেকনিশিয়ান ও কারিগর সরাসরি বুকিং করুন।'
                  : 'Book vetted technicians and skilled craftspeople for home repairs, electrical work, plumbing, and appliance servicing.'}
              </p>
            </div>

            <ul className="space-y-3 text-xs sm:text-sm text-slate-700 dark:text-slate-300">
              {individualHighlights.map((item) => (
                <li key={item} className="flex items-center gap-2.5">
                  <CheckCircle2 className="h-4 w-4 text-teal-500 shrink-0" />
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          </div>

          {/* Card 2: Businesses & Organizations */}
          <div
            className="rounded-3xl border p-8 sm:p-10 space-y-6 shadow-sm hover:shadow-lg transition"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
            }}
          >
            <div className="inline-flex items-center gap-2 rounded-xl bg-blue-500/10 text-blue-700 dark:text-blue-300 px-3.5 py-1.5 text-xs font-bold">
              <Building2 className="h-4 w-4" />
              <span>{isBengali ? 'প্রাতিষ্ঠানিক ও বাণিজ্যিক সমাধান' : 'Business & Corporate Solutions'}</span>
            </div>

            <div className="space-y-2">
              <h3 className="font-heading text-2xl sm:text-3xl font-extrabold" style={{ color: 'var(--text-primary)' }}>
                {isBengali ? 'মাল্টি-স্কিল টিম ও টার্নকি প্রজেক্ট' : 'Multi-Skill Teams & Turnkey Projects'}
              </h3>
              <p className="text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
                {isBengali
                  ? 'অফিস, ফ্যাক্টরি ও প্রতিষ্ঠানের জন্য সমন্বিত প্রকল্প দল এবং দায়িত্বপ্রাপ্ত টিম লিডারের প্রত্যক্ষ তত্ত্বাবধান।'
                  : 'For commercial facilities, retail chains, and corporate offices, SKAVIA forms structured crews supervised by designated Team Leaders.'}
              </p>
            </div>

            <ul className="space-y-3 text-xs sm:text-sm text-slate-700 dark:text-slate-300">
              {businessHighlights.map((item) => (
                <li key={item} className="flex items-center gap-2.5">
                  <CheckCircle2 className="h-4 w-4 text-blue-600 dark:text-blue-400 shrink-0" />
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}
