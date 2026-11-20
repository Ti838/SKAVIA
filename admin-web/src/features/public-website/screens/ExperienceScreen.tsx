'use client';

import Link from 'next/link';
import {
  ArrowRight,
  CheckCircle2,
  KeyRound,
  Lock,
  RotateCcw,
  Smartphone,
} from 'lucide-react';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';

export function ExperienceScreen() {
  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-16 pt-4 pb-16 sm:pt-6 sm:pb-24">
          {/* Hero */}
          <section className="relative px-4 sm:px-6 lg:px-8 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />

            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white">
                Engineered for Total Household Safety
              </h1>

              <p className="mt-4 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto text-neutral-600 dark:text-neutral-400">
                Zero anxiety when inviting technicians into your home or commercial premises. Backed by biometric NID verification, arrival handshake OTPs, and atomic escrow protection.
              </p>

              <div className="pt-2 flex flex-wrap items-center justify-center gap-4">
                <Link
                  href="/download"
                  className="inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold text-white shadow-lg shadow-teal-900/20 bg-gradient-to-r from-[#003399] to-[#06B6D4] hover:from-[#002266] hover:to-[#0891b2] transition-all hover:scale-[1.02]"
                >
                  <Smartphone className="h-4 w-4" />
                  <span>Download Verified App</span>
                  <ArrowRight className="h-4 w-4" />
                </Link>

                <Link
                  href="/how-it-works"
                  className={`inline-flex items-center gap-2 px-6 py-3 rounded-full text-xs sm:text-sm font-semibold border transition-all ${
                    t.dark
                      ? 'border-slate-800 bg-slate-900/80 text-white hover:bg-slate-800'
                      : 'border-slate-300 bg-white text-slate-900 hover:bg-slate-50'
                  }`}
                >
                  <span>How It Works</span>
                </Link>
              </div>
            </div>
          </section>

          {/* 3 Pillars of Customer Protection */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Card 1: Handshake OTP */}
              <div className={`rounded-3xl border p-8 space-y-4 ${t.railBorder} ${t.cardBg} shadow-lg`}>
                <div className="p-3 rounded-2xl bg-teal-500/10 text-teal-400 w-fit">
                  <KeyRound className="h-6 w-6" />
                </div>
                <h3 className={`text-xl font-bold ${t.textPrimary}`}>
                  4-Digit Arrival Handshake OTP
                </h3>
                <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                  The confidential 4-digit code generated exclusively on your phone must be physically confirmed by the specialist upon arrival before any job clock starts.
                </p>
                <div className={`p-4 rounded-2xl border text-xs font-mono-code ${t.railBorder} ${t.surfaceBg}`}>
                  <span className="text-slate-400">Handshake Verification:</span>
                  <div className="text-xl font-bold text-teal-400 tracking-widest mt-1">8 4 2 1</div>
                </div>
              </div>

              {/* Card 2: Atomic Escrow */}
              <div className={`rounded-3xl border p-8 space-y-4 ${t.railBorder} ${t.cardBg} shadow-lg`}>
                <div className="p-3 rounded-2xl bg-blue-500/10 text-[#3898EC] w-fit">
                  <Lock className="h-6 w-6" />
                </div>
                <h3 className={`text-xl font-bold ${t.textPrimary}`}>
                  Atomic Escrow Protection
                </h3>
                <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                  Your money is never paid directly upfront to an unknown person. It remains in protected escrow and is credited only after you verify full completion.
                </p>
                <div className={`p-4 rounded-2xl border text-xs font-mono-code ${t.railBorder} ${t.surfaceBg}`}>
                  <span className="text-slate-400">Fair Split Protocol:</span>
                  <div className="text-xs font-bold text-blue-500 mt-1">90% Specialist &bull; 10% Operations</div>
                </div>
              </div>

              {/* Card 3: 14-Day Warranty & Protection */}
              <div className={`rounded-3xl border p-8 space-y-4 ${t.railBorder} ${t.cardBg} shadow-lg`}>
                <div className="p-3 rounded-2xl bg-amber-500/10 text-amber-400 w-fit">
                  <RotateCcw className="h-6 w-6" />
                </div>
                <h3 className={`text-xl font-bold ${t.textPrimary}`}>
                  14-Day Revisit Warranty
                </h3>
                <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                  If the same operational issue reoccurs within 14 days of completion, SKAVIA dispatches a specialist to rectify it with zero additional labor fee.
                </p>
                <div className={`p-4 rounded-2xl border text-xs font-mono-code ${t.railBorder} ${t.surfaceBg}`}>
                  <span className="text-slate-400">Protection Policy:</span>
                  <div className="text-xs font-bold text-amber-500 mt-1">Guaranteed Revisit &bull; Full Liability</div>
                </div>
              </div>
            </div>
          </section>

          {/* Transparent Rate Guarantee */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-5xl mx-auto">
              <div className={`rounded-3xl border p-8 sm:p-12 space-y-6 ${t.railBorder} ${t.cardBg}`}>
                <div className="max-w-2xl space-y-2">
                  <span className="text-xs font-mono-code uppercase tracking-wider text-[#3898EC] font-semibold">
                    HONEST PRICING CHARTER
                  </span>
                  <h2 className={`text-2xl sm:text-3xl font-extrabold ${t.textPrimary}`}>
                    Zero Hidden Surcharges, Ever
                  </h2>
                  <p className={`text-sm sm:text-base leading-relaxed ${t.textSecondary}`}>
                    Unmonitored freelancers routinely double their charges once your pipes or air conditioner are taken apart. SKAVIA enforces fixed transparent rate cards.
                  </p>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
                  <div className={`p-5 rounded-2xl border ${t.railBorder} ${t.surfaceBg} space-y-2`}>
                    <div className="flex items-center gap-2 text-teal-500 font-bold text-xs font-mono-code">
                      <CheckCircle2 className="h-4 w-4" />
                      <span>Automated Digital Invoices</span>
                    </div>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      Official itemized invoice delivered directly to your email and app wallet.
                    </p>
                  </div>

                  <div className={`p-5 rounded-2xl border ${t.railBorder} ${t.surfaceBg} space-y-2`}>
                    <div className="flex items-center gap-2 text-teal-500 font-bold text-xs font-mono-code">
                      <CheckCircle2 className="h-4 w-4" />
                      <span>Central Dispute Arbitration</span>
                    </div>
                    <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                      Direct escalation to the SKAVIA Operations Command Center within 15 minutes.
                    </p>
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
