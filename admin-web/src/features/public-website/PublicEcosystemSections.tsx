'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  ArrowRight,
  BadgeCheck,
  Check,
  ChevronDown,
  Copy,
  Download,
  Hammer,
  HelpCircle,
  KeyRound,
  Mail,
  MapPin,
  Phone,
  ShieldCheck,
  Smartphone,
} from 'lucide-react';
import { useSakugaToast } from '@/components/sakuga';
import { formatBytes } from '@/lib/formatters';
import { SmartphoneDeviceMockup } from './SmartphoneDeviceMockup';
import { DeviceCompatibilityCard } from './components/DeviceCompatibilityCard';
import { HeroAtmosphere } from './components/HeroAtmosphere';
import { useDeviceDetection } from './hooks/useDeviceDetection';
import {
  getFaqItems,
  getMobileFeatures,
  getWorkerOnboardingSteps,
  type DistributionInfo,
  type PublicThemeTokens,
} from './public-site-data';

export function WorkerAndFeaturesSection({ t }: { t: PublicThemeTokens }) {
  const onboardingSteps = getWorkerOnboardingSteps(false);
  const mobileFeatures = getMobileFeatures(false);

  return (
    <section id="workers" className={`relative border-b ${t.railBorder} py-20 px-4 sm:px-6 lg:px-8 overflow-hidden scroll-mt-20`}>
      {/* Seamless Ambient Lighting with no sharp bounding borders */}
      <div 
        className="absolute inset-0 pointer-events-none select-none overflow-hidden" 
        style={{
          background: t.dark
            ? 'radial-gradient(ellipse 65% 50% at 0% 50%, rgba(0, 51, 153, 0.18) 0%, rgba(21, 231, 202, 0.05) 50%, transparent 100%)'
            : 'radial-gradient(ellipse 65% 50% at 0% 50%, rgba(0, 51, 153, 0.05) 0%, rgba(56, 152, 236, 0.03) 50%, transparent 100%)'
        }}
        aria-hidden="true"
      />

      <div className="max-w-7xl mx-auto space-y-12 relative z-10">
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <div
            className={`inline-flex items-center gap-2 px-3.5 py-1 rounded-full border text-xs font-mono-code ${
              t.dark
                ? 'border-cyan-400/25 bg-cyan-500/10 text-cyan-300'
                : 'border-sky-300 bg-sky-50 text-sky-700'
            }`}
          >
            <span className={`w-1.5 h-1.5 rounded-full ${t.dark ? 'bg-cyan-400' : 'bg-sky-600'} animate-pulse`} />
            <span>VERIFIED SKILLED WORKFORCE &middot; 90% DIRECT EARNINGS</span>
          </div>

          <h2 className={`text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight ${t.textPrimary}`}>
            Empowering Skilled Field Specialists
          </h2>

          <p className={`text-base sm:text-lg max-w-2xl mx-auto leading-relaxed ${t.textSecondary}`}>
            SKAVIA treats technicians as valued professionals. On our platform, 90% of every customer booking is credited directly to the verified specialist with weekly bank or MFS settlements.
          </p>
        </div>

        {/* 4-Step Specialist Onboarding Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {onboardingSteps.map((item, idx) => (
            <div
              key={idx}
              className={`p-6 rounded-2xl border ${t.railBorder} ${t.cardBg} space-y-3 shadow-sm`}
            >
              <span className="text-xl font-bold font-mono-code text-[#003399] dark:text-[#15E7CA]">
                {item.step}
              </span>
              <p className={`text-xs leading-relaxed ${t.textSecondary}`}>{item.detail}</p>
            </div>
          ))}
        </div>

        {/* Unified Dual App Mode Highlights */}
        <div className="pt-8">
          <div className="max-w-3xl mx-auto text-center space-y-3 mb-10">
            <span className="text-xs font-mono-code uppercase tracking-wider text-[#3898EC] font-bold">
              UNIFIED MOBILE ARCHITECTURE
            </span>
            <h3 className={`text-2xl sm:text-3xl font-bold ${t.textPrimary}`}>
              One App. Dual Client &amp; Specialist Modes.
            </h3>
            <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
              Zero duplicate applications. Seamlessly toggle between Client booking and Verified Specialist dispatch inside one unified mobile binary.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 max-w-5xl mx-auto">
            {mobileFeatures.map((feat) => {
              const Icon = feat.icon;
              return (
                <div
                  key={feat.title}
                  className={`p-5 rounded-2xl border transition-all ${t.railBorder} ${t.surfaceBg} hover:border-[#3898EC]/50 hover:shadow-lg hover:shadow-blue-500/5 group`}
                >
                  <div className="h-9 w-9 rounded-xl bg-blue-500/10 dark:bg-cyan-500/10 border border-blue-500/20 dark:border-cyan-500/20 flex items-center justify-center mb-3 text-[#003399] dark:text-[#15E7CA] group-hover:scale-105 transition-transform">
                    <Icon className="h-4 w-4" />
                  </div>
                  <h4 className={`text-sm font-semibold ${t.textPrimary}`}>
                    {feat.title}
                  </h4>
                  <p className={`text-xs mt-1.5 leading-relaxed ${t.textSecondary}`}>
                    {feat.desc}
                  </p>
                </div>
              );
            })}
          </div>

          {/* Verification & Trust Callout */}
          <div className={`mt-8 max-w-2xl mx-auto p-4 rounded-2xl border ${t.railBorder} ${t.subtleCardBg} flex items-center gap-3.5`}>
            <div className="p-2 rounded-xl bg-emerald-500/10 text-emerald-500 shrink-0">
              <ShieldCheck className="h-5 w-5" />
            </div>
            <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
              Every technician is authenticated via Bangladesh National ID (NID) and certified in their trade specialization by master engineers.
            </p>
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
  const [shaExpanded, setShaExpanded] = useState(false);
  const [notesExpanded, setNotesExpanded] = useState(false);
  const { showToast } = useSakugaToast();

  const primaryApkUrl =
    distribution.android.apkUrl || '/downloads/skavia-latest.apk';
  const armv7ApkUrl =
    distribution.android.armv7Url || '/downloads/skavia-v1.0.0-armeabi-v7a.apk';
  const sha256 =
    distribution.android.sha256Checksum ||
    'c2ff57a1c6c6b64f1f52ecff435419bb63353486e4940cdb853b04b64ec365e3';
  const version = distribution.android.version ?? '1.0.0';

  const publishedDateLabel = distribution.android.publishedAt
    ? new Intl.DateTimeFormat('en-GB', { dateStyle: 'medium' }).format(
        new Date(distribution.android.publishedAt)
      )
    : 'Latest Production';

  const apkSizeLabel =
    distribution.android.fileSizeBytes && distribution.android.fileSizeBytes > 0
      ? formatBytes(distribution.android.fileSizeBytes, 1)
      : '22.6 MB';

  const telemetry = useDeviceDetection();

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
    <section id="download" className={`relative border-b ${t.railBorder} py-20 px-4 sm:px-6 lg:px-8 overflow-hidden scroll-mt-20`}>
      {/* Seamless Multi-Layered Atmosphere with Zero Banding */}
      <HeroAtmosphere dark={t.dark} variant="subpage" />

      {/* Centered Modern Header */}
      <div className="max-w-3xl mx-auto text-center mb-12 relative z-10 space-y-4">
        <div
          className={`inline-flex items-center gap-2 px-3.5 py-1 rounded-full border text-xs font-mono-code ${
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
          <span>OFFICIAL ANDROID PRODUCTION RELEASE</span>
        </div>
        <h2 className={`text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight ${t.textPrimary}`}>
          Download SKAVIA for Android
        </h2>
        <p className={`text-base sm:text-lg max-w-xl mx-auto leading-relaxed ${t.textSecondary}`}>
          Instant client bookings, live technician dispatch, and cryptographic OTP handoff &mdash; built for high-accountability workforce operations.
        </p>
      </div>

      <div className="max-w-7xl mx-auto relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-center">
          {/* Left Column: Direct Download Actions & Technical Verification */}
          <div className="lg:col-span-7 space-y-6">
            {/* Real-time Hardware, Network & OS Compatibility Assessment */}
            <DeviceCompatibilityCard
              telemetry={telemetry}
              t={t}
            />

            <div className={`rounded-3xl border p-6 sm:p-8 ${t.railBorder} ${t.cardBg} backdrop-blur-md shadow-xl space-y-6`}>
              <div className="flex items-center justify-between gap-3 flex-wrap">
                <div className="flex items-center gap-2.5">
                  <span
                    className={`rounded-full px-3 py-1 text-xs font-bold ${
                      t.dark
                        ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30'
                        : 'bg-emerald-50 text-emerald-700 border border-emerald-300'
                    }`}
                  >
                    v{version} (Production)
                  </span>
                  <span className={`text-xs ${t.textMuted}`}>
                    {publishedDateLabel}
                  </span>
                </div>
                <span className="text-xs font-mono-code px-2.5 py-0.5 rounded-full border border-blue-500/20 bg-blue-500/5 text-[#3898EC]">
                  Lightweight {apkSizeLabel}
                </span>
              </div>

              <p className={`text-sm leading-relaxed ${t.textSecondary}`}>
                Download the official SKAVIA client and worker companion app for Android. 
                No third-party app stores or intermediary brokers required.
              </p>

              {/* Primary Download Button with Auto-Recommendation Highlighting */}
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
                {/* ARM64 Primary Option */}
                <div className="relative flex-1">
                  {telemetry.isLoaded && telemetry.recommendedApk === 'arm64' && (
                    <span className="absolute -top-3 left-4 z-10 px-2.5 py-0.5 rounded-full text-[10px] font-extrabold uppercase tracking-wider bg-amber-400 text-slate-950 shadow-md flex items-center gap-1 animate-pulse">
                      <span>★</span>
                      <span>Recommended for your phone</span>
                    </span>
                  )}
                  <a
                    href={primaryApkUrl}
                    download="skavia-latest.apk"
                    className={`w-full inline-flex items-center justify-center gap-2.5 px-6 py-4 rounded-2xl bg-gradient-to-r from-[#003399] to-[#1D4ED8] hover:from-[#002266] hover:to-[#1e40af] text-white font-semibold text-sm shadow-xl shadow-blue-900/30 transition-all text-center hover:scale-[1.01] ${
                      telemetry.isLoaded && telemetry.recommendedApk === 'arm64'
                        ? 'ring-2 ring-amber-400/80 shadow-amber-400/10'
                        : ''
                    }`}
                  >
                    <Download className="h-4 w-4 shrink-0" />
                    <span>Download Official Production APK ({apkSizeLabel})</span>
                  </a>
                </div>

                {/* ARMv7 32-bit Legacy Option */}
                <div className="relative">
                  {telemetry.isLoaded && telemetry.recommendedApk === 'armv7' && (
                    <span className="absolute -top-3 left-3 z-10 px-2.5 py-0.5 rounded-full text-[10px] font-extrabold uppercase tracking-wider bg-amber-400 text-slate-950 shadow-md flex items-center gap-1 animate-pulse">
                      <span>★</span>
                      <span>Recommended for your phone</span>
                    </span>
                  )}
                  <a
                    href={armv7ApkUrl}
                    download="skavia-v1.0.0-armeabi-v7a.apk"
                    className={`inline-flex items-center justify-center gap-2 px-4 py-4 rounded-2xl border text-xs font-semibold transition-all text-center hover:scale-[1.01] ${
                      telemetry.isLoaded && telemetry.recommendedApk === 'armv7'
                        ? 'border-amber-400 text-amber-300 ring-2 ring-amber-400/60 bg-amber-500/10'
                        : `${t.railBorder} ${t.surfaceBg} ${t.textSecondary} hover:${t.textPrimary}`
                    }`}
                  >
                    <span>ARMv7 32-bit Legacy (20.3 MB)</span>
                  </a>
                </div>
              </div>

              {/* Security Trust Badges */}
              <div className="flex items-center gap-4 text-xs pt-1 flex-wrap">
                <div className="flex items-center gap-1.5 text-emerald-500">
                  <ShieldCheck className="h-4 w-4" />
                  <span className="font-semibold">
                    Play Protect &amp; VirusTotal Verified
                  </span>
                </div>
                <span className={t.textMuted}>&bull;</span>
                <span className={t.textMuted}>Android 7.0 (Nougat) to 15/16 Ready</span>
              </div>

              {/* SHA-256 Checksum Accordion */}
              <div className={`pt-4 border-t ${t.railBorder} space-y-3`}>
                <div className="flex items-center justify-between">
                  <button
                    type="button"
                    onClick={() => setShaExpanded(!shaExpanded)}
                    className={`flex items-center gap-1.5 text-xs font-mono-code ${t.textSecondary} hover:${t.textPrimary}`}
                  >
                    <span>SHA-256 Checksum Verification</span>
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
                <div className="pt-1">
                  <button
                    type="button"
                    onClick={() => setNotesExpanded(!notesExpanded)}
                    className={`flex items-center gap-1.5 text-xs ${t.textSecondary} hover:${t.textPrimary}`}
                  >
                    <span>View Release Notes</span>
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
              <div className={`rounded-2xl border p-4 ${t.railBorder} ${t.cardBg} backdrop-blur-md`}>
                <div className="flex items-center gap-2 mb-1.5">
                  <MapPin className="h-4 w-4 text-[#3898EC]" />
                  <p className={`text-xs font-bold ${t.textPrimary}`}>
                    Haversine Dispatch
                  </p>
                </div>
                <p className={`text-[11px] leading-relaxed ${t.textSecondary}`}>
                  Matches verified specialists by physical proximity.
                </p>
              </div>

              <div className={`rounded-2xl border p-4 ${t.railBorder} ${t.cardBg} backdrop-blur-md`}>
                <div className="flex items-center gap-2 mb-1.5">
                  <KeyRound className="h-4 w-4 text-[#15E7CA]" />
                  <p className={`text-xs font-bold ${t.textPrimary}`}>
                    4-Digit Arrival OTP
                  </p>
                </div>
                <p className={`text-[11px] leading-relaxed ${t.textSecondary}`}>
                  Zero billable time begins before doorstep handshake.
                </p>
              </div>

              <div className={`rounded-2xl border p-4 ${t.railBorder} ${t.cardBg} backdrop-blur-md`}>
                <div className="flex items-center gap-2 mb-1.5">
                  <BadgeCheck className="h-4 w-4 text-emerald-400" />
                  <p className={`text-xs font-bold ${t.textPrimary}`}>
                    Escrow Settlement
                  </p>
                </div>
                <p className={`text-[11px] leading-relaxed ${t.textSecondary}`}>
                  Guaranteed fund release upon customer sign-off.
                </p>
              </div>
            </div>
          </div>

          {/* Right Column: Realistic Flagship Smartphone Device Mockup */}
          <div className="lg:col-span-5 flex justify-center items-center relative">
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
  const faqItems = getFaqItems(false);

  return (
    <section id="faq" className={`relative border-b ${t.railBorder} py-20 px-4 sm:px-6 lg:px-8 overflow-hidden scroll-mt-20`}>
      <div className="max-w-7xl mx-auto space-y-12 relative z-10">
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <div
            className={`inline-flex items-center gap-2 px-3.5 py-1 rounded-full border text-xs font-mono-code ${
              t.dark
                ? 'border-cyan-400/25 bg-cyan-500/10 text-cyan-300'
                : 'border-sky-300 bg-sky-50 text-sky-700'
            }`}
          >
            <HelpCircle className="h-3.5 w-3.5" />
            <span>TRANSPARENCY &amp; OPERATIONS HUB</span>
          </div>

          <h2 className={`text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight ${t.textPrimary}`}>
            Frequently Asked Questions &amp; Support
          </h2>

          <p className={`text-base sm:text-lg max-w-2xl mx-auto leading-relaxed ${t.textSecondary}`}>
            Clear operational answers on SKAVIA&apos;s managed branch model, verification standards, and operational command protocols.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-start">
          {/* FAQ Accordion (7 cols) */}
          <div className="lg:col-span-7 space-y-4">
            {faqItems.map((item, idx) => {
              const open = openFaq === idx;
              return (
                <div
                  key={item.q}
                  className={`rounded-2xl border transition-all overflow-hidden ${
                    open
                      ? `${t.cardBg} border-[#003399]/40 dark:border-[#15E7CA]/40 shadow-lg shadow-blue-500/5`
                      : `${t.surfaceBg} ${t.railBorder} hover:border-slate-400/40 dark:hover:border-slate-700/60`
                  }`}
                >
                  <button
                    type="button"
                    onClick={() => onToggleFaq(idx)}
                    className={`w-full px-6 py-5 text-left flex items-center justify-between gap-4 text-sm sm:text-base font-semibold transition-colors ${
                      open ? (t.dark ? 'text-[#15E7CA]' : 'text-[#003399]') : t.textPrimary
                    }`}
                  >
                    <span>{item.q}</span>
                    <div
                      className={`h-7 w-7 rounded-full flex items-center justify-center shrink-0 transition-transform duration-200 ${
                        open ? 'bg-[#003399]/10 dark:bg-[#15E7CA]/15 rotate-180' : 'bg-slate-100 dark:bg-slate-800'
                      }`}
                    >
                      <ChevronDown
                        className={`h-4 w-4 ${open ? (t.dark ? 'text-[#15E7CA]' : 'text-[#003399]') : 'text-slate-500'}`}
                      />
                    </div>
                  </button>
                  {open && (
                    <div className={`px-6 pb-6 text-xs sm:text-sm leading-relaxed border-t ${t.railBorder} pt-4 ${t.textSecondary}`}>
                      {item.a}
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          {/* Dhaka HQ Operations Desk Card (5 cols) */}
          <div id="contact" className="lg:col-span-5 scroll-mt-20">
            <div className={`rounded-3xl border p-6 sm:p-8 space-y-6 ${t.railBorder} ${t.cardBg} backdrop-blur-md shadow-xl`}>
              <div className="flex items-center justify-between flex-wrap gap-2">
                <div className={`inline-flex items-center gap-2 text-xs font-mono-code uppercase tracking-wider font-semibold ${t.dark ? 'text-[#15E7CA]' : 'text-teal-700'}`}>
                  <Hammer className="h-4 w-4" />
                  <span>Central Operations Command</span>
                </div>
                <span className="flex items-center gap-1.5 text-[11px] font-mono-code px-2.5 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                  <span>SLA &lt; 15m</span>
                </span>
              </div>

              <div className="space-y-2">
                <h3 className={`text-xl sm:text-2xl font-bold ${t.textPrimary}`}>
                  Enterprise SLAs &amp; Priority Dispatch
                </h3>
                <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                  Direct line to the SKAVIA Operations Command Center for commercial facility contracts, retail rollouts, and critical technical assistance.
                </p>
              </div>

              <div className="space-y-3 pt-2 text-xs">
                <div className={`flex items-start gap-3.5 rounded-2xl border p-4 ${t.railBorder} ${t.surfaceBg}`}>
                  <div className="p-2 rounded-xl bg-blue-500/10 text-[#3898EC] shrink-0">
                    <Mail className="h-4 w-4" />
                  </div>
                  <div>
                    <p className={`font-semibold ${t.textPrimary}`}>
                      Official Operations Desk
                    </p>
                    <p className="text-slate-500 dark:text-slate-400 font-mono-code text-[11px] mt-0.5">
                      operations@skavia.com &middot; support@skavia.com
                    </p>
                  </div>
                </div>

                <div className={`flex items-start gap-3.5 rounded-2xl border p-4 ${t.railBorder} ${t.surfaceBg}`}>
                  <div className="p-2 rounded-xl bg-teal-500/10 text-teal-400 shrink-0">
                    <Phone className="h-4 w-4" />
                  </div>
                  <div>
                    <p className={`font-semibold ${t.textPrimary}`}>
                      Emergency Dispatch Hotline (Dhaka Hub)
                    </p>
                    <p className="text-slate-500 dark:text-slate-400 font-mono-code text-[11px] mt-0.5">
                      +880 9612-SKAVIA (09:00 – 21:00 BST Daily)
                    </p>
                  </div>
                </div>

                <div className={`flex items-start gap-3.5 rounded-2xl border p-4 ${t.railBorder} ${t.surfaceBg}`}>
                  <div className="p-2 rounded-xl bg-amber-500/10 text-amber-400 shrink-0">
                    <MapPin className="h-4 w-4" />
                  </div>
                  <div>
                    <p className={`font-semibold ${t.textPrimary}`}>
                      Headquarters &amp; Dispatch Center
                    </p>
                    <p className={`text-[11px] mt-0.5 ${t.textSecondary}`}>
                      Gulshan-2, Dhaka-1212, Bangladesh
                    </p>
                  </div>
                </div>
              </div>

              <div className="pt-2">
                <Link
                  href="/download"
                  className="w-full inline-flex items-center justify-center gap-2 px-5 py-3 rounded-xl border border-slate-300 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-800 text-xs font-semibold transition-all text-slate-800 dark:text-slate-200"
                >
                  <Smartphone className="h-4 w-4 text-[#3898EC]" />
                  <span>Get Mobile App to Book &amp; Track</span>
                  <ArrowRight className="h-3.5 w-3.5 text-[#3898EC]" />
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
