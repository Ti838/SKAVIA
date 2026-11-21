'use client';

import Link from 'next/link';
import {
  ArrowRight,
  CheckCircle2,
  FileText,
  KeyRound,
  Smartphone,
  UserCheck,
  Wallet,
} from 'lucide-react';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';

export function HowItWorksScreen() {
  const detailedSteps = [
    {
      num: '01',
      titleEn: 'Explain Your Requirement Once',
      descEn:
        'Submit what you need in natural English or trade terms. Our scoping engine breaks it down into required trade skills, estimates tools, and provides upfront transparent pricing.',
      icon: FileText,
      accent: '#3898EC',
      badgeEn: 'Dynamic Scoping',
      pointsEn: [
        'No endless phone calls haggling with unaccountable brokers',
        'Transparent BDT price estimates before you confirm',
        'Automatic selection of correct branch (HOME, TECH, AGRI, etc.)',
      ],
    },
    {
      num: '02',
      titleEn: 'Verified Specialist Matching & Dispatch',
      descEn:
        'SKAVIA assigns your task to a background-checked specialist from the specific trade branch. Track their real-time transit on the in-app map with verified photo, NID badge, and ratings.',
      icon: UserCheck,
      accent: '#15E7CA',
      badgeEn: '100% NID Verified',
      pointsEn: [
        'Government biometric NID verified & permanent address checked',
        'Level-3 technical skill testing by SKAVIA master engineers',
        'Live GPS arrival countdown right in your mobile app',
      ],
    },
    {
      num: '03',
      titleEn: 'Physical Arrival Handshake OTP',
      descEn:
        'A secure, confidential 4-digit OTP is generated exclusively on your phone. You share this code ONLY when the technician physically arrives at your door. The timer cannot start without this handshake.',
      icon: KeyRound,
      accent: '#06B6D4',
      badgeEn: 'Zero Phantom Bookings',
      pointsEn: [
        'Guarantees physical technician presence before work begins',
        'Completely eliminates fake arrivals and billing disputes',
        'Activates official SKAVIA comprehensive property damage protection',
      ],
    },
    {
      num: '04',
      titleEn: 'Atomic Escrow Protection & Digital Sign-off',
      descEn:
        'Customer funds are held safely in atomic bank escrow. The technician completes the work under standard SOPs, you inspect the result, and funds are released only upon your final digital confirmation.',
      icon: Wallet,
      accent: '#10B981',
      badgeEn: '90/10 Fair Settlement',
      pointsEn: [
        '90% of funds transfer directly to the technician with zero broker cuts',
        '10% platform fee funds damage protection, operations, and support',
        'Official digital tax invoice and warranty certificate emailed instantly',
      ],
    },
  ];

  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-16 pb-16 sm:pb-24">
          {/* Header */}
          <section className="relative px-4 sm:px-6 lg:px-8 pt-12 pb-16 sm:pt-16 sm:pb-20 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />

            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white">
                How SKAVIA Delivers Guaranteed Quality
              </h1>

              <p className="mt-4 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto text-neutral-600 dark:text-neutral-400">
                From natural requirement scoping to physical OTP arrival and atomic escrow release: a transparent four-stage process.
              </p>
            </div>
          </section>

          {/* 4 Deep Lifecycle Stage Cards */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-5xl mx-auto space-y-8">
              {detailedSteps.map((step) => {
                const Icon = step.icon;
                return (
                  <div
                    key={step.num}
                    className={`rounded-3xl border p-6 sm:p-10 transition-all ${t.railBorder} ${t.cardBg} hover:border-[#15E7CA]/40 shadow-xl`}
                  >
                    <div className="grid grid-cols-1 md:grid-cols-12 gap-6 items-start">
                      {/* Left: Step number and Icon (3 cols) */}
                      <div className="md:col-span-3 space-y-3">
                        <span className="text-3xl sm:text-4xl font-extrabold font-mono-code text-[#003399] dark:text-[#3898EC]">
                          {step.num}
                        </span>
                        <div
                          className="h-12 w-12 rounded-2xl flex items-center justify-center"
                          style={{ backgroundColor: `${step.accent}15`, color: step.accent }}
                        >
                          <Icon className="h-6 w-6" />
                        </div>
                        <span
                          className="inline-block text-[10px] font-mono-code uppercase tracking-wider font-bold px-2.5 py-0.5 rounded-full"
                          style={{ backgroundColor: `${step.accent}15`, color: step.accent }}
                        >
                          {step.badgeEn}
                        </span>
                      </div>

                      {/* Right: Content & Bullet points (9 cols) */}
                      <div className="md:col-span-9 space-y-4">
                        <h2 className={`text-xl sm:text-2xl font-bold ${t.textPrimary}`}>
                          {step.titleEn}
                        </h2>

                        <p className={`text-sm sm:text-base leading-relaxed ${t.textSecondary}`}>
                          {step.descEn}
                        </p>

                        <ul className="space-y-2 pt-2 text-xs sm:text-sm">
                          {step.pointsEn.map((pt, pIdx) => (
                            <li key={pIdx} className={`flex items-start gap-2.5 ${t.textSecondary}`}>
                              <CheckCircle2 className="h-4 w-4 text-teal-500 shrink-0 mt-0.5" />
                              <span>{pt}</span>
                            </li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </section>

          {/* CTA Banner */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-4xl mx-auto">
              <div
                className={`rounded-3xl border p-8 sm:p-12 text-center space-y-6 ${t.railBorder} ${t.cardBg} shadow-2xl relative overflow-hidden`}
              >
                <div className="space-y-3 max-w-xl mx-auto">
                  <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                    Experience Accountable Service Today
                  </h2>
                  <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                    Download the official SKAVIA Android application to submit your first service requirement.
                  </p>
                </div>

                <div className="flex flex-wrap items-center justify-center gap-4">
                  <Link
                    href="/download"
                    className="inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold text-white bg-[#003399] hover:bg-[#002266] shadow-lg shadow-blue-900/25 transition-all hover:scale-[1.02]"
                  >
                    <Smartphone className="h-4 w-4" />
                    <span>Download SKAVIA App</span>
                    <ArrowRight className="h-4 w-4" />
                  </Link>

                  <Link
                    href="/services-catalog"
                    className={`inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold border transition-all ${
                      t.dark
                        ? 'border-slate-800 bg-slate-900 text-white hover:bg-slate-800'
                        : 'border-slate-300 bg-white text-slate-900 hover:bg-slate-50'
                    }`}
                  >
                    <span>Explore Rate Cards</span>
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
