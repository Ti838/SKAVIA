'use client';

import Link from 'next/link';
import { Home, LogIn, ShieldAlert } from 'lucide-react';
import { useTranslation } from '@/lib/l10n/LanguageContext';

export function AccessDeniedScreen() {
  const { isBengali } = useTranslation();

  return (
    <div className="min-h-screen relative flex items-center justify-center p-4 sm:p-6 bg-[#05080F] text-slate-100 skavia-subtle-mesh-dark">
      {/* Ambient Red/Blue Accent */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[300px] bg-gradient-to-tr from-rose-500/15 via-[#003399]/15 to-transparent rounded-full blur-3xl pointer-events-none" />

      <div className="relative z-10 max-w-lg w-full rounded-3xl border border-rose-500/30 bg-[#0A0F1C]/90 backdrop-blur-xl p-6 sm:p-8 text-center space-y-6 shadow-2xl">
        <div className="flex justify-center">
          <div className="h-16 w-16 rounded-2xl border border-rose-500/30 bg-rose-500/10 flex items-center justify-center shadow-lg shadow-rose-950/40">
            <ShieldAlert className="h-8 w-8 text-rose-400" />
          </div>
        </div>

        <div className="space-y-2">
          <div className="inline-flex items-center gap-2 rounded-full border border-rose-500/30 bg-rose-500/10 px-3 py-1 text-[11px] font-mono-code font-semibold text-rose-300">
            <span className="h-1.5 w-1.5 rounded-full bg-rose-400 animate-pulse" />
            <span>403 &middot; {isBengali ? 'নিরাপত্তা সীমা সুরক্ষা' : 'Security Boundary Enforced'}</span>
          </div>

          <h1 className="font-heading text-xl sm:text-2xl font-bold text-white tracking-tight">
            {isBengali ? 'প্রবেশাধিকার সংরক্ষিত / প্রত্যাখ্যান' : 'Portal Surface Access Denied'}
          </h1>

          <p className="text-xs sm:text-sm text-slate-300 leading-relaxed max-w-md mx-auto">
            {isBengali
              ? 'আপনি যে রুটটিতে প্রবেশের চেষ্টা করেছেন তা আপনার বর্তমান ভূমিকা বা পোর্টাল পৃষ্ঠার অনুমোদনের বাইরে। নিরাপত্তা নীতির কারণে এই অনুরোধটি ব্লক করা হয়েছে।'
              : 'You attempted to access an administrative route outside your assigned portal surface or role authorization boundary. Zero-trust fail-closed security has blocked this request.'}
          </p>
        </div>

        <div className="pt-2 flex flex-col sm:flex-row items-center justify-center gap-3">
          <Link
            href="/login"
            className="sakuga-spring-tap w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-xl bg-[#003399] px-5 py-2.5 text-xs font-semibold text-white shadow-md hover:bg-[#00287a] transition"
          >
            <LogIn className="h-4 w-4" />
            <span>{isBengali ? 'অনুমোদিত একাউন্টে লগইন করুন' : 'Authenticate with Authorized Account'}</span>
          </Link>

          <Link
            href="/"
            className="sakuga-spring-tap w-full sm:w-auto inline-flex items-center justify-center gap-2 rounded-xl border border-slate-700 bg-slate-800/80 px-5 py-2.5 text-xs font-semibold text-slate-200 hover:text-white hover:border-slate-600 transition"
          >
            <Home className="h-4 w-4" />
            <span>{isBengali ? 'পাবলিক হোমপেজে যান' : 'Go to Homepage'}</span>
          </Link>
        </div>

        <div className="pt-4 border-t border-slate-800 text-[11px] font-mono-code text-slate-500 flex items-center justify-between">
          <span>SKAVIA RBAC Engine</span>
          <span>Fail-Closed Governance</span>
        </div>
      </div>
    </div>
  );
}
