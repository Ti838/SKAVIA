import Link from 'next/link';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';

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
      className="min-h-screen py-12 px-4 sm:px-6"
      style={{ backgroundColor: 'var(--bg-canvas)', color: 'var(--text-primary)' }}
    >
      <div
        className="max-w-3xl mx-auto rounded-2xl border p-8 shadow-sm space-y-6"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div
          className="flex items-center justify-between border-b pb-5"
          style={{ borderColor: 'var(--border-subtle)' }}
        >
          <div className="flex items-center gap-3">
            <SkaviaBrandMark variant="emblem" size={32} />
            <div>
              <h1 className="text-xl font-bold">{title}</h1>
              <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                {subtitle}
              </p>
            </div>
          </div>
          <Link
            href="/"
            className="text-xs font-semibold text-blue-700 dark:text-sky-400 hover:underline"
          >
            &larr; Back to Home
          </Link>
        </div>

        {sections.map((section) => (
          <section
            key={section.heading}
            className="space-y-2 text-sm leading-relaxed"
            style={{ color: 'var(--text-secondary)' }}
          >
            <h2 className="text-base font-semibold" style={{ color: 'var(--text-primary)' }}>
              {section.heading}
            </h2>
            <p>{section.body}</p>
          </section>
        ))}
      </div>
    </div>
  );
}

