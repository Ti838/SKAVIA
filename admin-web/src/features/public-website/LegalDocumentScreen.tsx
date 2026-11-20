'use client';

import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { LanguageSwitcher } from '@/components/navigation/LanguageSwitcher';
import { PublicFooter } from '@/components/navigation/PublicFooter';
import { useTranslation } from '@/lib/l10n/LanguageContext';

export interface LegalSection {
  heading: string;
  headingBn?: string;
  body: string;
  bodyBn?: string;
}

export function LegalDocumentScreen({
  title,
  titleBn,
  subtitle,
  subtitleBn,
  sections,
}: {
  title: string;
  titleBn?: string;
  subtitle: string;
  subtitleBn?: string;
  sections: LegalSection[];
}) {
  const { isBengali } = useTranslation();

  return (
    <div
      className="min-h-screen flex flex-col justify-between transition-colors"
      style={{ backgroundColor: 'var(--bg-canvas)', color: 'var(--text-primary)' }}
    >
      <div className="py-8 sm:py-12 px-4 sm:px-6 flex-1">
        <div
          className="max-w-3xl mx-auto rounded-3xl border p-6 sm:p-8 shadow-sm space-y-6"
          style={{
            backgroundColor: 'var(--bg-surface)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <div
            className="flex flex-wrap items-center justify-between gap-4 border-b pb-5"
            style={{ borderColor: 'var(--border-subtle)' }}
          >
            <div className="flex items-center gap-3">
              <SkaviaBrandMark variant="emblem" size={32} />
              <div>
                <h1 className="font-heading text-lg sm:text-xl font-bold">
                  {isBengali && titleBn ? titleBn : title}
                </h1>
                <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                  {isBengali && subtitleBn ? subtitleBn : subtitle} &middot;{' '}
                  {isBengali ? 'সর্বশেষ হালনাগাদ নভেম্বর ২০২৬' : 'Last updated November 2026'}
                </p>
              </div>
            </div>

            <div className="flex items-center gap-3">
              <LanguageSwitcher />
              <Link
                href="/"
                className="inline-flex items-center gap-1.5 text-xs font-semibold text-[#003399] dark:text-[#3898EC] hover:underline"
              >
                <ArrowLeft className="h-3.5 w-3.5" />
                <span>{isBengali ? 'হোমপেজ' : 'Home'}</span>
              </Link>
            </div>
          </div>

          <div className="space-y-6">
            {sections.map((section) => (
              <section
                key={section.heading}
                className="space-y-2 text-xs sm:text-sm leading-relaxed"
                style={{ color: 'var(--text-secondary)' }}
              >
                <h2 className="font-heading text-sm sm:text-base font-semibold" style={{ color: 'var(--text-primary)' }}>
                  {isBengali && section.headingBn ? section.headingBn : section.heading}
                </h2>
                <p>{isBengali && section.bodyBn ? section.bodyBn : section.body}</p>
              </section>
            ))}
          </div>
        </div>
      </div>

      <PublicFooter />
    </div>
  );
}
