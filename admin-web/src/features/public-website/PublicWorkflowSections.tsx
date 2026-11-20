'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  ArrowRight,
  Building2,
  CheckCircle2,
  Cpu,
  HardHat,
  Home,
  KeyRound,
  Play,
  Search,
  ShieldCheck,
  Smartphone,
  Sprout,
  Zap,
} from 'lucide-react';
import { CinematicAtmosphereCanvas } from './CinematicAtmosphereCanvas';
import { CinematicStoryModal } from './CinematicStoryModal';
import { HeroAtmosphere } from './components/HeroAtmosphere';
import {
  getBusinessHighlights,
  getIndividualHighlights,
  getSpecializationBranches,
  type PublicThemeTokens,
  type WorkflowTab,
} from './public-site-data';

interface ScopingSuggestion {
  query: string;
  branchCode: string;
  branchName: string;
  price: string;
  sla: string;
  icon: typeof Zap;
  accent: string;
  description: string;
  targetHref: string;
}

const SCOPING_SUGGESTIONS: ScopingSuggestion[] = [
  {
    query: 'AC Cooling & Jet Wash Servicing',
    branchCode: 'TECH',
    branchName: 'SKAVIA Technical',
    price: '৳ 1,200 – ৳ 2,500',
    sla: 'Specialist dispatched in 45m',
    icon: Zap,
    accent: '#3898EC',
    description: 'High-pressure chemical jet wash, amperage test, and refrigerant leak detection.',
    targetHref: '/services-catalog/inverter-ac-jet-wash',
  },
  {
    query: 'Sanitary Plumbing & Pipe Leakage',
    branchCode: 'HOME',
    branchName: 'SKAVIA Home',
    price: '৳ 600 – ৳ 1,500',
    sla: 'Urgent doorstep response available',
    icon: Home,
    accent: '#15E7CA',
    description: 'Concealed leak localization, pressure pump balancing, and PPR pipe fusion.',
    targetHref: '/branches/home',
  },
  {
    query: 'Main DB Board & Electrical Setup',
    branchCode: 'TECH',
    branchName: 'SKAVIA Technical',
    price: '৳ 1,500 – ৳ 3,200',
    sla: 'Level-3 certified wireman dispatch',
    icon: Zap,
    accent: '#3898EC',
    description: 'RCCB earth leakage breaker tuning, 3-phase balancing, and thermal thermography.',
    targetHref: '/services-catalog/main-db-board-setup',
  },
  {
    query: 'LAN Cabling & PoE IP Surveillance',
    branchCode: 'DIGI',
    branchName: 'SKAVIA Digital',
    price: '৳ 1,800 – ৳ 4,000',
    sla: 'Diagnostic hardware scan included',
    icon: Cpu,
    accent: '#8B5CF6',
    description: 'Structured Cat6 ethernet punchdown, PoE NVR setup, and WiFi mesh calibration.',
    targetHref: '/services-catalog',
  },
  {
    query: 'Commercial Turnkey Office Fit-Out',
    branchCode: 'CONS',
    branchName: 'SKAVIA Construction',
    price: 'Milestone Escrow Contract',
    sla: 'Supervised by on-site Team Leader',
    icon: HardHat,
    accent: '#F97316',
    description: 'Acoustic gypsum partitions, aluminum-glass walls, and commercial vinyl finishing.',
    targetHref: '/business',
  },
  {
    query: 'Irrigation Pump & Agri-Automation',
    branchCode: 'AGRI',
    branchName: 'SKAVIA Agriculture',
    price: '৳ 1,500 – ৳ 3,500',
    sla: 'Field-tested electromechanic dispatch',
    icon: Sprout,
    accent: '#22C55E',
    description: 'Drip solenoid valve wiring, submersible pump priming, and sensor tuning.',
    targetHref: '/services-catalog',
  },
];

export function HeroSection({ t: theme }: { t: PublicThemeTokens }) {
  const [searchQuery, setSearchQuery] = useState('');
  const [activeSuggestionIdx, setActiveSuggestionIdx] = useState(0);
  const [isStoryOpen, setIsStoryOpen] = useState(false);

  const filteredSuggestions = searchQuery.trim()
    ? SCOPING_SUGGESTIONS.filter((s) =>
        s.query.toLowerCase().includes(searchQuery.toLowerCase()) ||
        s.branchName.toLowerCase().includes(searchQuery.toLowerCase()) ||
        s.description.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : SCOPING_SUGGESTIONS;

  const activeScoping =
    filteredSuggestions[activeSuggestionIdx] ??
    filteredSuggestions[0] ??
    SCOPING_SUGGESTIONS[0]!;
  const ActiveIcon = activeScoping.icon;

  return (
    <section className="relative overflow-hidden pt-12 pb-20 sm:pt-20 sm:pb-28 transition-colors">
      {/* Seamless Multi-Layered Hero Atmosphere (Zero-Banding Full-Bleed Lighting & Precision Dot Grid) */}
      <HeroAtmosphere dark={theme.dark} variant="hero" />
      <CinematicAtmosphereCanvas dark={theme.dark} />

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        {/* Trust Pill */}
        <div className="inline-flex items-center gap-2 rounded-full border border-blue-500/30 bg-blue-500/10 px-4 py-1.5 text-xs font-semibold backdrop-blur-md mb-6 shadow-sm">
          <span className="h-2 w-2 rounded-full bg-[#15E7CA] animate-pulse" />
          <span className="text-slate-800 dark:text-cyan-200">
            Live in Bangladesh &middot; 8 Internal Specialization Branches &middot; Single Corporate Accountability
          </span>
        </div>

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

        {/* Taskrabbit-style Interactive Requirement Search Bar */}
        <div className="mt-10 max-w-2xl mx-auto">
          <div className="relative flex items-center rounded-2xl border border-slate-300 dark:border-slate-700 bg-white dark:bg-[#0B1120] shadow-2xl p-2 transition-all focus-within:ring-2 focus-within:ring-[#3898EC] focus-within:border-transparent">
            <Search className="h-5 w-5 text-slate-400 ml-3 shrink-0" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => {
                setSearchQuery(e.target.value);
                setActiveSuggestionIdx(0);
              }}
              placeholder="What skilled trade do you need? (e.g. AC Repair, Electrical, Plumbing, Fit-Out)"
              className="w-full bg-transparent px-3 py-2 text-xs sm:text-sm text-slate-900 dark:text-white outline-none placeholder:text-slate-400"
            />
            <Link
              href={searchQuery ? `/services-catalog?q=${encodeURIComponent(searchQuery)}` : '/services-catalog'}
              className="hidden sm:inline-flex items-center gap-1.5 rounded-xl bg-[#003399] hover:bg-[#002266] px-5 py-2.5 text-xs font-bold text-white transition-all shrink-0"
            >
              <span>Explore</span>
              <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </div>
        </div>

        {/* Action CTAs */}
        <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
          <Link
            href="/download"
            className="inline-flex items-center gap-2.5 rounded-full px-7 py-3 text-xs sm:text-sm font-semibold bg-neutral-950 text-white hover:bg-neutral-800 dark:bg-white dark:text-neutral-950 dark:hover:bg-neutral-200 shadow-md transition-all hover:scale-[1.02] active:scale-[0.98]"
          >
            <Smartphone className="h-4 w-4" />
            <span>Download Official Mobile App</span>
            <ArrowRight className="h-4 w-4" />
          </Link>

          <button
            type="button"
            onClick={() => setIsStoryOpen(true)}
            className="inline-flex items-center gap-2 rounded-full border border-neutral-200 dark:border-neutral-800 bg-white/80 dark:bg-neutral-900/80 px-6 py-3 text-xs sm:text-sm font-medium text-neutral-800 dark:text-neutral-200 transition-all hover:border-neutral-400 dark:hover:border-neutral-600 backdrop-blur-md"
          >
            <span className="flex h-5 w-5 items-center justify-center rounded-full bg-blue-500/10 text-blue-600 dark:text-blue-400">
              <Play className="h-3 w-3 fill-current ml-0.5" />
            </span>
            <span>Watch How It Works</span>
          </button>

          <Link
            href="/services-catalog"
            className="inline-flex items-center gap-2 rounded-full border border-neutral-200 dark:border-neutral-800 bg-white/80 dark:bg-neutral-900/80 px-6 py-3 text-xs sm:text-sm font-medium text-neutral-800 dark:text-neutral-200 transition-all hover:border-neutral-400 dark:hover:border-neutral-600 backdrop-blur-md"
          >
            <span>View 8 Specialization Branches</span>
          </Link>
        </div>

        {/* Interactive Story Modal */}
        <CinematicStoryModal
          isOpen={isStoryOpen}
          onClose={() => setIsStoryOpen(false)}
          t={theme}
          apkUrl="/download"
        />

        {/* Interactive Requirement Scoping Engine */}
        <div className="mt-14 max-w-3xl mx-auto text-left">
          <div className="rounded-3xl border border-slate-200 dark:border-slate-800/80 bg-white dark:bg-[#0B1120] p-6 sm:p-8 shadow-2xl backdrop-blur-xl space-y-5 transition-all">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-slate-200 dark:border-slate-800 pb-4">
              <div>
                <p className="text-[11px] font-mono-code uppercase tracking-wider text-[#003399] dark:text-[#3898EC] font-bold">
                  Interactive Service Blueprint
                </p>
                <h3 className="text-base sm:text-lg font-bold text-slate-900 dark:text-white">
                  Select a trade requirement to preview operational delivery:
                </h3>
              </div>
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20">
                <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                <span>Live Estimator</span>
              </span>
            </div>

            {/* Quick Suggestion Chips */}
            <div className="flex flex-wrap gap-2">
              {filteredSuggestions.map((item, idx) => {
                const isSelected = activeSuggestionIdx === idx;
                return (
                  <button
                    key={item.query}
                    type="button"
                    onClick={() => setActiveSuggestionIdx(idx)}
                    className={`rounded-full px-3.5 py-1.5 text-xs transition font-semibold flex items-center gap-1.5 ${
                      isSelected
                        ? 'bg-[#003399] text-white shadow-md'
                        : 'border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 hover:border-slate-400 dark:hover:border-slate-600 bg-slate-50 dark:bg-slate-900/60'
                    }`}
                  >
                    <span>{item.query}</span>
                  </button>
                );
              })}
            </div>

            {/* Matched Delivery Blueprint Preview */}
            <div className="rounded-2xl border border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-900/50 p-5 space-y-4 transition-all">
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
                      <span className="font-bold text-sm text-slate-900 dark:text-white">
                        {activeScoping.branchName}
                      </span>
                      <span className="text-[11px] font-mono-code px-2 py-0.5 rounded bg-slate-200 dark:bg-slate-800 text-slate-700 dark:text-slate-300 font-bold">
                        {activeScoping.branchCode}
                      </span>
                    </div>
                    <p className="text-xs text-slate-500 dark:text-slate-400">
                      {activeScoping.sla}
                    </p>
                  </div>
                </div>

                <div className="text-right">
                  <p className="text-xs font-mono-code text-slate-500">Base Estimate:</p>
                  <p className="text-base font-extrabold text-[#003399] dark:text-[#3898EC]">
                    {activeScoping.price}
                  </p>
                </div>
              </div>

              <p className="text-xs text-slate-600 dark:text-slate-400">
                {activeScoping.description}
              </p>

              {/* Trust Signals */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs pt-3 border-t border-slate-200 dark:border-slate-800">
                <div className="flex items-center gap-2 text-slate-700 dark:text-slate-300 font-medium">
                  <KeyRound className="h-4 w-4 text-blue-600 shrink-0" />
                  <span>4-digit physical arrival handshake OTP</span>
                </div>
                <div className="flex items-center gap-2 text-slate-700 dark:text-slate-300 font-medium">
                  <ShieldCheck className="h-4 w-4 text-teal-600 shrink-0" />
                  <span>NID biometric background-checked specialist</span>
                </div>
              </div>
            </div>

            {/* Direct Action Link */}
            <div className="flex flex-col sm:flex-row items-center justify-between gap-3 pt-1">
              <p className="text-xs text-slate-500">
                Direct dispatch with 90% specialist revenue retention and zero broker cuts.
              </p>
              <Link
                href={activeScoping.targetHref}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-xl bg-[#003399] hover:bg-[#002266] px-5 py-2.5 text-xs font-bold text-white transition shadow-md"
              >
                <span>View Trade Protocol</span>
                <ArrowRight className="h-4 w-4" />
              </Link>
            </div>
          </div>
        </div>

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
    <section id="branches" className="py-16 sm:py-24 border-t border-b border-slate-200 dark:border-slate-800 bg-slate-50/60 dark:bg-[#070A11] transition-colors">
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
    <section id="how-it-works" className="py-16 sm:py-24 border-b border-slate-200 dark:border-slate-800 transition-colors">
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
    <section id="solutions" className={`py-16 sm:py-24 border-b ${t.railBorder} bg-slate-50/50 dark:bg-[#070A11] transition-colors`}>
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
