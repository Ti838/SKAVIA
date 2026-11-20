'use client';

import { useState } from 'react';
import {
  Check,
  Copy,
  Download,
  ShieldCheck,
} from 'lucide-react';
import { formatBytes } from '@/lib/formatters';
import { useSakugaToast } from '@/components/sakuga';
import { HeroAtmosphere } from '../components/HeroAtmosphere';
import { PublicPageShell } from '../components/PublicPageShell';
import { INITIAL_DISTRIBUTION } from '../public-site-data';
import { useDeviceDetection } from '../hooks/useDeviceDetection';
import { SmartphoneDeviceMockup } from '../SmartphoneDeviceMockup';
import { DeviceCompatibilityCard } from '../components/DeviceCompatibilityCard';

export function DownloadHubScreen() {
  const { showToast } = useSakugaToast();
  const detection = useDeviceDetection();
  const dist = INITIAL_DISTRIBUTION.android;
  const [copiedSha, setCopiedSha] = useState(false);

  const handleCopySha = (hash: string) => {
    try {
      navigator.clipboard.writeText(hash);
      setCopiedSha(true);
      showToast('SHA-256 hash copied to clipboard', 'success');
      setTimeout(() => setCopiedSha(false), 2500);
    } catch {}
  };

  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-16 pt-4 pb-16 sm:pt-6 sm:pb-24">
          {/* Hero */}
          <section className="relative px-4 sm:px-6 lg:px-8 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />

            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white">
                Download the Official SKAVIA Application
              </h1>

              <p className="mt-4 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto text-neutral-600 dark:text-neutral-400">
                Single unified app for Individual Customers, Enterprise Businesses, and Skilled Specialists with live map dispatch, arrival OTP handshakes, and escrow protection.
              </p>
            </div>
          </section>

          {/* Hardware Detection & Download Cards */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-5xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
              {/* Left Column: Download Options & Device Telemetry (7 cols) */}
              <div className="lg:col-span-7 space-y-6">
                {/* Live Device Hardware Telemetry Card */}
                <DeviceCompatibilityCard
                  telemetry={detection}
                  t={t}
                />

                {/* Primary Download Option: ARM64-v8a */}
                <div
                  className={`rounded-3xl border p-6 sm:p-8 space-y-5 relative overflow-hidden transition-all ${t.railBorder} ${t.cardBg} hover:border-[#15E7CA]/40 shadow-xl`}
                >
                  <div className="flex items-center justify-between flex-wrap gap-2">
                    <div className="flex items-center gap-2">
                      <span className="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
                      <span className="text-xs font-mono-code font-bold uppercase tracking-wider text-emerald-500">
                        Recommended for Modern Phones
                      </span>
                    </div>

                    <span className="text-xs font-mono-code text-slate-400">
                      {formatBytes(dist.fileSizeBytes ?? 23668477)} &middot; Android 7.0+
                    </span>
                  </div>

                  <div>
                    <h3 className={`text-xl sm:text-2xl font-bold ${t.textPrimary}`}>
                      Universal Production Build (All Devices)
                    </h3>
                    <p className={`text-xs sm:text-sm mt-1 leading-relaxed ${t.textSecondary}`}>
                      Complete universal package compatible with all Android devices (ARM64, ARMv7, x86_64).
                    </p>
                  </div>

                  <div className="pt-2 flex flex-col sm:flex-row items-center gap-3">
                    <a
                      href={dist.apkUrl ?? '/downloads/skavia-latest.apk'}
                      download="skavia-latest.apk"
                      className="w-full sm:w-auto flex-1 inline-flex items-center justify-center gap-2 px-6 py-3 rounded-2xl bg-[#003399] hover:bg-[#002266] text-white text-xs sm:text-sm font-semibold shadow-lg shadow-blue-900/25 transition-all hover:scale-[1.01]"
                    >
                      <Download className="h-4 w-4" />
                      <span>Download Official APK ({formatBytes(dist.fileSizeBytes ?? 69726983)})</span>
                    </a>

                    <button
                      type="button"
                      onClick={() => handleCopySha(dist.sha256Checksum ?? '')}
                      className="w-full sm:w-auto inline-flex items-center justify-center gap-1.5 px-4 py-3 rounded-2xl border border-slate-300 dark:border-slate-800 hover:bg-slate-100 dark:hover:bg-slate-800 text-xs font-mono-code transition"
                      style={{ color: 'var(--text-secondary)' }}
                      title="Copy SHA-256 Checksum"
                    >
                      {copiedSha ? <Check className="h-3.5 w-3.5 text-teal-400" /> : <Copy className="h-3.5 w-3.5" />}
                      <span>SHA-256</span>
                    </button>
                  </div>
                </div>

                {/* Secondary Option: ARMv7 (32-Bit Legacy) */}
                <div
                  className={`rounded-3xl border p-6 space-y-4 transition-all ${t.railBorder} ${t.cardBg}`}
                >
                  <div className="flex items-center justify-between flex-wrap gap-2">
                    <span className="text-xs font-mono-code uppercase tracking-wider text-slate-400 font-semibold">
                      Legacy Compatible
                    </span>
                    <span className="text-xs font-mono-code text-slate-400">
                      {formatBytes(dist.armv7SizeBytes ?? 21257429)} &middot; armeabi-v7a
                    </span>
                  </div>

                  <div>
                    <h3 className={`text-lg font-bold ${t.textPrimary}`}>
                      ARMv7 (32-Bit Universal Build)
                    </h3>
                    <p className={`text-xs mt-1 leading-relaxed ${t.textSecondary}`}>
                      Designed specifically for budget 32-bit Android phones and legacy field tablets.
                    </p>
                  </div>

                  <div>
                    <a
                      href={dist.armv7Url ?? '/downloads/skavia-v1.0.0-armeabi-v7a.apk'}
                      download="skavia-v1.0.0-armeabi-v7a.apk"
                      className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl border border-slate-300 dark:border-slate-800 hover:bg-slate-100 dark:hover:bg-slate-800 text-xs font-semibold transition"
                      style={{ color: 'var(--text-primary)' }}
                    >
                      <Download className="h-3.5 w-3.5" />
                      <span>Download ARMv7 APK (20.3 MB)</span>
                    </a>
                  </div>
                </div>

                {/* Cryptographic SHA-256 Verification Guide */}
                <div className={`rounded-3xl border p-6 space-y-4 ${t.railBorder} ${t.cardBg}`}>
                  <div className="flex items-center gap-2 text-xs font-mono-code text-[#15E7CA]">
                    <ShieldCheck className="h-4 w-4" />
                    <span>CRYPTOGRAPHIC INTEGRITY</span>
                  </div>

                  <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                    Official Verified SHA-256 Checksum
                  </h3>

                  <div className={`p-3 rounded-xl border overflow-x-auto ${t.railBorder} ${t.surfaceBg}`}>
                    <code className="text-[11px] font-mono-code text-teal-400 break-all select-all">
                      {dist.sha256Checksum}
                    </code>
                  </div>

                  <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
                    Verify in terminal: certutil -hashfile skavia-v1.0.0-arm64-v8a.apk SHA256
                  </p>
                </div>
              </div>

              {/* Right Column: Realistic Device Mockup Preview (5 cols) */}
              <div className="lg:col-span-5 space-y-6">
                <div
                  className={`rounded-3xl border p-6 sm:p-8 flex flex-col items-center text-center space-y-4 ${t.railBorder} ${t.cardBg} shadow-2xl`}
                >
                  <span className="text-[11px] font-mono-code uppercase tracking-wider text-slate-400 font-semibold">
                    Live App Experience
                  </span>

                  <SmartphoneDeviceMockup t={t} />

                  <div className="space-y-1 pt-2">
                    <p className={`font-bold text-sm ${t.textPrimary}`}>
                      Dual Client &amp; Specialist Modes
                    </p>
                    <p className={`text-xs ${t.textSecondary}`}>
                      Seamlessly toggle between Client booking and Worker dispatch within one app.
                    </p>
                  </div>
                </div>

                {/* Android Installation Steps */}
                <div className={`rounded-3xl border p-6 space-y-3 ${t.railBorder} ${t.cardBg}`}>
                  <h3 className={`font-bold text-sm ${t.textPrimary}`}>
                    How to Install on Android
                  </h3>

                  <ol className={`space-y-2 text-xs leading-relaxed list-decimal list-inside ${t.textSecondary}`}>
                    <li>Download the APK file onto your phone.</li>
                    <li>Open the downloaded file from notifications.</li>
                    <li>Allow &quot;Install unknown apps&quot; if prompted by Android.</li>
                    <li>Complete installation and sign in with your phone number.</li>
                  </ol>
                </div>
              </div>
            </div>
          </section>
        </div>
      )}
    </PublicPageShell>
  );
}
