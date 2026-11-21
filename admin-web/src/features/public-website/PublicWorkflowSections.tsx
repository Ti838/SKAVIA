'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  ArrowRight,
  Building2,
  CheckCircle2,
  Home,
  Play,
  Smartphone,
} from 'lucide-react';
import { CinematicAtmosphereCanvas } from './CinematicAtmosphereCanvas';
import { CinematicStoryModal } from './CinematicStoryModal';
import { HeroAtmosphere } from './components/HeroAtmosphere';
import { SakugaButton, SakugaLink } from '@/components/sakuga';
import {
  getBusinessHighlights,
  getIndividualHighlights,
  getSpecializationBranches,
  type PublicThemeTokens,
  type WorkflowTab,
} from './public-site-data';

export function HeroSection({ t: theme }: { t: PublicThemeTokens }) {
  const [isStoryOpen, setIsStoryOpen] = useState(false);

  const branches = [
    { code: 'HOME', name: 'SKAVIA Home', href: '/branches/home' },
    { code: 'TECH', name: 'SKAVIA Technical', href: '/branches/technical' },
    { code: 'AGRI', name: 'SKAVIA Agriculture', href: '/services-catalog' },
    { code: 'LOGI', name: 'SKAVIA Logistics', href: '/services-catalog' },
    { code: 'DIGI', name: 'SKAVIA Digital', href: '/services-catalog' },
    { code: 'BIZ', name: 'SKAVIA Business', href: '/business' },
    { code: 'CONS', name: 'SKAVIA Construction', href: '/services-catalog' },
    { code: 'EVNT', name: 'SKAVIA Events', href: '/services-catalog' },
  ];

  return (
    <section className="relative overflow-hidden pt-8 pb-16 sm:pt-12 sm:pb-24 transition-colors">
      {/* Seamless Multi-Layered Hero Atmosphere (Zero-Banding Full-Bleed Lighting & Precision Dot Grid) */}
      <HeroAtmosphere dark={theme.dark} variant="hero" />
      <CinematicAtmosphereCanvas dark={theme.dark} />

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        {/* Hero Headline */}
        <h1 className="font-heading font-extrabold text-4xl sm:text-6xl md:text-7xl tracking-tight leading-[1.08] max-w-5xl mx-auto text-slate-900 dark:text-white">
          Every Skilled Service.
          <span className="block mt-2 bg-gradient-to-r from-[#003399] via-[#3898EC] to-[#15E7CA] bg-clip-text text-transparent">
            One Accountable Platform.
          </span>
        </h1>

        {/* Subtitle */}
        <p className="mt-6 max-w-3xl mx-auto text-base sm:text-lg leading-relaxed text-slate-600 dark:text-slate-300">
          Say goodbye to unmonitored freelancer directories and broker haggling. 
          SKAVIA scopes your requirement, dispatches NID-verified specialists with calibrated tools, 
          and guarantees quality through a mandatory 4-digit arrival OTP handshake and protected escrow.
        </p>

        {/* Action CTAs */}
        <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
          <SakugaLink
            href="/download"
            className="inline-flex items-center gap-2.5 rounded-full px-7 py-3.5 text-xs sm:text-sm font-semibold bg-neutral-950 text-white hover:bg-neutral-800 dark:bg-white dark:text-neutral-950 dark:hover:bg-neutral-200 shadow-md transition-all active:scale-[0.98]"
          >
            <Smartphone className="h-4 w-4" />
            <span>Download Official Mobile App</span>
            <ArrowRight className="h-4 w-4" />
          </SakugaLink>

          <SakugaButton
            variant="ghost"
            onClick={() => setIsStoryOpen(true)}
            className="inline-flex items-center gap-2 rounded-full border border-neutral-200 dark:border-neutral-800 bg-white/80 dark:bg-neutral-900/80 px-6 py-3.5 text-xs sm:text-sm font-medium text-neutral-800 dark:text-neutral-200 transition-all hover:border-neutral-400 dark:hover:border-neutral-600 backdrop-blur-md active:scale-[0.98]"
          >
            <span className="flex h-5 w-5 items-center justify-center rounded-full bg-blue-500/10 text-blue-600 dark:text-blue-400">
              <Play className="h-3 w-3 fill-current ml-0.5" />
            </span>
            <span>Watch How It Works</span>
          </SakugaButton>

          <SakugaLink
            href="/services-catalog"
            className="inline-flex items-center gap-2 rounded-full border border-neutral-200 dark:border-neutral-800 bg-white/80 dark:bg-neutral-900/80 px-6 py-3.5 text-xs sm:text-sm font-medium text-neutral-800 dark:text-neutral-200 transition-all hover:border-neutral-400 dark:hover:border-neutral-600 backdrop-blur-md active:scale-[0.98]"
          >
            <span>Explore Services Catalog</span>
          </SakugaLink>
        </div>

        {/* Quick Branch Access Strip */}
        <div className="mt-12 pt-8 border-t border-neutral-200/60 dark:border-white/10 max-w-4xl mx-auto">
          <p className="text-[11px] font-mono uppercase tracking-wider text-neutral-400 dark:text-neutral-500 mb-4 font-semibold">
            Direct Access to 8 Internal Specialization Branches
          </p>
          <div className="flex flex-wrap items-center justify-center gap-2">
            {branches.map((b) => (
              <Link
                key={b.code}
                href={b.href}
                className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border border-neutral-200 dark:border-neutral-800 bg-white/70 dark:bg-neutral-900/70 text-neutral-700 dark:text-neutral-300 hover:text-neutral-950 dark:hover:text-white hover:border-neutral-400 dark:hover:border-neutral-600 transition-all backdrop-blur-xs"
              >
                <span className="font-mono text-[10px] font-bold text-[#003399] dark:text-[#3898EC]">
                  {b.code}
                </span>
                <span>{b.name}</span>
              </Link>
            ))}
          </div>
        </div>

        {/* Interactive Story Modal */}
        <CinematicStoryModal
          isOpen={isStoryOpen}
          onClose={() => setIsStoryOpen(false)}
          t={theme}
          apkUrl="/download"
        />



        {/* Linear/Stripe-style Trust Metric Strip */}
        <div className="mt-16 pt-8 border-t border-slate-200 dark:border-slate-800/80 grid grid-cols-2 lg:grid-cols-4 gap-6 text-center">
          <div className="space-y-1">
            <p className="font-heading font-extrabold text-2xl sm:text-3xl text-[#003399] dark:text-[#3898EC]">
              8 Branches
            </p>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              One Accountable Enterprise
            </p>
          </div>
          <div className="space-y-1">
            <p className="font-heading font-extrabold text-2xl sm:text-3xl text-teal-600 dark:text-teal-400">
              4-Digit OTP
            </p>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              Physical Arrival Handshake
            </p>
          </div>
          <div className="space-y-1">
            <p className="font-heading font-extrabold text-2xl sm:text-3xl text-amber-500 dark:text-amber-400">
              90/10 Escrow
            </p>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              Settlement on Customer Sign-Off
            </p>
          </div>
          <div className="space-y-1">
            <p className="font-heading font-extrabold text-2xl sm:text-3xl text-indigo-600 dark:text-indigo-400">
              100% NID
            </p>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              Pre-Vetted Skilled Workforce
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
  const branches = getSpecializationBranches(false);

  return (
    <section id="branches" className="py-16 sm:py-24 border-t border-b border-slate-200 dark:border-slate-800 bg-slate-50/60 dark:bg-[#070A11] transition-colors scroll-mt-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-12 sm:mb-16">
          <p className="text-xs font-mono-code uppercase tracking-widest text-[#003399] dark:text-[#3898EC] font-bold mb-3">
            Internal Specialization Branches
          </p>
          <h2 className="font-heading text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-slate-900 dark:text-white">
            Eight Specialization Branches. One Unified Company.
          </h2>
          <p className="mt-4 text-sm sm:text-base text-slate-600 dark:text-slate-300 leading-relaxed">
            Every trade operates as an internal SKAVIA operational unit with uniform tool standards, 
            biometric background checks, and single-point corporate accountability.
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
                className={`rounded-3xl border p-6 flex flex-col justify-between transition-all cursor-pointer bg-white dark:bg-[#0B1120] ${
                  isSelected
                    ? 'ring-2 ring-blue-500 shadow-xl'
                    : 'hover:shadow-lg border-slate-200 dark:border-slate-800'
                }`}
              >
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div
                      className="h-11 w-11 rounded-2xl flex items-center justify-center shadow-xs"
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
                    <h3 className="font-heading font-bold text-lg text-slate-900 dark:text-white">
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

                <div className="pt-5 mt-5 border-t border-slate-200 dark:border-slate-800 space-y-2">
                  <p className="text-[10px] font-mono-code uppercase tracking-wider text-slate-400">
                    Typical Solutions:
                  </p>
                  <div className="flex flex-wrap gap-1.5">
                    {branch.examples.map((ex) => (
                      <span
                        key={ex}
                        className="inline-flex items-center gap-1 text-[11px] font-medium px-2 py-0.5 rounded-md border border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-900 text-slate-700 dark:text-slate-300"
                      >
                        <CheckCircle2 className="h-3 w-3 text-teal-500" />
                        <span>{ex}</span>
                      </span>
                    ))}
                  </div>

                  <div className="pt-2">
                    <Link
                      href={
                        branch.code === 'HOME'
                          ? '/branches/home'
                          : branch.code === 'TECH'
                          ? '/branches/technical'
                          : '/services-catalog'
                      }
                      className="inline-flex items-center gap-1 text-xs font-semibold text-[#003399] dark:text-[#3898EC] hover:underline"
                    >
                      <span>Explore {branch.code} SOP</span>
                      <ArrowRight className="h-3 w-3" />
                    </Link>
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
  const tabs = [
    {
      id: 'requirement' as WorkflowTab,
      label: '1. Scoping Engine',
      title: 'Explain Your Requirement Once',
      desc: 'Submit your requirement in natural language. Our system scopes the exact trade branch, estimates tools, and locks transparent upfront BDT pricing before confirmation.',
      points: [
        'Zero haggling with unaccountable brokers',
        'Transparent price estimates prior to confirmation',
        'Automatic selection of correct branch (HOME, TECH, etc.)',
      ],
    },
    {
      id: 'assembly' as WorkflowTab,
      label: '2. Specialist Dispatch',
      title: 'Biometric NID Matching & Proximity Routing',
      desc: 'SKAVIA assigns an authenticated specialist from the specific trade branch. Track their real-time transit with verified photo, NID badge, and ratings.',
      points: [
        'Government biometric NID verified with verified permanent address',
        'Trade qualification test passed before onboarding',
        'Live GPS arrival countdown on mobile map',
      ],
    },
    {
      id: 'delivery' as WorkflowTab,
      label: '3. Handshake & Escrow',
      title: '4-Digit Arrival OTP & Atomic Escrow',
      desc: 'The technician enters your confidential 4-digit arrival OTP upon physical door arrival. Payment is held in atomic escrow and released only after your digital sign-off.',
      points: [
        'Guaranteed physical technician presence before timer starts',
        '90% direct transfer to specialist with zero hidden commission cuts',
        'Official digital tax invoice and property protection warranty',
      ],
    },
  ];

  const currentTab = tabs.find((t) => t.id === activeTab) ?? tabs[0]!;

  return (
    <section id="how-it-works" className="py-16 sm:py-24 border-b border-slate-200 dark:border-slate-800 transition-colors scroll-mt-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <p className="text-xs font-mono-code uppercase tracking-widest text-[#003399] dark:text-[#3898EC] font-bold">
            End-to-End Operational Lifecycle
          </p>
          <h2 className="font-heading text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-slate-900 dark:text-white">
            How SKAVIA Delivers Guaranteed Quality
          </h2>
          <p className="text-sm sm:text-base text-slate-600 dark:text-slate-300 leading-relaxed">
            From natural requirement scoping to physical arrival OTP and atomic escrow release: a transparent four-stage process.
          </p>
        </div>

        {/* Tab Buttons */}
        <div className="flex justify-center">
          <div className="inline-flex p-1.5 rounded-2xl border border-slate-200 dark:border-slate-800 bg-slate-100 dark:bg-slate-900/60 gap-2">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                type="button"
                onClick={() => onSelectTab(tab.id)}
                className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-semibold transition-all ${
                  activeTab === tab.id
                    ? 'bg-[#003399] text-white shadow-md'
                    : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>

        {/* Active Tab Card */}
        <div className="max-w-4xl mx-auto rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-[#0B1120] p-8 sm:p-12 shadow-xl space-y-6">
          <h3 className="text-2xl sm:text-3xl font-extrabold text-slate-900 dark:text-white">
            {currentTab.title}
          </h3>
          <p className="text-sm sm:text-base text-slate-600 dark:text-slate-300 leading-relaxed">
            {currentTab.desc}
          </p>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-4 border-t border-slate-200 dark:border-slate-800">
            {currentTab.points.map((pt, i) => (
              <div key={i} className="flex items-start gap-2.5 text-xs text-slate-700 dark:text-slate-300">
                <CheckCircle2 className="h-4 w-4 text-teal-500 shrink-0 mt-0.5" />
                <span>{pt}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

export function SolutionsSection({ t }: { t: PublicThemeTokens }) {
  const individualHighlights = getIndividualHighlights(false);
  const businessHighlights = getBusinessHighlights(false);

  return (
    <section id="solutions" className={`py-16 sm:py-24 border-b ${t.railBorder} bg-slate-50/50 dark:bg-[#070A11] transition-colors scroll-mt-20`}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <p className="text-xs font-mono-code uppercase tracking-widest text-[#003399] dark:text-[#3898EC] font-bold">
            Tailored Operational Engagement
          </p>
          <h2 className={`font-heading text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight ${t.textPrimary}`}>
            Built for Residents &amp; Commercial Enterprises
          </h2>
          <p className={`text-sm sm:text-base ${t.textSecondary} leading-relaxed`}>
            Whether booking an urgent doorstep AC repair or negotiating a multi-site facility maintenance contract, SKAVIA provides structured accountability.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Residential Card */}
          <div className={`rounded-3xl border ${t.railBorder} ${t.cardBg} p-8 sm:p-10 space-y-6 shadow-xl`}>
            <div className="flex items-center gap-3">
              <div className="p-3 rounded-2xl bg-blue-500/10 text-blue-600 dark:text-blue-400">
                <Home className="h-6 w-6" />
              </div>
              <div>
                <span className="text-[11px] font-mono-code uppercase tracking-wider text-slate-400 font-bold">
                  Consumer Experience
                </span>
                <h3 className="text-xl sm:text-2xl font-bold text-slate-900 dark:text-white">
                  Individual Residential Services
                </h3>
              </div>
            </div>

            <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
              Instant mobile dispatch for plumbing, AC servicing, electrical wiring, and residential maintenance. Every technician is background-checked and checked in via arrival OTP.
            </p>

            <ul className="space-y-2.5 text-xs">
              {individualHighlights.map((h, i) => (
                <li key={i} className="flex items-start gap-2.5 text-slate-700 dark:text-slate-300">
                  <CheckCircle2 className="h-4 w-4 text-teal-500 shrink-0 mt-0.5" />
                  <span>{h}</span>
                </li>
              ))}
            </ul>

            <div className="pt-4 border-t border-slate-200 dark:border-slate-800">
              <Link
                href="/download"
                className="inline-flex items-center gap-2 text-xs font-bold text-[#003399] dark:text-[#3898EC] hover:underline"
              >
                <span>Download Client Mobile App</span>
                <ArrowRight className="h-4 w-4" />
              </Link>
            </div>
          </div>

          {/* Commercial Enterprise Card (ServiceTitan style) */}
          <div className="rounded-3xl border border-purple-200 dark:border-purple-900/40 bg-white dark:bg-[#0B1120] p-8 sm:p-10 space-y-6 shadow-xl">
            <div className="flex items-center gap-3">
              <div className="p-3 rounded-2xl bg-purple-500/10 text-purple-600 dark:text-purple-400">
                <Building2 className="h-6 w-6" />
              </div>
              <div>
                <span className="text-[11px] font-mono-code uppercase tracking-wider text-purple-500 font-bold">
                  B2B &amp; Corporate
                </span>
                <h3 className="text-xl sm:text-2xl font-bold text-slate-900 dark:text-white">
                  Commercial Facility Turnkey SLAs
                </h3>
              </div>
            </div>

            <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
              Multi-branch workforce coordination for corporate offices, retail chains, and institutional buildings. Managed by a dedicated on-site Team Leader with milestone escrow sign-offs.
            </p>

            <ul className="space-y-2.5 text-xs">
              {businessHighlights.map((h, i) => (
                <li key={i} className="flex items-start gap-2.5 text-slate-700 dark:text-slate-300">
                  <CheckCircle2 className="h-4 w-4 text-purple-500 shrink-0 mt-0.5" />
                  <span>{h}</span>
                </li>
              ))}
            </ul>

            <div className="pt-4 border-t border-slate-200 dark:border-slate-800">
              <Link
                href="/business"
                className="inline-flex items-center gap-2 text-xs font-bold text-purple-600 dark:text-purple-400 hover:underline"
              >
                <span>Explore Enterprise Solutions &amp; SLAs</span>
                <ArrowRight className="h-4 w-4" />
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
