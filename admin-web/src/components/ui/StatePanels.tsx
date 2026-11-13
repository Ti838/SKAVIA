'use client';

import { AlertOctagon, Inbox, Loader2, RefreshCw } from 'lucide-react';

export function LoadingPanel({ label = 'Loading live SKAVIA data...' }: { label?: string }) {
  return (
    <div
      className="rounded-xl border p-12 flex flex-col items-center justify-center text-center"
      style={{
        backgroundColor: 'var(--bg-surface)',
        borderColor: 'var(--border-subtle)',
      }}
    >
      <Loader2 className="h-7 w-7 animate-spin text-blue-600 mb-3" />
      <p className="text-sm font-medium" style={{ color: 'var(--text-secondary)' }}>
        {label}
      </p>
    </div>
  );
}

export function ErrorPanel({
  message,
  code,
  correlationId,
  onRetry,
}: {
  message: string;
  code?: string;
  correlationId?: string;
  onRetry?: () => void;
}) {
  return (
    <div
      role="alert"
      className="rounded-xl border border-red-300 dark:border-red-800/70 bg-red-50/90 dark:bg-red-950/50 p-6 text-red-950 dark:text-red-100"
    >
      <div className="flex items-start gap-3">
        <AlertOctagon className="h-5 w-5 text-red-600 dark:text-red-400 shrink-0 mt-0.5" />
        <div className="flex-1 min-w-0">
          <p className="text-sm font-semibold">
            Unable to load authoritative backend data{code ? ` (${code})` : ''}
          </p>
          <p className="mt-1 text-sm text-red-900 dark:text-red-200">{message}</p>
          {correlationId && (
            <p className="mt-1.5 text-xs font-mono-code text-red-800 dark:text-red-300">
              Correlation ID: {correlationId}
            </p>
          )}
          {onRetry && (
            <button
              type="button"
              onClick={onRetry}
              className="mt-3 inline-flex items-center gap-1.5 rounded-lg bg-red-700 px-3 py-1.5 text-xs font-semibold text-white hover:bg-red-800"
            >
              <RefreshCw className="h-3.5 w-3.5" />
              Retry Request
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

export function EmptyPanel({
  title,
  description,
}: {
  title: string;
  description: string;
}) {
  return (
    <div
      className="rounded-xl border p-12 flex flex-col items-center justify-center text-center"
      style={{
        backgroundColor: 'var(--bg-surface)',
        borderColor: 'var(--border-subtle)',
      }}
    >
      <Inbox className="h-8 w-8 mb-3" style={{ color: 'var(--text-muted)' }} />
      <p className="text-sm font-semibold" style={{ color: 'var(--text-primary)' }}>
        {title}
      </p>
      <p className="mt-1 text-xs max-w-md" style={{ color: 'var(--text-muted)' }}>
        {description}
      </p>
    </div>
  );
}

