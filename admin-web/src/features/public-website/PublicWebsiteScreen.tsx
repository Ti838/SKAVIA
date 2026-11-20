'use client';

import { useState } from 'react';
import {
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
import { PublicPageShell } from './components/PublicPageShell';

export function PublicWebsiteScreen({
  initialDistribution = INITIAL_DISTRIBUTION,
}: {
  initialDistribution?: DistributionInfo;
}) {
  const [activeTab, setActiveTab] = useState<WorkflowTab>('requirement');
  const [selectedBranchCode, setSelectedBranchCode] = useState<string>('HOME');
  const [openFaq, setOpenFaq] = useState<number | null>(0);
  const distribution = initialDistribution;

  return (
    <PublicPageShell>
      {(t) => (
        <>
          <HeroSection t={t} />
          <BranchesSection
            t={t}
            selectedBranchCode={selectedBranchCode}
            onSelectBranch={setSelectedBranchCode}
          />
          <WorkflowSection t={t} activeTab={activeTab} onSelectTab={setActiveTab} />
          <SolutionsSection t={t} />
          <WorkerAndFeaturesSection t={t} />
          <DownloadSection t={t} distribution={distribution} />
          <FaqAndContactSection
            t={t}
            openFaq={openFaq}
            onToggleFaq={(idx) => setOpenFaq((prev) => (prev === idx ? null : idx))}
          />
        </>
      )}
    </PublicPageShell>
  );
}
