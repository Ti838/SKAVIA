'use client';

import Link from 'next/link';
import {
  ArrowRight,
  CheckCircle2,
  KeyRound,
  ShieldCheck,
  Smartphone,
  Sparkles,
} from 'lucide-react';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';
import { PUBLIC_SERVICES } from '../services-catalog-data';

export function BranchHomeScreen() {
  const homeServices = PUBLIC_SERVICES.filter((s) => s.branchCode === 'HOME');

  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-16 pt-4 pb-16 sm:pt-6 sm:pb-24">
          {/* Hero */}
          <section className="relative px-4 sm:px-6 lg:px-8 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />

            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white">
                SKAVIA Home — Residential Maintenance &amp; Diagnostics
              </h1>

              <p className="mt-4 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto text-neutral-600 dark:text-neutral-400">
                Specialized residential solutions including acoustic concealed water leak detection, sanitary engineering, domestic circuit balancing, and master carpentry.
              </p>

              <div className="pt-2 flex flex-wrap items-center justify-center gap-4">
                <Link
                  href="/download"
                  className="inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold text-white shadow-lg shadow-teal-900/20 bg-gradient-to-r from-[#003399] to-[#06B6D4] hover:from-[#002266] hover:to-[#0891b2] transition-all hover:scale-[1.02]"
                >
                  <Smartphone className="h-4 w-4" />
                  <span>Book Home Specialist</span>
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
                  <span>All Home Services</span>
                </Link>
              </div>
            </div>
          </section>

          {/* Core Safeguards for Family Homes */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto">
              <div className={`rounded-3xl border p-8 sm:p-12 space-y-8 ${t.railBorder} ${t.cardBg}`}>
                <div className="max-w-2xl space-y-3">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-[#15E7CA] font-semibold">
                    FAMILY RESIDENTIAL PROTOCOLS
                  </span>
                  <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                    Peace of Mind for Your Family Home
                  </h2>
                  <p className={`text-sm sm:text-base leading-relaxed ${t.textSecondary}`}>
                    Inviting a technician into your home requires complete trust. Every SKAVIA Home technician undergoes biometric verification, uniform identification, and mandatory arrival OTP protocols.
                  </p>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 pt-2">
                  <div className={`rounded-2xl border p-5 space-y-2.5 ${t.railBorder} ${t.surfaceBg}`}>
                    <ShieldCheck className="h-6 w-6 text-teal-500" />
                    <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                      Biometric Background Check
                    </h3>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      Government NID verified, background cleared, and permanent address documented.
                    </p>
                  </div>

                  <div className={`rounded-2xl border p-5 space-y-2.5 ${t.railBorder} ${t.surfaceBg}`}>
                    <KeyRound className="h-6 w-6 text-blue-500" />
                    <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                      Arrival Handshake Code
                    </h3>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      Confidential 4-digit OTP ensures the technician is physically present before timer starts.
                    </p>
                  </div>

                  <div className={`rounded-2xl border p-5 space-y-2.5 ${t.railBorder} ${t.surfaceBg}`}>
                    <Sparkles className="h-6 w-6 text-amber-500" />
                    <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                      Clean Worksite Guarantee
                    </h3>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      Furniture protection sheets laid before work begins; worksite left spotless.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Featured Home Services */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto space-y-8">
              <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
                <div className="space-y-2">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-[#15E7CA] font-semibold">
                    CORE HOME TRADES
                  </span>
                  <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                    Engineered Solutions for Common Home Issues
                  </h2>
                </div>

                <Link
                  href="/services-catalog"
                  className="inline-flex items-center gap-1.5 text-xs font-semibold text-[#003399] dark:text-[#3898EC] hover:underline"
                >
                  <span>Explore All Services</span>
                  <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {homeServices.map((service) => (
                  <div
                    key={service.slug}
                    className={`rounded-3xl border p-6 sm:p-8 flex flex-col justify-between space-y-6 ${t.railBorder} ${t.cardBg} hover:border-[#15E7CA]/40 transition`}
                  >
                    <div className="space-y-4">
                      <div className="flex items-center justify-between">
                        <span className="text-xs font-mono-code font-bold text-[#15E7CA] px-2.5 py-0.5 rounded-full bg-[#15E7CA]/10">
                          {service.categoryNameEn}
                        </span>
                        <span className="text-sm font-bold font-mono-code text-[#003399] dark:text-[#3898EC]">
                          {service.priceRangeEn}
                        </span>
                      </div>

                      <h3 className={`text-xl font-bold ${t.textPrimary}`}>
                        {service.nameEn}
                      </h3>

                      <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                        {service.summaryEn}
                      </p>

                      <ul className="space-y-2 text-xs">
                        {service.featuresEn.slice(0, 3).map((f, i) => (
                          <li key={i} className={`flex items-start gap-2 ${t.textSecondary}`}>
                            <CheckCircle2 className="h-3.5 w-3.5 text-teal-500 shrink-0 mt-0.5" />
                            <span>{f}</span>
                          </li>
                        ))}
                      </ul>
                    </div>

                    <div className="pt-4 border-t flex items-center justify-between" style={{ borderColor: 'var(--border-subtle)' }}>
                      <Link
                        href={`/services-catalog/${service.slug}`}
                        className="inline-flex items-center gap-1 text-xs font-semibold text-[#003399] dark:text-[#3898EC] hover:underline"
                      >
                        <span>Full Trade Protocol</span>
                        <ArrowRight className="h-3 w-3" />
                      </Link>

                      <Link
                        href="/download"
                        className="inline-flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-semibold text-white bg-[#003399] hover:bg-[#002266] transition shadow-sm"
                      >
                        <Smartphone className="h-3.5 w-3.5" />
                        <span>Book Specialist</span>
                      </Link>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </section>
        </div>
      )}
    </PublicPageShell>
  );
}
