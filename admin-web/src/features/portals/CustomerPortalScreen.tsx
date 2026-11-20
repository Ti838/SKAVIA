'use client';

import { useState } from 'react';
import {
  Download,
  FileText,
  KeyRound,
  ShieldCheck,
  UserCheck,
} from 'lucide-react';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import { EmptyPanel } from '@/components/ui/StatePanels';

interface CustomerBooking {
  id: string;
  bookingRef: string;
  serviceTitle: string;
  workerName: string;
  scheduledAt: string;
  status: 'requested' | 'matched' | 'in_route' | 'in_progress' | 'completed';
  amountBdt: number;
  arrivalOtp: string; // The confidential 4-digit OTP
}

export function CustomerPortalScreen() {
  const { t, language } = useTranslation();

  // Zero simulated bookings - starts honestly empty in production
  const [activeBookings] = useState<CustomerBooking[]>([]);
  const [pastBookings] = useState<CustomerBooking[]>([]);

  return (
    <div className="space-y-6">
      {/* Top Header */}
      <div
        className="p-5 rounded-2xl border flex flex-col sm:flex-row sm:items-center justify-between gap-4"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="p-1.5 rounded-lg bg-blue-500/10 text-blue-600 dark:text-blue-400">
              <UserCheck className="h-5 w-5" />
            </span>
            <h1 className="text-xl sm:text-2xl font-bold tracking-tight" style={{ color: 'var(--text-primary)' }}>
              {t.customerPortalTitle}
            </h1>
          </div>
          <p className="text-xs sm:text-sm" style={{ color: 'var(--text-secondary)' }}>
            {t.customerPortalSubtitle}
          </p>
        </div>

        <div className="flex items-center gap-2">
          <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold bg-emerald-500/10 text-emerald-700 dark:text-emerald-400 border border-emerald-500/20">
            <ShieldCheck className="h-4 w-4" />
            {t.escrowProtected}
          </span>
        </div>
      </div>

      {/* Active Service Requests & OTP Display */}
      <div
        className="rounded-2xl border p-5 sm:p-6"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base sm:text-lg font-bold" style={{ color: 'var(--text-primary)' }}>
            {t.activeRequests}
          </h2>
          <span
            className="text-xs px-2.5 py-0.5 rounded-full font-medium"
            style={{ backgroundColor: 'var(--bg-canvas)', color: 'var(--text-secondary)' }}
          >
            {activeBookings.length} {language === 'bn' ? 'চলমান' : 'Active'}
          </span>
        </div>

        {activeBookings.length === 0 ? (
          <EmptyPanel
            title={t.noRequestsTitle}
            description={t.noRequestsDesc}
          />
        ) : (
          <div className="space-y-4">
            {activeBookings.map((b) => (
              <div
                key={b.id}
                className="rounded-xl border p-4 sm:p-5 flex flex-col md:flex-row md:items-center justify-between gap-4"
                style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
              >
                <div className="space-y-1.5">
                  <div className="flex items-center gap-2">
                    <span className="font-mono-code text-xs font-semibold px-2 py-0.5 rounded bg-blue-500/10 text-blue-600 dark:text-blue-400">
                      {b.bookingRef}
                    </span>
                    <h3 className="font-bold text-sm" style={{ color: 'var(--text-primary)' }}>
                      {b.serviceTitle}
                    </h3>
                  </div>
                  <p className="text-xs" style={{ color: 'var(--text-secondary)' }}>
                    {language === 'bn' ? 'নিয়োজিত টেকনিশিয়ান:' : 'Assigned Specialist:'} {b.workerName} · {b.scheduledAt}
                  </p>
                </div>

                {/* Secure OTP Card */}
                <div className="p-3.5 rounded-xl border border-blue-200 dark:border-blue-900/60 bg-blue-50/50 dark:bg-blue-950/20 max-w-sm">
                  <div className="flex items-center gap-2 text-xs font-semibold text-blue-800 dark:text-blue-300 mb-1">
                    <KeyRound className="h-4 w-4" />
                    <span>{t.yourArrivalOtp}: <strong className="font-mono-code text-base text-blue-700 dark:text-blue-400">{b.arrivalOtp}</strong></span>
                  </div>
                  <p className="text-[11px] leading-relaxed text-blue-700/80 dark:text-blue-300/70">
                    {t.shareOtpWithWorker}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Completed Orders & Certified Receipts */}
      <div
        className="rounded-2xl border p-5 sm:p-6"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base sm:text-lg font-bold" style={{ color: 'var(--text-primary)' }}>
            {t.completedBookings}
          </h2>
          <span
            className="text-xs px-2.5 py-0.5 rounded-full font-medium"
            style={{ backgroundColor: 'var(--bg-canvas)', color: 'var(--text-secondary)' }}
          >
            {pastBookings.length} {language === 'bn' ? 'সম্পন্ন' : 'Completed'}
          </span>
        </div>

        {pastBookings.length === 0 ? (
          <EmptyPanel
            title={language === 'bn' ? 'কোনো পূর্ববর্তী অর্ডার নেই' : 'No Past Orders Recorded'}
            description={
              language === 'bn'
                ? 'আপনার সম্পন্ন সেবাসমূহ ও অফিসিয়াল ট্যাক্স রসিদ এখানে সংরক্ষিত হবে।'
                : 'Your completed service orders and certified VAT invoices will appear here upon job signoff.'
            }
          />
        ) : (
          <div className="space-y-3">
            {pastBookings.map((b) => (
              <div
                key={b.id}
                className="flex items-center justify-between p-3.5 rounded-xl border"
                style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
              >
                <div className="flex items-center gap-3">
                  <FileText className="h-5 w-5 text-slate-400" />
                  <div>
                    <p className="text-xs font-bold" style={{ color: 'var(--text-primary)' }}>
                      {b.serviceTitle} ({b.bookingRef})
                    </p>
                    <p className="text-[11px]" style={{ color: 'var(--text-muted)' }}>
                      {b.scheduledAt}
                    </p>
                  </div>
                </div>
                <button
                  type="button"
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold border transition hover:bg-slate-50 dark:hover:bg-slate-800"
                  style={{ borderColor: 'var(--border-subtle)', color: 'var(--text-primary)' }}
                >
                  <Download className="h-3.5 w-3.5" />
                  <span>{t.downloadReceipt}</span>
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
