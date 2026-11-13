'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowRight, Search, X } from 'lucide-react';
import { apiFetch } from '@/lib/api-client';
import type { GlobalSearchResultDto } from '@/lib/types';
import { useAdminSession } from './SessionProvider';

export function CommandPalette({
  open,
  onClose,
}: {
  open: boolean;
  onClose: () => void;
}) {
  const router = useRouter();
  const { selectedBranchId } = useAdminSession();
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<GlobalSearchResultDto[]>([]);
  const [searching, setSearching] = useState(false);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, onClose]);

  useEffect(() => {
    if (!open) return;
    const q = query.trim();
    if (q.length < 2) {
      setResults([]);
      return;
    }

    let cancelled = false;
    const timer = setTimeout(async () => {
      setSearching(true);
      try {
        const qs = new URLSearchParams({ q });
        if (selectedBranchId) qs.set('branchId', selectedBranchId);
        const data = await apiFetch<{ results: GlobalSearchResultDto[] }>(
          `/api/admin/search?${qs.toString()}`
        );
        if (!cancelled) setResults(data.results);
      } catch {
        if (!cancelled) setResults([]);
      } finally {
        if (!cancelled) setSearching(false);
      }
    }, 180);

    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
  }, [open, query, selectedBranchId]);

  if (!open) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-start justify-center pt-20 p-4 bg-slate-950/60"
      role="dialog"
      aria-modal="true"
      aria-label="Global Command Search"
    >
      <div
        className="w-full max-w-xl rounded-xl border shadow-2xl overflow-hidden"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div
          className="flex items-center gap-3 px-4 py-3 border-b"
          style={{ borderColor: 'var(--border-subtle)' }}
        >
          <Search className="h-4 w-4 shrink-0" style={{ color: 'var(--text-muted)' }} />
          <input
            type="text"
            autoFocus
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search SKAVIA customers, specialists, branches..."
            className="flex-1 bg-transparent text-sm outline-none"
            style={{ color: 'var(--text-primary)' }}
          />
          <button
            type="button"
            onClick={onClose}
            aria-label="Close search"
            className="p-1 rounded hover:bg-slate-100 dark:hover:bg-slate-800"
          >
            <X className="h-4 w-4" style={{ color: 'var(--text-muted)' }} />
          </button>
        </div>

        <div className="max-h-80 overflow-y-auto p-2">
          {searching ? (
            <p className="p-4 text-xs" style={{ color: 'var(--text-muted)' }}>
              Searching scoped records...
            </p>
          ) : query.trim().length < 2 ? (
            <p className="p-4 text-xs" style={{ color: 'var(--text-muted)' }}>
              Type at least 2 characters to search within your authorized SKAVIA branch scope.
            </p>
          ) : results.length === 0 ? (
            <p className="p-4 text-xs" style={{ color: 'var(--text-muted)' }}>
              No authorized records matched &ldquo;{query}&rdquo;.
            </p>
          ) : (
            <ul className="space-y-1">
              {results.map((r) => (
                <li key={`${r.type}-${r.id}`}>
                  <button
                    type="button"
                    onClick={() => {
                      onClose();
                      router.push(r.href);
                    }}
                    className="w-full flex items-center justify-between gap-3 rounded-lg px-3 py-2 text-left hover:bg-slate-100 dark:hover:bg-slate-800 transition"
                  >
                    <div className="min-w-0">
                      <p className="text-sm font-medium truncate" style={{ color: 'var(--text-primary)' }}>
                        {r.title}
                      </p>
                      <p className="text-xs truncate" style={{ color: 'var(--text-muted)' }}>
                        {r.subtitle}
                      </p>
                    </div>
                    <span className="inline-flex items-center gap-1 text-xs uppercase font-semibold text-blue-600 shrink-0">
                      {r.type}
                      <ArrowRight className="h-3.5 w-3.5" />
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </div>
  );
}

