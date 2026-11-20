'use client';

import { useEffect, useState } from 'react';
import {
  getPublicThemeTokens,
  INITIAL_DISTRIBUTION,
  type DistributionInfo,
  type WorkflowTab,
} from './public-site-data';
import {
  BranchesSection,
  HeroSection,
  SolutionsSection,
  WorkflowSection,
} from './PublicWorkflowSections';
import {
  DownloadSection,
  FaqAndContactSection,
  WorkerAndFeaturesSection,
} from './PublicEcosystemSections';
import { PublicHeader } from '@/components/navigation/PublicHeader';
import { PublicFooter } from '@/components/navigation/PublicFooter';

export function PublicWebsiteScreen({
  initialDistribution = INITIAL_DISTRIBUTION,
}: {
  initialDistribution?: DistributionInfo;
}) {
  const [themePreference, setThemePreference] = useState<'system' | 'light' | 'dark'>('system');
  const [isSystemDark, setIsSystemDark] = useState<boolean>(true);
  const [activeTab, setActiveTab] = useState<WorkflowTab>('requirement');
  const [selectedBranchCode, setSelectedBranchCode] = useState<string>('HOME');
  const [openFaq, setOpenFaq] = useState<number | null>(0);
  const distribution = initialDistribution;

  // 1. Detect System OS Theme & sync with localStorage
  useEffect(() => {
    try {
      const savedTheme = localStorage.getItem('skavia-theme');
      if (savedTheme === 'light' || savedTheme === 'dark' || savedTheme === 'system') {
        setThemePreference(savedTheme);
      }
      if (window.matchMedia) {
        setIsSystemDark(window.matchMedia('(prefers-color-scheme: dark)').matches);
      }
    } catch {}

    // Listen for automatic system OS theme changes dynamically
    const mediaQuery = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;
    const handleChange = (e: MediaQueryListEvent) => {
      setIsSystemDark(e.matches);
    };

    mediaQuery?.addEventListener('change', handleChange);
    return () => mediaQuery?.removeEventListener('change', handleChange);
  }, []);

  // Compute effective dark mode:
  // If user chooses 'system', it dynamically reacts to OS system dark/light mode
  const effectiveDark =
    themePreference === 'system' ? isSystemDark : themePreference === 'dark';

  // 2. Synchronize html class and data-theme
  useEffect(() => {
    try {
      if (effectiveDark) {
        document.documentElement.classList.add('dark');
        document.documentElement.setAttribute('data-theme', 'dark');
      } else {
        document.documentElement.classList.remove('dark');
        document.documentElement.setAttribute('data-theme', 'light');
      }
    } catch {}
  }, [effectiveDark]);

  const handleCycleTheme = () => {
    let nextPreference: 'system' | 'light' | 'dark';
    if (themePreference === 'system') {
      nextPreference = 'light';
    } else if (themePreference === 'light') {
      nextPreference = 'dark';
    } else {
      nextPreference = 'system';
    }
    setThemePreference(nextPreference);
    try {
      localStorage.setItem('skavia-theme', nextPreference);
    } catch {}
  };

  const t = getPublicThemeTokens(effectiveDark);

  return (
    <div
      className={`min-h-screen transition-colors duration-300 overflow-x-clip ${
        effectiveDark ? 'bg-[#03050A] text-white' : 'bg-[#FAFAFA] text-slate-950'
      }`}
    >
      <PublicHeader
        themeMode={themePreference}
        onCycleTheme={handleCycleTheme}
      />

      <main className={`max-w-[1200px] mx-auto border-x ${t.railBorder}`}>
        <HeroSection t={t} />
        <WorkflowSection t={t} activeTab={activeTab} onSelectTab={setActiveTab} />
        <BranchesSection
          t={t}
          selectedBranchCode={selectedBranchCode}
          onSelectBranch={setSelectedBranchCode}
        />
        <SolutionsSection t={t} />
        <WorkerAndFeaturesSection t={t} />
        <DownloadSection t={t} distribution={distribution} />
        <FaqAndContactSection
          t={t}
          openFaq={openFaq}
          onToggleFaq={(idx) => setOpenFaq((prev) => (prev === idx ? null : idx))}
        />
        <PublicFooter />
      </main>
    </div>
  );
}
