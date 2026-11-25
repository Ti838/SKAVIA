'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  ArrowRight,
  BadgeCheck,
  CheckCircle2,
  Clock,
  KeyRound,
  Search,
  ShieldCheck,
  Smartphone,
} from 'lucide-react';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';
import { PUBLIC_SERVICES } from '../services-catalog-data';
import { SPECIALIZATION_BRANCHES } from '../public-site-data';

export function ServicesCatalogScreen() {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedBranch, setSelectedBranch] = useState<string>('ALL');

  const filteredServices = PUBLIC_SERVICES.filter((s) => {
    const matchesBranch = selectedBranch === 'ALL' || s.branchCode === selectedBranch;
    const query = searchQuery.trim().toLowerCase();
    if (!query) return matchesBranch;

    const matchesName =
      s.nameEn.toLowerCase().includes(query) ||
      s.categoryNameEn.toLowerCase().includes(query) ||
      s.summaryEn.toLowerCase().includes(query);

    return matchesBranch && matchesName;
  });

  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-12 pb-16 sm:pb-24">
          {/* Header */}
          <section className="relative px-4 sm:px-6 lg:px-8 pt-6 pb-12 sm:pt-8 sm:pb-16 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />
            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white">
                Accountable Trade Services &amp;
                <span className="block mt-1 sm:mt-2 bg-gradient-to-r from-[#003399] via-[#3898EC] to-[#15E7CA] bg-clip-text text-transparent">
                  Transparent Pricing.
                </span>
              </h1>

              <p className="mt-4 text-base sm:text-lg max-w-2xl mx-auto leading-relaxed text-neutral-600 dark:text-neutral-400">
                Zero hidden surcharges. All services executed by verified specialists under 4-digit arrival OTP handshakes and atomic escrow guarantees.
              </p>
            </div>
          </section>

          {/* Controls: Search and Branch Filters */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto space-y-4">
              {/* Search Bar */}
              <div className="relative max-w-xl mx-auto">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search services (e.g. AC Servicing, Leakage, DB Board, CCTV)..."
                  className={`w-full pl-11 pr-4 py-3 rounded-2xl border text-xs sm:text-sm outline-none transition-all ${
                    t.dark
                      ? 'bg-slate-900/90 border-slate-800 text-white placeholder-slate-500 focus:border-[#15E7CA]'
                      : 'bg-white border-slate-200 text-slate-900 placeholder-slate-400 focus:border-[#003399]'
                  }`}
                />
              </div>

              {/* Branch Filter Pills */}
              <div className="flex items-center justify-center flex-wrap gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setSelectedBranch('ALL')}
                  className={`px-3.5 py-1.5 rounded-full text-xs font-semibold transition-all ${
                    selectedBranch === 'ALL'
                      ? 'bg-[#003399] text-white shadow-md'
                      : t.dark
                      ? 'bg-slate-900/60 border border-slate-800 text-slate-300 hover:bg-slate-800'
                      : 'bg-white border border-slate-200 text-slate-700 hover:bg-slate-50'
                  }`}
                >
                  All Trades
                </button>

                {SPECIALIZATION_BRANCHES.map((b) => (
                  <button
                    key={b.code}
                    type="button"
                    onClick={() => setSelectedBranch(b.code)}
                    className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all ${
                      selectedBranch === b.code
                        ? 'bg-[#003399] text-white shadow-md'
                        : t.dark
                        ? 'bg-slate-900/60 border border-slate-800 text-slate-300 hover:bg-slate-800'
                        : 'bg-white border border-slate-200 text-slate-700 hover:bg-slate-50'
                    }`}
                  >
                    <span>{b.name}</span>
                  </button>
                ))}
              </div>
            </div>
          </section>

          {/* Service Cards Grid */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto">
              {filteredServices.length === 0 ? (
                <div className={`text-center py-16 px-4 rounded-3xl border ${t.railBorder} ${t.cardBg}`}>
                  <p className={`text-base font-semibold ${t.textPrimary}`}>
                    No services published yet
                  </p>
                  <p className={`text-sm mt-1 max-w-md mx-auto ${t.textSecondary}`}>
                    Standardized trade services and transparent rates will appear here once officially published by the SKAVIA team.
                  </p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {filteredServices.map((service) => (
                    <div
                      key={service.slug}
                      className={`rounded-3xl border p-6 flex flex-col justify-between transition-all hover:border-[#15E7CA]/40 hover:shadow-xl ${t.railBorder} ${t.cardBg}`}
                    >
                      <div className="space-y-4">
                        {/* Branch badge & SLA */}
                        <div className="flex items-center justify-between gap-2">
                          <span
                            className="inline-flex items-center gap-1 text-[11px] font-mono-code font-semibold px-2.5 py-0.5 rounded-full"
                            style={{
                              backgroundColor: service.branchCode === 'TECH' ? '#3898EC15' : '#15E7CA15',
                              color: service.branchCode === 'TECH' ? '#3898EC' : '#15E7CA',
                            }}
                          >
                            <span>{service.branchCode}</span> &middot;{' '}
                            <span>{service.branchNameEn}</span>
                          </span>

                          <span className="flex items-center gap-1 text-[11px] font-mono-code text-slate-400">
                            <Clock className="h-3 w-3" />
                            <span>{service.slaEn}</span>
                          </span>
                        </div>

                        {/* Title & Description */}
                        <div>
                          <h3 className={`text-lg font-bold leading-snug ${t.textPrimary}`}>
                            {service.nameEn}
                          </h3>
                          <p className={`text-xs mt-2 leading-relaxed ${t.textSecondary}`}>
                            {service.summaryEn}
                          </p>
                        </div>

                        {/* Pricing Highlight */}
                        <div
                          className={`p-3.5 rounded-2xl border ${
                            t.dark ? 'border-slate-800 bg-slate-900/50' : 'border-slate-200 bg-slate-50'
                          }`}
                        >
                          <div className="flex items-center justify-between">
                            <span className="text-[11px] font-mono-code uppercase tracking-wider text-slate-400">
                              Transparent Rate
                            </span>
                            <span className="text-sm font-bold font-mono-code text-[#003399] dark:text-[#15E7CA]">
                              {service.priceRangeEn}
                            </span>
                          </div>
                        </div>

                        {/* Feature bullets */}
                        <ul className="space-y-1.5 text-xs">
                          {service.featuresEn.slice(0, 3).map((feat, i) => (
                            <li key={i} className={`flex items-start gap-2 ${t.textSecondary}`}>
                              <CheckCircle2 className="h-3.5 w-3.5 text-teal-500 shrink-0 mt-0.5" />
                              <span>{feat}</span>
                            </li>
                          ))}
                        </ul>
                      </div>

                      {/* Card Action Links */}
                      <div className="pt-6 border-t mt-6 flex items-center justify-between gap-3" style={{ borderColor: 'var(--border-subtle)' }}>
                        <Link
                          href={`/services-catalog/${service.slug}`}
                          className="inline-flex items-center gap-1 text-xs font-semibold text-[#003399] dark:text-[#3898EC] hover:underline"
                        >
                          <span>Trade Details</span>
                          <ArrowRight className="h-3 w-3" />
                        </Link>

                        <Link
                          href="/download"
                          className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-semibold text-white bg-[#003399] hover:bg-[#002266] shadow-sm transition"
                        >
                          <Smartphone className="h-3 w-3" />
                          <span>Book in App</span>
                        </Link>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </section>

          {/* Trust Footnote */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-4xl mx-auto text-center space-y-3">
              <div className="inline-flex items-center gap-4 text-xs font-mono-code text-slate-400 flex-wrap justify-center">
                <span className="flex items-center gap-1">
                  <ShieldCheck className="h-4 w-4 text-teal-500" />
                  <span>100% NID Verified</span>
                </span>
                <span>&bull;</span>
                <span className="flex items-center gap-1">
                  <KeyRound className="h-4 w-4 text-blue-500" />
                  <span>4-Digit Handshake OTP</span>
                </span>
                <span>&bull;</span>
                <span className="flex items-center gap-1">
                  <BadgeCheck className="h-4 w-4 text-amber-500" />
                  <span>Atomic Escrow Protection</span>
                </span>
              </div>
            </div>
          </section>
        </div>
      )}
    </PublicPageShell>
  );
}
