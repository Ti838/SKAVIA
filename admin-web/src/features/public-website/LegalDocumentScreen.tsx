'use client';

import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { HeroAtmosphere } from './components/HeroAtmosphere';
import { PublicPageShell } from './components/PublicPageShell';

export interface LegalSection {
  heading: string;
  headingBn?: string;
  body: string;
  bodyBn?: string;
}

export function LegalDocumentScreen({
  title,
  subtitle,
  sections,
}: {
  title: string;
  titleBn?: string;
  subtitle: string;
  subtitleBn?: string;
  sections: LegalSection[];
}) {
  return (
    <PublicPageShell>
      {(t) => (
        <div className="space-y-12 pt-4 pb-16 sm:pt-6 sm:pb-24">
          {/* Header */}
          <section className="relative px-4 sm:px-6 lg:px-8 overflow-hidden">
            <HeroAtmosphere dark={t.dark} variant="subpage" />
            <div className="max-w-4xl mx-auto text-center space-y-4 relative z-10">
              <h1 className="font-heading font-extrabold text-3xl sm:text-5xl lg:text-6xl tracking-tight text-neutral-900 dark:text-white">
                {title}
              </h1>

              <p className="mt-4 text-base sm:text-lg max-w-2xl mx-auto leading-relaxed text-neutral-600 dark:text-neutral-400">
                {subtitle} &middot; Last updated November 2026 &middot; Headquartered in Dhaka, Bangladesh
              </p>
            </div>
          </section>

          {/* Document Content */}
          <section className="px-4 sm:px-6 lg:px-8">
            <div className="max-w-3xl mx-auto space-y-8">
              <div className="flex items-center justify-between pb-2 border-b border-neutral-200 dark:border-neutral-800">
                <Link
                  href="/"
                  className="inline-flex items-center gap-1.5 text-xs font-semibold text-[#003399] dark:text-[#3898EC] hover:underline"
                >
                  <ArrowLeft className="h-3.5 w-3.5" />
                  <span>Return to Home</span>
                </Link>
                <span className="text-xs font-mono text-neutral-400">
                  Document ID: SKV-LEGAL-{title.slice(0, 4).toUpperCase()}
                </span>
              </div>

              <div className={`rounded-3xl border p-6 sm:p-10 space-y-8 ${t.railBorder} ${t.cardBg} shadow-sm backdrop-blur-md`}>
                {sections.map((sec, idx) => (
                  <div key={idx} className="space-y-3">
                    <h2 className={`font-heading text-lg sm:text-xl font-bold tracking-tight ${t.textPrimary}`}>
                      {sec.heading}
                    </h2>
                    <p className={`text-xs sm:text-sm leading-relaxed ${t.textSecondary}`}>
                      {sec.body}
                    </p>
                    {sec.bodyBn && (
                      <p className={`text-xs sm:text-sm leading-relaxed font-bengali text-neutral-500 dark:text-neutral-400 pt-1`}>
                        {sec.bodyBn}
                      </p>
                    )}
                  </div>
                ))}
              </div>
            </div>
          </section>
        </div>
      )}
    </PublicPageShell>
  );
}
