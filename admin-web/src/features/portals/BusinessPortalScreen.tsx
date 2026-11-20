'use client';

import { useState } from 'react';
import {
  Briefcase,
  Building2,
} from 'lucide-react';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import { EmptyPanel } from '@/components/ui/StatePanels';

interface CorporateProject {
  id: string;
  projectCode: string;
  title: string;
  branchName: string;
  leadArchitect: string;
  progressPercent: number;
  status: 'planning' | 'active' | 'milestone_review' | 'completed';
  milestonesCount: number;
  completedMilestones: number;
}

export function BusinessPortalScreen() {
  const { t, language } = useTranslation();

  // Zero simulated corporate projects - starts honestly empty in production
  const [projects] = useState<CorporateProject[]>([]);

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
            <span className="p-1.5 rounded-lg bg-indigo-500/10 text-indigo-600 dark:text-indigo-400">
              <Building2 className="h-5 w-5" />
            </span>
            <h1 className="text-xl sm:text-2xl font-bold tracking-tight" style={{ color: 'var(--text-primary)' }}>
              {t.businessPortalTitle}
            </h1>
          </div>
          <p className="text-xs sm:text-sm" style={{ color: 'var(--text-secondary)' }}>
            {t.businessPortalSubtitle}
          </p>
        </div>

        <div className="flex items-center gap-2">
          <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold bg-blue-500/10 text-blue-700 dark:text-blue-400 border border-blue-500/20">
            <Briefcase className="h-4 w-4" />
            {language === 'bn' ? 'কর্পোরেট এসএলএ চুক্তি' : 'Corporate SLA Contract'}
          </span>
        </div>
      </div>

      {/* Turnkey Commercial Projects */}
      <div
        className="rounded-2xl border p-5 sm:p-6"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base sm:text-lg font-bold" style={{ color: 'var(--text-primary)' }}>
            {t.corporateProjects}
          </h2>
          <span
            className="text-xs px-2.5 py-0.5 rounded-full font-medium"
            style={{ backgroundColor: 'var(--bg-canvas)', color: 'var(--text-secondary)' }}
          >
            {projects.length} {language === 'bn' ? 'প্রকল্প' : 'Projects'}
          </span>
        </div>

        {projects.length === 0 ? (
          <EmptyPanel
            title={t.noProjectsTitle}
            description={t.noProjectsDesc}
          />
        ) : (
          <div className="space-y-4">
            {projects.map((p) => (
              <div
                key={p.id}
                className="rounded-xl border p-4 sm:p-5 space-y-3"
                style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
              >
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                  <div className="flex items-center gap-2">
                    <span className="font-mono-code text-xs font-semibold px-2 py-0.5 rounded bg-indigo-500/10 text-indigo-600 dark:text-indigo-400">
                      {p.projectCode}
                    </span>
                    <h3 className="font-bold text-sm" style={{ color: 'var(--text-primary)' }}>
                      {p.title}
                    </h3>
                  </div>
                  <span className="text-xs font-medium px-2.5 py-0.5 rounded-full bg-slate-200 dark:bg-slate-800 text-slate-700 dark:text-slate-300 self-start sm:self-auto">
                    {p.branchName}
                  </span>
                </div>

                {/* Progress bar */}
                <div>
                  <div className="flex justify-between text-xs mb-1" style={{ color: 'var(--text-muted)' }}>
                    <span>{language === 'bn' ? 'অগ্রগতি' : 'Progress'}</span>
                    <span>{p.progressPercent}%</span>
                  </div>
                  <div className="h-2 w-full rounded-full bg-slate-200 dark:bg-slate-700 overflow-hidden">
                    <div
                      className="h-full bg-indigo-600 dark:bg-indigo-400 rounded-full transition-all duration-300"
                      style={{ width: `${p.progressPercent}%` }}
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Corporate Invoices & VAT Statements */}
      <div
        className="rounded-2xl border p-5 sm:p-6"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base sm:text-lg font-bold" style={{ color: 'var(--text-primary)' }}>
            {t.corporateBilling}
          </h2>
        </div>

        <EmptyPanel
          title={language === 'bn' ? 'কোনো অমীমাংসিত চালান নেই' : 'No Pending Corporate Invoices'}
          description={
            language === 'bn'
              ? 'আপনার প্রতিষ্ঠানের সমস্ত মাসিক বিলিং বিবরণী এবং সরকারি ভ্যাট চালান এখানে উপলব্ধ হবে।'
              : 'All monthly consolidated billing statements and certified VAT invoices will appear here.'
          }
        />
      </div>
    </div>
  );
}
