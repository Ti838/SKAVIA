'use client';

import { useEffect, useState } from 'react';
import {
  ArrowLeft,
  ArrowRight,
  CheckCircle2,
  Clock,
  Download,
  KeyRound,
  MapPin,
  Pause,
  Play,
  RotateCcw,
  ShieldCheck,
  Sparkles,
  X,
  Zap,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import type { PublicThemeTokens } from './public-site-data';

interface StoryScene {
  id: number;
  actEn: string;
  actBn: string;
  titleEn: string;
  titleBn: string;
  subtitleEn: string;
  subtitleBn: string;
  icon: typeof Zap;
  color: string;
  bulletsEn: string[];
  bulletsBn: string[];
  visualType: 'scope' | 'match' | 'otp' | 'escrow';
}

const STORY_SCENES: StoryScene[] = [
  {
    id: 1,
    actEn: 'Act 1 · Explain Your Need',
    actBn: 'দৃশ্য ১ · প্রয়োজন জানান',
    titleEn: 'No Endless Phone Lists. Instant Scoping.',
    titleBn: 'অনির্দিষ্ট ফোনের তালিকা নয়। তাৎক্ষণিক রিকোয়ারমেন্ট স্কোপিং।',
    subtitleEn:
      'Unlike unverified classifieds that leave you negotiating with strangers, describe what outcome you need once inside the SKAVIA app.',
    subtitleBn:
      'মধ্যস্বত্বভোগী বা অপরীক্ষিত তালিকার ঝামেলা এড়িয়ে, স্ক্যাভিয়া অ্যাপে আপনার কী সেবা প্রয়োজন তা সংক্ষেপে জানান।',
    icon: Sparkles,
    color: '#003399',
    bulletsEn: [
      'Structured task scoping across 8 internal specialization branches',
      'Instant transparent price range guidance before commitment',
      'Zero public phone leakage or spam calls',
    ],
    bulletsBn: [
      '৮টি অভ্যন্তরীণ বিশেষায়িত শাখার সমন্বয়ে সুস্পষ্ট কাজের পরিধি নির্ধারণ',
      'কাজের পূর্বেই স্বচ্ছ আনুমানিক ব্যয়ের বিবরণী',
      'ব্যক্তিগত ফোন নম্বরের কোনো অপব্যবহার বা অযাচিত কল নেই',
    ],
    visualType: 'scope',
  },
  {
    id: 2,
    actEn: 'Act 2 · Proximity Dispatch',
    actBn: 'দৃশ্য ২ · নিকটবর্তী কর্মী বরাদ্দ',
    titleEn: 'Direct Haversine Matching & Team Leaders',
    titleBn: 'নিকটবর্তী যাচাইকৃত কর্মী ও দক্ষ টিম লিডার',
    subtitleEn:
      'SKAVIA coordinates either a single background-checked specialist for focused repairs or a multi-skill crew led by a Team Leader for enterprise projects.',
    subtitleBn:
      'নির্দিষ্ট মেরামতের জন্য একা স্পেশালিস্ট কিংবা বড় প্রজেক্টের জন্য টিম লিডারের অধীনে সমন্বিত অভিজ্ঞ দল নিয়োজিত হয়।',
    icon: Zap,
    color: '#15E7CA',
    bulletsEn: [
      'NID and police-clearance verified professional workforce',
      'Live Haversine radius tracking with realistic arrival ETA',
      'Single accountability: SKAVIA stands behind every team',
    ],
    bulletsBn: [
      'জাতীয় পরিচয়পত্র ও দক্ষতা যাচাইকৃত পেশাদার কর্মী বাহিনী',
      'দূরত্ব ও ট্রাফিকের ভিত্তিতে বাস্তবসম্মত আগমনের সময় গণনা',
      'একক প্রাতিষ্ঠানিক দায়িত্ব: কাজের সকল পর্যায়ে স্ক্যাভিয়া দায়বদ্ধ',
    ],
    visualType: 'match',
  },
  {
    id: 3,
    actEn: 'Act 3 · Physical Handshake',
    actBn: 'দৃশ্য ৩ · আগমন ও ৪-সংখ্যার ওটিপি',
    titleEn: '4-Digit Arrival OTP. Zero Unauthorized Start.',
    titleBn: '৪-সংখ্যার আগমন ওটিপি। আগমনের পূর্বে কোনো বিলিং নয়।',
    subtitleEn:
      'Work timers and billing only begin after physical arrival at your site and reciprocal verification of the 4-digit cryptographic OTP.',
    subtitleBn:
      'কর্মী কর্মস্থলে সশরীরে পৌঁছানোর পর উভয় পক্ষের উপস্থিতিতে ৪-সংখ্যার ওটিপি মেলানোর পরেই কেবলমাত্র কাজ শুরু হয়।',
    icon: KeyRound,
    color: '#3898EC',
    bulletsEn: [
      'Client verifies worker digital ID and security badge in-person',
      'Worker enters the 4-digit code provided on client mobile screen',
      'Cryptographically marks on-site arrival and activates safety insurance',
    ],
    bulletsBn: [
      'গ্রাহক সরাসরি কর্মীর ডিজিটাল আইডি ও স্ক্যাভিয়া ব্যাজ মিলিয়ে দেখেন',
      'গ্রাহকের মোবাইল স্ক্রিনে প্রদর্শিত ৪-সংখ্যার ওটিপি কর্মী অ্যাপে ইনপুট করেন',
      'নিরাপদ এনক্রিপশনে শারীরিক উপস্থিতি নিশ্চিতের পর কাজ শুরু হয়',
    ],
    visualType: 'otp',
  },
  {
    id: 4,
    actEn: 'Act 4 · Protected Settlement',
    actBn: 'দৃশ্য ৪ · সুরক্ষিত এসক্রো ও সমাপ্তি',
    titleEn: 'Milestone Escrow & Permanent Reputation',
    titleBn: 'ধাপভিত্তিক এসক্রো পেমেন্ট ও স্থায়ী রেটিং',
    subtitleEn:
      'Funds remain safely held in escrow until completion is inspected and signed off by the customer. Honest reviews build lasting worker ratings.',
    subtitleBn:
      'গ্রাহক কাজ পরীক্ষা করে সন্তোষজনক সমাপ্তি নিশ্চিত না করা পর্যন্ত অর্থ নিরাপদ এসক্রোতে থাকে। নিরপেক্ষ রিভিউ কর্মীদের দীর্ঘমেয়াদি সম্মাননা নিশ্চিত করে।',
    icon: ShieldCheck,
    color: '#22C55E',
    bulletsEn: [
      'Zero surprise charges: transparent milestone sign-off',
      'Automated payouts released directly to worker wallet',
      'Verified performance history impacts future dispatch priority',
    ],
    bulletsBn: [
      'কোনো অতিরিক্ত বা লুকানো ফি নেই: ধাপে ধাপে যাচাইকৃত মূল্য পরিশোধ',
      'কাজ সম্পন্নের পর স্বচ্ছ কমিশন বাদে কর্মীদের নিরাপদ ওয়ালেট স্থানান্তর',
      'যাচাইকৃত পারফরম্যান্স হিস্ট্রি পরবর্তী ডিসপ্যাচে কর্মীদের অগ্রাধিকার দেয়',
    ],
    visualType: 'escrow',
  },
];

interface CinematicStoryModalProps {
  isOpen: boolean;
  onClose: () => void;
  t: PublicThemeTokens;
  apkUrl?: string | null;
}

export function CinematicStoryModal({
  isOpen,
  onClose,
  t,
  apkUrl,
}: CinematicStoryModalProps) {
  const { isBengali } = useTranslation();
  const [currentSceneIdx, setCurrentSceneIdx] = useState(0);
  const [isPlaying, setIsPlaying] = useState(true);
  const [progress, setProgress] = useState(0);

  const scene = STORY_SCENES[currentSceneIdx] ?? STORY_SCENES[0]!;

  // Scene auto-advance timer
  useEffect(() => {
    if (!isOpen || !isPlaying) return;

    const intervalMs = 60;
    const totalDurationMs = 6500;
    const step = (intervalMs / totalDurationMs) * 100;

    const timer = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          setCurrentSceneIdx((sc) => (sc + 1) % STORY_SCENES.length);
          return 0;
        }
        return prev + step;
      });
    }, intervalMs);

    return () => clearInterval(timer);
  }, [isOpen, isPlaying, currentSceneIdx]);

  // Reset when modal opens
  useEffect(() => {
    if (isOpen) {
      setCurrentSceneIdx(0);
      setProgress(0);
      setIsPlaying(true);
    }
  }, [isOpen]);

  // Keyboard navigation
  useEffect(() => {
    if (!isOpen) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
      if (e.key === 'ArrowRight' || e.key === ' ') {
        e.preventDefault();
        setCurrentSceneIdx((sc) => (sc + 1) % STORY_SCENES.length);
        setProgress(0);
      }
      if (e.key === 'ArrowLeft') {
        e.preventDefault();
        setCurrentSceneIdx((sc) => (sc - 1 + STORY_SCENES.length) % STORY_SCENES.length);
        setProgress(0);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const handleNext = () => {
    setCurrentSceneIdx((sc) => (sc + 1) % STORY_SCENES.length);
    setProgress(0);
  };

  const handlePrev = () => {
    setCurrentSceneIdx((sc) => (sc - 1 + STORY_SCENES.length) % STORY_SCENES.length);
    setProgress(0);
  };

  const handleSelectScene = (idx: number) => {
    setCurrentSceneIdx(idx);
    setProgress(0);
  };

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label="How SKAVIA Works Cinematic Story"
      className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-6 bg-black/80 backdrop-blur-xl animate-fade-in"
    >
      <div
        className="relative w-full max-w-4xl rounded-3xl border shadow-2xl overflow-hidden flex flex-col max-h-[92vh]"
        style={{
          borderColor: 'var(--border-subtle)',
          backgroundColor: t.dark ? '#070A11' : '#FFFFFF',
          color: 'var(--text-primary)',
        }}
      >
        {/* Top Header Bar */}
        <div
          className="flex items-center justify-between px-5 sm:px-6 py-4 border-b"
          style={{ borderColor: 'var(--border-subtle)' }}
        >
          <div className="flex items-center gap-3">
            <div className="h-9 w-9 rounded-xl bg-[#003399] flex items-center justify-center p-1.5 shadow-sm">
              <SkaviaBrandMark variant="emblem" size={24} priority />
            </div>
            <div>
              <p className="font-heading font-extrabold text-sm tracking-tight text-[#003399] dark:text-[#3898EC]">
                SKAVIA CINEMATIC TOUR
              </p>
              <p className="text-[11px] text-slate-500">
                {isBengali ? 'একক দায়িত্বশীল ডেলিভারি প্রক্রিয়া' : 'Accountable Service Delivery Experience'}
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            aria-label="Close modal"
            className="p-2 rounded-full border text-slate-500 hover:text-slate-900 dark:hover:text-white transition hover:bg-slate-500/10"
            style={{ borderColor: 'var(--border-subtle)' }}
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Story Scrubber Timeline Bar */}
        <div className="grid grid-cols-4 gap-1.5 px-5 sm:px-6 pt-3 pb-1">
          {STORY_SCENES.map((sc, idx) => {
            const isCurrent = currentSceneIdx === idx;
            const isPassed = currentSceneIdx > idx;
            return (
              <button
                key={sc.id}
                type="button"
                onClick={() => handleSelectScene(idx)}
                className="group flex flex-col gap-1 text-left py-1"
              >
                <div className="h-1.5 w-full bg-slate-200 dark:bg-slate-800 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-[#003399] dark:bg-[#3898EC] transition-all duration-100 rounded-full"
                    style={{
                      width: isPassed ? '100%' : isCurrent ? `${progress}%` : '0%',
                    }}
                  />
                </div>
                <span
                  className={`text-[10px] font-mono-code truncate transition ${
                    isCurrent
                      ? 'text-[#003399] dark:text-[#3898EC] font-bold'
                      : 'text-slate-400 group-hover:text-slate-600 dark:group-hover:text-slate-200'
                  }`}
                >
                  {isBengali ? sc.actBn : sc.actEn}
                </span>
              </button>
            );
          })}
        </div>

        {/* Scene Main Presentation */}
        <div className="p-6 sm:p-10 flex-1 overflow-y-auto">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
            {/* Left Narrative Column */}
            <div className="lg:col-span-7 space-y-4">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-blue-500/10 text-blue-600 dark:text-blue-400 border border-blue-500/20">
                <scene.icon className="h-3.5 w-3.5" />
                <span>{isBengali ? scene.actBn : scene.actEn}</span>
              </div>

              <h2 className="font-heading font-extrabold text-2xl sm:text-3xl tracking-tight leading-snug">
                {isBengali ? scene.titleBn : scene.titleEn}
              </h2>

              <p className="text-sm sm:text-base leading-relaxed text-slate-600 dark:text-slate-300">
                {isBengali ? scene.subtitleBn : scene.subtitleEn}
              </p>

              <div className="space-y-2.5 pt-2">
                {(isBengali ? scene.bulletsBn : scene.bulletsEn).map((bullet, bIdx) => (
                  <div key={bIdx} className="flex items-start gap-2.5 text-xs sm:text-sm">
                    <CheckCircle2 className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />
                    <span className="text-slate-600 dark:text-slate-300">{bullet}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Right Interactive Visual Simulation Card */}
            <div className="lg:col-span-5 flex justify-center">
              <div
                className="w-full max-w-[340px] rounded-2xl border p-5 shadow-lg space-y-3 relative overflow-hidden backdrop-blur-md"
                style={{
                  borderColor: 'var(--border-subtle)',
                  backgroundColor: t.dark ? '#0E1424' : '#F8FAFC',
                }}
              >
                {scene.visualType === 'scope' && (
                  <div className="space-y-3">
                    <div className="flex items-center justify-between text-xs border-b pb-2" style={{ borderColor: 'var(--border-subtle)' }}>
                      <span className="font-mono-code text-[11px] text-blue-500 font-semibold">
                        {isBengali ? 'চাহিদা স্কোপিং' : 'Requirement Engine'}
                      </span>
                      <span className="text-[10px] text-emerald-500 font-semibold">
                        ✓ {isBengali ? 'তাৎক্ষণিক গণনা' : 'Estimated'}
                      </span>
                    </div>
                    <div className="p-3 rounded-xl bg-white dark:bg-[#141C30] border border-slate-200 dark:border-white/10 space-y-1.5">
                      <p className="text-[11px] font-semibold">
                        {isBengali ? 'সার্ভিস: এসি কুলিং ও পাওয়ার ডায়াগনস্টিকস' : 'Service: AC Cooling & Diagnostics'}
                      </p>
                      <p className="text-[10px] text-slate-500">
                        {isBengali ? 'শাখা: SKAVIA Technical' : 'Branch: SKAVIA Technical'} &middot; SLA: 45 min
                      </p>
                      <div className="pt-1 flex items-center justify-between text-xs font-bold text-[#003399] dark:text-[#3898EC]">
                        <span>{isBengali ? 'আনুমানিক রেট' : 'Base Est'}:</span>
                        <span>৳ ১,২০০ – ৳ ২,৫০০</span>
                      </div>
                    </div>
                    <p className="text-[10.5px] text-slate-500 text-center">
                      {isBengali ? 'কোনো হিডেন ফি নেই · পূর্বানুমতি ছাড়া অতিরিক্ত চার্জ নেই' : 'No hidden broker fees or unagreed charges'}
                    </p>
                  </div>
                )}

                {scene.visualType === 'match' && (
                  <div className="space-y-3">
                    <div className="flex items-center justify-between text-xs border-b pb-2" style={{ borderColor: 'var(--border-subtle)' }}>
                      <span className="font-mono-code text-[11px] text-blue-500 font-semibold">
                        {isBengali ? 'হাভারসাইন ডিসপ্যাচ' : 'Haversine Dispatch'}
                      </span>
                      <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                    </div>
                    <div className="p-3 rounded-xl bg-white dark:bg-[#141C30] border border-slate-200 dark:border-white/10 space-y-2">
                      <div className="flex items-center gap-2.5">
                        <div className="w-10 h-10 rounded-xl bg-[#003399] text-white flex items-center justify-center font-bold text-xs">
                          ম.র
                        </div>
                        <div>
                          <p className="font-bold text-xs">{isBengali ? 'মো. রফিকুল ইসলাম' : 'Md. Rafiqul Islam'}</p>
                          <p className="text-[10px] text-slate-500">★ 4.95 &middot; NID Verified</p>
                        </div>
                      </div>
                      <div className="flex items-center justify-between text-[10.5px] font-mono-code text-slate-600 dark:text-slate-300 pt-1 border-t border-slate-100 dark:border-white/5">
                        <span className="flex items-center gap-1">
                          <MapPin className="h-3 w-3 text-blue-500" />
                          ০.৮ কিমি
                        </span>
                        <span className="flex items-center gap-1">
                          <Clock className="h-3 w-3 text-blue-500" />
                          ১৪ মিনিট
                        </span>
                      </div>
                    </div>
                  </div>
                )}

                {scene.visualType === 'otp' && (
                  <div className="space-y-3 text-center">
                    <div className="flex items-center justify-between text-xs border-b pb-2" style={{ borderColor: 'var(--border-subtle)' }}>
                      <span className="font-mono-code text-[11px] text-blue-500 font-semibold">
                        {isBengali ? 'আগমন ওটিপি যাচাই' : 'On-Site Arrival OTP'}
                      </span>
                      <span className="text-[10px] text-emerald-500 font-semibold">
                        4-Digit Safe
                      </span>
                    </div>
                    <p className="text-[11px] text-slate-600 dark:text-slate-300">
                      {isBengali ? 'কর্মীকে সরাসরি এই ওটিপি কোডটি প্রদান করুন:' : 'Handshake verification code:'}
                    </p>
                    <div className="flex items-center justify-center gap-2">
                      {['4', '7', '2', '9'].map((digit, idx) => (
                        <span
                          key={idx}
                          className="w-10 h-11 rounded-xl bg-[#003399] text-white font-mono-code font-extrabold text-lg flex items-center justify-center shadow-md border border-blue-400/30"
                        >
                          {digit}
                        </span>
                      ))}
                    </div>
                    <p className="text-[10px] text-emerald-600 dark:text-emerald-400 font-medium">
                      ✓ {isBengali ? 'শারীরিক উপস্থিতি ব্যতিরেকে বিলিং শুরু হয় না' : 'Physical arrival handshake required'}
                    </p>
                  </div>
                )}

                {scene.visualType === 'escrow' && (
                  <div className="space-y-3">
                    <div className="flex items-center justify-between text-xs border-b pb-2" style={{ borderColor: 'var(--border-subtle)' }}>
                      <span className="font-mono-code text-[11px] text-emerald-500 font-semibold">
                        {isBengali ? 'এসক্রো চুক্তি সমাপ্তি' : 'Escrow Protected'}
                      </span>
                      <ShieldCheck className="h-4 w-4 text-emerald-500" />
                    </div>
                    <div className="p-3 rounded-xl bg-white dark:bg-[#141C30] border border-slate-200 dark:border-white/10 space-y-1.5">
                      <div className="flex items-center justify-between text-xs">
                        <span className="text-slate-500">{isBengali ? 'তহবিল অবস্থা' : 'Escrow Status'}:</span>
                        <span className="font-semibold text-emerald-600 dark:text-emerald-400">
                          {isBengali ? 'সুরক্ষিত জমা' : 'Protected in Trust'}
                        </span>
                      </div>
                      <div className="flex items-center justify-between text-xs">
                        <span className="text-slate-500">{isBengali ? 'গ্রাহক অনুমোদন' : 'Sign-Off'}:</span>
                        <span className="font-semibold text-blue-500">{isBengali ? 'সম্পন্ন' : 'Confirmed'}</span>
                      </div>
                      <div className="pt-1.5 border-t border-slate-100 dark:border-white/5 flex items-center justify-between text-sm font-bold text-[#003399] dark:text-[#3898EC]">
                        <span>{isBengali ? 'নিট নিষ্পত্তি' : 'Net Settlement'}:</span>
                        <span className="font-mono-code">৳ ১,২০০</span>
                      </div>
                    </div>
                    <p className="text-[10px] text-slate-500 text-center">
                      {isBengali ? 'স্থায়ী রিভিউ স্কোর ভবিষ্যতের ডিসপ্যাচ নিয়ন্ত্রণ করে' : 'Permanent review ratings establish worker reputation'}
                    </p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Control Bar */}
        <div
          className="px-5 sm:px-6 py-4 border-t flex flex-wrap items-center justify-between gap-3"
          style={{ borderColor: 'var(--border-subtle)' }}
        >
          {/* Playback Controls */}
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => setIsPlaying((p) => !p)}
              className="p-2 rounded-xl border text-slate-600 dark:text-slate-300 hover:text-slate-900 dark:hover:text-white transition"
              style={{ borderColor: 'var(--border-subtle)' }}
              title={isPlaying ? 'Pause tour' : 'Play tour'}
            >
              {isPlaying ? <Pause className="h-4 w-4" /> : <Play className="h-4 w-4" />}
            </button>

            <button
              type="button"
              onClick={() => {
                setCurrentSceneIdx(0);
                setProgress(0);
              }}
              className="p-2 rounded-xl border text-slate-600 dark:text-slate-300 hover:text-slate-900 dark:hover:text-white transition"
              style={{ borderColor: 'var(--border-subtle)' }}
              title="Restart tour"
            >
              <RotateCcw className="h-4 w-4" />
            </button>

            <span className="text-xs font-mono-code text-slate-500 pl-1">
              {currentSceneIdx + 1} / {STORY_SCENES.length}
            </span>
          </div>

          {/* Stepper & Action CTAs */}
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={handlePrev}
              disabled={currentSceneIdx === 0}
              className="px-3 py-1.5 rounded-xl border text-xs font-medium text-slate-600 dark:text-slate-300 hover:bg-slate-500/10 disabled:opacity-40 transition"
              style={{ borderColor: 'var(--border-subtle)' }}
            >
              <ArrowLeft className="h-3.5 w-3.5" />
            </button>

            {currentSceneIdx < STORY_SCENES.length - 1 ? (
              <button
                type="button"
                onClick={handleNext}
                className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#003399] text-white text-xs font-semibold hover:bg-[#00287a] transition shadow-xs"
              >
                <span>{isBengali ? 'পরবর্তী দৃশ্য' : 'Next Scene'}</span>
                <ArrowRight className="h-3.5 w-3.5" />
              </button>
            ) : (
              <a
                href={apkUrl || '#download'}
                onClick={onClose}
                className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-emerald-600 text-white text-xs font-semibold hover:bg-emerald-700 transition shadow-xs"
              >
                <Download className="h-3.5 w-3.5" />
                <span>{isBengali ? 'অ্যাপ ডাউনলোড করুন (২২.৬ এমবি)' : 'Download APK (22.6 MB)'}</span>
              </a>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
