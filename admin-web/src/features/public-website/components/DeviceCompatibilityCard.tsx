'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  AlertTriangle,
  CheckCircle2,
  ChevronDown,
  ExternalLink,
  Info,
  Laptop,
  Monitor,
  ShieldAlert,
  Smartphone,
  Tablet,
  Zap,
} from 'lucide-react';
import type { DeviceTelemetry } from '../hooks/useDeviceDetection';
import type { PublicThemeTokens } from '../public-site-data';

interface DeviceCompatibilityCardProps {
  telemetry: DeviceTelemetry;
  t: PublicThemeTokens;
}

export function DeviceCompatibilityCard({
  telemetry,
  t,
}: DeviceCompatibilityCardProps) {
  const [detailsOpen, setDetailsOpen] = useState(false);

  if (!telemetry.isLoaded) {
    return (
      <div
        className={`p-4 rounded-xl border animate-pulse ${t.railBorder} ${t.subtleCardBg}`}
      >
        <div className="flex items-center gap-2">
          <div className="h-4 w-4 rounded-full bg-blue-500/30" />
          <div className="h-3 w-48 rounded bg-slate-400/20" />
        </div>
      </div>
    );
  }

  const {
    os,
    osVersion,
    browser,
    browserVersion,
    deviceCategory,
    screen,
    hardware,
    network,
    pwaFeatures,
    compatibilityStatus,
  } = telemetry;

  // Icon for category
  const CategoryIcon =
    deviceCategory === 'Mobile'
      ? Smartphone
      : deviceCategory === 'Tablet'
      ? Tablet
      : Monitor;

  const networkLabel =
    network.effectiveType === '4g'
      ? (network.downlinkMbps && network.downlinkMbps >= 10 ? '5G / 4G (High-Speed)' : '5G / 4G LTE')
      : network.effectiveType === 'Unknown'
      ? '5G / 4G / Wi-Fi'
      : network.effectiveType.toUpperCase();

  return (
    <div
      className={`rounded-2xl border p-5 sm:p-6 ${t.railBorder} ${t.cardBg} backdrop-blur-md shadow-md space-y-4`}
    >
      {/* Top Banner: Detected Device Summary & Real-Time Pill */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <div
            className={`p-2 rounded-xl ${
              t.dark ? 'bg-blue-500/10 text-cyan-400' : 'bg-blue-50 text-[#003399]'
            }`}
          >
            <CategoryIcon className="h-5 w-5" />
          </div>
          <div>
            <div className="flex items-center gap-2 flex-wrap">
              <span className={`text-sm font-bold ${t.textPrimary}`}>
                {os} {osVersion ? `v${osVersion}` : ''}
              </span>
              <span
                className={`text-[11px] font-mono-code px-2 py-0.5 rounded-full border ${
                  t.dark
                    ? 'border-slate-700 bg-slate-800/60 text-slate-300'
                    : 'border-slate-300 bg-slate-100 text-slate-700'
                }`}
              >
                {browser} {browserVersion.split('.')[0] ? `v${browserVersion.split('.')[0]}` : ''}
              </span>
              <span
                className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-emerald-500/15 text-emerald-400 border border-emerald-500/30"
              >
                5G & 4G Ready
              </span>
            </div>
            <p className={`text-xs ${t.textSecondary} mt-0.5`}>
              Detected Device: {deviceCategory} · Network: {networkLabel}
            </p>
          </div>
        </div>

        {/* Status Badge */}
        <div>
          {compatibilityStatus === 'fully_compatible' && (
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
              <CheckCircle2 className="h-3.5 w-3.5" />
              <span>Fully Compatible</span>
            </span>
          )}
          {compatibilityStatus === 'legacy_compatible' && (
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-sky-500/15 text-sky-400 border border-sky-500/30">
              <Zap className="h-3.5 w-3.5" />
              <span>32-Bit Compatible</span>
            </span>
          )}
          {compatibilityStatus === 'incompatible_ios' && (
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-amber-500/15 text-amber-400 border border-amber-500/30">
              <AlertTriangle className="h-3.5 w-3.5" />
              <span>iOS Device</span>
            </span>
          )}
          {compatibilityStatus === 'desktop_transfer' && (
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-indigo-500/15 text-indigo-400 border border-indigo-500/30">
              <Laptop className="h-3.5 w-3.5" />
              <span>Desktop Mode</span>
            </span>
          )}
        </div>
      </div>

      {/* Dynamic Recommendation Message */}
      <div
        className={`p-3.5 rounded-xl border text-xs leading-relaxed ${
          compatibilityStatus === 'incompatible_ios'
            ? t.dark
              ? 'bg-amber-500/10 border-amber-500/20 text-amber-200'
              : 'bg-amber-50 border-amber-200 text-amber-800'
            : compatibilityStatus === 'desktop_transfer'
            ? t.dark
              ? 'bg-blue-500/10 border-blue-500/20 text-cyan-200'
              : 'bg-sky-50 border-sky-200 text-sky-800'
            : t.dark
            ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-200'
            : 'bg-emerald-50 border-emerald-200 text-emerald-800'
        }`}
      >
        {compatibilityStatus === 'fully_compatible' && (
          <p>
            <strong>Recommended for your device:</strong>{' '}
            <span className="underline font-bold">ARM64 APK (22.6 MB)</span>.
            Your device supports modern 64-bit Android architecture with
            instant Haversine dispatch and OTP verification.
          </p>
        )}

        {compatibilityStatus === 'legacy_compatible' && (
          <p>
            <strong>Recommended for your device:</strong>{' '}
            <span className="underline font-bold">ARMv7 APK (20.3 MB)</span>.
            Legacy 32-bit architecture detected. The ARMv7 build ensures
            stable, crash-free execution.
          </p>
        )}

        {compatibilityStatus === 'incompatible_ios' && (
          <div className="space-y-1.5">
            <p>
              <strong>Apple iOS Detected:</strong> Android APK packages
              cannot be directly installed on iPhone or iPad. An official
              Apple App Store release is currently in progress.
            </p>
            <div className="pt-1">
              <Link
                href="/customer-portal"
                className="inline-flex items-center gap-1 font-semibold underline hover:opacity-80"
              >
                <span>Launch SKAVIA Web Portal</span>
                <ExternalLink className="h-3 w-3" />
              </Link>
            </div>
          </div>
        )}

        {compatibilityStatus === 'desktop_transfer' && (
          <p>
            <strong>Desktop Computer Detected:</strong> You can download the
            SKAVIA APK to transfer to your Android device via USB/Drive, or
            explore our complete{' '}
            <Link href="/services-catalog" className="underline font-semibold">
              Trade Services Catalog
            </Link>
            .
          </p>
        )}
      </div>

      {/* Accordion: Detailed Hardware & Network Telemetry */}
      <div className="border-t pt-3">
        <button
          type="button"
          onClick={() => setDetailsOpen(!detailsOpen)}
          className={`w-full flex items-center justify-between text-xs font-mono-code ${t.textSecondary} hover:${t.textPrimary} transition-colors`}
        >
          <div className="flex items-center gap-1.5">
            <Info className="h-3.5 w-3.5 text-blue-500" />
            <span>Browser-Reported Hardware & Network Telemetry</span>
          </div>
          <ChevronDown
            className={`h-3.5 w-3.5 transition-transform ${
              detailsOpen ? 'rotate-180' : ''
            }`}
          />
        </button>

        {detailsOpen && (
          <div
            className={`mt-3 p-3.5 rounded-xl border grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs font-mono-code ${t.railBorder} ${t.surfaceBg}`}
          >
            <div>
              <p className={t.textMuted}>Screen &amp; DPR</p>
              <p className={`font-semibold ${t.textPrimary} mt-0.5`}>
                {screen.width} × {screen.height}
              </p>
              <p className={`text-[10px] ${t.textSecondary}`}>
                {screen.dpr}x Device Pixel Ratio
              </p>
            </div>

            <div>
              <p className={t.textMuted}>CPU Cores</p>
              <p className={`font-semibold ${t.textPrimary} mt-0.5`}>
                {hardware.cpuCores ? `${hardware.cpuCores} Logical Cores` : 'Restricted'}
              </p>
              <p className={`text-[10px] ${t.textSecondary}`}>
                Hardware Concurrency
              </p>
            </div>

            <div>
              <p className={t.textMuted}>Device Memory</p>
              <p className={`font-semibold ${t.textPrimary} mt-0.5`}>
                {hardware.deviceMemoryGb
                  ? `${hardware.deviceMemoryGb} GB (Approx)`
                  : 'Safari/Firefox Privacy'}
              </p>
              <p className={`text-[10px] ${t.textSecondary}`}>
                Client RAM Estimate
              </p>
            </div>

            <div>
              <p className={t.textMuted}>Network Speed</p>
              <p className={`font-semibold ${t.textPrimary} mt-0.5`}>
                {networkLabel}
                {network.downlinkMbps ? ` · ${network.downlinkMbps} Mbps` : ''}
              </p>
              <p className={`text-[10px] ${t.textSecondary}`}>
                {network.rttMs ? `${network.rttMs}ms RTT` : '5G/4G Online'}
              </p>
            </div>

            <div className="col-span-2 sm:col-span-4 border-t pt-2 mt-1 flex flex-wrap items-center gap-x-4 gap-y-1 text-[11px]">
              <span className={t.textMuted}>Web Capabilities:</span>
              <span
                className={
                  pwaFeatures.serviceWorker ? 'text-emerald-500' : 'text-slate-400'
                }
              >
                ServiceWorker: {pwaFeatures.serviceWorker ? 'Active' : 'No'}
              </span>
              <span
                className={
                  pwaFeatures.webAuthn ? 'text-emerald-500' : 'text-slate-400'
                }
              >
                Passkeys (WebAuthn): {pwaFeatures.webAuthn ? 'Supported' : 'No'}
              </span>
              <span
                className={
                  pwaFeatures.storageEstimate
                    ? 'text-emerald-500'
                    : 'text-slate-400'
                }
              >
                Storage API: {pwaFeatures.storageEstimate ? 'Available' : 'No'}
              </span>
            </div>
          </div>
        )}
      </div>

      {/* Transparent Disclaimer */}
      <div className="flex items-start gap-2 pt-1 text-[11px] leading-relaxed text-slate-500">
        <ShieldAlert className="h-3.5 w-3.5 shrink-0 mt-0.5 text-slate-400" />
        <p>
          Browser device detection provides estimated guidance based on client telemetry. Final package compatibility and installation authorization are strictly enforced by the Android OS Package Manager.
        </p>
      </div>
    </div>
  );
}
