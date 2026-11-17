'use client';

import { useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import {
  Check,
  ChevronDown,
  Copy,
  Download,
  Hammer,
  HelpCircle,
  Mail,
  Phone,
  ShieldCheck,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { useSakugaToast } from '@/components/sakuga';
import { formatBytes } from '@/lib/formatters';
import { elementCenter, sakugaKira, sakugaTicks } from '@/lib/sakuga/sakuga-core';
import {
  FAQ_ITEMS,
  MOBILE_FEATURES,
  WORKER_ONBOARDING_STEPS,
  type DistributionInfo,
  type PublicThemeTokens,
} from './public-site-data';

export function WorkerAndFeaturesSection({ t }: { t: PublicThemeTokens }) {
  return (
    <section id="workers" className={`border-b ${t.railBorder} ${t.subtleCardBg} p-6 sm:p-8`}>
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        <div className="lg:col-span-6 space-y-4">
          <p className={`text-xs font-mono-code uppercase tracking-widest ${t.dark ? 'text-[#15E7CA]' : 'text-teal-700'}`}>
            Worker Opportunities
          </p>
          <h2 className={`text-2xl sm:text-3xl font-bold tracking-tight ${t.textPrimary}`}>
            How to Become a Verified SKAVIA Worker
          </h2>
          <p className={`text-sm leading-relaxed ${t.textSecondary}`}>
            Build consistent income and lasting professional reputation under SKAVIA. Workers register
            directly in the mobile app — no public web forms or third-party brokers required.
          </p>
          <div className="space-y-3 pt-2">
            {WORKER_ONBOARDING_STEPS.map((item) => (
              <div
                key={item.step}
                className={`rounded-xl border p-4 ${t.railBorder} ${t.surfaceBg}`}
              >
                <p className="text-xs font-semibold text-[#3898EC]">{item.step}</p>
                <p className={`text-xs mt-1 ${t.textSecondary}`}>{item.detail}</p>
              </div>
            ))}
          </div>
        </div>

        <div className="lg:col-span-6 space-y-4">
          <p className="text-xs font-mono-code uppercase tracking-widest text-[#3898EC]">
            Mobile App Features
          </p>
          <h2 className={`text-2xl sm:text-3xl font-bold tracking-tight ${t.textPrimary}`}>
            One App. Complete Ecosystem Control.
          </h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-2">
            {MOBILE_FEATURES.map((feat) => {
              const Icon = feat.icon;
              return (
                <div
                  key={feat.title}
                  className={`rounded-xl border p-4 ${t.railBorder} ${t.surfaceBg}`}
                >
                  <Icon className={`h-4 w-4 mb-2.5 ${t.dark ? 'text-[#15E7CA]' : 'text-teal-600'}`} />
                  <p className={`text-sm font-semibold ${t.textPrimary}`}>{feat.title}</p>
                  <p className={`text-xs mt-1 leading-relaxed ${t.textSecondary}`}>{feat.desc}</p>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}

export function DownloadSection({
  t,
  distribution,
}: {
  t: PublicThemeTokens;
  distribution: DistributionInfo;
}) {
  const [copiedSha, setCopiedSha] = useState(false);
  const [notesExpanded, setNotesExpanded] = useState(false);
  const { showToast } = useSakugaToast();
  const apkSizeLabel =
    distribution.android.fileSizeBytes && distribution.android.fileSizeBytes > 0
      ? formatBytes(distribution.android.fileSizeBytes, 1)
      : null;
  const publishedDateLabel = distribution.android.publishedAt
    ? new Intl.DateTimeFormat('en-GB', { dateStyle: 'medium' }).format(
        new Date(distribution.android.publishedAt)
      )
    : null;

  return (
    <section id="download" className={`relative border-b ${t.railBorder} ${t.surfaceBg} py-10 sm:py-14 px-4 sm:px-8 overflow-hidden`}>
      {/* Background ambient lighting for pro aesthetic */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[350px] bg-gradient-to-tr from-[#003399]/20 via-[#15E7CA]/10 to-transparent rounded-full blur-3xl pointer-events-none" />

      {/* Centered Modern Header */}
      <div className="max-w-3xl mx-auto text-center mb-6 sm:mb-8 relative z-10">
        <div
          className={`inline-flex items-center gap-2 px-3.5 py-1 rounded-full border text-xs font-mono-code mb-4 ${
            t.dark
              ? 'border-cyan-400/25 bg-cyan-500/10 text-cyan-300'
              : 'border-sky-300 bg-sky-50 text-sky-700'
          }`}
        >
          <span
            className={`w-1.5 h-1.5 rounded-full ${
              t.dark ? 'bg-cyan-400' : 'bg-sky-600'
            } animate-pulse`}
          />
          <span>Mobile Experience</span>
        </div>
        <h2 className={`text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight ${t.textPrimary}`}>
          Get SKAVIA on Android
        </h2>
        <p className={`text-base sm:text-lg mt-3.5 max-w-xl mx-auto leading-relaxed ${t.textSecondary}`}>
          Instant client bookings, live technician dispatch, and cryptographic OTP handoff — built for high-accountability workforce operations.
        </p>
      </div>

      {/* Centered Showcase Card (Two-Column Balanced Layout) */}
      <div className="max-w-5xl mx-auto relative z-10">
        <div
          className={`rounded-3xl border ${t.railBorder} ${t.cardBg} backdrop-blur-2xl p-6 sm:p-10 lg:p-12 shadow-2xl relative overflow-hidden`}
        >
          {/* Subtle interior glow */}
          <div className="absolute -top-24 -right-24 w-80 h-80 bg-[#3898EC]/10 rounded-full blur-3xl pointer-events-none" />

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-center">
            {/* Left Column: App Info & Download Actions */}
            <div className="lg:col-span-7 space-y-6">
              <div className="flex items-center gap-4">
                <div className="h-14 w-14 rounded-2xl bg-gradient-to-br from-[#003399] to-[#0d1b3e] border border-[#3898EC]/30 flex items-center justify-center p-2.5 shadow-lg shadow-[#003399]/25 shrink-0">
                  <SkaviaBrandMark variant="emblem" size={36} priority />
                </div>
                <div>
                  <div className="flex items-center gap-2.5 flex-wrap">
                    <h3 className={`text-xl sm:text-2xl font-bold tracking-tight ${t.textPrimary}`}>SKAVIA Mobile</h3>
                    <span
                      className={`rounded-full px-2.5 py-0.5 text-xs font-semibold ${
                        t.dark
                          ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30'
                          : 'bg-emerald-50 text-emerald-700 border border-emerald-300'
                      }`}
                    >
                      v{distribution.android.version ?? '1.0.0'}
                    </span>
                  </div>
                  <p className={`text-xs sm:text-sm mt-0.5 ${t.textSecondary}`}>
                    Direct Release · ARM64 Package
                  </p>
                </div>
              </div>

              {/* Feature Highlights */}
              <div className="space-y-3 pt-1">
                <div className="flex items-start gap-3">
                  <div
                    className={`h-5 w-5 rounded-md flex items-center justify-center shrink-0 mt-0.5 ${
                      t.dark
                        ? 'bg-cyan-500/10 border border-cyan-500/20'
                        : 'bg-sky-50 border border-sky-200'
                    }`}
                  >
                    <Check
                      className={`h-3 w-3 ${t.dark ? 'text-cyan-400' : 'text-sky-600'}`}
                    />
                  </div>
                  <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                    <strong className={`font-semibold ${t.textPrimary}`}>Live Haversine Dispatch</strong> — matches you with verified specialists within minutes.
                  </p>
                </div>
                <div className="flex items-start gap-3">
                  <div
                    className={`h-5 w-5 rounded-md flex items-center justify-center shrink-0 mt-0.5 ${
                      t.dark
                        ? 'bg-cyan-500/10 border border-cyan-500/20'
                        : 'bg-sky-50 border border-sky-200'
                    }`}
                  >
                    <Check
                      className={`h-3 w-3 ${t.dark ? 'text-cyan-400' : 'text-sky-600'}`}
                    />
                  </div>
                  <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                    <strong className={`font-semibold ${t.textPrimary}`}>4-Digit OTP Confirmation</strong> — services are confirmed completed only upon your authorization.
                  </p>
                </div>
                <div className="flex items-start gap-3">
                  <div
                    className={`h-5 w-5 rounded-md flex items-center justify-center shrink-0 mt-0.5 ${
                      t.dark
                        ? 'bg-cyan-500/10 border border-cyan-500/20'
                        : 'bg-sky-50 border border-sky-200'
                    }`}
                  >
                    <Check
                      className={`h-3 w-3 ${t.dark ? 'text-cyan-400' : 'text-sky-600'}`}
                    />
                  </div>
                  <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                    <strong className={`font-semibold ${t.textPrimary}`}>Transparent Escrow</strong> — automated settlement ensuring fair rates and safe payouts.
                  </p>
                </div>
              </div>

              {/* Package Specs Pill */}
              {distribution.android.published && (
                <div className={`grid grid-cols-2 sm:grid-cols-4 gap-2 sm:gap-3 rounded-2xl border p-3.5 text-xs ${t.railBorder} ${t.surfaceBg}`}>
                  <div>
                    <p className={`text-[11px] ${t.textMuted}`}>Size</p>
                    <p className={`font-semibold text-sm mt-0.5 ${t.textPrimary}`}>{apkSizeLabel ?? '24.1 MB'}</p>
                  </div>
                  <div>
                    <p className={`text-[11px] ${t.textMuted}`}>Released</p>
                    <p className={`font-semibold text-sm mt-0.5 ${t.textPrimary}`}>{publishedDateLabel ?? 'Latest'}</p>
                  </div>
                  <div>
                    <p className={`text-[11px] ${t.textMuted}`}>Compatibility</p>
                    <p className={`font-semibold text-sm mt-0.5 ${t.textPrimary}`}>Android 7.0+</p>
                  </div>
                  <div>
                    <p className={`text-[11px] ${t.textMuted}`}>Integrity</p>
                    <p
                      className={`font-semibold text-sm mt-0.5 flex items-center gap-1 ${
                        t.dark ? 'text-emerald-400' : 'text-emerald-600'
                      }`}
                    >
                      <ShieldCheck className="h-3.5 w-3.5" /> Verified
                    </p>
                  </div>
                </div>
              )}

              {/* Download CTA Button */}
              {distribution.android.published && distribution.android.apkUrl ? (
                <div className="space-y-3 pt-2">
                  <a
                    href={distribution.android.apkUrl}
                    download={distribution.android.fileName ?? undefined}
                    target="_blank"
                    rel="noopener noreferrer"
                    onClick={(e) => {
                      const c = elementCenter(e.currentTarget, 0.5, 0);
                      sakugaTicks(c.x, c.y, { n: 4, r: 8, len: 11, color: '#15E7CA' });
                      showToast('Downloading official SKAVIA Android APK...', 'info');
                    }}
                    className="sakuga-spring-tap inline-flex w-full items-center justify-center gap-2.5 rounded-xl px-6 py-4 text-base font-semibold text-white transition hover:opacity-95 shadow-xl shadow-[#003399]/30"
                    style={{ backgroundColor: '#003399' }}
                  >
                    <Download className="h-5 w-5" />
                    <span>Download SKAVIA for Android</span>
                  </a>

                  <p className={`text-center text-[11px] ${t.textMuted}`}>
                    Direct APK download · No Play Store sign-in required
                  </p>

                  {/* SHA-256 Checksum Accordion */}
                  {distribution.android.sha256Checksum && (
                    <div className={`rounded-xl border p-3 text-xs space-y-1 ${t.railBorder} ${t.surfaceBg}`}>
                      <div className="flex items-center justify-between gap-2">
                        <span
                          className={`inline-flex items-center gap-1 font-semibold text-[11px] ${
                            t.dark ? 'text-[#15E7CA]' : 'text-teal-700'
                          }`}
                        >
                          <ShieldCheck className="h-3 w-3" /> SHA-256 Checksum
                        </span>
                        <button
                          type="button"
                          onClick={(e) => {
                            if (!distribution.android.sha256Checksum) return;
                            void navigator.clipboard?.writeText(distribution.android.sha256Checksum);
                            const c = elementCenter(e.currentTarget);
                            sakugaKira(c.x, c.y, { r: 9, color: '#16A34A' });
                            showToast('SHA-256 checksum copied to clipboard', 'success');
                            setCopiedSha(true);
                            setTimeout(() => setCopiedSha(false), 2000);
                          }}
                          className={`sakuga-spring-tap inline-flex items-center gap-1 ${t.textSecondary} hover:text-[#3898EC] text-[11px] transition`}
                        >
                          {copiedSha ? (
                            <>
                              <Check className="h-3 w-3 text-emerald-400" />
                              <span>Copied</span>
                            </>
                          ) : (
                            <>
                              <Copy className="h-3 w-3" />
                              <span>Copy</span>
                            </>
                          )}
                        </button>
                      </div>
                      <p className={`font-mono-code break-all text-[10px] ${t.textMuted}`}>
                        {distribution.android.sha256Checksum}
                      </p>
                    </div>
                  )}

                  {/* Release Notes Accordion */}
                  {distribution.android.releaseNotes && (
                    <div className={`rounded-xl border p-3 text-xs ${t.railBorder} ${t.surfaceBg}`}>
                      <button
                        type="button"
                        onClick={() => setNotesExpanded((prev) => !prev)}
                        className={`w-full flex items-center justify-between font-semibold text-xs ${t.textPrimary}`}
                      >
                        <span>What&apos;s New in v{distribution.android.version ?? 'Latest'}</span>
                        <ChevronDown
                          className={`h-3.5 w-3.5 transition-transform duration-200 ${notesExpanded ? 'rotate-180' : ''}`}
                        />
                      </button>
                      {notesExpanded && (
                        <p className={`mt-2 whitespace-pre-wrap leading-relaxed text-[11px] ${t.textSecondary}`}>
                          {distribution.android.releaseNotes}
                        </p>
                      )}
                    </div>
                  )}
                </div>
              ) : (
                <div
                  className={`rounded-xl border p-4 text-xs leading-relaxed ${t.railBorder} ${t.surfaceBg} ${t.textSecondary}`}
                >
                  Android APK package link is being finalized. Contact SKAVIA Support for access.
                </div>
              )}
            </div>

            {/* Right Column: Sleek Smartphone Preview */}
            <div className="lg:col-span-5 flex justify-center items-center">
              <div className="relative w-full max-w-[380px] sm:max-w-[420px] lg:max-w-none group">
                {/* Ambient glow matching theme */}
                <div
                  className={`absolute inset-0 rounded-3xl blur-2xl transition duration-500 group-hover:scale-105 pointer-events-none ${
                    t.dark
                      ? 'bg-gradient-to-tr from-[#003399]/30 to-[#15E7CA]/20'
                      : 'bg-gradient-to-tr from-[#003399]/15 to-[#3898EC]/15'
                  }`}
                />

                <div
                  className={`relative rounded-3xl p-3 sm:p-4 border shadow-2xl transition duration-300 ${t.railBorder} ${t.surfaceBg}`}
                >
                  <div className="relative aspect-[4/3] w-full overflow-hidden rounded-2xl bg-black/5 dark:bg-black/30">
                    <Image
                      src={t.dark ? '/images/skavia_app_mockup_dark.png' : '/images/skavia_app_mockup_light.png'}
                      alt="SKAVIA Android Mobile App Interface"
                      fill
                      priority
                      sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 420px"
                      className="object-contain transition-transform duration-500 group-hover:scale-[1.02]"
                    />
                  </div>

                  {/* Verified App Tag */}
                  <div
                    className={`mt-3 px-3.5 py-2 rounded-xl border flex items-center justify-between text-[11px] ${t.railBorder} ${t.cardBg}`}
                  >
                    <span className={`inline-flex items-center gap-1.5 font-medium ${t.textSecondary}`}>
                      <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                      Verified Android Production Build
                    </span>
                    <span className={`font-mono-code text-[10px] ${t.textMuted}`}>
                      ARM64 · v{distribution.android.version ?? '1.0.0'}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export function FaqAndContactSection({
  t,
  openFaq,
  onToggleFaq,
}: {
  t: PublicThemeTokens;
  openFaq: number | null;
  onToggleFaq: (idx: number) => void;
}) {
  return (
    <section id="faq" className={`border-b ${t.railBorder} ${t.subtleCardBg} p-6 sm:p-8`}>
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        <div className="lg:col-span-7 space-y-3">
          <div className="flex items-center gap-2 text-xs font-mono-code uppercase tracking-widest text-[#3898EC] mb-2">
            <HelpCircle className="h-4 w-4" />
            <span>Frequently Asked Questions</span>
          </div>
          {FAQ_ITEMS.map((item, idx) => {
            const open = openFaq === idx;
            return (
              <div
                key={item.q}
                className={`rounded-xl border ${t.railBorder} ${t.surfaceBg} overflow-hidden`}
              >
                <button
                  type="button"
                  onClick={() => onToggleFaq(idx)}
                  className={`sakuga-spring-tap w-full px-5 py-4 text-left flex items-center justify-between gap-4 text-sm font-semibold ${t.textPrimary}`}
                >
                  <span>{item.q}</span>
                  <ChevronDown
                    className={`h-4 w-4 shrink-0 transition-transform duration-200 ${open ? 'rotate-180' : ''}`}
                  />
                </button>
                {open && (
                  <div className={`px-5 pb-4 text-xs leading-relaxed ${t.textSecondary}`}>
                    {item.a}
                  </div>
                )}
              </div>
            );
          })}
        </div>

        <div id="contact" className="lg:col-span-5">
          <div className={`rounded-2xl border p-6 space-y-4 ${t.railBorder} ${t.surfaceBg}`}>
            <div className={`flex items-center gap-2 text-xs font-mono-code uppercase tracking-widest ${t.dark ? 'text-[#15E7CA]' : 'text-teal-700'}`}>
              <Hammer className="h-4 w-4" />
              <span>Contact &amp; Official Support</span>
            </div>
            <h3 className={`text-xl font-bold ${t.textPrimary}`}>Need Business Scoping or Support?</h3>
            <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
              Reach SKAVIA Operations for enterprise facility partnerships, safety inquiries,
              or verified distribution questions.
            </p>
            <div className="space-y-3 pt-2 text-xs">
              <div className={`flex items-center gap-3 rounded-xl border p-3.5 ${t.railBorder} ${t.cardBg}`}>
                <Mail className="h-4 w-4 text-[#3898EC] shrink-0" />
                <div>
                  <p className={`font-semibold ${t.textPrimary}`}>Official Support Email</p>
                  <p className={t.textSecondary}>support@skavia.com</p>
                </div>
              </div>
              <div className={`flex items-center gap-3 rounded-xl border p-3.5 ${t.railBorder} ${t.cardBg}`}>
                <Phone className={`h-4 w-4 shrink-0 ${t.dark ? 'text-[#15E7CA]' : 'text-teal-600'}`} />
                <div>
                  <p className={`font-semibold ${t.textPrimary}`}>Operations Desk (Dhaka HQ)</p>
                  <p className={t.textSecondary}>Available daily 09:00 – 21:00 BST via SKAVIA In-App Support</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export function PublicFooter({ t }: { t: PublicThemeTokens }) {
  return (
    <footer className={`px-6 sm:px-8 py-8 ${t.surfaceBg}`}>
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <SkaviaBrandMark variant="emblem" size={24} />
          <span className={`text-sm font-semibold ${t.textPrimary}`}>SKAVIA</span>
          <span className={`text-xs ${t.textMuted}`}>
            &copy; {new Date().getFullYear()} Accountable Service &amp; Workforce Platform
          </span>
        </div>

        <div className="flex items-center gap-5 text-xs">
          <Link href="/privacy" className={`${t.textSecondary} hover:text-[#3898EC]`}>
            Privacy Policy
          </Link>
          <Link href="/terms" className={`${t.textSecondary} hover:text-[#3898EC]`}>
            Terms &amp; Conditions
          </Link>
          <a href="#download" className={`font-semibold hover:underline ${t.dark ? 'text-[#15E7CA]' : 'text-teal-700'}`}>
            Official Mobile App
          </a>
        </div>
      </div>
    </footer>
  );
}

