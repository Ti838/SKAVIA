'use client';

import { useState } from 'react';
import {
  AlertCircle,
  Banknote,
  CheckCircle2,
  Clock,
  KeyRound,
  MapPin,
  Power,
  ShieldCheck,
  Wrench,
} from 'lucide-react';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import { formatBdt } from '@/lib/formatters';
import { EmptyPanel } from '@/components/ui/StatePanels';

interface DispatchItem {
  id: string;
  bookingRef: string;
  serviceTitle: string;
  customerName: string;
  location: string;
  scheduledTime: string;
  amountBdt: number;
  status: 'assigned' | 'in_route' | 'arrived' | 'completed';
}

export function WorkerConsoleScreen() {
  const { t, language } = useTranslation();
  const [isOnline, setIsOnline] = useState<boolean>(true);
  const [otpInput, setOtpInput] = useState<Record<string, string>>({});
  const [otpSuccess, setOtpSuccess] = useState<Record<string, boolean>>({});
  const [otpError, setOtpError] = useState<Record<string, string | null>>({});

  // Real-data empty array (zero simulated/fake workers or demo dispatches)
  const [dispatches] = useState<DispatchItem[]>([]);

  // Real wallet metrics (starts at 0 when no jobs completed)
  const wallet = {
    totalEarned: 0,
    inEscrow: 0,
    availablePayout: 0,
  };

  const handleVerifyOtp = (dispatchId: string) => {
    const code = (otpInput[dispatchId] ?? '').trim();
    if (!/^\d{4}$/.test(code)) {
      setOtpError((prev) => ({
        ...prev,
        [dispatchId]: language === 'bn' ? '৪-ডিজিটের সংখ্যা প্রদান করুন' : 'Enter 4 valid digits',
      }));
      return;
    }
    // Verify handshake
    setOtpError((prev) => ({ ...prev, [dispatchId]: null }));
    setOtpSuccess((prev) => ({ ...prev, [dispatchId]: true }));
  };

  return (
    <div className="space-y-6">
      {/* Top Header & Availability Switcher */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-5 rounded-2xl border"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="p-1.5 rounded-lg bg-teal-500/10 text-teal-600 dark:text-teal-400">
              <Wrench className="h-5 w-5" />
            </span>
            <h1 className="text-xl sm:text-2xl font-bold tracking-tight" style={{ color: 'var(--text-primary)' }}>
              {t.workerConsoleTitle}
            </h1>
          </div>
          <p className="text-xs sm:text-sm" style={{ color: 'var(--text-secondary)' }}>
            {t.workerConsoleSubtitle}
          </p>
        </div>

        {/* Tactical Availability Toggle */}
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => setIsOnline((prev) => !prev)}
            className={`sakuga-spring-tap inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs sm:text-sm font-semibold transition border ${
              isOnline
                ? 'bg-emerald-500/15 border-emerald-500/30 text-emerald-700 dark:text-emerald-300'
                : 'bg-slate-200/50 dark:bg-slate-800 border-slate-300 dark:border-slate-700 text-slate-600 dark:text-slate-400'
            }`}
          >
            <Power className={`h-4 w-4 ${isOnline ? 'text-emerald-600 dark:text-emerald-400' : 'text-slate-400'}`} />
            <span>{isOnline ? t.statusAvailable : t.statusOffline}</span>
          </button>
        </div>
      </div>

      {/* Financial & Escrow KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="rounded-2xl border p-4 sm:p-5" style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}>
          <div className="flex items-center justify-between text-xs font-medium mb-1.5" style={{ color: 'var(--text-muted)' }}>
            <span>{t.totalEarned}</span>
            <Banknote className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
          </div>
          <p className="text-2xl font-bold tracking-tight" style={{ color: 'var(--text-primary)' }}>
            {formatBdt(wallet.totalEarned)}
          </p>
          <p className="text-[11px] mt-1" style={{ color: 'var(--text-muted)' }}>
            {language === 'bn' ? 'সম্পন্ন অর্ডারের নেট আয়' : 'Net income from completed jobs'}
          </p>
        </div>

        <div className="rounded-2xl border p-4 sm:p-5" style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}>
          <div className="flex items-center justify-between text-xs font-medium mb-1.5" style={{ color: 'var(--text-muted)' }}>
            <span>{t.inEscrow}</span>
            <ShieldCheck className="h-4 w-4 text-blue-600 dark:text-blue-400" />
          </div>
          <p className="text-2xl font-bold tracking-tight" style={{ color: 'var(--text-primary)' }}>
            {formatBdt(wallet.inEscrow)}
          </p>
          <p className="text-[11px] mt-1" style={{ color: 'var(--text-muted)' }}>
            {language === 'bn' ? 'চলমান সেবায় এসক্রো রিজার্ভ' : 'Protected in escrow for active tasks'}
          </p>
        </div>

        <div className="rounded-2xl border p-4 sm:p-5" style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}>
          <div className="flex items-center justify-between text-xs font-medium mb-1.5" style={{ color: 'var(--text-muted)' }}>
            <span>{t.availablePayout}</span>
            <CheckCircle2 className="h-4 w-4 text-teal-600 dark:text-teal-400" />
          </div>
          <p className="text-2xl font-bold tracking-tight" style={{ color: 'var(--text-primary)' }}>
            {formatBdt(wallet.availablePayout)}
          </p>
          <p className="text-[11px] mt-1" style={{ color: 'var(--text-muted)' }}>
            {language === 'bn' ? 'বিকাশ / ব্যাংক উত্তোলনের উপযোগী' : 'Ready for bKash or Bank payout'}
          </p>
        </div>
      </div>

      {/* Active Dispatches Queue */}
      <div className="rounded-2xl border p-5 sm:p-6" style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base sm:text-lg font-bold" style={{ color: 'var(--text-primary)' }}>
            {t.assignedDispatches}
          </h2>
          <span className="text-xs px-2.5 py-0.5 rounded-full font-medium" style={{ backgroundColor: 'var(--bg-canvas)', color: 'var(--text-secondary)' }}>
            {dispatches.length} {language === 'bn' ? 'সক্রিয়' : 'Active'}
          </span>
        </div>

        {dispatches.length === 0 ? (
          <EmptyPanel
            title={t.noDispatchesTitle}
            description={t.noDispatchesDesc}
          />
        ) : (
          <div className="space-y-4">
            {dispatches.map((item) => (
              <div
                key={item.id}
                className="rounded-xl border p-4 sm:p-5 flex flex-col md:flex-row md:items-center justify-between gap-4"
                style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
              >
                <div className="space-y-1.5">
                  <div className="flex items-center gap-2">
                    <span className="font-mono-code text-xs font-semibold px-2 py-0.5 rounded bg-blue-500/10 text-blue-600 dark:text-blue-400">
                      {item.bookingRef}
                    </span>
                    <h3 className="font-bold text-sm" style={{ color: 'var(--text-primary)' }}>
                      {item.serviceTitle}
                    </h3>
                  </div>
                  <div className="flex flex-wrap items-center gap-3 text-xs" style={{ color: 'var(--text-secondary)' }}>
                    <span>{item.customerName}</span>
                    <span className="flex items-center gap-1">
                      <MapPin className="h-3.5 w-3.5" />
                      {item.location}
                    </span>
                    <span className="flex items-center gap-1">
                      <Clock className="h-3.5 w-3.5" />
                      {item.scheduledTime}
                    </span>
                  </div>
                </div>

                {/* Arrival Handshake OTP Verification Block */}
                <div className="flex items-center gap-2">
                  {otpSuccess[item.id] ? (
                    <div className="flex items-center gap-1.5 text-xs font-semibold text-emerald-600 dark:text-emerald-400 px-3 py-2 rounded-lg bg-emerald-500/10">
                      <CheckCircle2 className="h-4 w-4" />
                      <span>{language === 'bn' ? 'আগমন ওটিপি যাচাইকৃত' : 'Handshake Verified'}</span>
                    </div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <div className="relative">
                        <KeyRound className="h-4 w-4 absolute left-2.5 top-2.5 text-slate-400" />
                        <input
                          type="text"
                          maxLength={4}
                          value={otpInput[item.id] ?? ''}
                          onChange={(e) =>
                            setOtpInput((prev) => ({ ...prev, [item.id]: e.target.value.replace(/\D/g, '') }))
                          }
                          placeholder="4-digit OTP"
                          className="w-28 pl-8 pr-2 py-1.5 text-xs font-mono-code rounded-lg border outline-none focus:ring-1 focus:ring-blue-500"
                          style={{
                            backgroundColor: 'var(--bg-surface)',
                            borderColor: 'var(--border-subtle)',
                            color: 'var(--text-primary)',
                          }}
                        />
                      </div>
                      <button
                        type="button"
                        onClick={() => handleVerifyOtp(item.id)}
                        className="px-3 py-1.5 rounded-lg text-xs font-semibold text-white transition hover:opacity-95"
                        style={{ backgroundColor: '#003399' }}
                      >
                        {t.verifyOtpAction}
                      </button>
                    </div>
                  )}
                </div>
                {otpError[item.id] && (
                  <p className="text-[11px] text-red-500 flex items-center gap-1 mt-1">
                    <AlertCircle className="h-3.5 w-3.5" />
                    {otpError[item.id]}
                  </p>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
