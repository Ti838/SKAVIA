'use client';

import { useState } from 'react';
import {
  getPublicThemeTokens,
  INITIAL_DISTRIBUTION,
  type DistributionInfo,
  type WorkflowTab,
} from './public-site-data';
import {
  BranchesSection,
  HeroSection,
  PublicHeader,
  SolutionsSection,
  WorkflowSection,
} from './PublicWorkflowSections';
import {
  DownloadSection,
  FaqAndContactSection,
  PublicFooter,
  WorkerAndFeaturesSection,
} from './PublicEcosystemSections';

export function PublicWebsiteScreen({
  initialDistribution = INITIAL_DISTRIBUTION,
}: {
  initialDistribution?: DistributionInfo;
}) {
  const [dark, setDark] = useState(true);
  const [activeTab, setActiveTab] = useState<WorkflowTab>('requirement');
  const [selectedBranchCode, setSelectedBranchCode] = useState<string>('HOME');
  const [openFaq, setOpenFaq] = useState<number | null>(0);
  const distribution = initialDistribution;

  const t = getPublicThemeTokens(dark);

  return (
    <div
      className={`min-h-screen transition-colors duration-300 overflow-x-clip ${
        dark ? 'bg-[#03050A] text-white' : 'bg-[#FAFAFA] text-slate-950'
      }`}
    >
      <PublicHeader t={t} onToggleTheme={() => setDark((prev) => !prev)} />

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
        <PublicFooter t={t} />
      </main>
    </div>
  );
}
