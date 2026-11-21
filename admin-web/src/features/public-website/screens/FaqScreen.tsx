'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  ChevronDown,
  Search,
  Smartphone,
} from 'lucide-react';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';

interface CategorizedFaq {
  category: 'general' | 'otp' | 'escrow' | 'workers' | 'corporate';
  categoryLabelEn: string;
  qEn: string;
  aEn: string;
}

const EXTENDED_FAQS: CategorizedFaq[] = [
  {
    category: 'general',
    categoryLabelEn: 'General & Safety',
    qEn: 'What makes SKAVIA different from other listing platforms?',
    aEn: 'Unlike unmonitored freelancer directories, SKAVIA operates as a single accountable enterprise across 8 specialized branches. We biometrically verify every technician, mandate physical arrival OTP handshakes, lock client funds in atomic escrow, and take 100% organizational responsibility for the completed work.',
  },
  {
    category: 'otp',
    categoryLabelEn: '4-Digit Arrival OTP',
    qEn: 'Why is the 4-digit arrival handshake OTP required?',
    aEn: 'The 4-digit OTP is generated exclusively on your mobile app and confirms physical technician arrival at your premises. The specialist must enter this OTP into their terminal before the job clock or billable timer begins. This completely prevents phantom bookings, unverified charges, and billing disputes.',
  },
  {
    category: 'escrow',
    categoryLabelEn: 'Escrow & Billing',
    qEn: 'How does the 90/10 escrow financial protection work?',
    aEn: 'When you confirm a booking, your payment is held safely in atomic bank escrow. It is never paid directly upfront to the technician. Only after the service is physically completed and you inspect and sign off on the app, 90% is released directly to the specialist’s wallet, while 10% covers platform operations and insurance.',
  },
  {
    category: 'general',
    categoryLabelEn: 'General & Safety',
    qEn: 'What happens if household equipment or property is damaged?',
    aEn: 'Every verified SKAVIA service is covered under our comprehensive property damage protection. If any accidental damage occurs during technical operations, submit a report with photos through the app or call our emergency desk at +880 9612-SKAVIA. Our central dispatch team initiates inspection and covers certified repairs.',
  },
  {
    category: 'workers',
    categoryLabelEn: 'Specialists & Payouts',
    qEn: 'How much do skilled technicians earn and when are they paid?',
    aEn: 'SKAVIA field specialists earn 90% of the gross order value—the highest fair-compensation rate in Bangladesh. Settlements are transferred weekly directly to the technician’s bank account or bKash / Nagad wallet with zero hidden deductions.',
  },
  {
    category: 'corporate',
    categoryLabelEn: 'Corporate Contracts',
    qEn: 'Can corporate clients book multi-trade teams for commercial facilities?',
    aEn: 'Yes. Through SKAVIA Business and SKAVIA Construction, enterprise clients commission turnkey teams (carpenters, electricians, HVAC engineers, masons) overseen by a designated on-site Team Leader, with milestone-based escrow contracts and official NBR VAT invoices.',
  },
];

export function FaqScreen() {
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('ALL');
  const [openIdx, setOpenIdx] = useState<number | null>(0);

  const filteredFaqs = EXTENDED_FAQS.filter((item) => {
    const matchesCat = selectedCategory === 'ALL' || item.category === selectedCategory;
    const q = search.trim().toLowerCase();
    if (!q) return matchesCat;

    const matchesQuery =
      item.qEn.toLowerCase().includes(q) ||
      item.aEn.toLowerCase().includes(q);

    return matchesCat && matchesQuery;
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
                Frequently Asked
                <span className="block mt-1 sm:mt-2 bg-gradient-to-r from-[#003399] via-[#3898EC] to-[#15E7CA] bg-clip-text text-transparent">
                  Questions &amp; Architecture.
                </span>
              </h1>

              <p className="mt-4 text-base sm:text-lg max-w-2xl mx-auto leading-relaxed text-neutral-600 dark:text-neutral-400">
                Everything you need to know about arrival OTP handshakes, escrow financial security, and technician verification.
              </p>
            </div>
          </section>

          {/* Search & Filter Tabs */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-4xl mx-auto space-y-4">
              {/* Search input */}
              <div className="relative">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                <input
                  type="text"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  placeholder="Search FAQs (e.g. OTP, Escrow, Warranty, Damage, Payout)..."
                  className={`w-full pl-11 pr-4 py-3 rounded-2xl border text-xs sm:text-sm outline-none transition ${
                    t.dark
                      ? 'bg-slate-900 border-slate-800 text-white placeholder-slate-500 focus:border-[#15E7CA]'
                      : 'bg-white border-slate-200 text-slate-900 placeholder-slate-400 focus:border-[#003399]'
                  }`}
                />
              </div>

              {/* Category Pills */}
              <div className="flex items-center justify-center flex-wrap gap-2 pt-1">
                <button
                  type="button"
                  onClick={() => setSelectedCategory('ALL')}
                  className={`px-3.5 py-1.5 rounded-full text-xs font-semibold transition ${
                    selectedCategory === 'ALL'
                      ? 'bg-[#003399] text-white shadow-md'
                      : t.dark
                      ? 'bg-slate-900/60 border border-slate-800 text-slate-300 hover:bg-slate-800'
                      : 'bg-white border border-slate-200 text-slate-700 hover:bg-slate-50'
                  }`}
                >
                  All Topics
                </button>

                <button
                  type="button"
                  onClick={() => setSelectedCategory('otp')}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium transition ${
                    selectedCategory === 'otp'
                      ? 'bg-[#003399] text-white shadow-md'
                      : t.dark
                      ? 'bg-slate-900/60 border border-slate-800 text-slate-300 hover:bg-slate-800'
                      : 'bg-white border border-slate-200 text-slate-700 hover:bg-slate-50'
                  }`}
                >
                  Arrival OTP
                </button>

                <button
                  type="button"
                  onClick={() => setSelectedCategory('escrow')}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium transition ${
                    selectedCategory === 'escrow'
                      ? 'bg-[#003399] text-white shadow-md'
                      : t.dark
                      ? 'bg-slate-900/60 border border-slate-800 text-slate-300 hover:bg-slate-800'
                      : 'bg-white border border-slate-200 text-slate-700 hover:bg-slate-50'
                  }`}
                >
                  Escrow Protection
                </button>

                <button
                  type="button"
                  onClick={() => setSelectedCategory('workers')}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium transition ${
                    selectedCategory === 'workers'
                      ? 'bg-[#003399] text-white shadow-md'
                      : t.dark
                      ? 'bg-slate-900/60 border border-slate-800 text-slate-300 hover:bg-slate-800'
                      : 'bg-white border border-slate-200 text-slate-700 hover:bg-slate-50'
                  }`}
                >
                  Specialist Earnings
                </button>

                <button
                  type="button"
                  onClick={() => setSelectedCategory('corporate')}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium transition ${
                    selectedCategory === 'corporate'
                      ? 'bg-[#003399] text-white shadow-md'
                      : t.dark
                      ? 'bg-slate-900/60 border border-slate-800 text-slate-300 hover:bg-slate-800'
                      : 'bg-white border border-slate-200 text-slate-700 hover:bg-slate-50'
                  }`}
                >
                  Corporate Contracts
                </button>
              </div>
            </div>
          </section>

          {/* Accordion List */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-4xl mx-auto space-y-4">
              {filteredFaqs.length === 0 ? (
                <div className={`text-center py-12 rounded-3xl border ${t.railBorder} ${t.cardBg}`}>
                  <p className={`text-sm ${t.textSecondary}`}>
                    No matching questions found.
                  </p>
                </div>
              ) : (
                filteredFaqs.map((faq, index) => {
                  const isOpen = openIdx === index;
                  return (
                    <div
                      key={index}
                      className={`rounded-2xl border transition-all ${t.railBorder} ${t.cardBg} ${
                        isOpen ? 'shadow-md border-[#15E7CA]/40' : ''
                      }`}
                    >
                      <button
                        type="button"
                        onClick={() => setOpenIdx(isOpen ? null : index)}
                        className="w-full p-5 sm:p-6 text-left flex items-center justify-between gap-4 cursor-pointer"
                      >
                        <span className={`text-sm sm:text-base font-bold ${t.textPrimary}`}>
                          {faq.qEn}
                        </span>

                        <div
                          className={`h-7 w-7 rounded-full flex items-center justify-center shrink-0 transition-transform ${
                            isOpen ? 'bg-[#003399]/10 rotate-180' : 'bg-slate-100 dark:bg-slate-800'
                          }`}
                        >
                          <ChevronDown className="h-4 w-4 text-slate-500" />
                        </div>
                      </button>

                      {isOpen && (
                        <div
                          className={`px-5 sm:px-6 pb-6 text-xs sm:text-sm leading-relaxed border-t pt-4 ${t.railBorder} ${t.textSecondary}`}
                        >
                          {faq.aEn}
                        </div>
                      )}
                    </div>
                  );
                })
              )}
            </div>
          </section>

          {/* CTA Box */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-4xl mx-auto">
              <div
                className={`rounded-3xl border p-8 sm:p-10 text-center space-y-4 ${t.railBorder} ${t.cardBg}`}
              >
                <h2 className={`text-xl sm:text-2xl font-bold ${t.textPrimary}`}>
                  Still have questions?
                </h2>
                <p className={`text-xs sm:text-sm max-w-lg mx-auto ${t.textSecondary}`}>
                  Reach our central operations desk directly or download the mobile app to get started.
                </p>
                <div className="pt-2 flex flex-wrap items-center justify-center gap-3">
                  <Link
                    href="/contact"
                    className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-slate-300 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-800 text-xs font-semibold transition"
                    style={{ color: 'var(--text-primary)' }}
                  >
                    <span>Contact Us</span>
                  </Link>

                  <Link
                    href="/download"
                    className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-[#003399] hover:bg-[#002266] text-white text-xs font-semibold shadow-md transition"
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
