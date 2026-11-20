'use client';

import Link from 'next/link';
import {
  ArrowRight,
  Coins,
  Hammer,
  Smartphone,
  Wallet,
} from 'lucide-react';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';
import { WORKER_ONBOARDING_STEPS } from '../public-site-data';

export function SpecialistsScreen() {
  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-16 py-12 md:py-16">
          {/* Hero */}
          <section className="relative px-4 sm:px-6 lg:px-8 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />

            <div className="max-w-4xl mx-auto text-center space-y-5 relative z-10">
              <div
                className={`inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full border text-xs font-mono-code ${
                  t.dark
                    ? 'border-cyan-400/30 bg-cyan-500/10 text-cyan-300'
                    : 'border-blue-300 bg-blue-50 text-blue-700'
                }`}
              >
                <Wallet className="h-4 w-4 text-[#15E7CA]" />
                <span>SPECIALIST REVENUE CHARTER &middot; 90% DIRECT EARNINGS</span>
              </div>

              <h1 className={`text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight ${t.textPrimary}`}>
                Empowering Bangladesh&apos;s Skilled Field Specialists
              </h1>

              <p className={`text-base sm:text-lg lg:text-xl leading-relaxed max-w-2xl mx-auto ${t.textSecondary}`}>
                Say goodbye to arbitrary broker cuts. On SKAVIA, 90% of every customer booking is credited directly to the verified technician’s wallet with weekly bank and MFS settlements.
              </p>

              <div className="pt-2 flex flex-wrap items-center justify-center gap-4">
                <Link
                  href="/download"
                  className="inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold text-white shadow-lg shadow-teal-900/20 bg-gradient-to-r from-[#003399] to-[#06B6D4] hover:from-[#002266] hover:to-[#0891b2] transition-all hover:scale-[1.02]"
                >
                  <Smartphone className="h-4 w-4" />
                  <span>Join as Specialist (Get App)</span>
                  <ArrowRight className="h-4 w-4" />
                </Link>

                <Link
                  href="/services-catalog"
                  className={`inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold border transition-all ${
                    t.dark
                      ? 'border-slate-800 bg-slate-900/80 text-white hover:bg-slate-800'
                      : 'border-slate-300 bg-white text-slate-900 hover:bg-slate-50'
                  }`}
                >
                  <span>Explore Rate Cards</span>
                </Link>
              </div>
            </div>
          </section>

          {/* 3 High-Impact Earnings & Benefits Cards */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto grid grid-cols-1 sm:grid-cols-3 gap-6">
              <div className={`rounded-3xl border p-8 space-y-3 ${t.railBorder} ${t.cardBg} shadow-lg`}>
                <div className="flex items-center justify-between">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-[#15E7CA] font-bold">
                    Revenue Share
                  </span>
                  <Wallet className="h-5 w-5 text-[#15E7CA]" />
                </div>
                <div className={`text-3xl sm:text-4xl font-extrabold ${t.textPrimary}`}>
                  90% <span className="text-sm font-normal text-slate-400">Direct</span>
                </div>
                <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                  90% of order value goes directly to you. The 10% platform fee funds 24/7 client dispatch, safety insurance, and tool support.
                </p>
              </div>

              <div className={`rounded-3xl border p-8 space-y-3 ${t.railBorder} ${t.cardBg} shadow-lg`}>
                <div className="flex items-center justify-between">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-[#3898EC] font-bold">
                    Weekly Settlements
                  </span>
                  <Coins className="h-5 w-5 text-[#3898EC]" />
                </div>
                <div className={`text-3xl sm:text-4xl font-extrabold ${t.textPrimary}`}>
                  100% <span className="text-sm font-normal text-slate-400">On Time</span>
                </div>
                <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                  Regular weekly settlement batches directly to your bank account or bKash / Nagad wallet without delays.
                </p>
              </div>

              <div className={`rounded-3xl border p-8 space-y-3 ${t.railBorder} ${t.cardBg} shadow-lg`}>
                <div className="flex items-center justify-between">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-teal-400 font-bold">
                    Tooling &amp; Safety Gear
                  </span>
                  <Hammer className="h-5 w-5 text-teal-400" />
                </div>
                <div className={`text-3xl sm:text-4xl font-extrabold ${t.textPrimary}`}>
                  Grade-A <span className="text-sm font-normal text-slate-400">Equipped</span>
                </div>
                <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                  Equipped with official SKAVIA uniforms, insulated safety kits, and subsidized diagnostic equipment.
                </p>
              </div>
            </div>
          </section>

          {/* 4-Step Onboarding Process */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-5xl mx-auto space-y-8">
              <div className="text-center max-w-2xl mx-auto space-y-3">
                <span className="text-xs font-mono-code uppercase tracking-wider text-[#3898EC] font-semibold">
                  VERIFICATION ROADMAP
                </span>
                <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                  From Application to Verified Specialist
                </h2>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                {WORKER_ONBOARDING_STEPS.map((step, idx) => (
                  <div key={idx} className={`rounded-2xl border p-6 space-y-3 ${t.railBorder} ${t.cardBg}`}>
                    <span className="text-xl font-bold font-mono-code text-[#003399] dark:text-[#15E7CA]">
                      {step.step}
                    </span>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>{step.detail}</p>
                  </div>
                ))}
              </div>
            </div>
          </section>

          {/* Code of Dignity & Respect */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-5xl mx-auto">
              <div
                className={`rounded-3xl border p-8 sm:p-12 space-y-6 ${t.railBorder} ${t.cardBg} text-center`}
              >
                <div className="space-y-3 max-w-2xl mx-auto">
                  <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                    The SKAVIA Dignity of Labor Charter
                  </h2>
                  <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                    Skilled technicians build Bangladesh’s physical infrastructure. SKAVIA guarantees professional respect, safe working conditions, and upward career mobility for every verified technician.
                  </p>
                </div>

                <div className="pt-2">
                  <Link
                    href="/download"
                    className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-[#003399] hover:bg-[#002266] text-white text-xs sm:text-sm font-semibold shadow-lg shadow-blue-900/25 transition-all hover:scale-[1.02]"
                  >
                    <Smartphone className="h-4 w-4" />
                    <span>Download App &amp; Apply in Worker Mode</span>
                    <ArrowRight className="h-4 w-4" />
                  </Link>
                </div>
              </div>
            </div>
          </section>
        </div>
      )}
    </PublicPageShell>
  );
}
