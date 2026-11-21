'use client';

import Link from 'next/link';
import {
  ArrowRight,
  BadgeCheck,
  KeyRound,
  Lock,
  MapPin,
  ShieldCheck,
  Smartphone,
} from 'lucide-react';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';
import { SakugaLink } from '@/components/sakuga';
import { SPECIALIZATION_BRANCHES } from '../public-site-data';

export function AboutScreen() {
  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-20 pb-16 sm:pb-24">
          {/* Hero Section */}
          <section className="relative px-4 sm:px-6 lg:px-8 pt-6 pb-12 sm:pt-8 sm:pb-16 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />

            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white">
                Explain Your Requirement.
                <span className="block mt-1 sm:mt-2 bg-gradient-to-r from-[#003399] via-[#3898EC] to-[#15E7CA] bg-clip-text text-transparent">
                  SKAVIA Delivers the Solution.
                </span>
              </h1>

              <p className="mt-4 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto text-neutral-600 dark:text-neutral-400">
                SKAVIA is not an unvetted gig marketplace or broker directory. We are Bangladesh&apos;s single accountable service enterprise, executing complex trade solutions through 8 internal specialization branches.
              </p>

              <div className="pt-2 flex flex-wrap items-center justify-center gap-4">
                <SakugaLink
                  href="/download"
                  className="inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold text-white shadow-lg shadow-blue-900/25 bg-gradient-to-r from-[#003399] to-[#1D4ED8] hover:from-[#002266] hover:to-[#1e40af] transition-all active:scale-[0.98]"
                >
                  <Smartphone className="h-4 w-4" />
                  <span>Download Mobile App</span>
                  <ArrowRight className="h-4 w-4" />
                </SakugaLink>

                <SakugaLink
                  href="/services-catalog"
                  className={`inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold border transition-all active:scale-[0.98] ${
                    t.dark
                      ? 'border-slate-800 bg-slate-900/80 text-white hover:bg-slate-800'
                      : 'border-slate-300 bg-white text-slate-900 hover:bg-slate-50'
                  }`}
                >
                  <span>Explore Services Catalog</span>
                </SakugaLink>
              </div>
            </div>
          </section>

          {/* Core Philosophy: Single Accountability vs Broken Marketplaces */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto">
              <div
                className={`rounded-3xl border p-8 sm:p-12 space-y-8 ${t.railBorder} ${t.cardBg} backdrop-blur-md shadow-xl`}
              >
                <div className="max-w-2xl space-y-3">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-[#3898EC] font-semibold">
                    ARCHITECTURAL ADVANTAGE
                  </span>
                  <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                    Ending Unaccountable Broker Systems With Single Enterprise Accountability
                  </h2>
                  <p className={`text-sm sm:text-base leading-relaxed ${t.textSecondary}`}>
                    Open directory websites wash their hands of operational failure by claiming to merely be matching intermediaries. SKAVIA takes end-to-end legal, operational, and financial responsibility for every service delivered.
                  </p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4">
                  <div
                    className={`rounded-2xl border p-6 space-y-4 ${
                      t.dark ? 'border-rose-900/30 bg-rose-950/10' : 'border-rose-200 bg-rose-50/50'
                    }`}
                  >
                    <div className="flex items-center gap-2 text-rose-500 font-bold text-sm font-mono-code">
                      <span>✕</span>
                      <span>Traditional Gig Marketplaces</span>
                    </div>
                    <ul className={`space-y-2.5 text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                      <li className="flex items-start gap-2">
                        <span className="text-rose-500 shrink-0">•</span>
                        <span>Unverified freelance contractors arriving at your family home.</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-rose-500 shrink-0">•</span>
                        <span>Surprise hidden surcharges and uncalibrated pricing after work starts.</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-rose-500 shrink-0">•</span>
                        <span>Complete denial of liability if household equipment or pipes burst.</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-rose-500 shrink-0">•</span>
                        <span>High 30–40% broker commissions exploiting skilled technicians.</span>
                      </li>
                    </ul>
                  </div>

                  <div
                    className={`rounded-2xl border p-6 space-y-4 ${
                      t.dark ? 'border-emerald-900/30 bg-emerald-950/10' : 'border-emerald-200 bg-emerald-50/50'
                    }`}
                  >
                    <div className="flex items-center gap-2 text-emerald-500 font-bold text-sm font-mono-code">
                      <span>✓</span>
                      <span>The SKAVIA Standard</span>
                    </div>
                    <ul className={`space-y-2.5 text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                      <li className="flex items-start gap-2">
                        <span className="text-emerald-500 shrink-0">•</span>
                        <span>Mandatory Government NID, police check &amp; trade assessment.</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-emerald-500 shrink-0">•</span>
                        <span>Cryptographic 4-digit arrival OTP handshake required before work starts.</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-emerald-500 shrink-0">•</span>
                        <span>Funds locked safely in atomic escrow until you inspect and approve.</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-emerald-500 shrink-0">•</span>
                        <span>90% direct payout to verified technicians with transparent 10% platform fee.</span>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* 4 Pillars of Trust */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto space-y-8">
              <div className="text-center max-w-2xl mx-auto space-y-3">
                <span className="text-xs font-mono-code uppercase tracking-wider text-[#15E7CA] font-semibold">
                  FOUR PILLARS OF INTEGRITY
                </span>
                <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                  Where Trust Meets Engineering Discipline
                </h2>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                <div className={`rounded-2xl border p-6 space-y-3 ${t.railBorder} ${t.cardBg}`}>
                  <div className="p-3 rounded-xl bg-blue-500/10 text-[#3898EC] w-fit">
                    <ShieldCheck className="h-6 w-6" />
                  </div>
                  <h3 className={`font-bold text-base ${t.textPrimary}`}>
                    Verified Identity &amp; Skills
                  </h3>
                  <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                    Biometric NID verification, permanent address validation, and rigorous hands-on technical skill assessment.
                  </p>
                </div>

                <div className={`rounded-2xl border p-6 space-y-3 ${t.railBorder} ${t.cardBg}`}>
                  <div className="p-3 rounded-xl bg-teal-500/10 text-teal-400 w-fit">
                    <KeyRound className="h-6 w-6" />
                  </div>
                  <h3 className={`font-bold text-base ${t.textPrimary}`}>
                    4-Digit Arrival OTP
                  </h3>
                  <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                    Physical presence handshake code. Prevents phantom bookings and verifies actual technician arrival at your premises.
                  </p>
                </div>

                <div className={`rounded-2xl border p-6 space-y-3 ${t.railBorder} ${t.cardBg}`}>
                  <div className="p-3 rounded-xl bg-amber-500/10 text-amber-400 w-fit">
                    <Lock className="h-6 w-6" />
                  </div>
                  <h3 className={`font-bold text-base ${t.textPrimary}`}>
                    90/10 Atomic Escrow
                  </h3>
                  <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                    Payments are locked in secure escrow and released to the worker’s balance only after customer sign-off.
                  </p>
                </div>

                <div className={`rounded-2xl border p-6 space-y-3 ${t.railBorder} ${t.cardBg}`}>
                  <div className="p-3 rounded-xl bg-indigo-500/10 text-indigo-400 w-fit">
                    <BadgeCheck className="h-6 w-6" />
                  </div>
                  <h3 className={`font-bold text-base ${t.textPrimary}`}>
                    Damage Protection Guarantee
                  </h3>
                  <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                    SKAVIA stands behind every job with comprehensive property protection and dedicated dispute arbitration.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Specialization Branches Overview */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto space-y-8">
              <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
                <div className="space-y-2">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-[#3898EC] font-semibold">
                    8 SPECIALIZATION BRANCHES
                  </span>
                  <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                    Tailored Specialization Across Bangladesh
                  </h2>
                </div>

                <Link
                  href="/services-catalog"
                  className="inline-flex items-center gap-1.5 text-xs font-semibold text-[#003399] dark:text-[#3898EC] hover:underline w-fit"
                >
                  <span>View Full Catalog</span>
                  <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                {SPECIALIZATION_BRANCHES.map((b) => {
                  const Icon = b.icon;
                  return (
                    <div
                      key={b.code}
                      className={`rounded-2xl border p-5 space-y-3 transition-all hover:border-[#15E7CA]/40 ${t.railBorder} ${t.cardBg}`}
                    >
                      <div
                        className="h-10 w-10 rounded-xl flex items-center justify-center"
                        style={{ backgroundColor: `${b.accent}15`, color: b.accent }}
                      >
                        <Icon className="h-5 w-5" />
                      </div>
                      <div>
                        <span className="text-[10px] font-mono-code font-bold uppercase tracking-wider text-slate-400">
                          {b.code}
                        </span>
                        <h3 className={`font-bold text-sm ${t.textPrimary}`}>{b.name}</h3>
                      </div>
                      <p className={`text-xs leading-relaxed ${t.textSecondary}`}>{b.tagline}</p>
                    </div>
                  );
                })}
              </div>
            </div>
          </section>

          {/* Headquarters & Central Operations */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto">
              <div
                className={`rounded-3xl border p-8 sm:p-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6 ${t.railBorder} ${t.cardBg}`}
              >
                <div className="space-y-3 max-w-xl">
                  <div className="inline-flex items-center gap-2 text-xs font-mono-code text-teal-400">
                    <MapPin className="h-4 w-4" />
                    <span>CENTRAL COMMAND &amp; HQ</span>
                  </div>
                  <h3 className={`text-xl sm:text-2xl font-bold ${t.textPrimary}`}>
                    Gulshan-2, Dhaka-1212, Bangladesh
                  </h3>
                  <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                    Operating the central dispatch coordination center, dispute resolution desk, and technical engineering supervision across all Dhaka zones.
                  </p>
                </div>

                <div className="flex flex-col sm:flex-row items-center gap-3 shrink-0 w-full sm:w-auto">
                  <Link
                    href="/contact"
                    className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-800 text-xs font-semibold transition"
                    style={{ color: 'var(--text-primary)' }}
                  >
                    <span>Contact Operations Desk</span>
                  </Link>

                  <Link
                    href="/download"
                    className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl bg-[#003399] hover:bg-[#002266] text-white text-xs font-semibold shadow-md transition"
                  >
                    <Smartphone className="h-4 w-4" />
                    <span>Get Mobile App</span>
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
