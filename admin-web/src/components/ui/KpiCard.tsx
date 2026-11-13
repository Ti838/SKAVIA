'use client';

import type { ReactNode } from 'react';
import Link from 'next/link';

export function KpiCard({
  label,
  value,
  subtitle,
  icon,
  href,
  tone = 'royal',
}: {
  label: string;
  value: string | number;
  subtitle?: string;
  icon?: ReactNode;
  href?: string;
  tone?: 'royal' | 'sky' | 'aqua' | 'peach' | 'danger' | 'neutral';
}) {
  const accentColor =
    tone === 'royal'
      ? '#003399'
      : tone === 'sky'
        ? '#3898EC'
        : tone === 'aqua'
          ? '#0D9488'
          : tone === 'peach'
            ? '#EA580C'
            : tone === 'danger'
              ? '#DC2626'
              : '#475569';

  const card = (
    <div
      className="rounded-xl border p-4 transition hover:shadow-sm"
      style={{
        backgroundColor: 'var(--bg-surface)',
        borderColor: 'var(--border-subtle)',
      }}
    >
      <div className="flex items-start justify-between gap-2">
        <div>
          <p className="text-xs font-medium uppercase tracking-wider" style={{ color: 'var(--text-muted)' }}>
            {label}
          </p>
          <p
            className="mt-1.5 text-2xl font-bold tabular-nums tracking-tight"
            style={{ color: 'var(--text-primary)' }}
          >
            {value}
          </p>
        </div>
        {icon && (
          <div
            className="h-9 w-9 rounded-lg flex items-center justify-center shrink-0 text-white"
            style={{ backgroundColor: accentColor }}
          >
            {icon}
          </div>
        )}
      </div>
      {subtitle && (
        <p className="mt-2 text-xs truncate" style={{ color: 'var(--text-secondary)' }}>
          {subtitle}
        </p>
      )}
    </div>
  );

  if (href) {
    return (
      <Link href={href} className="block focus:outline-none focus:ring-2 focus:ring-blue-500 rounded-xl">
        {card}
      </Link>
    );
  }

  return card;
}

