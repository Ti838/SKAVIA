'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  ArrowRight,
  BadgeCheck,
  Check,
  ChevronDown,
  Clock,
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
  Wallet,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { useSakugaToast } from '@/components/sakuga';
import { formatBytes } from '@/lib/formatters';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import { elementCenter, sakugaKira, sakugaTicks } from '@/lib/sakuga/sakuga-core';
import { SmartphoneDeviceMockup } from './SmartphoneDeviceMockup';
import { DeviceCompatibilityCard } from './components/DeviceCompatibilityCard';
import { useDeviceDetection } from './hooks/useDeviceDetection';
import {
  getFaqItems,
  getMobileFeatures,
  getWorkerOnboardingSteps,
  type DistributionInfo,
  type PublicThemeTokens,
} from './public-site-data';

export function WorkerAndFeaturesSection({ t }: { t: PublicThemeTokens }) {
  const { isBengali } = useTranslation();
  const onboardingSteps = getWorkerOnboardingSteps(isBengali);
  const mobileFeatures = getMobileFeatures(isBengali);

  return (
    <section id="workers" className={`relative border-b ${t.railBorder} py-20 px-4 sm:px-6 lg:px-8 overflow-hidden`}>
      {/* Ambient background light */}
      <div className="absolute top-1/2 left-0 -translate-y-1/2 w-[500px] h-[400px] bg-gradient-to-r from-blue-600/10 via-cyan-500/5 to-transparent rounded-full blur-3xl pointer-events-none" />

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
            <span>{isBengali ? 'যাচাইকৃত দক্ষ কর্মী প্ল্যাটফর্ম · ৯০% সরাসরি আয়' : 'VERIFIED SKILLED WORKFORCE · 90% DIRECT EARNINGS'}</span>
          </div>

          <h2 className={`text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight ${t.textPrimary}`}>
            {isBengali ? 'দক্ষ কারিগর ও ফিল্ড স্পেশালিস্টদের ক্ষমতায়ন' : "Empowering Bangladesh's Field Specialists"}
          </h2>

          <p className={`text-base sm:text-lg max-w-2xl mx-auto leading-relaxed ${t.textSecondary}`}>
            {isBengali
              ? 'মধ্যস্বত্বভোগী ও অনৈতিক দালাল ব্যবস্থার অবসান। সরাসরি মোবাইল অ্যাপে কাজের অর্ডার, সাপ্তাহিক ব্যাংকিং/এমএফএস পেআউট এবং নিশ্চিত পেশাদার সম্মান।'
              : "Direct job dispatches, zero broker exploitation, weekly bank and MFS settlements, and verifiable reputation building on Bangladesh's accountable workforce platform."}
          </p>
        </div>

        {/* 3 High-Impact KPI Stat Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 lg:gap-6">
          <div className={`p-6 rounded-2xl border transition-all ${t.railBorder} ${t.cardBg} backdrop-blur-md hover:border-[#15E7CA]/40`}>
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-mono-code uppercase tracking-wider text-[#15E7CA] font-semibold">
                {isBengali ? 'কর্মী রাজস্ব অংশীদারিত্ব' : 'Revenue Share'}
              </span>
              <Wallet className="h-5 w-5 text-[#15E7CA]" />
            </div>
            <div className={`text-3xl sm:text-4xl font-extrabold ${t.textPrimary}`}>
              90% <span className="text-sm font-normal text-slate-400">Direct</span>
            </div>
            <p className={`text-xs mt-2 leading-relaxed ${t.textSecondary}`}>
              {isBengali
                ? 'কাজের মোট মূল্যের ৯০% সরাসরি কর্মীর ব্যাংক বা bKash/Nagad একাউন্টে ট্রান্সফার হয়।'
                : "90% of order value is transferred directly to the verified specialist's account."}
            </p>
          </div>

          <div className={`p-6 rounded-2xl border transition-all ${t.railBorder} ${t.cardBg} backdrop-blur-md hover:border-[#3898EC]/40`}>
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-mono-code uppercase tracking-wider text-[#3898EC] font-semibold">
                {isBengali ? 'দালালমুক্ত প্ল্যাটফর্ম' : 'Zero Middlemen'}
              </span>
              <ShieldCheck className="h-5 w-5 text-[#3898EC]" />
            </div>
            <div className={`text-3xl sm:text-4xl font-extrabold ${t.textPrimary}`}>
              ৳0 <span className="text-sm font-normal text-slate-400">Broker Fee</span>
            </div>
            <p className={`text-xs mt-2 leading-relaxed ${t.textSecondary}`}>
              {isBengali
                ? 'কোনো অনাকাঙ্ক্ষিত মধ্যস্থতাকারী নেই। স্ক্যাভিয়ার কেন্দ্রীয় অডিটের অধীনে প্রতিটি কাজ সুরক্ষিত।'
                : 'Zero commission leakage to external touts or brokers. Transparent corporate oversight.'}
            </p>
          </div>

          <div className={`p-6 rounded-2xl border transition-all ${t.railBorder} ${t.cardBg} backdrop-blur-md hover:border-emerald-400/40`}>
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-mono-code uppercase tracking-wider text-emerald-400 font-semibold">
                {isBengali ? 'দ্রুত সেটেলমেন্ট' : 'Settlement Cycle'}
              </span>
              <Clock className="h-5 w-5 text-emerald-400" />
            </div>
            <div className={`text-3xl sm:text-4xl font-extrabold ${t.textPrimary}`}>
              {isBengali ? 'সাপ্তাহিক' : 'Weekly'} <span className="text-sm font-normal text-slate-400">Payout</span>
            </div>
            <p className={`text-xs mt-2 leading-relaxed ${t.textSecondary}`}>
              {isBengali
                ? 'প্রতি সপ্তাহে স্বয়ংক্রিয় পেআউট সাইকেল। কাজের সাইন-অফ হওয়ার পর তাত্ক্ষণিক ব্যালেন্স ক্রেডিট।'
                : 'Automated weekly payout disbursement with real-time balance tracking in the worker app.'}
            </p>
          </div>
        </div>

        {/* Two-Column Split: Onboarding Stepper vs Unified Mobile Features */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-start">
          {/* Left Column: Onboarding Stepper (6 cols) */}
          <div className={`lg:col-span-6 p-6 sm:p-8 rounded-3xl border ${t.railBorder} ${t.cardBg} backdrop-blur-md space-y-6`}>
            <div className="space-y-2">
              <span className="text-xs font-mono-code uppercase tracking-widest text-[#3898EC] font-semibold">
                {isBengali ? 'অনবোর্ডিং প্রক্রিয়া' : 'Step-by-Step Pathway'}
              </span>
              <h3 className={`text-xl sm:text-2xl font-bold ${t.textPrimary}`}>
                {isBengali ? 'কীভাবে স্ক্যাভিয়া ভেরিফাইড স্পেশালিস্ট হবেন' : 'How to Become a Verified SKAVIA Specialist'}
              </h3>
              <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                {isBengali
                  ? 'সকল অনবোর্ডিং প্রক্রিয়া অফিসিয়াল অ্যান্ড্রয়েড অ্যাপের ওয়ার্কার মোডে সম্পন্ন হয়। কোনো ফিজিক্যাল কাগজপত্র নিয়ে ঘুরতে হয় না।'
                  : 'Onboarding is executed directly inside the SKAVIA Android App. No tedious paperwork or office visits required.'}
              </p>
            </div>

            <div className="space-y-4 pt-2">
              {onboardingSteps.map((item, idx) => (
                <div
                  key={item.step}
                  className={`group relative p-4 rounded-2xl border transition-all ${t.railBorder} ${t.surfaceBg} hover:border-[#003399]/50 dark:hover:border-[#15E7CA]/40`}
                >
                  <div className="flex items-start gap-3.5">
                    <span className="flex items-center justify-center h-7 w-7 rounded-full bg-[#003399]/15 dark:bg-[#15E7CA]/15 text-[#003399] dark:text-[#15E7CA] font-mono-code font-bold text-xs shrink-0 mt-0.5">
                      0{idx + 1}
                    </span>
                    <div>
                      <h4 className={`text-sm font-semibold ${t.textPrimary} group-hover:text-[#003399] dark:group-hover:text-[#15E7CA] transition-colors`}>
                        {item.step}
                      </h4>
                      <p className={`text-xs mt-1 leading-relaxed ${t.textSecondary}`}>
                        {item.detail}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            <div className={`p-4 rounded-2xl border border-dashed ${t.railBorder} bg-slate-50/50 dark:bg-slate-900/40 flex flex-col sm:flex-row items-center justify-between gap-3`}>
              <div className="flex items-center gap-2.5">
                <Smartphone className="h-5 w-5 text-[#3898EC] shrink-0" />
                <span className={`text-xs font-medium ${t.textPrimary}`}>
                  {isBengali ? 'মোবাইল অ্যাপে রেজিস্ট্রেশন করুন' : 'Apply via Official Mobile App'}
                </span>
              </div>
              <a
                href="#download"
                className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-semibold text-white bg-[#003399] hover:bg-[#002266] transition-all shrink-0"
              >
                <span>{isBengali ? 'অ্যাপ ডাউনলোড' : 'Get The App'}</span>
                <ArrowRight className="h-3.5 w-3.5" />
              </a>
            </div>
          </div>

          {/* Right Column: Unified Mobile App Features (6 cols) */}
          <div className="lg:col-span-6 space-y-6">
            <div className="space-y-2">
              <span className="text-xs font-mono-code uppercase tracking-widest text-[#15E7CA] font-semibold">
                {isBengali ? 'একক মোবাইল আর্কিটেকচার' : 'Single Mobile Architecture'}
              </span>
              <h3 className={`text-xl sm:text-2xl font-bold ${t.textPrimary}`}>
                {isBengali ? 'একটি অ্যাপ। ক্লায়েন্ট ও কর্মী উভয়ের জন্য সম্পূর্ণ নিয়ন্ত্রণ।' : 'One App. Client & Worker Ecosystem Control.'}
              </h3>
              <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                {isBengali
                  ? 'পৃথক দুটি অ্যাপের দরকার নেই। আপনার একই ভেরিফাইড প্রোফাইল থেকে এক ট্যাপে ক্লায়েন্ট ও ওয়ার্কার মোডের মধ্যে স্যুইচ করুন।'
                  : 'Zero duplicate applications. Seamlessly toggle between Client Mode and Verified Worker Mode inside one unified binary.'}
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
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
            <div className={`p-4 rounded-2xl border ${t.railBorder} ${t.subtleCardBg} flex items-center gap-3.5`}>
              <div className="p-2 rounded-xl bg-emerald-500/10 text-emerald-500 shrink-0">
                <ShieldCheck className="h-5 w-5" />
              </div>
              <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                {isBengali
                  ? 'সকল কর্মী জাতীয় পরিচয়পত্র (NID), পুলিশ ক্লিয়ারেন্স ও নির্দিষ্ট ট্রেড টেস্টের মাধ্যমে যাচাইকৃত।'
                  : 'Every technician is verified via Bangladesh National ID (NID) and certified in their trade specialization.'}
              </p>
            </div>
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
    <section id="download" className={`relative border-b ${t.railBorder} py-20 px-4 sm:px-6 lg:px-8 overflow-hidden`}>
      {/* Background ambient lighting for pro aesthetic */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[450px] bg-gradient-to-tr from-[#003399]/25 via-[#15E7CA]/15 to-transparent rounded-full blur-3xl pointer-events-none" />

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
          <span>{isBengali ? 'অফিসিয়াল অ্যান্ড্রয়েড প্রোডাকশন রিলিজ' : 'OFFICIAL ANDROID PRODUCTION RELEASE'}</span>
        </div>
        <h2 className={`text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight ${t.textPrimary}`}>
          {isBengali ? 'অফিসিয়াল স্ক্যাভিয়া অ্যান্ড্রয়েড অ্যাপ ডাউনলোড' : 'Download SKAVIA for Android'}
        </h2>
        <p className={`text-base sm:text-lg max-w-xl mx-auto leading-relaxed ${t.textSecondary}`}>
          {isBengali
            ? 'ইনস্ট্যান্ট সার্ভিস বুকিং, লাইভ টেকনিশিয়ান ডিসপ্যাচ ও আগমন ওটিপি হ্যান্ডশেক — সব একটি মাত্র নিরাপদ অ্যাপে।'
            : 'Instant client bookings, live technician dispatch, and cryptographic OTP handoff — built for high-accountability workforce operations.'}
        </p>
      </div>

      <div className="max-w-7xl mx-auto relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-center">
          {/* Left Column: Direct Download Actions & Technical Verification */}
          <div className="lg:col-span-7 space-y-6">
            {/* Real-time Hardware, Network & OS Compatibility Assessment */}
            <DeviceCompatibilityCard
              telemetry={telemetry}
              isBengali={isBengali}
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
                {isBengali
                  ? 'ক্লায়েন্ট ও ওয়ার্কার উভয়ের জন্য এক সমন্বিত অভিজ্ঞতা। শারীরিক আগমন ও ৪-সংখ্যার ওটিপি ব্যতিরেকে কোনো জব শুরু বা বিলিং হয় না।'
                  : 'Download the official SKAVIA client and worker companion app for Android. No third-party stores or intermediary brokers required.'}
              </p>

              {/* Primary Download Button with Auto-Recommendation Highlighting */}
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
                {/* ARM64 Primary Option */}
                <div className="relative flex-1">
                  {telemetry.isLoaded && telemetry.recommendedApk === 'arm64' && (
                    <span className="absolute -top-3 left-4 z-10 px-2.5 py-0.5 rounded-full text-[10px] font-extrabold uppercase tracking-wider bg-amber-400 text-slate-950 shadow-md flex items-center gap-1 animate-pulse">
                      <span>★</span>
                      <span>{isBengali ? 'আপনার ডিভাইসের জন্য সেরা' : 'Recommended for you'}</span>
                    </span>
                  )}
                  <a
                    href={primaryApkUrl}
                    download="skavia-v1.0.0-arm64-v8a.apk"
                    className={`sakuga-spring-tap w-full inline-flex items-center justify-center gap-2.5 px-6 py-4 rounded-2xl bg-gradient-to-r from-[#003399] to-[#1D4ED8] hover:from-[#002266] hover:to-[#1e40af] text-white font-semibold text-sm shadow-xl shadow-blue-900/30 transition-all text-center hover:scale-[1.01] ${
                      telemetry.isLoaded && telemetry.recommendedApk === 'arm64'
                        ? 'ring-2 ring-amber-400/80 shadow-amber-400/10'
                        : ''
                    }`}
                    onClick={(e) => {
                      const pos = elementCenter(e.currentTarget);
                      sakugaTicks(pos.x, pos.y);
                      sakugaKira(pos.x, pos.y);
                    }}
                  >
                    <Download className="h-4 w-4 shrink-0" />
                    <span>
                      {isBengali ? 'অ্যান্ড্রয়েড APK (5G ও 4G · ARM64 · ২২.৬ MB)' : 'Download APK (5G & 4G · ARM64 · 22.6 MB)'}
                    </span>
                  </a>
                </div>

                {/* ARMv7 32-bit Legacy Option */}
                <div className="relative">
                  {telemetry.isLoaded && telemetry.recommendedApk === 'armv7' && (
                    <span className="absolute -top-3 left-3 z-10 px-2.5 py-0.5 rounded-full text-[10px] font-extrabold uppercase tracking-wider bg-amber-400 text-slate-950 shadow-md flex items-center gap-1 animate-pulse">
                      <span>★</span>
                      <span>{isBengali ? 'আপনার ডিভাইসের জন্য সেরা' : 'Recommended for you'}</span>
                    </span>
                  )}
                  <a
                    href={armv7ApkUrl}
                    download="skavia-v1.0.0-armeabi-v7a.apk"
                    className={`sakuga-spring-tap inline-flex items-center justify-center gap-2 px-4 py-4 rounded-2xl border text-xs font-semibold transition-all text-center hover:scale-[1.01] ${
                      telemetry.isLoaded && telemetry.recommendedApk === 'armv7'
                        ? 'border-amber-400 text-amber-300 ring-2 ring-amber-400/60 bg-amber-500/10'
                        : `${t.railBorder} ${t.surfaceBg} ${t.textSecondary} hover:${t.textPrimary}`
                    }`}
                  >
                    <span>{isBengali ? 'ARMv7 ৩২-বিট পুরোনো ফোন (২০.৩ MB)' : 'ARMv7 32-bit Legacy (20.3 MB)'}</span>
                  </a>
                </div>
              </div>

              {/* Security Trust Badges */}
              <div className="flex items-center gap-4 text-xs pt-1 flex-wrap">
                <div className="flex items-center gap-1.5 text-emerald-500">
                  <ShieldCheck className="h-4 w-4" />
                  <span className="font-semibold">
                    {isBengali ? 'গুগল প্লে প্রটেক্ট ও ভাইরাসটোটাল দ্বারা পরীক্ষিত' : 'Play Protect & VirusTotal Verified'}
                  </span>
                </div>
                <span className={t.textMuted}>•</span>
                <span className={t.textMuted}>Android 7.0 (Nougat) – 15/16 Ready</span>
              </div>

              {/* SHA-256 Checksum Accordion */}
              <div className={`pt-4 border-t ${t.railBorder} space-y-3`}>
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
                <div className="pt-1">
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
              <div className={`rounded-2xl border p-4 ${t.railBorder} ${t.cardBg} backdrop-blur-md`}>
                <div className="flex items-center gap-2 mb-1.5">
                  <MapPin className="h-4 w-4 text-[#3898EC]" />
                  <p className={`text-xs font-bold ${t.textPrimary}`}>
                    {isBengali ? 'হাভারসাইন ডিসপ্যাচ' : 'Haversine Dispatch'}
                  </p>
                </div>
                <p className={`text-[11px] leading-relaxed ${t.textSecondary}`}>
                  {isBengali ? 'নিকটবর্তী যাচাইকৃত টেকনিশিয়ান অনুসন্ধান।' : 'Matches verified specialists nearby.'}
                </p>
              </div>

              <div className={`rounded-2xl border p-4 ${t.railBorder} ${t.cardBg} backdrop-blur-md`}>
                <div className="flex items-center gap-2 mb-1.5">
                  <KeyRound className="h-4 w-4 text-[#15E7CA]" />
                  <p className={`text-xs font-bold ${t.textPrimary}`}>
                    {isBengali ? '৪-সংখ্যার আগমন ওটিপি' : '4-Digit Arrival OTP'}
                  </p>
                </div>
                <p className={`text-[11px] leading-relaxed ${t.textSecondary}`}>
                  {isBengali ? 'আগমন ব্যতিরেকে কাজ শুরু বা বিলিং নয়।' : 'Zero billable time before handoff.'}
                </p>
              </div>

              <div className={`rounded-2xl border p-4 ${t.railBorder} ${t.cardBg} backdrop-blur-md`}>
                <div className="flex items-center gap-2 mb-1.5">
                  <BadgeCheck className="h-4 w-4 text-emerald-400" />
                  <p className={`text-xs font-bold ${t.textPrimary}`}>
                    {isBengali ? 'এসক্রো সেটেলমেন্ট' : 'Escrow Settlement'}
                  </p>
                </div>
                <p className={`text-[11px] leading-relaxed ${t.textSecondary}`}>
                  {isBengali ? 'কাজ সন্তোষজনক হলে স্বয়ংক্রিয় পেআউট।' : 'Guaranteed payout upon sign-off.'}
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
  const { isBengali } = useTranslation();
  const faqItems = getFaqItems(isBengali);

  return (
    <section id="faq" className={`relative border-b ${t.railBorder} py-20 px-4 sm:px-6 lg:px-8 overflow-hidden`}>
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
            <span>{isBengali ? 'স্বচ্ছতা ও প্রাতিষ্ঠানিক সহায়তা' : 'TRANSPARENCY & OPERATIONS HUB'}</span>
          </div>

          <h2 className={`text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight ${t.textPrimary}`}>
            {isBengali ? 'সাধারণ জিজ্ঞাসা ও অপারেশনস সাপোর্ট' : 'Frequently Asked Questions & Operations'}
          </h2>

          <p className={`text-base sm:text-lg max-w-2xl mx-auto leading-relaxed ${t.textSecondary}`}>
            {isBengali
              ? 'স্ক্যাভিয়ার পরিচালনা কাঠামো, অর্ডার পদ্ধতি ও এন্টারপ্রাইজ সাপোর্ট সম্পর্কে আপনার যা জানা প্রয়োজন।'
              : "Clear answers on SKAVIA's managed branch model, verification standards, and operational command protocols."}
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
                    className={`sakuga-spring-tap w-full px-6 py-5 text-left flex items-center justify-between gap-4 text-sm sm:text-base font-semibold transition-colors ${
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
          <div id="contact" className="lg:col-span-5">
            <div className={`rounded-3xl border p-6 sm:p-8 space-y-6 ${t.railBorder} ${t.cardBg} backdrop-blur-md shadow-xl`}>
              <div className="flex items-center justify-between flex-wrap gap-2">
                <div className={`inline-flex items-center gap-2 text-xs font-mono-code uppercase tracking-wider font-semibold ${t.dark ? 'text-[#15E7CA]' : 'text-teal-700'}`}>
                  <Hammer className="h-4 w-4" />
                  <span>{isBengali ? 'অপারেশনস হেডকোয়ার্টার' : 'Dhaka Operations Desk'}</span>
                </div>
                <span className="flex items-center gap-1.5 text-[11px] font-mono-code px-2.5 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                  <span>SLA &lt; 15m</span>
                </span>
              </div>

              <div className="space-y-2">
                <h3 className={`text-xl sm:text-2xl font-bold ${t.textPrimary}`}>
                  {isBengali ? 'প্রাতিষ্ঠানিক চুক্তি বা জরুরী সহায়তা' : 'Enterprise SLAs & Priority Support'}
                </h3>
                <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                  {isBengali
                    ? 'বাণিজ্যিক ফ্যাসিলিটি চুক্তি, মাল্টি-সাইট প্রজেক্ট বা জরুরী টেকনিক্যাল ডিসপ্যাচের জন্য স্ক্যাভিয়া সেন্ট্রাল কন্ট্রোল ডেস্কে যোগাযোগ করুন।'
                    : 'Direct escalation to the SKAVIA Operations Command Center for commercial facility contracts and critical technical response.'}
                </p>
              </div>

              <div className="space-y-3 pt-2 text-xs">
                <div className={`flex items-start gap-3.5 rounded-2xl border p-4 ${t.railBorder} ${t.surfaceBg}`}>
                  <div className="p-2 rounded-xl bg-blue-500/10 text-[#3898EC] shrink-0">
                    <Mail className="h-4 w-4" />
                  </div>
                  <div>
                    <p className={`font-semibold ${t.textPrimary}`}>
                      {isBengali ? 'অফিসিয়াল অপারেশনস ইমেইল' : 'Official Operations Desk'}
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
                      {isBengali ? 'জরুরী ডিসপ্যাচ ও হেল্পডেস্ক (ঢাকা)' : 'Emergency Dispatch (Dhaka Hub)'}
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
                      {isBengali ? 'প্রধান কার্যালয়' : 'Headquarters & Dispatch Center'}
                    </p>
                    <p className={`text-[11px] mt-0.5 ${t.textSecondary}`}>
                      {isBengali ? 'গুলশান-২, ঢাকা-১২১২, বাংলাদেশ' : 'Gulshan-2, Dhaka-1212, Bangladesh'}
                    </p>
                  </div>
                </div>
              </div>

              <div className="pt-2">
                <Link
                  href="/login"
                  className="w-full inline-flex items-center justify-center gap-2 px-5 py-3 rounded-xl border border-slate-300 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-800 text-xs font-semibold transition-all"
                  style={{ color: 'var(--text-primary)' }}
                >
                  <span>{isBengali ? 'প্রশাসনিক পোর্টাল লগইন' : 'Administrative Console Sign In'}</span>
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
