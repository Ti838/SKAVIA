'use client';

import { useState } from 'react';
import {
  ArrowRight,
  Building2,
  CheckCircle2,
  KeyRound,
  Play,
  ShieldCheck,
  Smartphone,
  Wrench,
  Zap,
} from 'lucide-react';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import { CinematicAtmosphereCanvas } from './CinematicAtmosphereCanvas';
import { CinematicStoryModal } from './CinematicStoryModal';
import {
  BUSINESS_HIGHLIGHTS,
  INDIVIDUAL_HIGHLIGHTS,
  LIFECYCLE_STEPS,
  SPECIALIZATION_BRANCHES,
  WORKFLOW_TABS,
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
  },
  {
    queryEn: 'Office Civil & Interior Fit-Out',
    queryBn: 'অফিস রেনোভেশন ও ইন্টেরিয়র',
    branchCode: 'CONS',
    branchNameEn: 'SKAVIA Construction',
    branchNameBn: 'স্ক্যাভিয়া কনস্ট্রাকশন',
    priceEn: 'Custom Milestone Escrow',
    priceBn: 'ধাপভিত্তিক এসক্রো চুক্তি',
    slaEn: 'Led by designated Team Leader',
    slaBn: 'টিম লিডারের প্রত্যক্ষ তত্ত্বাবধান',
  },
];

export function HeroSection({ t: theme }: { t: PublicThemeTokens }) {
  const { t, isBengali } = useTranslation();
  const [activeSuggestionIdx, setActiveSuggestionIdx] = useState(0);
  const [isStoryOpen, setIsStoryOpen] = useState(false);
  const activeScoping = SCOPING_SUGGESTIONS[activeSuggestionIdx] ?? SCOPING_SUGGESTIONS[0]!;

  return (
    <section
      className={`relative border-b transition-colors overflow-hidden ${theme.railBorder} ${
        theme.dark ? 'skavia-subtle-mesh-dark bg-[#070B14]' : 'skavia-subtle-mesh-light bg-[#FAFAFA]'
      }`}
    >
      {/* Cinematic GPU Atmosphere Canvas */}
      <CinematicAtmosphereCanvas dark={theme.dark} />

      <div className="relative z-10 px-4 sm:px-8 pt-8 sm:pt-12 pb-12 sm:pb-16 text-center max-w-5xl mx-auto">
        {/* Organization Badge */}
        <div
          className={`inline-flex items-center gap-2 rounded-full border px-3.5 py-1 text-xs font-medium mb-4 sm:mb-5 ${theme.railBorder}`}
          style={{
            backgroundColor: 'var(--bg-surface)',
            color: 'var(--text-secondary)',
          }}
        >
          <span className="h-2 w-2 rounded-full bg-[#15E7CA] animate-pulse" />
          <span>
            {t.oneAccountableOrg} &middot; {t.eightBranches}
          </span>
        </div>

        {/* Hero Main Heading */}
        <h1
          className="font-heading font-extrabold text-3xl sm:text-5xl md:text-6xl tracking-tight leading-[1.12]"
          style={{ color: 'var(--text-primary)' }}
        >
          {isBengali ? (
            <>
              আপনার প্রয়োজন জানান।
              <span className="block mt-2 text-[#003399] dark:text-[#3898EC]">
                স্ক্যাভিয়া সমাধান পৌঁছে দেবে।
              </span>
            </>
          ) : (
            <>
              Explain Your Requirement.
              <span className="block mt-2 text-[#003399] dark:text-[#3898EC]">
                SKAVIA Delivers the Solution.
              </span>
            </>
          )}
        </h1>

        {/* Hero Subtitle */}
        <p
          className="mt-4 sm:mt-5 max-w-2xl mx-auto text-sm sm:text-base leading-relaxed"
          style={{ color: 'var(--text-secondary)' }}
        >
          {t.ecosystemSubtitle}
        </p>

        {/* Action CTAs */}
        <div className="mt-6 sm:mt-8 flex flex-wrap items-center justify-center gap-3">
          <a
            href="#download"
            className="inline-flex items-center gap-2 rounded-full px-5 py-2.5 sm:px-6 sm:py-3 text-xs sm:text-sm font-semibold text-white shadow-md bg-[#003399] hover:bg-[#00287a] transition"
          >
            <Smartphone className="h-4 w-4" />
            <span>{t.downloadApkTitle}</span>
            <ArrowRight className="h-4 w-4" />
          </a>

          <button
            type="button"
            onClick={() => setIsStoryOpen(true)}
            className="inline-flex items-center gap-2 rounded-full border px-5 py-2.5 sm:px-6 sm:py-3 text-xs sm:text-sm font-semibold transition hover:border-[#3898EC]"
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
            className="inline-flex items-center gap-2 rounded-full border px-5 py-2.5 sm:px-6 sm:py-3 text-xs sm:text-sm font-semibold transition"
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

        {/* Interactive Requirement Scoping Card */}
        <div className="mt-10 sm:mt-12 text-left max-w-2xl mx-auto">
          <div
            className="rounded-2xl border p-5 sm:p-6 shadow-xl space-y-4 backdrop-blur-md"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
            }}
          >
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b pb-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <div>
                <p className="text-[11px] font-mono-code uppercase tracking-wider text-[#003399] dark:text-[#3898EC] font-semibold">
                  {isBengali ? 'ইন্টারেক্টিভ রিকোয়ারমেন্ট স্কোপিং' : 'Interactive Requirement Scoping'}
                </p>
                <h3 className="text-sm sm:text-base font-bold" style={{ color: 'var(--text-primary)' }}>
                  {isBengali ? 'আপনার কাজটি বেছে নিন বা লিখুন:' : 'Select or describe your service need:'}
                </h3>
              </div>
              <span className="text-[11px] font-mono-code text-slate-400">
                {isBengali ? 'তাৎক্ষণিক এস্টিমেশন' : 'Instant Estimate'}
              </span>
            </div>

            {/* Quick Suggestion Chips */}
            <div className="flex flex-wrap gap-1.5 sm:gap-2">
              {SCOPING_SUGGESTIONS.map((item, idx) => {
                const isSelected = activeSuggestionIdx === idx;
                return (
                  <button
                    key={item.queryEn}
                    type="button"
                    onClick={() => setActiveSuggestionIdx(idx)}
                    className={`rounded-full px-3 py-1 text-xs transition font-medium ${
                      isSelected
                        ? 'bg-[#003399] text-white font-semibold shadow-xs'
                        : 'border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-400 hover:border-slate-300'
                    }`}
                  >
                    {isBengali ? item.queryBn : item.queryEn}
                  </button>
                );
              })}
            </div>

            {/* Matched Delivery Blueprint Preview */}
            <div
              className="rounded-xl border p-4 space-y-3"
              style={{
                backgroundColor: 'var(--bg-surface-subtle)',
                borderColor: 'var(--border-subtle)',
              }}
            >
              <div className="flex flex-wrap items-center justify-between gap-2">
                <div className="flex items-center gap-2">
                  <span className="inline-flex items-center gap-1 rounded-md bg-blue-100 dark:bg-blue-950/60 border border-blue-200 dark:border-blue-800/60 px-2 py-0.5 text-xs font-semibold text-blue-900 dark:text-blue-200">
                    <Zap className="h-3 w-3 text-blue-600" />
                    {isBengali ? activeScoping.branchNameBn : activeScoping.branchNameEn}
                  </span>
                  <span className="text-xs text-slate-500 font-mono-code">
                    {activeScoping.branchCode}
                  </span>
                </div>

                <div className="text-right">
                  <p className="text-xs font-mono-code text-slate-500">{isBengali ? 'আনুমানিক মূল্য' : 'Base Est.'}:</p>
                  <p className="text-sm font-bold text-[#003399] dark:text-[#3898EC]">
                    {isBengali ? activeScoping.priceBn : activeScoping.priceEn}
                  </p>
                </div>
              </div>

              {/* Trust Signals */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs pt-1 border-t" style={{ borderColor: 'var(--border-subtle)' }}>
                <div className="flex items-center gap-2 text-slate-600 dark:text-slate-300">
                  <KeyRound className="h-3.5 w-3.5 text-blue-600 shrink-0" />
                  <span>{isBengali ? '৪-সংখ্যার আগমন ওটিপি দ্বারা কাজ শুরু' : '4-digit physical arrival handshake OTP'}</span>
                </div>
                <div className="flex items-center gap-2 text-slate-600 dark:text-slate-300">
                  <ShieldCheck className="h-3.5 w-3.5 text-teal-600 shrink-0" />
                  <span>{isBengali ? 'জাতীয় পরিচয়পত্র ও দক্ষতা যাচাইকৃত' : 'NID background-checked specialist'}</span>
                </div>
              </div>
            </div>

            {/* Direct Action Link */}
            <div className="flex flex-col sm:flex-row items-center justify-between gap-3 pt-1">
              <p className="text-xs text-slate-500">
                {isBengali ? activeScoping.slaBn : activeScoping.slaEn}
              </p>
              <a
                href="#download"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-1.5 rounded-lg bg-[#003399] px-4 py-2 text-xs font-semibold text-white hover:bg-[#00287a] transition shadow-xs"
              >
                <span>{isBengali ? 'সেবা নিন (অ্যাপে)' : 'Request via App'}</span>
                <ArrowRight className="h-3.5 w-3.5" />
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export function WorkflowSection({
  t: theme,
  activeTab,
  onSelectTab,
}: {
  t: PublicThemeTokens;
  activeTab: WorkflowTab;
  onSelectTab: (tab: WorkflowTab) => void;
}) {
  const { isBengali } = useTranslation();

  return (
    <section id="about" className={`border-b ${theme.railBorder} ${theme.surfaceBg}`}>
      <div id="how-it-works" className="grid grid-cols-1 lg:grid-cols-12">
        <div className={`lg:col-span-5 p-6 sm:p-8 border-b lg:border-b-0 lg:border-r ${theme.railBorder}`}>
          <p className="text-xs font-mono-code uppercase tracking-widest text-[#003399] dark:text-[#3898EC] mb-2 font-semibold">
            {isBengali ? 'পরিচিতি ও কার্যপ্রণালী' : 'About & Workflow'}
          </p>
          <h2 className={`text-2xl sm:text-3xl font-bold tracking-tight ${theme.textPrimary}`}>
            {isBengali
              ? 'শুধুমাত্র তালিকা নয়। একক দায়িত্বশীল ডেলিভারি ইঞ্জিন।'
              : 'Not just a directory. One accountable delivery engine.'}
          </h2>
          <p className={`text-sm mt-2.5 leading-relaxed ${theme.textSecondary}`}>
            {isBengali
              ? 'সাধারণ ক্লাসিফাইড সাইট বা মধ্যস্বত্বভোগীদের মতো নম্বর দিয়ে গ্রাহককে একা ছেড়ে না দিয়ে, স্ক্যাভিয়া রিকোয়ারমেন্ট স্কোপিং, কর্মী বরাদ্দ, টিম লিডারের তত্ত্বাবধান ও কাজের সন্তোষজনক সমাপ্তি পর্যন্ত সম্পূর্ণ দায়িত্ব বহন করে।'
              : 'Unlike generic classifieds or freelancer boards that abandon users after sharing a phone number, SKAVIA remains responsible across requirement scoping, verified worker matching, Team Leader supervision, milestone escrow, and verified completion.'}
          </p>

          <div className="mt-5 space-y-2">
            {WORKFLOW_TABS.map((tab) => {
              const active = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  type="button"
                  onClick={() => onSelectTab(tab.id)}
                  className={`w-full text-left rounded-xl border p-3.5 sm:p-4 transition ${
                    active
                      ? 'border-[#003399] bg-[#003399]/10 text-[#003399] dark:border-[#3898EC] dark:text-[#3898EC] font-semibold'
                      : 'border-slate-200 dark:border-slate-800 hover:border-slate-300 dark:hover:border-slate-700'
                  }`}
                >
                  <p className="text-[11px] font-mono-code uppercase tracking-wider text-[#003399] dark:text-[#3898EC]">
                    {tab.step}
                  </p>
                  <p className={`text-sm font-semibold mt-0.5 ${theme.textPrimary}`}>{tab.title}</p>
                  <p className={`text-xs mt-1 leading-relaxed ${theme.textSecondary}`}>{tab.subtitle}</p>
                </button>
              );
            })}
          </div>
        </div>

        <div className="lg:col-span-7 p-6 sm:p-8 flex flex-col justify-between">
          <div>
            <p className="text-xs font-mono-code uppercase tracking-widest mb-3 text-teal-600 dark:text-teal-400 font-semibold">
              {isBengali ? 'ধাপভিত্তিক সেবা পরিচালনা' : 'End-to-End Solution Lifecycle'}
            </p>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
              {LIFECYCLE_STEPS.map((step) => (
                <div
                  key={step.n}
                  className={`rounded-xl border p-3.5 sm:p-4 ${theme.railBorder} ${theme.cardBg}`}
                >
                  <div className="flex items-center gap-2.5 mb-2">
                    <span className="h-6 w-6 rounded-full bg-[#003399] text-white text-xs font-bold flex items-center justify-center">
                      {step.n}
                    </span>
                    <h3 className={`text-sm font-semibold ${theme.textPrimary}`}>{step.title}</h3>
                  </div>
                  <p className={`text-xs leading-relaxed ${theme.textSecondary}`}>{step.desc}</p>
                </div>
              ))}
            </div>
          </div>

          <div
            className={`mt-5 rounded-xl border p-4 flex items-center justify-between gap-4 ${theme.railBorder} ${theme.subtleCardBg}`}
          >
            <div className="flex items-center gap-3">
              <ShieldCheck className="h-5 w-5 shrink-0 text-teal-600 dark:text-teal-400" />
              <p className={`text-xs leading-relaxed ${theme.textSecondary}`}>
                {isBengali ? 'সকল সেবা অফিসিয়াল স্ক্যাভিয়া মোবাইল অ্যাপের মাধ্যমে পরিচালিত হয়।' : 'All operations securely coordinated via the official SKAVIA app.'}
              </p>
            </div>
            <a href="#download" className="text-xs font-semibold text-[#003399] dark:text-[#3898EC] hover:underline shrink-0">
              {isBengali ? 'অ্যাপ পান →' : 'Get App →'}
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}

export function BranchesSection({
  t: theme,
  selectedBranchCode,
  onSelectBranch,
}: {
  t: PublicThemeTokens;
  selectedBranchCode: string;
  onSelectBranch: (code: string) => void;
}) {
  const { isBengali } = useTranslation();
  const activeBranch =
    SPECIALIZATION_BRANCHES.find((b) => b.code === selectedBranchCode) ??
    SPECIALIZATION_BRANCHES[0]!;

  return (
    <section id="branches" className={`border-b ${theme.railBorder} ${theme.subtleCardBg} p-6 sm:p-8`}>
      <div className="max-w-3xl mb-6">
        <p className="text-xs font-mono-code uppercase tracking-widest text-[#003399] dark:text-[#3898EC] mb-2 font-semibold">
          {isBengali ? 'বিশেষায়িত অপারেশনাল শাখা' : 'Internal Operational Branches'}
        </p>
        <h2 className={`text-2xl sm:text-3xl font-bold tracking-tight ${theme.textPrimary}`}>
          {isBengali
            ? '৮টি বিশেষায়িত শাখা। একটি মাত্র প্রতিষ্ঠান।'
            : 'Eight Specialization Branches. One Unified Organization.'}
        </h2>
        <p className={`text-sm mt-2 leading-relaxed ${theme.textSecondary}`}>
          {isBengali
            ? 'প্রতিটি খাত স্ক্যাভিয়ার নিজস্ব তত্ত্বাবধানে পেশাদার কর্মীদের দ্বারা নিয়ন্ত্রিত ও পরিচালিত হয়।'
            : 'Every specialization operates as an internal SKAVIA operational unit with uniform background verification, equipment standards, and single-point accountability.'}
        </p>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-4">
        {SPECIALIZATION_BRANCHES.map((branch) => {
          const Icon = branch.icon;
          const selected = branch.code === selectedBranchCode;
          return (
            <button
              key={branch.code}
              type="button"
              onClick={() => onSelectBranch(branch.code)}
              className={`text-left rounded-xl border p-3.5 sm:p-4 transition ${
                selected
                  ? 'border-[#003399] bg-[#003399]/10 text-[#003399] dark:border-[#3898EC] dark:text-[#3898EC] font-semibold shadow-xs'
                  : `${theme.railBorder} ${theme.surfaceBg} hover:border-slate-400`
              }`}
            >
              <div className="flex items-center justify-between mb-2">
                <Icon className="h-4 w-4" style={{ color: branch.accent }} />
                <span className="text-[10px] font-mono-code uppercase tracking-wider opacity-60">
                  {branch.code}
                </span>
              </div>
              <p className={`text-sm font-semibold ${theme.textPrimary}`}>{branch.name}</p>
              <p className={`text-[11px] mt-1 line-clamp-1 ${theme.textMuted}`}>{branch.tagline}</p>
            </button>
          );
        })}
      </div>

      {/* Selected Branch Detail Card */}
      <div className={`rounded-2xl border p-5 sm:p-6 ${theme.railBorder} ${theme.surfaceBg}`}>
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="space-y-2 max-w-2xl">
            <div className="flex items-center gap-2">
              <span className="h-2.5 w-2.5 rounded-full bg-[#003399] dark:bg-[#3898EC]" />
              <span className="text-xs font-mono-code uppercase tracking-widest text-[#003399] dark:text-[#3898EC] font-semibold">
                {activeBranch.name} &middot; Internal Unit
              </span>
            </div>
            <h3 className={`text-xl font-bold ${theme.textPrimary}`}>{activeBranch.tagline}</h3>
            <p className={`text-sm leading-relaxed ${theme.textSecondary}`}>{activeBranch.scope}</p>
          </div>
          <div className="flex flex-wrap gap-2">
            {activeBranch.examples.map((ex) => (
              <span
                key={ex}
                className={`inline-flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-xs ${theme.railBorder} ${theme.cardBg}`}
              >
                <CheckCircle2 className="h-3.5 w-3.5 text-teal-600 dark:text-teal-400" />
                {ex}
              </span>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

export function SolutionsSection({ t: theme }: { t: PublicThemeTokens }) {
  const { isBengali } = useTranslation();

  return (
    <section id="solutions" className={`border-b ${theme.railBorder} ${theme.surfaceBg}`}>
      <div className={`grid grid-cols-1 md:grid-cols-2 gap-px ${theme.hairlineBg}`}>
        <div className={`p-6 sm:p-8 ${theme.surfaceBg}`}>
          <div className="inline-flex items-center gap-2 text-xs font-mono-code uppercase tracking-widest mb-3 text-teal-700 dark:text-teal-400 font-semibold">
            <Wrench className="h-4 w-4" />
            <span>{isBengali ? 'ব্যক্তিগত গ্রাহক সমাধান' : 'Individual Service Solutions'}</span>
          </div>
          <h3 className={`text-2xl font-bold tracking-tight ${theme.textPrimary}`}>
            {isBengali ? 'দৈনন্দিন ও জরুরি সার্ভিস' : 'Reliable Everyday & Urgent Help'}
          </h3>
          <p className={`text-sm mt-2 leading-relaxed ${theme.textSecondary}`}>
            {isBengali
              ? 'বাসাবাড়ির প্লাম্বিং, ইলেকট্রিক্যাল, এসি ও ফার্নিচার মেরামতে যাচাইকৃত টেকনিশিয়ান ও কারিগর সরাসরি বুকিং করুন।'
              : 'Book vetted technicians or skilled craftspeople for home repairs, AC & electrical work, renovations, and household support.'}
          </p>
          <ul className={`mt-5 space-y-2.5 text-xs ${theme.textSecondary}`}>
            {INDIVIDUAL_HIGHLIGHTS.map((item) => (
              <li key={item} className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 text-teal-600 dark:text-teal-400 shrink-0" />
                {item}
              </li>
            ))}
          </ul>
        </div>

        <div className={`p-6 sm:p-8 ${theme.surfaceBg}`}>
          <div className="inline-flex items-center gap-2 text-xs font-mono-code uppercase tracking-widest text-[#003399] dark:text-[#3898EC] mb-3 font-semibold">
            <Building2 className="h-4 w-4" />
            <span>{isBengali ? 'প্রাতিষ্ঠানিক ও ব্যবসায়িক সমাধান' : 'Business & Organization Solutions'}</span>
          </div>
          <h3 className={`text-2xl font-bold tracking-tight ${theme.textPrimary}`}>
            {isBengali ? 'মাল্টি-স্কিল টিম ও টার্নকি প্রজেক্ট' : 'Multi-Skill Teams & Turnkey Projects'}
          </h3>
          <p className={`text-sm mt-2 leading-relaxed ${theme.textSecondary}`}>
            {isBengali
              ? 'অফিস, ফ্যাক্টরি ও প্রতিষ্ঠানের জন্য সমন্বিত প্রকল্প দল এবং টিম লিডারের প্রত্যক্ষ তত্ত্বাবধান।'
              : 'For offices, factories, retail chains, and events, SKAVIA assembles structured project crews supervised by a designated Team Leader.'}
          </p>
          <ul className={`mt-5 space-y-2.5 text-xs ${theme.textSecondary}`}>
            {BUSINESS_HIGHLIGHTS.map((item) => (
              <li key={item} className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 text-[#003399] dark:text-[#3898EC] shrink-0" />
                {item}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}
