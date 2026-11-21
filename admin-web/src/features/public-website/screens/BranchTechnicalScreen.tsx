'use client';

import Link from 'next/link';
import {
  ArrowRight,
  CheckCircle2,
  Clock,
  Cpu,
  Smartphone,
  Zap,
} from 'lucide-react';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';
import { SakugaLink } from '@/components/sakuga';
import { PUBLIC_SERVICES } from '../services-catalog-data';

export function BranchTechnicalScreen() {
  const techServices = PUBLIC_SERVICES.filter((s) => s.branchCode === 'TECH');

  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-16 pb-16 sm:pb-24">
          {/* Hero */}
          <section className="relative px-4 sm:px-6 lg:px-8 pt-6 pb-12 sm:pt-8 sm:pb-16 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="technical" />

            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white">
                SKAVIA Technical —
                <span className="block mt-1 sm:mt-2 bg-gradient-to-r from-[#003399] via-[#3898EC] to-[#15E7CA] bg-clip-text text-transparent">
                  Advanced HVAC, Power &amp; Security.
                </span>
              </h1>

              <p className="mt-4 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto text-neutral-600 dark:text-neutral-400">
                Engineered solutions for residential and industrial HVAC cooling, electrical load distribution, IP CCTV camera grids, and enterprise network deployment.
              </p>

              <div className="pt-2 flex flex-wrap items-center justify-center gap-4">
                <SakugaLink
                  href="/download"
                  celebrateOnClick
                  className="inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold text-white shadow-lg shadow-blue-900/25 bg-gradient-to-r from-[#003399] to-[#3898EC] hover:from-[#002266] hover:to-[#2563eb] transition-all"
                >
                  <Smartphone className="h-4 w-4" />
                  <span>Request Technical Dispatch</span>
                  <ArrowRight className="h-4 w-4" />
                </SakugaLink>

                <SakugaLink
                  href="/services-catalog"
                  intensity="subtle"
                  className={`inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold border transition-all ${
                    t.dark
                      ? 'border-slate-800 bg-slate-900/80 text-white hover:bg-slate-800'
                      : 'border-slate-300 bg-white text-slate-900 hover:bg-slate-50'
                  }`}
                >
                  <span>View Technical Catalog</span>
                </SakugaLink>
              </div>
            </div>
          </section>

          {/* Engineering Rigor & Instrumentation */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto">
              <div className={`rounded-3xl border p-8 sm:p-12 space-y-8 ${t.railBorder} ${t.cardBg}`}>
                <div className="max-w-2xl space-y-3">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-[#3898EC] font-semibold">
                    ENGINEERING PROTOCOLS
                  </span>
                  <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                    Measured Diagnostics Over Guesswork
                  </h2>
                  <p className={`text-sm sm:text-base leading-relaxed ${t.textSecondary}`}>
                    Eliminating trial-and-error diagnostics. Our Level-3 certified technicians utilize calibrated instrumentation for precise troubleshooting before replacing parts.
                  </p>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 pt-2">
                  <div className={`rounded-2xl border p-5 space-y-2.5 ${t.railBorder} ${t.surfaceBg}`}>
                    <Zap className="h-6 w-6 text-[#3898EC]" />
                    <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                      1,000V Insulated Safety
                    </h3>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      VDE-certified hand tools preventing accidental phase-to-ground arcing and electric shock.
                    </p>
                  </div>

                  <div className={`rounded-2xl border p-5 space-y-2.5 ${t.railBorder} ${t.surfaceBg}`}>
                    <Clock className="h-6 w-6 text-teal-400" />
                    <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                      45-Minute Emergency SLA
                    </h3>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      Rapid emergency response across all operational Dhaka sectors for short circuits and leaks.
                    </p>
                  </div>

                  <div className={`rounded-2xl border p-5 space-y-2.5 ${t.railBorder} ${t.surfaceBg}`}>
                    <Cpu className="h-6 w-6 text-purple-400" />
                    <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                      Virgin Certified Consumables
                    </h3>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      Only factory-sealed virgin refrigerant and pure electrolytic copper cabling installed.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Featured Technical Services */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto space-y-8">
              <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
                <div className="space-y-2">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-[#3898EC] font-semibold">
                    TECHNICAL TRADE CATALOG
                  </span>
                  <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                    Core High-Voltage &amp; Precision Services
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

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {techServices.map((service) => (
                  <div
                    key={service.slug}
                    className={`rounded-3xl border p-6 flex flex-col justify-between space-y-6 ${t.railBorder} ${t.cardBg} hover:border-[#3898EC]/40 transition`}
                  >
                    <div className="space-y-4">
                      <div className="flex items-center justify-between">
                        <span className="text-xs font-mono-code font-bold text-[#3898EC] px-2.5 py-0.5 rounded-full bg-[#3898EC]/10">
                          {service.categoryNameEn}
                        </span>
                        <span className="text-sm font-bold font-mono-code text-[#003399] dark:text-[#3898EC]">
                          {service.priceRangeEn}
                        </span>
                      </div>

                      <h3 className={`text-lg font-bold leading-snug ${t.textPrimary}`}>
                        {service.nameEn}
                      </h3>

                      <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                        {service.summaryEn}
                      </p>

                      <ul className="space-y-1.5 text-xs">
                        {service.featuresEn.slice(0, 3).map((f, i) => (
                          <li key={i} className={`flex items-start gap-2 ${t.textSecondary}`}>
                            <CheckCircle2 className="h-3.5 w-3.5 text-blue-500 shrink-0 mt-0.5" />
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
                        <span>Trade SOP</span>
                        <ArrowRight className="h-3 w-3" />
                      </Link>

                      <Link
                        href="/download"
                        className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-semibold text-white bg-[#003399] hover:bg-[#002266] transition shadow-sm"
                      >
                        <Smartphone className="h-3.5 w-3.5" />
                        <span>Book Dispatch</span>
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
