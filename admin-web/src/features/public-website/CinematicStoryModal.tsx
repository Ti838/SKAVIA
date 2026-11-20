'use client';

import { useEffect, useState } from 'react';
import {
  ArrowLeft,
  ArrowRight,
  CheckCircle2,
  Download,
  KeyRound,
  MapPin,
  Pause,
  Play,
  ShieldCheck,
  Sparkles,
  X,
  Zap,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import type { PublicThemeTokens } from './public-site-data';

interface StoryScene {
  id: number;
  act: string;
  title: string;
  subtitle: string;
  icon: typeof Zap;
  color: string;
  bullets: string[];
  visualType: 'scope' | 'match' | 'otp' | 'escrow';
}

const STORY_SCENES: StoryScene[] = [
  {
    id: 1,
    act: 'Act 1 · Explain Your Need',
    title: 'No Endless Phone Lists. Instant Scoping.',
    subtitle:
      'Unlike unverified classifieds that leave you negotiating with strangers, describe what outcome you need once inside the SKAVIA app.',
    icon: Sparkles,
    color: '#003399',
    bullets: [
      'Structured task scoping across 8 internal specialization branches',
      'Instant transparent price range guidance before commitment',
      'Zero public phone leakage or spam calls',
    ],
    visualType: 'scope',
  },
  {
    id: 2,
    act: 'Act 2 · Proximity Dispatch',
    title: 'Direct Haversine Matching & Team Leaders',
    subtitle:
      'SKAVIA coordinates either a single background-checked specialist for focused repairs or a multi-skill crew led by a Team Leader for enterprise projects.',
    icon: Zap,
    color: '#15E7CA',
    bullets: [
      'NID and police-clearance verified professional workforce',
      'Live Haversine radius tracking with realistic arrival ETA',
      'Single accountability: SKAVIA stands behind every team',
    ],
    visualType: 'match',
  },
  {
    id: 3,
    act: 'Act 3 · Physical Handshake',
    title: '4-Digit Arrival OTP. Zero Unauthorized Start.',
    subtitle:
      'Work timers and billing only begin after physical arrival at your site and reciprocal verification of the 4-digit cryptographic OTP.',
    icon: KeyRound,
    color: '#3898EC',
    bullets: [
      'Guarantees physical technician presence before any timer starts',
      'Eliminates phantom visits, fake arrivals, and billing disputes',
      'Activates SKAVIA property damage protection instantly upon check-in',
    ],
    visualType: 'otp',
  },
  {
    id: 4,
    act: 'Act 4 · Escrow & Sign-off',
    title: 'Atomic Escrow Protection & Digital Release',
    subtitle:
      'Customer funds are held safely in atomic bank escrow until work is delivered according to standard SOPs and signed off digitally by the client.',
    icon: ShieldCheck,
    color: '#10B981',
    bullets: [
      '90% direct transfer to the technician with zero intermediary broker cuts',
      '10% platform fee covers insurance, operational support, and dispute arbitration',
      'Digital tax invoice and warranty certificate emailed instantly',
    ],
    visualType: 'escrow',
  },
];

export function CinematicStoryModal({
  isOpen,
  onClose,
  t,
  apkUrl = '#download',
}: {
  isOpen: boolean;
  onClose: () => void;
  t: PublicThemeTokens;
  apkUrl?: string;
}) {
  const [currentSceneIdx, setCurrentSceneIdx] = useState(0);
  const [isPlaying, setIsPlaying] = useState(true);
  const [progress, setProgress] = useState(0);

  const scene = STORY_SCENES[currentSceneIdx] ?? STORY_SCENES[0]!;
  const Icon = scene.icon;

  useEffect(() => {
    if (!isOpen || !isPlaying) return;

    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          setCurrentSceneIdx((sc) => (sc + 1) % STORY_SCENES.length);
          return 0;
        }
        return prev + 2;
      });
    }, 100);

    return () => clearInterval(interval);
  }, [isOpen, isPlaying, currentSceneIdx]);

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
      aria-label="How SKAVIA Works Cinematic Tour"
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
                Accountable Service Delivery Experience
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => setIsPlaying(!isPlaying)}
              aria-label={isPlaying ? 'Pause presentation' : 'Play presentation'}
              className="rounded-lg p-2 border hover:bg-slate-100 dark:hover:bg-slate-800 transition"
              style={{ borderColor: 'var(--border-subtle)' }}
            >
              {isPlaying ? <Pause className="h-4 w-4" /> : <Play className="h-4 w-4" />}
            </button>

            <button
              type="button"
              onClick={onClose}
              aria-label="Close presentation"
              className="rounded-lg p-2 border hover:bg-slate-100 dark:hover:bg-slate-800 transition"
              style={{ borderColor: 'var(--border-subtle)' }}
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        </div>

        {/* Story Progress Bars */}
        <div className="grid grid-cols-4 gap-1.5 px-5 sm:px-6 pt-3 pb-2">
          {STORY_SCENES.map((sc, idx) => {
            const isCompleted = idx < currentSceneIdx;
            const isCurrent = idx === currentSceneIdx;
            return (
              <button
                key={sc.id}
                type="button"
                onClick={() => handleSelectScene(idx)}
                className="h-1.5 rounded-full overflow-hidden bg-slate-200 dark:bg-slate-800 transition"
              >
                <div
                  className="h-full bg-gradient-to-r from-[#003399] to-[#15E7CA] transition-all"
                  style={{
                    width: isCompleted ? '100%' : isCurrent ? `${progress}%` : '0%',
                  }}
                />
              </button>
            );
          })}
        </div>

        {/* Main Content Area */}
        <div className="flex-1 overflow-y-auto p-5 sm:p-8 grid grid-cols-1 md:grid-cols-12 gap-8 items-center">
          {/* Left Text Narrative (7 cols) */}
          <div className="md:col-span-7 space-y-4">
            <div className="flex items-center gap-2">
              <span
                className="px-2.5 py-0.5 rounded-full text-[11px] font-mono-code font-bold uppercase tracking-wider"
                style={{ backgroundColor: `${scene.color}15`, color: scene.color }}
              >
                {scene.act}
              </span>
              <span className="text-xs text-slate-400 font-mono-code">
                Scene {currentSceneIdx + 1} of {STORY_SCENES.length}
              </span>
            </div>

            <h2 className="text-2xl sm:text-3xl font-heading font-extrabold tracking-tight">
              {scene.title}
            </h2>

            <p className="text-sm leading-relaxed text-slate-600 dark:text-slate-300">
              {scene.subtitle}
            </p>

            <ul className="space-y-2.5 pt-2 text-xs sm:text-sm">
              {scene.bullets.map((b, i) => (
                <li key={i} className="flex items-start gap-2.5 text-slate-700 dark:text-slate-200">
                  <CheckCircle2 className="h-4 w-4 text-teal-500 shrink-0 mt-0.5" />
                  <span>{b}</span>
                </li>
              ))}
            </ul>
          </div>

          {/* Right Visual Sandbox (5 cols) */}
          <div className="md:col-span-5 flex justify-center">
            <div
              className="w-full max-w-sm rounded-2xl border p-6 space-y-5 shadow-inner"
              style={{
                backgroundColor: 'var(--bg-surface-subtle)',
                borderColor: 'var(--border-subtle)',
              }}
            >
              <div
                className="h-12 w-12 rounded-2xl flex items-center justify-center text-white shadow-md mx-auto"
                style={{ backgroundColor: scene.color }}
              >
                <Icon className="h-6 w-6" />
              </div>

              {scene.visualType === 'scope' && (
                <div className="space-y-3 text-center">
                  <div className="p-3 rounded-xl border bg-white dark:bg-slate-900 border-slate-200 dark:border-slate-800 text-xs font-mono-code text-teal-500">
                    &ldquo;Inverter AC chemical wash + gas pressure diagnostic&rdquo;
                  </div>
                  <p className="text-[11px] text-slate-400">
                    Engine maps to SKAVIA Technical &middot; Upfront ৳ 1,500 – ৳ 2,500
                  </p>
                </div>
              )}

              {scene.visualType === 'match' && (
                <div className="space-y-3 text-center">
                  <div className="flex items-center justify-center gap-2 text-xs font-bold text-slate-800 dark:text-slate-200">
                    <MapPin className="h-4 w-4 text-[#3898EC]" />
                    <span>Specialist 2.1 km away &middot; ETA 18 mins</span>
                  </div>
                  <div className="h-2 w-full bg-slate-200 dark:bg-slate-800 rounded-full overflow-hidden">
                    <div className="h-full bg-[#15E7CA] w-2/3 animate-pulse" />
                  </div>
                  <p className="text-[11px] text-slate-400">
                    Level-3 Certified Specialist &middot; NID Biometric Verified
                  </p>
                </div>
              )}

              {scene.visualType === 'otp' && (
                <div className="space-y-3 text-center">
                  <p className="text-xs text-slate-400 font-mono-code">Confidential Arrival OTP:</p>
                  <div className="inline-flex gap-2 text-2xl font-mono-code font-bold text-teal-400 tracking-widest bg-slate-900 px-4 py-2 rounded-xl border border-teal-500/30 shadow-inner">
                    <span>8</span>
                    <span>4</span>
                    <span>2</span>
                    <span>1</span>
                  </div>
                  <p className="text-[11px] text-slate-400">
                    Technician enters upon physical door presence
                  </p>
                </div>
              )}

              {scene.visualType === 'escrow' && (
                <div className="space-y-3 text-center">
                  <div className="flex justify-between text-xs font-mono-code p-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800">
                    <span>Specialist Payout (90%)</span>
                    <span className="text-emerald-500 font-bold">৳ 2,250</span>
                  </div>
                  <div className="flex justify-between text-xs font-mono-code p-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800">
                    <span>SKAVIA Operations (10%)</span>
                    <span className="text-blue-500 font-bold">৳ 250</span>
                  </div>
                  <p className="text-[11px] text-slate-400">
                    Atomic release committed upon customer digital signature
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Bottom Control Footer */}
        <div
          className="flex items-center justify-between px-5 sm:px-6 py-4 border-t flex-wrap gap-3"
          style={{
            borderColor: 'var(--border-subtle)',
            backgroundColor: 'var(--bg-surface)',
          }}
        >
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={handlePrev}
              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl border text-xs font-semibold hover:bg-slate-100 dark:hover:bg-slate-800 transition"
              style={{ borderColor: 'var(--border-subtle)' }}
            >
              <ArrowLeft className="h-3.5 w-3.5" />
              <span>Previous</span>
            </button>

            <button
              type="button"
              onClick={handleNext}
              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl border text-xs font-semibold hover:bg-slate-100 dark:hover:bg-slate-800 transition"
              style={{ borderColor: 'var(--border-subtle)' }}
            >
              <span>Next</span>
              <ArrowRight className="h-3.5 w-3.5" />
            </button>
          </div>

          <a
            href={apkUrl}
            onClick={onClose}
            className="inline-flex items-center gap-2 px-5 py-2 rounded-xl text-xs font-bold text-white bg-[#003399] hover:bg-[#002266] transition shadow-md"
          >
            <Download className="h-3.5 w-3.5" />
            <span>Download SKAVIA Android App</span>
          </a>
        </div>
      </div>
    </div>
  );
}
