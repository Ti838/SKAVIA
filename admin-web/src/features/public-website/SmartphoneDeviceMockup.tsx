'use client';

import { useState } from 'react';
import Image from 'next/image';
import {
  Battery,
  Clock,
  KeyRound,
  MapPin,
  ShieldCheck,
  Signal,
  Sparkles,
  Users,
  Wifi,
  Wrench,
  Zap,
} from 'lucide-react';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import type { PublicThemeTokens } from './public-site-data';

interface SmartphoneDeviceMockupProps {
  t: PublicThemeTokens;
  version?: string;
  onDownloadClick?: () => void;
}

export function SmartphoneDeviceMockup({
  t,
  version = '1.0.0',
}: SmartphoneDeviceMockupProps) {
  const { isBengali } = useTranslation();
  const [activeScreen, setActiveScreen] = useState<'client' | 'worker'>('client');
  const [phoneDark, setPhoneDark] = useState<boolean>(t.dark);

  return (
    <div className="flex flex-col items-center w-full max-w-[380px] sm:max-w-[420px] mx-auto select-none">
      {/* Interactive Mode Pills on top of device */}
      <div
        className="flex items-center gap-1.5 p-1 rounded-2xl border mb-4 backdrop-blur-md text-xs font-medium shadow-sm"
        style={{
          borderColor: 'var(--border-subtle)',
          backgroundColor: 'var(--bg-surface)',
        }}
      >
        <button
          type="button"
          onClick={() => setActiveScreen('client')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl transition-all ${
            activeScreen === 'client'
              ? 'bg-[#003399] text-white shadow-xs font-semibold'
              : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
          }`}
        >
          <Sparkles className="h-3.5 w-3.5" />
          <span>{isBengali ? 'গ্রাহক মোড' : 'Client Mode'}</span>
        </button>

        <button
          type="button"
          onClick={() => setActiveScreen('worker')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl transition-all ${
            activeScreen === 'worker'
              ? 'bg-[#003399] text-white shadow-xs font-semibold'
              : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
          }`}
        >
          <Wrench className="h-3.5 w-3.5" />
          <span>{isBengali ? 'কর্মী মোড' : 'Worker Mode'}</span>
        </button>

        <button
          type="button"
          onClick={() => setPhoneDark((prev) => !prev)}
          title="Toggle phone theme preview"
          className="px-2 py-1.5 rounded-xl text-[11px] font-mono-code text-slate-500 hover:text-slate-900 dark:hover:text-white transition"
        >
          {phoneDark ? '🌙' : '☀️'}
        </button>
      </div>

      {/* Realistic Flagship Smartphone Chassis */}
      <div className="relative w-full max-w-[340px] sm:max-w-[360px] aspect-[9/18.8] group">
        {/* Ambient Back Glow */}
        <div
          className={`absolute -inset-1.5 rounded-[54px] blur-xl transition-opacity duration-700 pointer-events-none ${
            t.dark
              ? 'bg-gradient-to-tr from-[#003399]/40 via-[#15E7CA]/20 to-[#3898EC]/30 opacity-75 group-hover:opacity-100'
              : 'bg-gradient-to-tr from-[#003399]/20 via-[#3898EC]/20 to-teal-400/20 opacity-60 group-hover:opacity-85'
          }`}
        />

        {/* Side Buttons Hardware Accents */}
        <div className="absolute -left-[3px] top-[105px] w-[3.5px] h-[36px] bg-slate-700 dark:bg-slate-800 rounded-l-sm" />
        <div className="absolute -left-[3px] top-[152px] w-[3.5px] h-[52px] bg-slate-700 dark:bg-slate-800 rounded-l-sm" />
        <div className="absolute -right-[3px] top-[120px] w-[3.5px] h-[48px] bg-slate-700 dark:bg-slate-800 rounded-r-sm" />

        {/* Outer Titanium Chassis */}
        <div className="relative h-full w-full rounded-[48px] sm:rounded-[52px] p-[10px] sm:p-[11px] bg-gradient-to-b from-slate-700 via-slate-900 to-black shadow-[0_25px_60px_-15px_rgba(0,0,0,0.7),0_0_0_1px_rgba(255,255,255,0.12)]">
          {/* Inner Display Surface */}
          <div
            className={`relative h-full w-full rounded-[38px] sm:rounded-[42px] overflow-hidden flex flex-col justify-between transition-colors duration-300 ${
              phoneDark ? 'bg-[#070A11] text-[#EDEFEF]' : 'bg-[#FAFAFA] text-[#0F172A]'
            }`}
          >
            {/* Gloss Reflection Sheen */}
            <div className="absolute inset-0 bg-gradient-to-tr from-white/[0.04] via-transparent to-white/[0.08] pointer-events-none z-30" />

            {/* Top Hardware Notch / Dynamic Island */}
            <div className="relative z-40 pt-2.5 px-6 flex items-center justify-between text-[11px] font-mono-code font-semibold tracking-tight">
              <span className={phoneDark ? 'text-slate-300' : 'text-slate-800'}>09:41</span>

              {/* Dynamic Island Capsule */}
              <div className="h-[20px] w-[88px] bg-black rounded-full flex items-center justify-center gap-2 px-2 shadow-inner">
                <span className="w-2.5 h-2.5 rounded-full bg-slate-900 border border-slate-700/60 flex items-center justify-center">
                  <span className="w-1 h-1 rounded-full bg-blue-500/70" />
                </span>
                <span className="w-1.5 h-1.5 rounded-full bg-slate-900 border border-slate-800" />
              </div>

              {/* Status Icons */}
              <div className={`flex items-center gap-1.5 ${phoneDark ? 'text-slate-300' : 'text-slate-800'}`}>
                <Signal className="h-3 w-3" />
                <Wifi className="h-3 w-3" />
                <Battery className="h-3.5 w-3.5" />
              </div>
            </div>

            {/* App Top Bar */}
            <div
              className={`relative z-20 px-4 pt-2.5 pb-2 border-b flex items-center justify-between transition-colors ${
                phoneDark ? 'bg-[#0E1424]/90 border-white/[0.08]' : 'bg-white/95 border-slate-200'
              }`}
            >
              <div className="flex items-center gap-2">
                <div className="h-7 w-7 rounded-lg bg-[#003399] flex items-center justify-center p-1 shadow-xs">
                  <Image
                    src="/images/skavia_emblem.png"
                    alt="SKAVIA"
                    width={20}
                    height={20}
                    className="object-contain"
                  />
                </div>
                <div>
                  <div className="flex items-center gap-1">
                    <span className="font-heading font-extrabold text-xs tracking-tight text-[#003399] dark:text-[#3898EC]">
                      SKAVIA
                    </span>
                    <span className="text-[9px] font-mono-code px-1 py-0.2 rounded bg-blue-500/10 text-blue-600 dark:text-blue-300 font-semibold">
                      v{version}
                    </span>
                  </div>
                  <p className="text-[9.5px] leading-tight text-slate-500 dark:text-slate-400">
                    {activeScreen === 'client' ? (isBengali ? 'গ্রাহক সেবা হাব' : 'Customer Service') : (isBengali ? 'কর্মী অপারেশনস' : 'Worker Console')}
                  </p>
                </div>
              </div>

              {/* Mode Indicator Pill */}
              <div
                className={`flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold border ${
                  activeScreen === 'client'
                    ? 'border-blue-500/30 bg-blue-500/10 text-blue-600 dark:text-blue-400'
                    : 'border-emerald-500/30 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400'
                }`}
              >
                <span className="w-1.5 h-1.5 rounded-full bg-current animate-pulse" />
                <span>{activeScreen === 'client' ? (isBengali ? 'গ্রাহক' : 'Client') : (isBengali ? 'অনলাইন' : 'Online')}</span>
              </div>
            </div>

            {/* Scrollable Screen Body */}
            <div className="relative z-10 flex-1 px-3.5 py-2.5 space-y-2.5 overflow-hidden text-xs">
              {activeScreen === 'client' ? (
                /* CLIENT MODE SCREEN */
                <>
                  {/* Live Dispatch Tracker Card */}
                  <div
                    className={`rounded-2xl border p-3 shadow-xs space-y-2 transition-colors ${
                      phoneDark ? 'bg-[#0E1424] border-white/[0.08]' : 'bg-white border-slate-200'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <span className="inline-flex items-center gap-1 text-[10px] font-semibold text-[#003399] dark:text-[#3898EC] bg-blue-500/10 px-2 py-0.5 rounded-md">
                        <Zap className="h-2.5 w-2.5" />
                        <span>SKAVIA Technical</span>
                      </span>
                      <span className="text-[10px] font-mono-code text-emerald-600 dark:text-emerald-400 font-semibold flex items-center gap-1">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
                        {isBengali ? 'টেকনিশিয়ান পথে রয়েছেন' : 'Technician Dispatched'}
                      </span>
                    </div>

                    <div className="flex items-center gap-2.5 pt-1">
                      <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#003399] to-[#0A1633] flex items-center justify-center text-white font-bold text-sm shrink-0 border border-white/10">
                        ম.র
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center gap-1.5">
                          <p className="font-semibold text-xs truncate">
                            {isBengali ? 'মো. রফিকুল ইসলাম' : 'Md. Rafiqul Islam'}
                          </p>
                          <ShieldCheck className="h-3 w-3 text-emerald-500 shrink-0" />
                        </div>
                        <p className="text-[10px] text-slate-500 dark:text-slate-400">
                          {isBengali ? 'সার্টিফাইড এইচভ্যাক ও এসি স্পেশালিস্ট' : 'Certified HVAC Specialist'} &middot; ★ 4.95
                        </p>
                      </div>
                    </div>

                    <div
                      className={`grid grid-cols-2 gap-1.5 p-2 rounded-xl text-[10px] border ${
                        phoneDark ? 'bg-[#141C30] border-white/[0.05]' : 'bg-slate-50 border-slate-100'
                      }`}
                    >
                      <div className="flex items-center gap-1 text-slate-600 dark:text-slate-300">
                        <MapPin className="h-3 w-3 text-blue-500 shrink-0" />
                        <span className="truncate">{isBengali ? '০.৮ কিমি দূরে' : '0.8 km away'}</span>
                      </div>
                      <div className="flex items-center gap-1 text-slate-600 dark:text-slate-300">
                        <Clock className="h-3 w-3 text-blue-500 shrink-0" />
                        <span>{isBengali ? '১৪ মিনিটে পৌঁছাবে' : 'ETA: 14 mins'}</span>
                      </div>
                    </div>
                  </div>

                  {/* 4-Digit Handshake OTP Card */}
                  <div
                    className={`rounded-2xl border p-3 text-center space-y-1.5 ${
                      phoneDark
                        ? 'bg-gradient-to-br from-[#003399]/20 to-[#0E1424] border-blue-500/30'
                        : 'bg-gradient-to-br from-blue-50 to-white border-blue-200'
                    }`}
                  >
                    <div className="flex items-center justify-center gap-1 text-[10.5px] font-semibold text-[#003399] dark:text-[#3898EC]">
                      <KeyRound className="h-3.5 w-3.5" />
                      <span>{isBengali ? '৪-সংখ্যার আগমন যাচাই ওটিপি' : '4-Digit Arrival Handshake OTP'}</span>
                    </div>

                    <p className="text-[9.5px] text-slate-500 dark:text-slate-400">
                      {isBengali
                        ? 'টেকনিশিয়ান পৌঁছানোর পর কাজ শুরুর সময় এই কোডটি প্রদান করুন:'
                        : 'Provide this code in person when the technician arrives:'}
                    </p>

                    <div className="flex items-center justify-center gap-2 pt-0.5">
                      {['4', '7', '2', '9'].map((digit, idx) => (
                        <span
                          key={idx}
                          className="w-8 h-9 rounded-lg bg-[#003399] text-white font-mono-code font-extrabold text-base flex items-center justify-center shadow-xs border border-blue-400/40"
                        >
                          {digit}
                        </span>
                      ))}
                    </div>

                    <p className="text-[9px] text-emerald-600 dark:text-emerald-400 font-medium">
                      ✓ {isBengali ? 'ওটিপি যাচাইয়ের পূর্বে বিলিং শুরু হয় না' : 'Billing does not start until OTP verified'}
                    </p>
                  </div>

                  {/* Escrow Milestone Settlement */}
                  <div
                    className={`rounded-xl border p-2.5 flex items-center justify-between text-[10.5px] ${
                      phoneDark ? 'bg-[#0E1424] border-white/[0.08]' : 'bg-white border-slate-200'
                    }`}
                  >
                    <div>
                      <p className="font-semibold text-slate-700 dark:text-slate-200">
                        {isBengali ? 'সুরক্ষিত এসক্রো পেমেন্ট' : 'Escrow Protected Deposit'}
                      </p>
                      <p className="text-[9px] text-slate-500 dark:text-slate-400">
                        {isBengali ? 'কাজ সম্পূর্ণ না হওয়া পর্যন্ত তহবিল সুরক্ষিত' : 'Funds held securely until completion'}
                      </p>
                    </div>
                    <span className="font-bold text-[#003399] dark:text-[#3898EC] font-mono-code">
                      ৳ ১,২০০
                    </span>
                  </div>
                </>
              ) : (
                /* WORKER MODE SCREEN */
                <>
                  {/* Worker Reputation & Earnings Header */}
                  <div
                    className={`rounded-2xl border p-3 space-y-2 ${
                      phoneDark ? 'bg-[#0E1424] border-white/[0.08]' : 'bg-white border-slate-200'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] font-semibold text-emerald-600 dark:text-emerald-400 flex items-center gap-1">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
                        {isBengali ? 'অনলাইন ও সক্রিয়' : 'Online & Active'}
                      </span>
                      <span className="text-[9px] font-mono-code text-slate-400">
                        NID: Verified ★ 4.95
                      </span>
                    </div>

                    <div className="grid grid-cols-2 gap-2 text-center pt-1 border-t border-slate-100 dark:border-white/[0.05]">
                      <div>
                        <p className="text-[9px] text-slate-500">{isBengali ? 'আজকের মোট আয়' : "Today's Earnings"}</p>
                        <p className="text-xs font-bold text-emerald-600 dark:text-emerald-400 font-mono-code">
                          ৳ ৩,৪৫০
                        </p>
                      </div>
                      <div>
                        <p className="text-[9px] text-slate-500">{isBengali ? 'সম্পন্ন কাজ' : 'Completed Jobs'}</p>
                        <p className="text-xs font-bold text-[#003399] dark:text-[#3898EC] font-mono-code">
                          ৩টি
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Incoming Job Dispatch Card */}
                  <div
                    className={`rounded-2xl border p-3 space-y-2 ${
                      phoneDark
                        ? 'bg-gradient-to-br from-blue-950/40 to-[#0E1424] border-blue-500/40'
                        : 'bg-gradient-to-br from-blue-50/80 to-white border-blue-300'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <span className="inline-flex items-center gap-1 rounded bg-amber-500/15 border border-amber-500/30 px-1.5 py-0.2 text-[9.5px] font-semibold text-amber-600 dark:text-amber-400">
                        {isBengali ? 'জরুরি ডিসপ্যাচ' : 'Urgent Dispatch'}
                      </span>
                      <span className="text-[10px] font-mono-code text-slate-500">
                        {isBengali ? '১.২ কিমি দূরে' : '1.2 km away'}
                      </span>
                    </div>

                    <div>
                      <h4 className="font-bold text-xs">
                        {isBengali ? 'এসি কুলিং ও সার্কিট মেরামত' : 'AC Cooling & Circuit Diagnostics'}
                      </h4>
                      <p className="text-[10px] text-slate-500 dark:text-slate-400 flex items-center gap-1 mt-0.5">
                        <MapPin className="h-3 w-3 text-red-500 shrink-0" />
                        <span className="truncate">{isBengali ? 'বসুন্ধরা আবাসিক এলাকা, ব্লক সি' : 'Bashundhara R/A, Block C'}</span>
                      </p>
                    </div>

                    <div className="flex items-center justify-between text-[10px] font-semibold pt-1 border-t border-slate-100 dark:border-white/[0.05]">
                      <span className="text-slate-600 dark:text-slate-300">{isBengali ? 'নিট কর্মী পেআউট' : 'Net Worker Payout'}:</span>
                      <span className="text-emerald-600 dark:text-emerald-400 font-mono-code">৳ ১,৬২০</span>
                    </div>

                    <div className="grid grid-cols-2 gap-1.5 pt-1">
                      <button
                        type="button"
                        className="rounded-lg bg-[#003399] text-white py-1.5 text-[10px] font-semibold text-center hover:bg-[#00287a] transition shadow-xs"
                      >
                        {isBengali ? 'গ্রহণ করুন' : 'Accept Job'}
                      </button>
                      <button
                        type="button"
                        className="rounded-lg border border-slate-300 dark:border-slate-700 py-1.5 text-[10px] font-semibold text-center hover:bg-slate-500/10 transition"
                      >
                        {isBengali ? 'ম্যাপে দেখুন' : 'View Route'}
                      </button>
                    </div>
                  </div>

                  {/* Team Leader & Multi-Worker Coordination Pill */}
                  <div
                    className={`rounded-xl border p-2 flex items-center gap-2 text-[10px] ${
                      phoneDark ? 'bg-[#0E1424] border-white/[0.08]' : 'bg-white border-slate-200'
                    }`}
                  >
                    <Users className="h-3.5 w-3.5 text-blue-500 shrink-0" />
                    <span className="text-slate-600 dark:text-slate-300 leading-tight">
                      {isBengali
                        ? 'টিম লিডার মোড সক্রিয়: মাল্টি-স্পেশালিস্ট দল পরিচালনা করুন'
                        : 'Team Leader Mode enabled: coordinate multi-skill crews'}
                    </span>
                  </div>
                </>
              )}
            </div>

            {/* Bottom Android Gesture Navigation Bar */}
            <div className="relative z-30 pb-2 pt-1 flex items-center justify-center">
              <div className="w-28 h-1 bg-slate-400 dark:bg-slate-600 rounded-full" />
            </div>
          </div>
        </div>
      </div>

      {/* Verified App Hardware Tag */}
      <div
        className="mt-3.5 px-4 py-2 rounded-2xl border flex items-center justify-between gap-3 text-xs w-full max-w-[340px] sm:max-w-[360px]"
        style={{
          borderColor: 'var(--border-subtle)',
          backgroundColor: 'var(--bg-surface)',
        }}
      >
        <span className="inline-flex items-center gap-1.5 font-medium text-slate-600 dark:text-slate-300 text-[11px]">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse shrink-0" />
          <span>{isBengali ? 'অফিসিয়াল অ্যান্ড্রয়েড রিলিজ' : 'Official Android Release'}</span>
        </span>
        <span className="font-mono-code text-[10.5px] text-slate-500 font-semibold">
          ARM64 &middot; v{version}
        </span>
      </div>
    </div>
  );
}
