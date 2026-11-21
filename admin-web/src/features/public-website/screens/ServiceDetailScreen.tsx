'use client';

import Link from 'next/link';
import {
  ArrowLeft,
  ArrowRight,
  CheckCircle2,
  Clock,
  Hammer,
  ShieldCheck,
  Smartphone,
  Zap,
} from 'lucide-react';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';
import type { PublicServiceDetail } from '../services-catalog-data';

export function ServiceDetailScreen({ service }: { service: PublicServiceDetail }) {
  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-12 pb-16 sm:pb-24">
          {/* Breadcrumbs & Navigation */}
          <section className="px-4 sm:px-6 lg:px-8 pt-6">
            <div className="max-w-5xl mx-auto flex items-center gap-2 text-xs font-mono-code text-slate-500">
              <Link href="/" className="hover:text-[#003399] dark:hover:text-[#3898EC]">
                Home
              </Link>
              <span>/</span>
              <Link href="/services-catalog" className="hover:text-[#003399] dark:hover:text-[#3898EC]">
                Services Catalog
              </Link>
              <span>/</span>
              <span className={`font-semibold ${t.textPrimary}`}>
                {service.nameEn}
              </span>
            </div>
          </section>

          {/* Hero Header */}
          <section className="relative px-4 sm:px-6 lg:px-8 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="technical" />
            <div className="max-w-5xl mx-auto space-y-6 relative z-10">
              <div className="flex flex-wrap items-center gap-3">
                <span
                  className="inline-flex items-center gap-1.5 text-xs font-mono-code font-bold px-3 py-1 rounded-full"
                  style={{
                    backgroundColor: service.branchCode === 'TECH' ? '#3898EC15' : '#15E7CA15',
                    color: service.branchCode === 'TECH' ? '#3898EC' : '#15E7CA',
                  }}
                >
                  <Zap className="h-3.5 w-3.5" />
                  <span>{service.branchCode} &middot; {service.branchNameEn}</span>
                </span>

                <span className="text-xs font-mono-code px-3 py-1 rounded-full border border-slate-300 dark:border-slate-800 text-slate-500">
                  {service.categoryNameEn}
                </span>

                <span className="flex items-center gap-1.5 text-xs font-mono-code text-teal-600 dark:text-teal-400">
                  <Clock className="h-3.5 w-3.5" />
                  <span>{service.slaEn}</span>
                </span>
              </div>

              <h1 className={`text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight ${t.textPrimary}`}>
                {service.nameEn}
              </h1>

              <p className={`text-base sm:text-lg leading-relaxed max-w-3xl ${t.textSecondary}`}>
                {service.summaryEn}
              </p>
            </div>
          </section>

          {/* Two-Column Details & Sticky Booking CTA */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-5xl mx-auto grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Left Column: Deep Scope, Process & Tools (2 cols) */}
              <div className="lg:col-span-2 space-y-8">
                {/* Feature Highlights */}
                <div className={`rounded-3xl border p-6 sm:p-8 space-y-4 ${t.railBorder} ${t.cardBg}`}>
                  <h2 className={`text-xl font-bold ${t.textPrimary}`}>
                    Service Scope &amp; Guaranteed Deliverables
                  </h2>

                  <ul className="space-y-3 text-sm">
                    {service.featuresEn.map((f, i) => (
                      <li key={i} className={`flex items-start gap-3 ${t.textSecondary}`}>
                        <CheckCircle2 className="h-4 w-4 text-teal-500 shrink-0 mt-0.5" />
                        <span>{f}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                {/* 4-Step Process Walkthrough */}
                <div className={`rounded-3xl border p-6 sm:p-8 space-y-6 ${t.railBorder} ${t.cardBg}`}>
                  <h2 className={`text-xl font-bold ${t.textPrimary}`}>
                    Standard Operating Procedure (SOP)
                  </h2>

                  <div className="space-y-4">
                    {service.processStepsEn.map((step, idx) => (
                      <div key={idx} className="flex items-start gap-4">
                        <span className="flex items-center justify-center h-7 w-7 rounded-full bg-[#003399]/10 text-[#003399] dark:text-[#3898EC] font-mono-code font-bold text-xs shrink-0 mt-0.5">
                          0{idx + 1}
                        </span>
                        <div className="space-y-1">
                          <h3 className={`font-bold text-sm ${t.textPrimary}`}>{step.title}</h3>
                          <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>{step.desc}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Certified Tools & Diagnostics */}
                <div className={`rounded-3xl border p-6 sm:p-8 space-y-4 ${t.railBorder} ${t.cardBg}`}>
                  <div className="flex items-center gap-2 text-xs font-mono-code text-[#3898EC]">
                    <Hammer className="h-4 w-4" />
                    <span>CERTIFIED INSTRUMENTATION</span>
                  </div>

                  <h2 className={`text-xl font-bold ${t.textPrimary}`}>
                    Standard Trade Equipment
                  </h2>

                  <div className="flex flex-wrap gap-2 pt-1">
                    {service.toolsEn.map((tool, i) => (
                      <span
                        key={i}
                        className={`text-xs px-3 py-1.5 rounded-xl border ${
                          t.dark
                            ? 'border-slate-800 bg-slate-900/60 text-slate-300'
                            : 'border-slate-200 bg-slate-50 text-slate-700'
                        }`}
                      >
                        {tool}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Property Protection */}
                <div
                  className={`rounded-3xl border p-6 space-y-3 ${
                    t.dark ? 'border-teal-900/30 bg-teal-950/15' : 'border-teal-200 bg-teal-50/50'
                  }`}
                >
                  <div className="flex items-center gap-2 text-teal-600 dark:text-teal-400 font-bold text-sm">
                    <ShieldCheck className="h-4 w-4" />
                    <span>Comprehensive Property Protection</span>
                  </div>
                  <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                    {service.safetyGuaranteeEn}
                  </p>
                </div>
              </div>

              {/* Right Column: Pricing & Mobile Booking Card (1 col) */}
              <div className="space-y-6">
                <div
                  className={`sticky top-24 rounded-3xl border p-6 space-y-6 ${t.railBorder} ${t.cardBg} shadow-xl`}
                >
                  <div>
                    <span className="text-[11px] font-mono-code uppercase tracking-wider text-slate-400">
                      Transparent Rate Card
                    </span>
                    <div className="text-2xl sm:text-3xl font-extrabold font-mono-code text-[#003399] dark:text-[#15E7CA] mt-1">
                      {service.priceRangeEn}
                    </div>
                    <p className="text-xs text-slate-400 mt-1">
                      No hidden inspection surcharges
                    </p>
                  </div>

                  <div className="space-y-2.5 pt-2 border-t border-b py-4" style={{ borderColor: 'var(--border-subtle)' }}>
                    <div className="flex items-center justify-between text-xs">
                      <span className="text-slate-500">Specialist Dispatch:</span>
                      <span className={`font-semibold ${t.textPrimary}`}>{service.slaEn}</span>
                    </div>
                    <div className="flex items-center justify-between text-xs">
                      <span className="text-slate-500">Arrival Verification:</span>
                      <span className="font-semibold text-teal-500">4-Digit Handshake</span>
                    </div>
                    <div className="flex items-center justify-between text-xs">
                      <span className="text-slate-500">Payment Escrow:</span>
                      <span className="font-semibold text-blue-500">Post-Delivery Release</span>
                    </div>
                  </div>

                  <div className="space-y-3">
                    <Link
                      href="/download"
                      className="w-full inline-flex items-center justify-center gap-2 px-5 py-3 rounded-2xl bg-[#003399] hover:bg-[#002266] text-white text-xs sm:text-sm font-semibold shadow-lg shadow-blue-900/25 transition-all hover:scale-[1.01]"
                    >
                      <Smartphone className="h-4 w-4" />
                      <span>Book in Mobile App</span>
                      <ArrowRight className="h-4 w-4" />
                    </Link>

                    <p className="text-[11px] text-center text-slate-400 leading-relaxed">
                      Use the official SKAVIA Android application for live map arrival tracking and arrival OTP verification.
                    </p>
                  </div>

                  <div className="pt-2 text-center">
                    <Link
                      href="/services-catalog"
                      className="inline-flex items-center gap-1.5 text-xs text-slate-500 hover:text-[#003399] dark:hover:text-[#3898EC] transition"
                    >
                      <ArrowLeft className="h-3.5 w-3.5" />
                      <span>Back to Services Catalog</span>
                    </Link>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </div>
      )}
    </PublicPageShell>
  );
}
