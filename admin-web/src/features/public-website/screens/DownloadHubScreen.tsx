'use client';

import { useEffect, useState } from 'react';
import {
  ArrowRight,
  BadgeCheck,
  Check,
  Copy,
  Cpu,
  Download,
  FileText,
  ShieldCheck,
  Smartphone,
  Sparkles,
} from 'lucide-react';
import { formatBytes } from '@/lib/formatters';
import { useSakugaToast } from '@/components/sakuga';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';
import { INITIAL_DISTRIBUTION, type DistributionInfo } from '../public-site-data';
import { useDeviceDetection } from '../hooks/useDeviceDetection';
import { SmartphoneDeviceMockup } from '../SmartphoneDeviceMockup';
import { DeviceCompatibilityCard } from '../components/DeviceCompatibilityCard';
import { DownloadQrCode } from '../components/DownloadQrCode';

export function DownloadHubScreen({
  initialDistribution = INITIAL_DISTRIBUTION,
}: {
  initialDistribution?: DistributionInfo;
}) {
  const { showToast } = useSakugaToast();
  const detection = useDeviceDetection();
  const [activeDist, setActiveDist] = useState(
    (initialDistribution ?? INITIAL_DISTRIBUTION).android
  );
  const dist = activeDist;
  const [copiedSha, setCopiedSha] = useState(false);

  const directApkUrl = activeDist.apkUrl ?? '/downloads/skavia-latest.apk';
  const [fullDownloadUrl, setFullDownloadUrl] = useState(`https://skavia-bd.vercel.app${directApkUrl}`);

  const versionLabel = activeDist.version ? `v${activeDist.version}` : 'v1.0.0';
  const buildLabel = activeDist.buildNumber ? `#${activeDist.buildNumber}` : '#8';
  const apkSizeLabel =
    activeDist.fileSizeBytes && activeDist.fileSizeBytes > 0
      ? formatBytes(activeDist.fileSizeBytes, 1)
      : '69.7 MB';
  const publishedDateLabel = activeDist.publishedAt
    ? new Intl.DateTimeFormat('en-GB', { dateStyle: 'medium', timeZone: 'UTC' }).format(
        new Date(activeDist.publishedAt)
      )
    : 'Latest Production';

  useEffect(() => {
    fetch('/api/public/app-update?platform=android&channel=stable&installed_build=0')
      .then((res) => (res.ok ? res.json() : null))
      .then((data) => {
        if (data?.latestRelease) {
          const lr = data.latestRelease;
          setActiveDist((prev) => ({
            ...prev,
            version: lr.versionName || prev.version,
            buildNumber: lr.buildNumber || prev.buildNumber,
            fileSizeBytes: lr.fileSizeBytes || prev.fileSizeBytes,
            sha256Checksum: lr.sha256Checksum || prev.sha256Checksum,
            apkUrl: lr.downloadUrl || prev.apkUrl,
            publishedAt: lr.publishedAt || prev.publishedAt,
          }));
        }
      })
      .catch(() => null);
  }, []);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      if (directApkUrl.startsWith('http://') || directApkUrl.startsWith('https://')) {
        setFullDownloadUrl(directApkUrl);
      } else {
        setFullDownloadUrl(`${window.location.origin}${directApkUrl}`);
      }
    }
  }, [directApkUrl]);

  const handleCopySha = (hash: string) => {
    try {
      navigator.clipboard.writeText(hash);
      setCopiedSha(true);
      showToast('SHA-256 hash copied to clipboard', 'success');
      setTimeout(() => setCopiedSha(false), 2500);
    } catch {
      showToast('Unable to copy checksum', 'info');
    }
  };

  const handleDownloadClick = () => {
    showToast('Starting SKAVIA Universal APK download...', 'success', 3500);
  };

  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-10 sm:space-y-12 pb-16 sm:pb-24">
          {/* Hero Section (Starts seamlessly right below the header) */}
          <section className="relative px-4 sm:px-6 lg:px-8 pt-4 pb-8 sm:pt-6 sm:pb-10 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />

            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white leading-[1.1]">
                Download SKAVIA
                <span className="block mt-1 sm:mt-2 bg-gradient-to-r from-[#003399] via-[#3898EC] to-[#15E7CA] bg-clip-text text-transparent">
                  for Android.
                </span>
              </h1>

              <p className="mt-3 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto text-neutral-600 dark:text-neutral-400">
                Single unified app for Individual Clients, Enterprise Businesses, and Skilled Specialists. 
                Features real-time Haversine dispatch, 4-digit arrival OTP handshakes, and atomic escrow release.
              </p>

              {/* Quick Trust Highlights */}
              <div className="pt-2 flex flex-wrap items-center justify-center gap-3 text-xs text-neutral-500 dark:text-neutral-400">
                <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full border border-neutral-200 dark:border-neutral-800 bg-white/60 dark:bg-neutral-900/60 backdrop-blur-xs">
                  <ShieldCheck className="h-3.5 w-3.5 text-teal-500" />
                  <span>100% Verified Signed Build</span>
                </span>
                <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full border border-neutral-200 dark:border-neutral-800 bg-white/60 dark:bg-neutral-900/60 backdrop-blur-xs">
                  <BadgeCheck className="h-3.5 w-3.5 text-blue-500" />
                  <span>Zero Ads &amp; Zero Tracking</span>
                </span>
                <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full border border-neutral-200 dark:border-neutral-800 bg-white/60 dark:bg-neutral-900/60 backdrop-blur-xs">
                  <Sparkles className="h-3.5 w-3.5 text-amber-500" />
                  <span>Android 7.0 to 15+</span>
                </span>
              </div>
            </div>
          </section>

          {/* Main Action Hub: Primary Download & QR Code Section */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
              {/* Left Column: Primary Universal Download & Architecture Builds (7 cols) */}
              <div className="lg:col-span-7 space-y-5">
                {/* Live Device Hardware Telemetry Card */}
                <DeviceCompatibilityCard
                  telemetry={detection}
                  distribution={initialDistribution}
                  t={t}
                />

                {/* Main Hero Download Card */}
                <div className={`rounded-3xl border p-6 sm:p-7 space-y-5 relative overflow-hidden transition-all ${t.railBorder} ${t.cardBg} shadow-xl`}>
                  {/* Glowing Edge Gradient Accent */}
                  <div
                    suppressHydrationWarning
                    className="absolute -top-24 -right-24 w-64 h-64 rounded-full pointer-events-none blur-3xl opacity-20 dark:opacity-30"
                    style={{ backgroundImage: 'radial-gradient(circle, #3898EC, #15E7CA)' }}
                    aria-hidden="true"
                  />

                  <div className="flex items-center justify-between flex-wrap gap-2 relative z-10">
                    <div className="flex items-center gap-2">
                      <span className="h-2.5 w-2.5 rounded-full bg-emerald-500 animate-pulse" />
                      <span className="text-xs font-mono font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400">
                        Universal Build (All Android Phones)
                      </span>
                    </div>

                    <div className="flex items-center gap-2">
                      <span className="px-2.5 py-0.5 rounded-full text-[11px] font-mono font-bold bg-blue-500/10 text-blue-600 dark:text-blue-400 border border-blue-500/20">
                        {versionLabel} (Build {buildLabel})
                      </span>
                      <span className="text-xs font-mono text-neutral-500 dark:text-neutral-400">
                        {apkSizeLabel}
                      </span>
                    </div>
                  </div>

                  <div className="relative z-10 space-y-1.5">
                    <h2 className="text-2xl sm:text-3xl font-extrabold text-neutral-950 dark:text-white tracking-tight">
                      SKAVIA Universal Production APK
                    </h2>
                    <p className="text-xs sm:text-sm text-neutral-600 dark:text-neutral-400 leading-relaxed">
                      Pre-compiled native binaries supporting all modern and legacy Android architectures 
                      (ARM64-v8a, armeabi-v7a, and x86_64). One download works on every smartphone and tablet.
                    </p>
                  </div>

                  {/* Primary Download Action Bar */}
                  <div className="pt-1 flex flex-col sm:flex-row items-stretch sm:items-center gap-3 relative z-10">
                    <a
                      href={directApkUrl}
                      download="skavia-latest.apk"
                      onClick={handleDownloadClick}
                      className="sakuga-spring-tap flex-1 inline-flex items-center justify-center gap-2.5 px-6 py-3.5 rounded-2xl bg-neutral-950 text-white hover:bg-neutral-800 dark:bg-white dark:text-neutral-950 dark:hover:bg-neutral-200 text-sm font-bold shadow-xl transition-all text-center active:scale-[0.98]"
                    >
                      <Download className="h-4 w-4 shrink-0" />
                      <span>Download Universal APK ({apkSizeLabel})</span>
                      <ArrowRight className="h-4 w-4 shrink-0" />
                    </a>

                    <button
                      type="button"
                      onClick={() => handleCopySha(dist.sha256Checksum ?? '')}
                      className="inline-flex items-center justify-center gap-1.5 px-4 py-3.5 rounded-2xl border border-neutral-300 dark:border-neutral-800 hover:bg-neutral-100 dark:hover:bg-neutral-800 text-xs font-mono transition text-neutral-700 dark:text-neutral-300 active:scale-[0.98]"
                      title="Copy SHA-256 Checksum"
                    >
                      {copiedSha ? <Check className="h-4 w-4 text-emerald-500" /> : <Copy className="h-4 w-4" />}
                      <span>{copiedSha ? 'SHA-256 Copied' : 'Copy Checksum'}</span>
                    </button>
                  </div>

                  {/* Cryptographic SHA-256 Checksum Block */}
                  <div className="pt-1 relative z-10 space-y-1.5">
                    <div className="flex items-center justify-between text-xs text-neutral-500">
                      <span className="font-mono uppercase tracking-wider text-[11px] font-semibold">
                        SHA-256 Fingerprint
                      </span>
                      <span className="font-mono text-[10px]">ECDSA SHA256withRSA Signed</span>
                    </div>
                    <div className="p-2.5 rounded-xl border border-neutral-200 dark:border-neutral-800 bg-neutral-50 dark:bg-neutral-900/60 overflow-x-auto">
                      <code className="text-[11px] font-mono text-emerald-600 dark:text-teal-400 break-all select-all">
                        {dist.sha256Checksum}
                      </code>
                    </div>
                  </div>
                </div>

                {/* Live Admin Release Notes & What's New Card */}
                {dist.releaseNotes && (
                  <div className={`p-5 sm:p-6 rounded-2xl border ${t.railBorder} ${t.cardBg} space-y-3`}>
                    <div className="flex items-center justify-between flex-wrap gap-2">
                      <div className="flex items-center gap-2">
                        <FileText className="h-4 w-4 text-[#3898EC]" />
                        <span className="text-xs font-mono font-bold uppercase tracking-wider text-neutral-900 dark:text-white">
                          What&apos;s New in {versionLabel}
                        </span>
                      </div>
                      <span className="text-[11px] font-mono text-neutral-400">
                        Released {publishedDateLabel}
                      </span>
                    </div>
                    <div className="p-3.5 rounded-xl border border-neutral-200/70 dark:border-neutral-800/70 bg-neutral-50/50 dark:bg-neutral-900/40 text-xs sm:text-sm text-neutral-700 dark:text-neutral-300 whitespace-pre-wrap leading-relaxed font-sans">
                      {dist.releaseNotes}
                    </div>
                  </div>
                )}

                {/* Architecture-Specific Builds (ARM64 & ARMv7) */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {/* ARM64-v8a */}
                  <div className={`p-4 sm:p-5 rounded-2xl border ${t.railBorder} ${t.cardBg} space-y-2.5`}>
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-mono font-bold text-neutral-900 dark:text-white flex items-center gap-1.5">
                        <Cpu className="h-3.5 w-3.5 text-[#3898EC]" />
                        <span>ARM64-v8a Only</span>
                      </span>
                      <span className="text-[11px] font-mono text-neutral-400">24.5 MB</span>
                    </div>
                    <p className="text-xs text-neutral-500 dark:text-neutral-400 leading-relaxed">
                      Optimized specifically for 64-bit phones with smaller download size.
                    </p>
                    <a
                      href="/downloads/skavia-v1.0.0-arm64-v8a.apk"
                      download="skavia-v1.0.0-arm64-v8a.apk"
                      className="inline-flex items-center gap-1.5 text-xs font-semibold text-[#003399] dark:text-[#3898EC] hover:underline"
                    >
                      <Download className="h-3.5 w-3.5" />
                      <span>Download ARM64 APK</span>
                    </a>
                  </div>

                  {/* ARMv7-a */}
                  <div className={`p-4 sm:p-5 rounded-2xl border ${t.railBorder} ${t.cardBg} space-y-2.5`}>
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-mono font-bold text-neutral-900 dark:text-white flex items-center gap-1.5">
                        <Smartphone className="h-3.5 w-3.5 text-[#15E7CA]" />
                        <span>ARMv7 32-Bit</span>
                      </span>
                      <span className="text-[11px] font-mono text-neutral-400">20.3 MB</span>
                    </div>
                    <p className="text-xs text-neutral-500 dark:text-neutral-400 leading-relaxed">
                      Legacy build for older 32-bit Android devices and budget tablets.
                    </p>
                    <a
                      href={dist.armv7Url ?? '/downloads/skavia-v1.0.0-armeabi-v7a.apk'}
                      download="skavia-v1.0.0-armeabi-v7a.apk"
                      className="inline-flex items-center gap-1.5 text-xs font-semibold text-[#003399] dark:text-[#3898EC] hover:underline"
                    >
                      <Download className="h-3.5 w-3.5" />
                      <span>Download ARMv7 APK</span>
                    </a>
                  </div>
                </div>

                {/* Direct Android Sideload Guide (Balances Left Column Height to Match Right Column) */}
                <div className={`p-4 sm:p-5 rounded-2xl border ${t.railBorder} ${t.cardBg} space-y-3`}>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <ShieldCheck className="h-4 w-4 text-emerald-500" />
                      <span className="text-xs font-mono font-bold uppercase tracking-wider text-neutral-900 dark:text-white">
                        Direct Android Sideload Guide
                      </span>
                    </div>
                    <span className="text-[11px] font-mono text-neutral-400">Zero Third-Party Store</span>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5 pt-0.5">
                    <div className="p-2.5 rounded-xl border border-neutral-200/70 dark:border-neutral-800/70 bg-neutral-50/50 dark:bg-neutral-900/40 space-y-0.5">
                      <span className="text-[10px] font-mono font-bold text-[#3898EC]">01 &middot; DOWNLOAD</span>
                      <p className="text-[11px] text-neutral-600 dark:text-neutral-400 leading-snug">
                        Tap Universal APK or scan QR from your camera.
                      </p>
                    </div>
                    <div className="p-2.5 rounded-xl border border-neutral-200/70 dark:border-neutral-800/70 bg-neutral-50/50 dark:bg-neutral-900/40 space-y-0.5">
                      <span className="text-[10px] font-mono font-bold text-[#15E7CA]">02 &middot; ALLOW</span>
                      <p className="text-[11px] text-neutral-600 dark:text-neutral-400 leading-snug">
                        Tap Settings and toggle &ldquo;Allow from this source&rdquo;.
                      </p>
                    </div>
                    <div className="p-2.5 rounded-xl border border-neutral-200/70 dark:border-neutral-800/70 bg-neutral-50/50 dark:bg-neutral-900/40 space-y-0.5">
                      <span className="text-[10px] font-mono font-bold text-emerald-500">03 &middot; LAUNCH</span>
                      <p className="text-[11px] text-neutral-600 dark:text-neutral-400 leading-snug">
                        Install and authenticate with instant OTP handshake.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Right Column: Dedicated Scan-to-Download QR Code & Phone Preview (5 cols) - Perfectly Leveled */}
              <div className="lg:col-span-5 space-y-4">
                {/* Dedicated Scan-to-Download QR Code Card */}
                <DownloadQrCode url={fullDownloadUrl} variant="horizontal" />

                {/* Interactive Flagship Phone Preview */}
                <div className={`w-full rounded-3xl border p-5 sm:p-6 flex flex-col items-center text-center space-y-3.5 ${t.railBorder} ${t.cardBg} shadow-xl`}>
                  <div className="flex items-center justify-between w-full px-1">
                    <span className="text-[11px] font-mono uppercase tracking-wider text-neutral-400 font-semibold flex items-center gap-1.5">
                      <span className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                      <span>Live Interactive Preview</span>
                    </span>
                    <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-neutral-100 dark:bg-neutral-800 text-neutral-500">
                      {versionLabel}
                    </span>
                  </div>

                  <SmartphoneDeviceMockup t={t} size="compact" />

                  <div className="space-y-0.5 pt-1">
                    <p className="font-bold text-xs text-neutral-900 dark:text-white">
                      Unified Client &amp; Specialist Workspace
                    </p>
                    <p className="text-[11px] text-neutral-500 dark:text-neutral-400">
                      Toggle seamlessly between booking services and managing active trade assignments.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* 4-Step Sideload Installation Guide */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto space-y-8">
              <div className="text-center max-w-2xl mx-auto space-y-2">
                <span className="text-xs font-mono uppercase tracking-wider text-[#003399] dark:text-[#3898EC] font-semibold">
                  Simple 4-Step Setup
                </span>
                <h2 className="text-2xl sm:text-3xl font-extrabold text-neutral-900 dark:text-white tracking-tight">
                  How to Install SKAVIA on Android
                </h2>
                <p className="text-xs sm:text-sm text-neutral-500 dark:text-neutral-400">
                  Because SKAVIA distributes directly without third-party middleman app stores, follow these standard steps:
                </p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                {[
                  {
                    step: '01',
                    title: 'Download the APK',
                    desc: 'Tap "Download Universal APK" on this page or scan the QR code from your desktop screen.',
                  },
                  {
                    step: '02',
                    title: 'Open Downloaded File',
                    desc: 'When download completes, tap the notification or locate "skavia-latest.apk" in your Files / Downloads app.',
                  },
                  {
                    step: '03',
                    title: 'Allow Installation',
                    desc: 'If Android displays "Install unknown apps", tap Settings and switch on "Allow from this source" for your browser.',
                  },
                  {
                    step: '04',
                    title: 'Launch & Verify',
                    desc: 'Tap Install. Launch SKAVIA and sign in instantly using Google, Phone OTP, or Email with zero delays.',
                  },
                ].map((item) => (
                  <div
                    key={item.step}
                    className={`p-6 rounded-2xl border ${t.railBorder} ${t.cardBg} space-y-3 relative overflow-hidden`}
                  >
                    <span className="text-3xl font-extrabold font-mono text-neutral-200 dark:text-neutral-800">
                      {item.step}
                    </span>
                    <h3 className="text-sm font-bold text-neutral-900 dark:text-white">
                      {item.title}
                    </h3>
                    <p className="text-xs text-neutral-500 dark:text-neutral-400 leading-relaxed">
                      {item.desc}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          </section>
        </div>
      )}
    </PublicPageShell>
  );
}
