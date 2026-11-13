'use client';

import { useCallback, useEffect, useState } from 'react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatDateTime } from '@/lib/formatters';
import type { DisputeDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { DataTable, type TableColumn } from '@/components/ui/DataTable';
import { SideDrawer } from '@/components/ui/SideDrawer';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

export default function DisputesPage() {
  const { session, selectedBranchId } = useAdminSession();
  const [disputes, setDisputes] = useState<DisputeDto[]>([]);
  const [selected, setSelected] = useState<DisputeDto | null>(null);
  const [resolution, setResolution] = useState('');
  const [verdict, setVerdict] = useState<'Resolved' | 'Dismissed'>('Resolved');
  const [noteType, setNoteType] = useState<'Decision' | 'RefundRecommendation'>('Decision');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const canResolve = session.effectivePermissions.includes('dispute.resolve');

  const loadDisputes = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const qs = selectedBranchId ? `?branchId=${encodeURIComponent(selectedBranchId)}` : '';
      const res = await apiFetch<{ disputes: DisputeDto[] }>(`/api/admin/disputes${qs}`);
      setDisputes(res.disputes);
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading disputes.');
    } finally {
      setLoading(false);
    }
  }, [selectedBranchId]);

  useEffect(() => {
    void loadDisputes();
  }, [loadDisputes]);

  async function handleResolve(e: React.FormEvent) {
    e.preventDefault();
    if (!selected) return;
    setSubmitting(true);
    setError(null);
    try {
      const res = await apiFetch<{ dispute: DisputeDto }>(
        `/api/admin/disputes/${selected.dispute_id}/resolve`,
        {
          method: 'POST',
          body: JSON.stringify({
            status: verdict,
            resolution: resolution.trim(),
            noteType,
          }),
        }
      );
      setSelected(res.dispute);
      setResolution('');
      await loadDisputes();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Dispute resolution failed.');
    } finally {
      setSubmitting(false);
    }
  }

  const columns: TableColumn<DisputeDto>[] = [
    {
      key: 'category',
      header: 'Case & Category',
      render: (r) => (
        <div>
          <p className="font-medium">{r.category}</p>
          <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
            Filed by {r.filed_by_name} &middot; {r.branch_name || 'SKAVIA'}
          </p>
        </div>
      ),
    },
    {
      key: 'desc',
      header: 'Complaint Summary',
      render: (r) => (
        <p className="max-w-md truncate text-xs" style={{ color: 'var(--text-secondary)' }}>
          {r.complaint_description}
        </p>
      ),
    },
    {
      key: 'created',
      header: 'Opened',
      render: (r) => formatDateTime(r.created_at),
    },
    {
      key: 'status',
      header: 'Status',
      render: (r) => <StatusBadge status={r.status} />,
    },
  ];

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Disputes & Complaint Mediation</h1>
        <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
          Investigate client/worker complaints with preserved mediation notes and Step-Up audited verdicts.
        </p>
      </div>

      {error && <ErrorPanel message={error} onRetry={() => void loadDisputes()} />}
      {loading ? (
        <LoadingPanel />
      ) : (
        <DataTable
          columns={columns}
          rows={disputes}
          rowKey={(r) => r.dispute_id}
          onRowClick={(r) => setSelected(r)}
        />
      )}

      <SideDrawer
        open={Boolean(selected)}
        title={selected?.category || 'Dispute Case'}
        subtitle={selected ? `Filed by ${selected.filed_by_name} · ${selected.status}` : undefined}
        onClose={() => setSelected(null)}
      >
        {selected && (
          <div className="space-y-5 text-sm">
            <div>
              <p className="text-xs uppercase" style={{ color: 'var(--text-muted)' }}>
                Complaint Evidence
              </p>
              <p className="mt-1 leading-relaxed">{selected.complaint_description}</p>
            </div>

            <div className="space-y-2">
              <p className="text-xs uppercase" style={{ color: 'var(--text-muted)' }}>
                Mediation Timeline Notes ({selected.notes.length})
              </p>
              {selected.notes.map((n) => (
                <div
                  key={n.note_id}
                  className="rounded-lg border p-3 text-xs space-y-1"
                  style={{ borderColor: 'var(--border-subtle)', backgroundColor: 'var(--bg-canvas)' }}
                >
                  <div className="flex justify-between font-semibold">
                    <span>{n.note_type}</span>
                    <span style={{ color: 'var(--text-muted)' }}>{formatDateTime(n.created_at)}</span>
                  </div>
                  <p>{n.content}</p>
                </div>
              ))}
            </div>

            {canResolve && selected.status !== 'Resolved' && selected.status !== 'Dismissed' && (
              <form
                onSubmit={handleResolve}
                className="rounded-xl border p-4 space-y-3"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                <p className="text-xs font-semibold uppercase" style={{ color: 'var(--text-muted)' }}>
                  Record Resolution Verdict (Step-Up Required)
                </p>
                <div className="grid grid-cols-2 gap-2">
                  <select
                    value={verdict}
                    onChange={(e) => setVerdict(e.target.value as 'Resolved' | 'Dismissed')}
                    className="rounded-lg border px-3 py-2 text-sm"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  >
                    <option value="Resolved">Resolved</option>
                    <option value="Dismissed">Dismissed</option>
                  </select>
                  <select
                    value={noteType}
                    onChange={(e) =>
                      setNoteType(e.target.value as 'Decision' | 'RefundRecommendation')
                    }
                    className="rounded-lg border px-3 py-2 text-sm"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  >
                    <option value="Decision">Standard Decision</option>
                    <option value="RefundRecommendation">Recommend Refund</option>
                  </select>
                </div>
                <textarea
                  rows={3}
                  required
                  minLength={10}
                  value={resolution}
                  onChange={(e) => setResolution(e.target.value)}
                  placeholder="Detail investigation findings, evidence verified, and corrective outcome (min 10 chars)..."
                  className="w-full rounded-lg border p-2.5 text-sm"
                  style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                />
                <button
                  type="submit"
                  disabled={submitting}
                  className="rounded-lg px-4 py-2 text-xs font-semibold text-white"
                  style={{ backgroundColor: '#003399' }}
                >
                  {submitting ? 'Finalizing...' : 'Finalize Dispute Decision'}
                </button>
              </form>
            )}
          </div>
        )}
      </SideDrawer>
    </div>
  );
}

