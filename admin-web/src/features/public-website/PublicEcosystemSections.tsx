'use client';

import { useState } from 'react';
import Link from 'next/link';
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
import { useTranslation } from '@/lib/l10n/LanguageContext';
import { elementCenter, sakugaKira, sakugaTicks } from '@/lib/sakuga/sakuga-core';
import { SmartphoneDeviceMockup } from './SmartphoneDeviceMockup';
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
  const { isBengali } = useTranslation();
  const [copiedSha, setCopiedSha] = useState(false);
  const [shaExpanded, setShaExpanded] = useState(false);
  const [notesExpanded, setNotesExpanded] = useState(false);
  const { showToast } = useSakugaToast();

  const primaryApkUrl =
    distribution.android.apkUrl || '/downloads/skavia-v1.0.0-arm64-v8a.apk';
  const armv7ApkUrl =
    distribution.android.armv7Url || '/downloads/skavia-v1.0.0-armeabi-v7a.apk';
  const sha256 =
    distribution.android.sha256Checksum ||
    'c2ff57a1c6c6b64f1f52ecff435419bb63353486e4940cdb853b04b64ec365e3';
  const version = distribution.android.version ?? '1.0.0';

  const publishedDateLabel = distribution.android.publishedAt
    ? new Intl.DateTimeFormat(isBengali ? 'bn-BD' : 'en-GB', { dateStyle: 'medium' }).format(
        new Date(distribution.android.publishedAt)
      )
    : 'Latest Production';

  const apkSizeLabel =
    distribution.android.fileSizeBytes && distribution.android.fileSizeBytes > 0
      ? formatBytes(distribution.android.fileSizeBytes, 1)
      : '22.6 MB';

  const handleCopySha = async () => {
    try {
      await navigator.clipboard.writeText(sha256);
      setCopiedSha(true);
      showToast('SHA-256 checksum copied to clipboard', 'success');
      setTimeout(() => setCopiedSha(false), 2500);
    } catch {
      showToast('Unable to copy to clipboard', 'info');
    }
  };

  return (
    <section id="download" className={`relative border-b ${t.railBorder} ${t.surfaceBg} py-10 sm:py-14 px-4 sm:px-8 overflow-hidden`}>
      {/* Background ambient lighting for pro aesthetic */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[350px] bg-gradient-to-tr from-[#003399]/20 via-[#15E7CA]/10 to-transparent rounded-full blur-3xl pointer-events-none" />

      {/* Centered Modern Header */}
      <div className="max-w-3xl mx-auto text-center mb-8 relative z-10">
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
          <span>{isBengali ? 'অফিসিয়াল মোবাইল অভিজ্ঞতা' : 'Official Mobile App'}</span>
        </div>
        <h2 className={`text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight ${t.textPrimary}`}>
          {isBengali ? 'অফিসিয়াল স্ক্যাভিয়া অ্যান্ড্রয়েড অ্যাপ' : 'Get SKAVIA on Android'}
        </h2>
        <p className={`text-base sm:text-lg mt-3.5 max-w-xl mx-auto leading-relaxed ${t.textSecondary}`}>
          {isBengali
            ? 'ইনস্ট্যান্ট সার্ভিস বুকিং, লাইভ টেকনিশিয়ান ডিসপ্যাচ ও আগমন ওটিপি হ্যান্ডশেক — সব একটি মাত্র অ্যাপে।'
            : 'Instant client bookings, live technician dispatch, and cryptographic OTP handoff — built for high-accountability workforce operations.'}
        </p>
      </div>

      <div className="max-w-6xl mx-auto relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-center">
          {/* Left Column: Direct Download Actions & Technical Verification */}
          <div className="lg:col-span-7 space-y-6">
            <div className={`rounded-2xl border p-6 sm:p-8 ${t.railBorder} ${t.cardBg} backdrop-blur-md shadow-xl`}>
              <div className="flex items-center gap-3 mb-4 flex-wrap">
                <span
                  className={`rounded-full px-3 py-1 text-xs font-semibold ${
                    t.dark
                      ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30'
                      : 'bg-emerald-50 text-emerald-700 border border-emerald-300'
                  }`}
                >
                  v{version} (Production)
                </span>
                <span className={`text-xs ${t.textMuted}`}>
                  {isBengali
                    ? `অফিসিয়াল রিলিজ · হালকা ও দ্রুত (${apkSizeLabel})`
                    : `Official Direct Release · Lightweight ${apkSizeLabel} APK`}
                </span>
              </div>

              <div className="space-y-4">
                <p className={`text-sm leading-relaxed ${t.textSecondary}`}>
                  {isBengali
                    ? 'ক্লায়েন্ট ও ওয়ার্কার উভয়ের জন্য এক সমন্বিত অভিজ্ঞতা। শারীরিক আগমন ব্যতিরেকে কোনো জব শুরু বা বিলিং হয় না।'
                    : 'Download the official SKAVIA client and worker companion app for Android. No third-party stores required.'}
                </p>

                {/* Primary Download Button */}
                <div className="pt-2 flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
                  <a
                    href={primaryApkUrl}
                    download="skavia-v1.0.0-arm64-v8a.apk"
                    className="sakuga-spring-tap inline-flex items-center justify-center gap-2.5 px-6 py-3.5 rounded-xl bg-gradient-to-r from-[#003399] to-[#1D4ED8] hover:from-[#002266] hover:to-[#1e40af] text-white font-semibold text-sm shadow-lg shadow-blue-900/30 transition-all text-center"
                    onClick={(e) => {
                      const pos = elementCenter(e.currentTarget);
                      sakugaTicks(pos.x, pos.y);
                      sakugaKira(pos.x, pos.y);
                    }}
                  >
                    <Download className="h-4 w-4" />
                    <span>
                      {isBengali ? 'অ্যান্ড্রয়েড APK ডাউনলোড (ARM64)' : 'Download APK (ARM64 · 22.6 MB)'}
                    </span>
                  </a>

                  <a
                    href={armv7ApkUrl}
                    download="skavia-v1.0.0-armeabi-v7a.apk"
                    className={`sakuga-spring-tap inline-flex items-center justify-center gap-2 px-4 py-3 rounded-xl border text-xs font-medium ${t.railBorder} ${t.surfaceBg} ${t.textSecondary} hover:${t.textPrimary} transition-all text-center`}
                  >
                    <span>{isBengali ? 'ARMv7 সংস্করণ (২০.৩ MB)' : 'ARMv7 32-bit (20.3 MB)'}</span>
                  </a>
                </div>

                <div className="flex items-center gap-4 text-xs pt-1 flex-wrap">
                  <div className="flex items-center gap-1.5 text-emerald-500">
                    <ShieldCheck className="h-4 w-4" />
                    <span className="font-medium">Play Protect &amp; VirusTotal Verified</span>
                  </div>
                  <span className={t.textMuted}>•</span>
                  <span className={t.textMuted}>{publishedDateLabel}</span>
                </div>
              </div>

              {/* SHA-256 Checksum Accordion */}
              <div className={`mt-6 pt-5 border-t ${t.railBorder} space-y-3`}>
                <div className="flex items-center justify-between">
                  <button
                    type="button"
                    onClick={() => setShaExpanded(!shaExpanded)}
                    className={`flex items-center gap-1.5 text-xs font-mono-code ${t.textSecondary} hover:${t.textPrimary}`}
                  >
                    <span>SHA-256 Hash Verification</span>
                    <ChevronDown
                      className={`h-3.5 w-3.5 transition-transform ${shaExpanded ? 'rotate-180' : ''}`}
                    />
                  </button>

                  <button
                    type="button"
                    onClick={handleCopySha}
                    className={`flex items-center gap-1 px-2.5 py-1 rounded-md text-xs font-mono-code transition-all ${
                      copiedSha
                        ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/30'
                        : `${t.surfaceBg} ${t.textSecondary} border ${t.railBorder} hover:${t.textPrimary}`
                    }`}
                  >
                    {copiedSha ? (
                      <>
                        <Check className="h-3 w-3 text-emerald-400" />
                        <span>Copied!</span>
                      </>
                    ) : (
                      <>
                        <Copy className="h-3 w-3" />
                        <span>Copy Checksum</span>
                      </>
                    )}
                  </button>
                </div>

                {shaExpanded && (
                  <div className={`p-3 rounded-lg border font-mono-code text-[11px] break-all select-all ${t.railBorder} ${t.surfaceBg} text-[#15E7CA]`}>
                    {sha256}
                  </div>
                )}

                {/* Release Notes Accordion */}
                <div className="pt-2">
                  <button
                    type="button"
                    onClick={() => setNotesExpanded(!notesExpanded)}
                    className={`flex items-center gap-1.5 text-xs ${t.textSecondary} hover:${t.textPrimary}`}
                  >
                    <span>{isBengali ? 'রিলিজ নোট দেখুন' : 'View Release Notes'}</span>
                    <ChevronDown
                      className={`h-3.5 w-3.5 transition-transform ${notesExpanded ? 'rotate-180' : ''}`}
                    />
                  </button>
                  {notesExpanded && (
                    <p className={`mt-2 whitespace-pre-wrap leading-relaxed text-xs p-3 rounded-lg border ${t.railBorder} ${t.surfaceBg} ${t.textSecondary}`}>
                      {distribution.android.releaseNotes ??
                        'SKAVIA v1.0.0 official production release. Ultra-compact 22.6 MB optimized release APK with dual Client & Worker modes, live geolocation dispatch, 4-digit arrival OTP, and protected escrow settlement.'}
                    </p>
                  )}
                </div>
              </div>
            </div>

            {/* 3 Core Accountability Badges */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div className={`rounded-xl border p-3.5 ${t.railBorder} ${t.cardBg}`}>
                <p className={`text-xs font-semibold ${t.textPrimary}`}>
                  {isBengali ? 'হাভারসাইন ডিসপ্যাচ' : 'Haversine Dispatch'}
                </p>
                <p className={`text-[11px] mt-1 ${t.textSecondary}`}>
                  {isBengali ? 'নিকটবর্তী যাচাইকৃত টেকনিশিয়ান।' : 'Matches verified specialists nearby.'}
                </p>
              </div>

              <div className={`rounded-xl border p-3.5 ${t.railBorder} ${t.cardBg}`}>
                <p className={`text-xs font-semibold ${t.textPrimary}`}>
                  {isBengali ? '৪-সংখ্যার আগমন ওটিপি' : '4-Digit Arrival OTP'}
                </p>
                <p className={`text-[11px] mt-1 ${t.textSecondary}`}>
                  {isBengali ? 'আগমন ব্যতিরেকে কাজ শুরু নয়।' : 'Zero billable time before handoff.'}
                </p>
              </div>

              <div className={`rounded-xl border p-3.5 ${t.railBorder} ${t.cardBg}`}>
                <p className={`text-xs font-semibold ${t.textPrimary}`}>
                  {isBengali ? 'এসক্রো সেটেলমেন্ট' : 'Escrow Settlement'}
                </p>
                <p className={`text-[11px] mt-1 ${t.textSecondary}`}>
                  {isBengali ? 'কাজ সন্তোষজনক হলে স্বয়ংক্রিয় পেআউট।' : 'Guaranteed payout upon completion.'}
                </p>
              </div>
            </div>
          </div>

          {/* Right Column: Realistic Flagship Smartphone Device Mockup */}
          <div className="lg:col-span-5 flex justify-center items-center">
            <SmartphoneDeviceMockup t={t} version={version} />
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
