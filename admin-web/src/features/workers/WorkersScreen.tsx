'use client';

import { useCallback, useEffect, useState } from 'react';
import { Search, Star } from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatBdt } from '@/lib/formatters';
import type { WorkerDirectoryDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { DataTable, type TableColumn } from '@/components/ui/DataTable';
import { SideDrawer } from '@/components/ui/SideDrawer';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

export default function WorkersPage() {
  const { session, availableBranches, selectedBranchId } = useAdminSession();
  const [workers, setWorkers] = useState<WorkerDirectoryDto[]>([]);
  const [statusFilter, setStatusFilter] = useState('');
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selected, setSelected] = useState<WorkerDirectoryDto | null>(null);
  const [assignBranchId, setAssignBranchId] = useState('');
  const [modalAction, setModalAction] = useState<'suspend' | 'reactivate' | null>(null);
  const [mutating, setMutating] = useState(false);

  const canSuspend = session.effectivePermissions.includes('worker.suspend');
  const canAssignBranch = session.effectivePermissions.includes('worker.branch.assign');

  const loadWorkers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const qs = new URLSearchParams();
      if (selectedBranchId) qs.set('branchId', selectedBranchId);
      if (statusFilter) qs.set('verificationStatus', statusFilter);
      if (search.trim()) qs.set('search', search.trim());
      const res = await apiFetch<{ workers: WorkerDirectoryDto[] }>(
        `/api/admin/workers?${qs.toString()}`
      );
      setWorkers(res.workers);
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading specialists.');
    } finally {
      setLoading(false);
    }
  }, [selectedBranchId, statusFilter, search]);

  useEffect(() => {
    void loadWorkers();
  }, [loadWorkers]);

  async function handleSuspendAction(reason: string) {
    if (!selected || !modalAction) return;
    setMutating(true);
    try {
      const res = await apiFetch<{ worker: WorkerDirectoryDto }>(
        `/api/admin/workers/${selected.worker_profile_id}`,
        {
          method: 'PATCH',
          body: JSON.stringify({ action: modalAction, reason }),
        }
      );
      setSelected(res.worker);
      setModalAction(null);
      await loadWorkers();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Worker update failed.');
    } finally {
      setMutating(false);
    }
  }

  async function handleBranchTransfer() {
    if (!selected || !assignBranchId) return;
    setMutating(true);
    try {
      const res = await apiFetch<{ worker: WorkerDirectoryDto }>(
        `/api/admin/workers/${selected.worker_profile_id}`,
        {
          method: 'PATCH',
          body: JSON.stringify({
            action: 'assign_branch',
            branchId: assignBranchId,
            reason: 'Internal SKAVIA branch allocation update',
          }),
        }
      );
      setSelected(res.worker);
      await loadWorkers();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Branch transfer failed.');
    } finally {
      setMutating(false);
    }
  }

  const columns: TableColumn<WorkerDirectoryDto>[] = [
    {
      key: 'name',
      header: 'Specialist',
      render: (r) => (
        <div>
          <p className="font-medium">{r.full_name}</p>
          <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
            {r.title} &middot; {r.location}
          </p>
        </div>
      ),
    },
    {
      key: 'branch',
      header: 'Branch',
      render: (r) => r.branch_name || 'Unassigned',
    },
    {
      key: 'rate',
      header: 'Expected Rate',
      align: 'right',
      render: (r) => formatBdt(r.expected_rate),
    },
    {
      key: 'rating',
      header: 'Rating',
      render: (r) => (
        <span className="inline-flex items-center gap-1 text-xs font-semibold tabular-nums">
          <Star className="h-3.5 w-3.5 text-amber-500 fill-amber-500" />
          {r.rating_average.toFixed(1)} ({r.total_reviews})
        </span>
      ),
    },
    {
      key: 'verification',
      header: 'KYC & Status',
      render: (r) => (
        <div className="flex flex-wrap gap-1.5">
          <StatusBadge status={r.verification_status} />
          <StatusBadge status={r.account_status} />
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Specialists & Workforce</h1>
        <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
          Manage skilled professionals assigned across SKAVIA Home, Technical, and Corporate branches.
        </p>
      </div>

      <div className="flex flex-wrap items-center justify-between gap-3">
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="rounded-lg border px-3 py-2 text-sm outline-none"
          style={{
            backgroundColor: 'var(--bg-surface)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <option value="">All KYC Statuses</option>
          <option value="Verified">Verified</option>
          <option value="Pending">Pending</option>
          <option value="Rejected">Rejected</option>
        </select>

        <div className="relative w-full sm:w-72">
          <Search className="h-4 w-4 absolute left-3 top-2.5" style={{ color: 'var(--text-muted)' }} />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search specialist or title..."
            className="w-full rounded-lg border pl-9 pr-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
            }}
          />
        </div>
      </div>

      {error && <ErrorPanel message={error} onRetry={() => void loadWorkers()} />}
      {loading ? (
        <LoadingPanel />
      ) : (
        <DataTable
          columns={columns}
          rows={workers}
          rowKey={(r) => r.worker_profile_id}
          onRowClick={(r) => {
            setSelected(r);
            setAssignBranchId(r.branch_id || '');
          }}
        />
      )}

      <SideDrawer
        open={Boolean(selected)}
        title={selected?.full_name || 'Specialist'}
        subtitle={selected ? `${selected.title} · ${selected.branch_name || 'No branch'}` : undefined}
        onClose={() => setSelected(null)}
        footer={
          selected &&
          canSuspend && (
            <button
              type="button"
              onClick={() =>
                setModalAction(
                  selected.account_status === 'suspended' ? 'reactivate' : 'suspend'
                )
              }
              className="rounded-lg px-4 py-2 text-xs font-semibold text-white"
              style={{
                backgroundColor:
                  selected.account_status === 'suspended' ? '#16A34A' : '#DC2626',
              }}
            >
              {selected.account_status === 'suspended'
                ? 'Reactivate Specialist'
                : 'Suspend Specialist'}
            </button>
          )
        }
      >
        {selected && (
          <div className="space-y-4 text-sm">
            <div>
              <p className="text-xs uppercase" style={{ color: 'var(--text-muted)' }}>
                Completed Jobs & Availability
              </p>
              <p className="font-medium mt-0.5">
                {selected.completed_jobs} completed &middot;{' '}
                {selected.is_available ? 'Currently Available' : 'Unavailable'}
              </p>
            </div>
            <div>
              <p className="text-xs uppercase" style={{ color: 'var(--text-muted)' }}>
                Verified Skills
              </p>
              <div className="mt-1.5 flex flex-wrap gap-1.5">
                {selected.skills.length > 0 ? (
                  selected.skills.map((s) => <StatusBadge key={s} status={s} variant="neutral" />)
                ) : (
                  <span className="text-xs" style={{ color: 'var(--text-muted)' }}>
                    No skills listed
                  </span>
                )}
              </div>
            </div>

            {canAssignBranch && availableBranches.length > 0 && (
              <div
                className="rounded-xl border p-4 space-y-2.5"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                <p className="text-xs font-semibold uppercase" style={{ color: 'var(--text-muted)' }}>
                  Internal Branch Assignment
                </p>
                <div className="flex gap-2">
                  <select
                    value={assignBranchId}
                    onChange={(e) => setAssignBranchId(e.target.value)}
                    className="flex-1 rounded-lg border px-3 py-1.5 text-sm"
                    style={{
                      backgroundColor: 'var(--bg-canvas)',
                      borderColor: 'var(--border-subtle)',
                    }}
                  >
                    <option value="">Select branch...</option>
                    {availableBranches.map((b) => (
                      <option key={b.branch_id} value={b.branch_id}>
                        {b.name}
                      </option>
                    ))}
                  </select>
                  <button
                    type="button"
                    disabled={!assignBranchId || mutating}
                    onClick={() => void handleBranchTransfer()}
                    className="rounded-lg px-3 py-1.5 text-xs font-semibold text-white disabled:opacity-50"
                    style={{ backgroundColor: '#003399' }}
                  >
                    Assign
                  </button>
                </div>
              </div>
            )}
          </div>
        )}
      </SideDrawer>

      <ConfirmModal
        open={Boolean(modalAction)}
        danger={modalAction === 'suspend'}
        requireReason
        loading={mutating}
        title={modalAction === 'suspend' ? 'Suspend Specialist' : 'Reactivate Specialist'}
        description="Suspending disables booking assignments across SKAVIA until reactivated. Logged to audit_logs."
        confirmLabel={modalAction === 'suspend' ? 'Suspend' : 'Reactivate'}
        onCancel={() => setModalAction(null)}
        onConfirm={(reason) => void handleSuspendAction(reason)}
      />
    </div>
  );
}

