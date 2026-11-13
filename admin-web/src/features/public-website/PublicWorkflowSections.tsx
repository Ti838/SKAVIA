import Link from 'next/link';
import {
  ArrowRight,
  Building2,
  CheckCircle2,
  Moon,
  ShieldCheck,
  Smartphone,
  Sun,
  Wrench,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import {
  BUSINESS_HIGHLIGHTS,
  INDIVIDUAL_HIGHLIGHTS,
  LIFECYCLE_STEPS,
  SPECIALIZATION_BRANCHES,
  WORKFLOW_TABS,
  type PublicThemeTokens,
  type WorkflowTab,
} from './public-site-data';

function Crosshair({ dark }: { dark: boolean }) {
  return (
    <span
      aria-hidden="true"
      className={`pointer-events-none select-none font-mono-code text-xs leading-none ${
        dark ? 'text-white/30' : 'text-slate-400'
      }`}
    >
      +
    </span>
  );
}

export function PublicHeader({
  t,
  onToggleTheme,
}: {
  t: PublicThemeTokens;
  onToggleTheme: () => void;
}) {
  return (
    <header
      className={`sticky top-0 z-50 border-b backdrop-blur-xl transition-colors ${t.railBorder} ${
        t.dark ? 'bg-[#03050A]/85' : 'bg-white/90'
      }`}
    >
      <div className="max-w-[1200px] mx-auto px-4 sm:px-6 h-16 flex items-center justify-between gap-4">
        <Link href="/" className="flex items-center gap-2.5 shrink-0">
          <SkaviaBrandMark variant="emblem" size={32} priority />
          <span className="text-base font-bold tracking-tight">SKAVIA</span>
          <span
            className={`hidden sm:inline-flex items-center rounded-full border px-2.5 py-0.5 text-[10px] font-medium uppercase tracking-widest ${
              t.dark
                ? 'border-cyan-400/25 bg-cyan-500/10 text-cyan-300'
                : 'border-blue-200 bg-blue-50 text-blue-800'
            }`}
          >
            Official Platform
          </span>
        </Link>

        <nav
          aria-label="Public Website Navigation"
          className={`hidden md:flex items-center gap-6 text-sm font-medium ${t.textSecondary}`}
        >
          <a href="#about" className="hover:text-[#3898EC] transition-colors">
            About
          </a>
          <a href="#how-it-works" className="hover:text-[#3898EC] transition-colors">
            How It Works
          </a>
          <a href="#branches" className="hover:text-[#3898EC] transition-colors">
            Branches
          </a>
          <a href="#solutions" className="hover:text-[#3898EC] transition-colors">
            Solutions
          </a>
          <a href="#workers" className="hover:text-[#3898EC] transition-colors">
            Become a Worker
          </a>
          <a href="#faq" className="hover:text-[#3898EC] transition-colors">
            FAQ
          </a>
        </nav>

        <div className="flex items-center gap-2 sm:gap-2.5 shrink-0">
          <button
            type="button"
            onClick={onToggleTheme}
            aria-label="Toggle color theme"
            className={`inline-flex h-9 w-9 items-center justify-center rounded-full border transition ${t.railBorder} ${
              t.dark ? 'hover:bg-white/10 text-slate-300' : 'hover:bg-slate-100 text-slate-700'
            }`}
          >
            {t.dark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
          </button>

          <a
            href="#contact"
            className={`hidden sm:inline-flex items-center rounded-full border px-4 py-1.5 text-xs font-medium transition ${t.railBorder} ${
              t.dark ? 'text-slate-200 hover:bg-white/10' : 'text-slate-700 hover:bg-slate-100'
            }`}
          >
            Contact &amp; Support
          </a>

          <a
            href="#download"
            className={`inline-flex items-center gap-1.5 rounded-full px-4 py-1.5 text-xs font-semibold transition shadow-sm ${
              t.dark
                ? 'bg-white text-slate-950 hover:bg-slate-200'
                : 'bg-[#003399] text-white hover:bg-[#00287a]'
            }`}
          >
            <Smartphone className="h-3.5 w-3.5" />
            <span>Get Mobile App</span>
          </a>
        </div>
      </div>
    </header>
  );
}

export function HeroSection({ t }: { t: PublicThemeTokens }) {
  return (
    <section
      className={`relative border-b ${t.railBorder} ${
        t.dark ? 'skavia-blueprint-dark' : 'skavia-blueprint-light'
      } overflow-hidden`}
    >
      <div className="absolute top-2.5 left-2.5 z-20">
        <Crosshair dark={t.dark} />
      </div>
      <div className="absolute top-2.5 right-2.5 z-20">
        <Crosshair dark={t.dark} />
      </div>

      <div
        aria-hidden="true"
        className="pointer-events-none absolute -bottom-24 left-1/2 -translate-x-1/2 h-80 w-[760px] skavia-spectral-arc opacity-90"
      />

      <div className="relative z-10 px-4 sm:px-8 pt-16 sm:pt-24 pb-16 sm:pb-24 text-center">
        <div
          className={`inline-flex items-center gap-2 rounded-full border px-3.5 py-1 text-xs font-medium mb-7 ${t.railBorder} ${
            t.dark ? 'bg-white/[0.04] text-slate-200' : 'bg-white text-slate-700 shadow-xs'
          }`}
        >
          <span className="h-2 w-2 rounded-full bg-[#15E7CA] animate-pulse" />
          <span>One Accountable Organization &middot; 8 Specialization Branches</span>
        </div>

        <h1 className="mx-auto max-w-4xl text-4xl sm:text-6xl md:text-[4.15rem] font-bold tracking-[-0.04em] leading-[1.06]">
          Explain Your Requirement.
          <span
            className="block mt-2 bg-clip-text text-transparent"
            style={{
              backgroundImage: t.dark
                ? 'linear-gradient(90deg, #FFFFFF 0%, #3898EC 55%, #15E7CA 100%)'
                : 'linear-gradient(90deg, #003399 0%, #3898EC 55%, #0D9488 100%)',
            }}
          >
            SKAVIA Delivers the Solution.
          </span>
        </h1>

        <p className={`mx-auto mt-6 max-w-2xl text-base sm:text-lg leading-relaxed ${t.textSecondary}`}>
          SKAVIA is a complete solution-oriented service and workforce platform. Tell us what
          your home, farm, organization, or project needs — SKAVIA identifies required skills,
          matches verified workers or forms a Team-Leader-led crew, and manages delivery to verified completion.
        </p>

        <div className="mt-9 flex flex-wrap items-center justify-center gap-3.5">
          <a
            href="#download"
            className={`inline-flex items-center gap-2.5 rounded-full px-6 py-3 text-sm font-semibold transition shadow-lg ${
              t.dark
                ? 'bg-white text-slate-950 hover:bg-slate-200'
                : 'bg-[#003399] text-white hover:bg-[#00287a]'
            }`}
          >
            <SkaviaBrandMark variant="emblem" size={18} />
            <span>Download SKAVIA App</span>
            <ArrowRight className="h-4 w-4" />
          </a>

          <a
            href="#branches"
            className={`inline-flex items-center gap-2 rounded-full border px-6 py-3 text-sm font-medium transition ${t.railBorder} ${
              t.dark
                ? 'bg-[#0A0F1C]/80 text-white hover:border-white/40'
                : 'bg-white text-slate-900 hover:border-slate-400'
            }`}
          >
            <span>Explore 8 Branches</span>
          </a>
        </div>

        <div className="mt-14 mx-auto max-w-2xl">
          <div
            className={`relative rounded-2xl border p-6 sm:p-7 backdrop-blur-md shadow-2xl ${t.railBorder} ${
              t.dark ? 'bg-[#070B14]/85' : 'bg-white/95'
            }`}
          >
            <div className="flex flex-col sm:flex-row items-center justify-between gap-6">
              <div className="flex items-center gap-4 text-left">
                <div
                  className={`h-16 w-16 rounded-2xl border flex items-center justify-center p-2.5 shrink-0 ${t.railBorder} ${
                    t.dark ? 'bg-[#0B1938]/70' : 'bg-[#EBF5FF]'
                  }`}
                >
                  <SkaviaBrandMark variant="emblem" size={48} priority />
                </div>
                <div>
                  <p className="text-[11px] font-mono-code uppercase tracking-widest text-[#3898EC]">
                    SKAVIA ECOSYSTEM
                  </p>
                  <p className={`text-lg font-semibold tracking-tight ${t.textPrimary}`}>
                    Solution-First Managed Execution
                  </p>
                  <p className={`text-xs mt-0.5 ${t.textSecondary}`}>
                    Client Mode &middot; Worker Mode &middot; Team Leader Coordination
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2 w-full sm:w-auto text-left font-mono-code text-[11px]">
                <div className={`rounded-lg border px-3 py-2 ${t.railBorder} ${t.surfaceBg}`}>
                  <p className={t.textMuted}>BRANCHES</p>
                  <p className="font-semibold text-[#15E7CA]">8 Internal Units</p>
                </div>
                <div className={`rounded-lg border px-3 py-2 ${t.railBorder} ${t.surfaceBg}`}>
                  <p className={t.textMuted}>DELIVERY</p>
                  <p className="font-semibold text-[#3898EC]">Mobile App Only</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export function WorkflowSection({
  t,
  activeTab,
  onSelectTab,
}: {
  t: PublicThemeTokens;
  activeTab: WorkflowTab;
  onSelectTab: (tab: WorkflowTab) => void;
}) {
  return (
    <section id="about" className={`border-b ${t.railBorder} ${t.surfaceBg}`}>
      <div id="how-it-works" className="grid grid-cols-1 lg:grid-cols-12">
        <div className={`lg:col-span-5 p-6 sm:p-10 border-b lg:border-b-0 lg:border-r ${t.railBorder}`}>
          <p className="text-xs font-mono-code uppercase tracking-widest text-[#3898EC] mb-2">
            About &amp; Workflow
          </p>
          <h2 className="text-2xl sm:text-3xl font-bold tracking-tight">
            Not just a directory. One accountable delivery engine.
          </h2>
          <p className={`text-sm mt-3 leading-relaxed ${t.textSecondary}`}>
            Unlike generic classifieds or freelancer boards that abandon users after sharing a phone number,
            SKAVIA remains responsible across requirement scoping, verified worker matching, Team Leader
            supervision, milestone escrow, and verified ratings.
          </p>

          <div className="mt-7 space-y-2">
            {WORKFLOW_TABS.map((tab) => {
              const active = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  type="button"
                  onClick={() => onSelectTab(tab.id)}
                  className={`w-full text-left rounded-xl border p-4 transition ${
                    active
                      ? t.dark
                        ? 'border-[#3898EC]/60 bg-[#0B1938]/55'
                        : 'border-[#003399] bg-[#EBF5FF]'
                      : `${t.railBorder} ${t.cardBg} hover:border-slate-500/40`
                  }`}
                >
                  <p className="text-[11px] font-mono-code uppercase tracking-wider text-[#3898EC]">
                    {tab.step}
                  </p>
                  <p className={`text-sm font-semibold mt-0.5 ${t.textPrimary}`}>{tab.title}</p>
                  <p className={`text-xs mt-1 leading-relaxed ${t.textSecondary}`}>{tab.subtitle}</p>
                </button>
              );
            })}
          </div>
        </div>

        <div className="lg:col-span-7 p-6 sm:p-10 flex flex-col justify-between">
          <div>
            <p className="text-xs font-mono-code uppercase tracking-widest text-[#15E7CA] mb-3">
              End-to-End Solution Lifecycle
            </p>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {LIFECYCLE_STEPS.map((step) => (
                <div
                  key={step.n}
                  className={`rounded-xl border p-4 ${t.railBorder} ${t.cardBg}`}
                >
                  <div className="flex items-center gap-2.5 mb-2">
                    <span className="h-6 w-6 rounded-full bg-[#003399] text-white text-xs font-bold flex items-center justify-center">
                      {step.n}
                    </span>
                    <h3 className="text-sm font-semibold">{step.title}</h3>
                  </div>
                  <p className={`text-xs leading-relaxed ${t.textSecondary}`}>{step.desc}</p>
                </div>
              ))}
            </div>
          </div>

          <div
            className={`mt-6 rounded-xl border p-4 flex items-center justify-between gap-4 ${t.railBorder} ${t.subtleCardBg}`}
          >
            <div className="flex items-center gap-3">
              <ShieldCheck className="h-5 w-5 text-[#15E7CA] shrink-0" />
              <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                Active focus:{' '}
                <strong className={t.textPrimary}>
                  {WORKFLOW_TABS.find((x) => x.id === activeTab)?.title}
                </strong>{' '}
                — handled inside the SKAVIA mobile app.
              </p>
            </div>
            <a href="#download" className="text-xs font-semibold text-[#3898EC] shrink-0 hover:underline">
              Get App &rarr;
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}

export function BranchesSection({
  t,
  selectedBranchCode,
  onSelectBranch,
}: {
  t: PublicThemeTokens;
  selectedBranchCode: string;
  onSelectBranch: (code: string) => void;
}) {
  const activeBranch =
    SPECIALIZATION_BRANCHES.find((b) => b.code === selectedBranchCode) ??
    SPECIALIZATION_BRANCHES[0]!;

  return (
    <section id="branches" className={`border-b ${t.railBorder} ${t.subtleCardBg} p-6 sm:p-10`}>
      <div className="max-w-3xl mb-8">
        <p className="text-xs font-mono-code uppercase tracking-widest text-[#3898EC] mb-2">
          Internal Operational Branches
        </p>
        <h2 className="text-2xl sm:text-3xl font-bold tracking-tight">
          Eight Specialization Branches. One Unified Organization.
        </h2>
        <p className={`text-sm mt-2 leading-relaxed ${t.textSecondary}`}>
          Every specialization runs as an internal SKAVIA operational branch with consistent identity
          standards, verification checks, and coordinated supervision.
        </p>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6">
        {SPECIALIZATION_BRANCHES.map((branch) => {
          const Icon = branch.icon;
          const selected = branch.code === selectedBranchCode;
          return (
            <button
              key={branch.code}
              type="button"
              onClick={() => onSelectBranch(branch.code)}
              className={`text-left rounded-xl border p-4 transition ${
                selected
                  ? t.dark
                    ? 'border-[#3898EC] bg-[#0B1938]/60 shadow-md'
                    : 'border-[#003399] bg-white shadow-sm'
                  : `${t.railBorder} ${t.surfaceBg} hover:border-slate-500/40`
              }`}
            >
              <div className="flex items-center justify-between mb-2">
                <Icon className="h-4 w-4" style={{ color: branch.accent }} />
                <span className="text-[10px] font-mono-code uppercase tracking-wider opacity-60">
                  {branch.code}
                </span>
              </div>
              <p className="text-sm font-semibold">{branch.name}</p>
              <p className={`text-[11px] mt-1 line-clamp-1 ${t.textMuted}`}>{branch.tagline}</p>
            </button>
          );
        })}
      </div>

      <div className={`rounded-2xl border p-6 ${t.railBorder} ${t.surfaceBg}`}>
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="space-y-2 max-w-2xl">
            <div className="flex items-center gap-2">
              <span
                className="h-2.5 w-2.5 rounded-full"
                style={{ backgroundColor: activeBranch.accent }}
              />
              <span className="text-xs font-mono-code uppercase tracking-widest text-[#3898EC]">
                {activeBranch.name} &middot; Internal Branch
              </span>
            </div>
            <h3 className="text-xl font-bold">{activeBranch.tagline}</h3>
            <p className={`text-sm leading-relaxed ${t.textSecondary}`}>{activeBranch.scope}</p>
          </div>
          <div className="flex flex-wrap gap-2">
            {activeBranch.examples.map((ex) => (
              <span
                key={ex}
                className={`inline-flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-xs ${t.railBorder} ${t.cardBg}`}
              >
                <CheckCircle2 className="h-3.5 w-3.5 text-[#15E7CA]" />
                {ex}
              </span>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

export function SolutionsSection({ t }: { t: PublicThemeTokens }) {
  return (
    <section id="solutions" className={`border-b ${t.railBorder} ${t.surfaceBg}`}>
      <div className={`grid grid-cols-1 md:grid-cols-2 gap-px ${t.hairlineBg}`}>
        <div className={`p-8 sm:p-10 ${t.surfaceBg}`}>
          <div className="inline-flex items-center gap-2 text-xs font-mono-code uppercase tracking-widest text-[#15E7CA] mb-3">
            <Wrench className="h-4 w-4" />
            <span>Individual Service Solutions</span>
          </div>
          <h3 className="text-2xl font-bold tracking-tight">Reliable Everyday &amp; Urgent Help</h3>
          <p className={`text-sm mt-2 leading-relaxed ${t.textSecondary}`}>
            Book vetted technicians or skilled craftspeople for home repairs, AC &amp; electrical work,
            renovations, and household support directly from your phone.
          </p>
          <ul className={`mt-5 space-y-2.5 text-xs ${t.textSecondary}`}>
            {INDIVIDUAL_HIGHLIGHTS.map((item) => (
              <li key={item} className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 text-[#15E7CA] shrink-0" />
                {item}
              </li>
            ))}
          </ul>
        </div>

        <div className={`p-8 sm:p-10 ${t.surfaceBg}`}>
          <div className="inline-flex items-center gap-2 text-xs font-mono-code uppercase tracking-widest text-[#3898EC] mb-3">
            <Building2 className="h-4 w-4" />
            <span>Business &amp; Organization Solutions</span>
          </div>
          <h3 className="text-2xl font-bold tracking-tight">Multi-Skill Teams &amp; Turnkey Projects</h3>
          <p className={`text-sm mt-2 leading-relaxed ${t.textSecondary}`}>
            For offices, factories, farms, retail chains, and events, SKAVIA assembles structured
            project crews supervised by a dedicated Team Leader.
          </p>
          <ul className={`mt-5 space-y-2.5 text-xs ${t.textSecondary}`}>
            {BUSINESS_HIGHLIGHTS.map((item) => (
              <li key={item} className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 text-[#3898EC] shrink-0" />
                {item}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}

