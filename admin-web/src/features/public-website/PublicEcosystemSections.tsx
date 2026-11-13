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
  Layers,
  Mail,
  Phone,
  ShieldCheck,
  Smartphone,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { formatBytes } from '@/lib/formatters';
import {
  FAQ_ITEMS,
  MOBILE_FEATURES,
  WORKER_ONBOARDING_STEPS,
  type DistributionInfo,
  type PublicThemeTokens,
} from './public-site-data';

export function WorkerAndFeaturesSection({ t }: { t: PublicThemeTokens }) {
  return (
    <section id="workers" className={`border-b ${t.railBorder} ${t.subtleCardBg} p-6 sm:p-10`}>
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        <div className="lg:col-span-6 space-y-4">
          <p className="text-xs font-mono-code uppercase tracking-widest text-[#15E7CA]">
            Worker Opportunities
          </p>
          <h2 className="text-2xl sm:text-3xl font-bold tracking-tight">
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
          <h2 className="text-2xl sm:text-3xl font-bold tracking-tight">
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
                  <Icon className="h-4 w-4 text-[#15E7CA] mb-2.5" />
                  <p className="text-sm font-semibold">{feat.title}</p>
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
    <section id="download" className={`relative border-b ${t.railBorder} ${t.surfaceBg} p-6 sm:p-10`}>
      <div className="max-w-3xl mb-6">
        <p className="text-xs font-mono-code uppercase tracking-widest text-[#15E7CA] mb-2">
          Official Distribution
        </p>
        <h2 className="text-2xl sm:text-3xl font-bold tracking-tight">
          Download the Official SKAVIA Mobile App
        </h2>
        <p className={`text-sm mt-2 leading-relaxed ${t.textSecondary}`}>
          For genuine SKAVIA client bookings and verified worker onboarding, install only from
          official verified distribution links listed here.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        <div className={`rounded-2xl border p-6 space-y-4 ${t.railBorder} ${t.cardBg}`}>
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-3">
              <div className="h-11 w-11 rounded-xl bg-[#003399]/15 border border-[#3898EC]/30 flex items-center justify-center shrink-0">
                <Smartphone className="h-5 w-5 text-[#3898EC]" />
              </div>
              <div>
                <h3 className="text-base font-bold">Android Application</h3>
                <p className={`text-xs ${t.textSecondary}`}>
                  {distribution.android.distributionMethod}
                  {distribution.android.version ? ` · v${distribution.android.version}` : ''}
                  {distribution.android.buildNumber ? ` (#${distribution.android.buildNumber})` : ''}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-1.5 shrink-0">
              {distribution.android.isMandatory && (
                <span className="rounded-full px-2 py-0.5 text-[10px] font-semibold bg-red-500/15 text-red-400 border border-red-500/30">
                  Required Update
                </span>
              )}
              <span
                className={`rounded-full px-2.5 py-0.5 text-[11px] font-medium ${
                  distribution.android.published
                    ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30'
                    : 'bg-amber-500/15 text-amber-400 border border-amber-500/30'
                }`}
              >
                {distribution.android.published ? 'Available' : 'Release Pending'}
              </span>
            </div>
          </div>

          {distribution.android.published && (apkSizeLabel || publishedDateLabel || distribution.android.minSdkVersion) && (
            <div
              className={`grid grid-cols-3 gap-2 rounded-xl border p-3 text-[11px] ${t.railBorder} ${t.surfaceBg}`}
            >
              <div>
                <p className={t.textMuted}>Package Size</p>
                <p className="font-semibold mt-0.5">{apkSizeLabel ?? '—'}</p>
              </div>
              <div>
                <p className={t.textMuted}>Released</p>
                <p className="font-semibold mt-0.5">{publishedDateLabel ?? 'Latest'}</p>
              </div>
              <div>
                <p className={t.textMuted}>Android API</p>
                <p className="font-semibold mt-0.5">
                  {distribution.android.minSdkVersion
                    ? `API ${distribution.android.minSdkVersion}+`
                    : 'Android 7+'}
                </p>
              </div>
            </div>
          )}

          {distribution.android.published && distribution.android.apkUrl ? (
            <div className="space-y-3">
              <a
                href={distribution.android.apkUrl}
                download={distribution.android.fileName ?? undefined}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex w-full items-center justify-center gap-2 rounded-xl px-5 py-3 text-sm font-semibold text-white transition hover:opacity-95"
                style={{ backgroundColor: '#003399' }}
              >
                <Download className="h-4 w-4" />
                <span>
                  Download Official Android APK
                  {distribution.android.version ? ` (v${distribution.android.version})` : ''}
                </span>
              </a>

              {distribution.android.sha256Checksum && (
                <div className={`rounded-xl border p-3 text-[11px] space-y-1 ${t.railBorder} ${t.surfaceBg}`}>
                  <div className="flex items-center justify-between gap-2">
                    <span className="inline-flex items-center gap-1 font-semibold text-[#15E7CA]">
                      <ShieldCheck className="h-3.5 w-3.5" /> Verified SHA-256 Checksum
                    </span>
                    <button
                      type="button"
                      onClick={() => {
                        if (!distribution.android.sha256Checksum) return;
                        void navigator.clipboard?.writeText(distribution.android.sha256Checksum);
                        setCopiedSha(true);
                        setTimeout(() => setCopiedSha(false), 2000);
                      }}
                      className={`inline-flex items-center gap-1 ${t.textSecondary} hover:text-[#3898EC]`}
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
                  <p className={`font-mono-code break-all ${t.textMuted}`}>
                    {distribution.android.sha256Checksum}
                  </p>
                </div>
              )}

              {distribution.android.releaseNotes && (
                <div className={`rounded-xl border p-3 text-xs ${t.railBorder} ${t.surfaceBg}`}>
                  <button
                    type="button"
                    onClick={() => setNotesExpanded((prev) => !prev)}
                    className="w-full flex items-center justify-between font-semibold"
                  >
                    <span>What&apos;s New in v{distribution.android.version ?? 'Latest'}</span>
                    <ChevronDown
                      className={`h-3.5 w-3.5 transition-transform ${notesExpanded ? 'rotate-180' : ''}`}
                    />
                  </button>
                  {notesExpanded && (
                    <p className={`mt-2 whitespace-pre-wrap leading-relaxed ${t.textSecondary}`}>
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
              Official Android APK release link is being finalized. Contact SKAVIA Support for
              verified pilot build access — never download SKAVIA packages from unverified third-party mirrors.
            </div>
          )}
        </div>

        <div className={`rounded-2xl border p-6 space-y-4 ${t.railBorder} ${t.cardBg}`}>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="h-11 w-11 rounded-xl bg-white/5 border border-white/15 flex items-center justify-center">
                <Layers className="h-5 w-5 text-[#15E7CA]" />
              </div>
              <div>
                <h3 className="text-base font-bold">iOS Application</h3>
                <p className={`text-xs ${t.textSecondary}`}>{distribution.ios.distributionMethod}</p>
              </div>
            </div>
            <span
              className={`rounded-full px-2.5 py-0.5 text-[11px] font-medium ${
                distribution.ios.published
                  ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/30'
                  : 'bg-slate-500/15 text-slate-400 border border-slate-500/30'
              }`}
            >
              {distribution.ios.published ? 'Available' : 'Coming Soon'}
            </span>
          </div>

          {distribution.ios.published && distribution.ios.storeUrl ? (
            <a
              href={distribution.ios.storeUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex w-full items-center justify-center gap-2 rounded-xl border px-5 py-3 text-sm font-semibold transition hover:bg-white/10"
            >
              <Download className="h-4 w-4" />
              <span>Open Official App Store Page</span>
            </a>
          ) : (
            <div
              className={`rounded-xl border p-4 text-xs leading-relaxed ${t.railBorder} ${t.surfaceBg} ${t.textSecondary}`}
            >
              iOS App Store distribution will be published here once Apple App Store review completes.
            </div>
          )}
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
    <section id="faq" className={`border-b ${t.railBorder} ${t.subtleCardBg} p-6 sm:p-10`}>
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
                  className="w-full px-5 py-4 text-left flex items-center justify-between gap-4 text-sm font-semibold"
                >
                  <span>{item.q}</span>
                  <ChevronDown
                    className={`h-4 w-4 shrink-0 transition-transform ${open ? 'rotate-180' : ''}`}
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
            <div className="flex items-center gap-2 text-xs font-mono-code uppercase tracking-widest text-[#15E7CA]">
              <Hammer className="h-4 w-4" />
              <span>Contact &amp; Official Support</span>
            </div>
            <h3 className="text-xl font-bold">Need Business Scoping or Support?</h3>
            <p className={`text-xs leading-relaxed ${t.textSecondary}`}>
              Reach SKAVIA Operations for enterprise facility partnerships, safety inquiries,
              or verified distribution questions.
            </p>
            <div className="space-y-3 pt-2 text-xs">
              <div className={`flex items-center gap-3 rounded-xl border p-3.5 ${t.railBorder} ${t.cardBg}`}>
                <Mail className="h-4 w-4 text-[#3898EC] shrink-0" />
                <div>
                  <p className="font-semibold">Official Support Email</p>
                  <p className={t.textSecondary}>support@skavia.com</p>
                </div>
              </div>
              <div className={`flex items-center gap-3 rounded-xl border p-3.5 ${t.railBorder} ${t.cardBg}`}>
                <Phone className="h-4 w-4 text-[#15E7CA] shrink-0" />
                <div>
                  <p className="font-semibold">Operations Desk (Dhaka HQ)</p>
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
          <span className="text-sm font-semibold">SKAVIA</span>
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
          <a href="#download" className="text-[#15E7CA] font-medium hover:underline">
            Official Mobile App
          </a>
        </div>
      </div>
    </footer>
  );
}

