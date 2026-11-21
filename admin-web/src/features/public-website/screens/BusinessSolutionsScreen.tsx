'use client';

import Link from 'next/link';
import {
  ArrowRight,
  BadgeCheck,
  Briefcase,
  CheckCircle2,
  Clock,
  Cpu,
  FileText,
  HardHat,
  Smartphone,
  Users,
} from 'lucide-react';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';
import { BUSINESS_HIGHLIGHTS } from '../public-site-data';

export function BusinessSolutionsScreen() {
  const corporateOfferings = [
    {
      titleEn: 'Turnkey Commercial Fit-Out & Renovation',
      descEn:
        'Acoustic gypsum partitions, aluminum-glass facade installations, commercial vinyl flooring, and interior architectural finishing led by an on-site Team Leader.',
      icon: HardHat,
      accent: '#F97316',
    },
    {
      titleEn: 'Preventive Facility Maintenance SLAs',
      descEn:
        'Scheduled monthly or quarterly HVAC coil chemical descaling, electrical distribution board thermography, plumbing pressure tests, and generator utility upkeep.',
      icon: Briefcase,
      accent: '#3898EC',
    },
    {
      titleEn: 'Multi-Site Retail & POS Rollout',
      descEn:
        'Standardized structured Cat6 cabling, PoE IP surveillance, WiFi mesh routers, and barcode POS terminal deployments across chains in Dhaka and major hubs.',
      icon: Cpu,
      accent: '#8B5CF6',
    },
    {
      titleEn: 'Dedicated On-Site Team Leader',
      descEn:
        'Single point of operational contact who directs the trade specialists, coordinates materials, inspects workmanship against engineering specifications, and handles reporting.',
      icon: Users,
      accent: '#15E7CA',
    },
  ];

  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-16 pb-16 sm:pb-24">
          {/* Hero */}
          <section className="relative px-4 sm:px-6 lg:px-8 pt-12 pb-16 sm:pt-16 sm:pb-20 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />

            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white">
                Enterprise Turnkey Facility Infrastructure
              </h1>

              <p className="mt-4 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto text-neutral-600 dark:text-neutral-400">
                Commercial facility maintenance, turnkey office renovations, multi-branch service contracts, and dedicated on-site Team Leaders backed by single-enterprise accountability.
              </p>

              <div className="flex flex-wrap items-center justify-center gap-4 pt-1 max-w-3xl mx-auto">
                {BUSINESS_HIGHLIGHTS.map((hl, idx) => (
                  <span
                    key={idx}
                    className={`inline-flex items-center gap-2 text-xs px-3 py-1.5 rounded-full border ${t.railBorder} ${t.surfaceBg} ${t.textSecondary}`}
                  >
                    <CheckCircle2 className="h-3.5 w-3.5 text-purple-400 shrink-0" />
                    <span>{hl}</span>
                  </span>
                ))}
              </div>

              <div className="pt-2 flex flex-wrap items-center justify-center gap-4">
                <Link
                  href="/contact"
                  className="inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold text-white shadow-lg shadow-purple-900/25 bg-gradient-to-r from-[#003399] to-[#7C3AED] hover:from-[#002266] hover:to-[#6d28d9] transition-all hover:scale-[1.02]"
                >
                  <Briefcase className="h-4 w-4" />
                  <span>Contact Enterprise Team</span>
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
                  <span>Commercial Rate Cards</span>
                </Link>
              </div>
            </div>
          </section>

          {/* 4 Corporate Core Solutions */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-6">
              {corporateOfferings.map((offering) => {
                const Icon = offering.icon;
                return (
                  <div
                    key={offering.titleEn}
                    className={`rounded-3xl border p-8 space-y-4 transition-all hover:border-[#15E7CA]/40 ${t.railBorder} ${t.cardBg} shadow-lg`}
                  >
                    <div
                      className="h-12 w-12 rounded-2xl flex items-center justify-center"
                      style={{ backgroundColor: `${offering.accent}15`, color: offering.accent }}
                    >
                      <Icon className="h-6 w-6" />
                    </div>

                    <h3 className={`text-xl font-bold ${t.textPrimary}`}>
                      {offering.titleEn}
                    </h3>

                    <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                      {offering.descEn}
                    </p>
                  </div>
                );
              })}
            </div>
          </section>

          {/* Single Point of Contact & Milestone Escrow */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto">
              <div className={`rounded-3xl border p-8 sm:p-12 space-y-8 ${t.railBorder} ${t.cardBg}`}>
                <div className="max-w-2xl space-y-3">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-[#3898EC] font-semibold">
                    ENTERPRISE GOVERNANCE ADVANTAGE
                  </span>
                  <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                    Unified Enterprise Accountability
                  </h2>
                  <p className={`text-sm sm:text-base leading-relaxed ${t.textSecondary}`}>
                    Eliminate the headache of managing fragmented vendors across electrical, HVAC, and civil trades. SKAVIA bundles your entire commercial facility lifecycle under one audited corporate contract.
                  </p>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 pt-2">
                  <div className={`rounded-2xl border p-5 space-y-2.5 ${t.railBorder} ${t.surfaceBg}`}>
                    <FileText className="h-6 w-6 text-blue-500" />
                    <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                      Milestone Escrow Contracts
                    </h3>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      Capital is released progressively as milestones are inspected and signed off.
                    </p>
                  </div>

                  <div className={`rounded-2xl border p-5 space-y-2.5 ${t.railBorder} ${t.surfaceBg}`}>
                    <BadgeCheck className="h-6 w-6 text-teal-400" />
                    <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                      Official VAT Tax Invoices
                    </h3>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      Fully compliant automated NBR corporate tax invoicing with Mushak documentation.
                    </p>
                  </div>

                  <div className={`rounded-2xl border p-5 space-y-2.5 ${t.railBorder} ${t.surfaceBg}`}>
                    <Clock className="h-6 w-6 text-amber-500" />
                    <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                      Contractual Response SLAs
                    </h3>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      Guaranteed emergency response windows for mission-critical corporate infrastructure.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* CTA Banner */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-4xl mx-auto text-center space-y-6">
              <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                Ready to Commission a SKAVIA Commercial Project?
              </h2>
              <div className="flex flex-wrap items-center justify-center gap-4">
                <Link
                  href="/contact"
                  className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-[#003399] hover:bg-[#002266] text-white text-xs sm:text-sm font-semibold shadow-lg shadow-blue-900/25 transition-all hover:scale-[1.02]"
                >
                  <Briefcase className="h-4 w-4" />
                  <span>Contact Operations Desk</span>
                  <ArrowRight className="h-4 w-4" />
                </Link>

                <Link
                  href="/download"
                  className={`inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold border transition-all ${
                    t.dark
                      ? 'border-slate-800 bg-slate-900 text-white hover:bg-slate-800'
                      : 'border-slate-300 bg-white text-slate-900 hover:bg-slate-50'
                  }`}
                >
                  <Smartphone className="h-4 w-4" />
                  <span>View Mobile App</span>
                </Link>
              </div>
            </div>
          </section>
        </div>
      )}
    </PublicPageShell>
  );
}
