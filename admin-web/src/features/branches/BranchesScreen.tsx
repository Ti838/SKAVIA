'use client';

import { useCallback, useEffect, useState } from 'react';
import { Building2, Plus } from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatDateTime } from '@/lib/formatters';
import type { BranchSummary } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

export default function BranchesPage() {
  const { session } = useAdminSession();
  const [branches, setBranches] = useState<BranchSummary[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [name, setName] = useState('');
  const [code, setCode] = useState('');
  const [description, setDescription] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const canManage = session.effectivePermissions.includes('branch.manage');

  const loadBranches = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await apiFetch<{ branches: BranchSummary[] }>('/api/admin/branches');
      setBranches(res.branches);
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading branches.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadBranches();
  }, [loadBranches]);

  async function handleCreateBranch(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await apiFetch('/api/admin/branches', {
        method: 'POST',
        body: JSON.stringify({
          name: name.trim(),
          code: code.trim().toUpperCase(),
          description: description.trim() || undefined,
        }),
      });
      setName('');
      setCode('');
      setDescription('');
      setShowCreate(false);
      await loadBranches();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed creating branch.');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleToggleActive(b: BranchSummary) {
    setError(null);
    try {
      await apiFetch(`/api/admin/branches/${b.branch_id}`, {
        method: 'PATCH',
        body: JSON.stringify({ isActive: !b.is_active }),
      });
      await loadBranches();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed updating branch.');
    }
  }

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Internal SKAVIA Branches</h1>
          <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
            SKAVIA operational units (Home, Technical, Corporate) — single-company hierarchy.
          </p>
        </div>
        {canManage && (
          <button
            type="button"
            onClick={() => setShowCreate((v) => !v)}
            className="inline-flex items-center gap-1.5 rounded-lg px-4 py-2 text-xs font-semibold text-white"
            style={{ backgroundColor: '#003399' }}
          >
            <Plus className="h-4 w-4" />
            New Internal Branch
          </button>
        )}
      </div>

      {showCreate && canManage && (
        <form
          onSubmit={handleCreateBranch}
          className="rounded-xl border p-5 grid grid-cols-1 md:grid-cols-3 gap-4"
          style={{
            backgroundColor: 'var(--bg-surface)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <input
            type="text"
            required
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Branch Name (e.g. SKAVIA Logistics)"
            className="rounded-lg border px-3 py-2 text-sm"
            style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
          />
          <input
            type="text"
            required
            value={code}
            onChange={(e) => setCode(e.target.value.toUpperCase())}
            placeholder="Code (e.g. LOG)"
            className="rounded-lg border px-3 py-2 text-sm font-mono-code"
            style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
          />
          <div className="flex gap-2">
            <input
              type="text"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Optional description"
              className="flex-1 rounded-lg border px-3 py-2 text-sm"
              style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
            />
            <button
              type="submit"
              disabled={submitting}
              className="rounded-lg px-4 py-2 text-xs font-semibold text-white"
              style={{ backgroundColor: '#003399' }}
            >
              {submitting ? 'Saving...' : 'Create'}
            </button>
          </div>
        </form>
      )}

      {error && <ErrorPanel message={error} onRetry={() => void loadBranches()} />}

      {loading ? (
        <LoadingPanel />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {branches.map((b) => (
            <div
              key={b.branch_id}
              className="rounded-xl border p-5 space-y-3"
              style={{
                backgroundColor: 'var(--bg-surface)',
                borderColor: 'var(--border-subtle)',
              }}
            >
              <div className="flex items-start justify-between gap-2">
                <div className="flex items-center gap-2.5">
                  <div className="h-9 w-9 rounded-lg bg-blue-50 dark:bg-blue-950/60 text-blue-700 dark:text-sky-400 flex items-center justify-center">
                    <Building2 className="h-4 w-4" />
                  </div>
                  <div>
                    <h2 className="text-base font-semibold">{b.name}</h2>
                    <p className="text-xs font-mono-code" style={{ color: 'var(--text-muted)' }}>
                      Code: {b.code}
                    </p>
                  </div>
                </div>
                <StatusBadge status={b.is_active ? 'Active' : 'Suspended'} />
              </div>

              <p className="text-xs leading-relaxed" style={{ color: 'var(--text-secondary)' }}>
                {b.description || 'Internal SKAVIA operational branch unit.'}
              </p>

              <div className="pt-2 border-t flex items-center justify-between text-xs" style={{ borderColor: 'var(--border-subtle)' }}>
                <span style={{ color: 'var(--text-muted)' }}>
                  Created {formatDateTime(b.created_at)}
                </span>
                {canManage && (
                  <button
                    type="button"
                    onClick={() => void handleToggleActive(b)}
                    className="font-semibold text-blue-700 dark:text-sky-400 hover:underline"
                  >
                    {b.is_active ? 'Deactivate' : 'Activate'}
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

