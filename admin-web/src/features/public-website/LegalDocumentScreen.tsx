import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { LanguageSwitcher } from '@/components/navigation/LanguageSwitcher';
import { PublicFooter } from '@/components/navigation/PublicFooter';

export interface LegalSection {
  heading: string;
  body: string;
}

export function LegalDocumentScreen({
  title,
  subtitle,
  sections,
}: {
  title: string;
  subtitle: string;
  sections: LegalSection[];
}) {
  return (
    <div
      className="min-h-screen flex flex-col justify-between transition-colors"
      style={{ backgroundColor: 'var(--bg-canvas)', color: 'var(--text-primary)' }}
    >
      <div className="py-8 sm:py-12 px-4 sm:px-6 flex-1">
        <div
          className="max-w-3xl mx-auto rounded-2xl border p-6 sm:p-8 shadow-sm space-y-6"
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
                <h1 className="font-heading text-lg sm:text-xl font-bold">{title}</h1>
                <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                  {subtitle} &middot; Last updated November 2026
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
                <span>Home</span>
              </Link>
            </div>
          </div>

          {sections.map((section) => (
            <section
              key={section.heading}
              className="space-y-2 text-xs sm:text-sm leading-relaxed"
              style={{ color: 'var(--text-secondary)' }}
            >
              <h2 className="font-heading text-sm sm:text-base font-semibold" style={{ color: 'var(--text-primary)' }}>
                {section.heading}
              </h2>
              <p>{section.body}</p>
            </section>
          ))}
        </div>
      </div>

      <PublicFooter />
    </div>
  );
}

