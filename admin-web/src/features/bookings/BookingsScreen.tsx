'use client';

import { useCallback, useEffect, useState } from 'react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatBdt, formatDateTime } from '@/lib/formatters';
import type { BookingListDto, WorkerDirectoryDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { DataTable, type TableColumn } from '@/components/ui/DataTable';
import { SideDrawer } from '@/components/ui/SideDrawer';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

export default function BookingsPage() {
  const { session, selectedBranchId } = useAdminSession();
  const [bookings, setBookings] = useState<BookingListDto[]>([]);
  const [workers, setWorkers] = useState<WorkerDirectoryDto[]>([]);
  const [statusFilter, setStatusFilter] = useState('');
  const [selected, setSelected] = useState<BookingListDto | null>(null);
  const [actionType, setActionType] = useState<'assign_worker' | 'reschedule' | 'complete' | 'cancel'>('assign_worker');
  const [workerProfileId, setWorkerProfileId] = useState('');
  const [scheduledAtInput, setScheduledAtInput] = useState('');
  const [reason, setReason] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const canManage = session.effectivePermissions.includes('booking.manage');

  const loadData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const qs = new URLSearchParams();
      if (selectedBranchId) qs.set('branchId', selectedBranchId);
      if (statusFilter) qs.set('status', statusFilter);
      const [bRes, wRes] = await Promise.all([
        apiFetch<{ bookings: BookingListDto[] }>(`/api/admin/bookings?${qs.toString()}`),
        apiFetch<{ workers: WorkerDirectoryDto[] }>(
          selectedBranchId
            ? `/api/admin/workers?branchId=${encodeURIComponent(selectedBranchId)}`
            : '/api/admin/workers'
        ),
      ]);
      setBookings(bRes.bookings);
      setWorkers(wRes.workers);
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading bookings.');
    } finally {
      setLoading(false);
    }
  }, [selectedBranchId, statusFilter]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  async function handleBookingMutation(e: React.FormEvent) {
    e.preventDefault();
    if (!selected) return;
    setSubmitting(true);
    setError(null);
    try {
      const res = await apiFetch<{ booking: BookingListDto }>(
        `/api/admin/bookings/${selected.service_request_id}`,
        {
          method: 'PATCH',
          body: JSON.stringify({
            action: actionType,
            workerProfileId: actionType === 'assign_worker' ? workerProfileId : undefined,
            scheduledAt:
              actionType === 'reschedule' && scheduledAtInput
                ? new Date(scheduledAtInput).toISOString()
                : undefined,
            reason: reason.trim(),
          }),
        }
      );
      setSelected(res.booking);
      setReason('');
      await loadData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Booking update failed.');
    } finally {
      setSubmitting(false);
    }
  }

  const columns: TableColumn<BookingListDto>[] = [
    {
      key: 'id',
      header: 'Booking',
      render: (r) => (
        <div>
          <p className="font-medium">{r.client_name}</p>
          <p className="text-xs font-mono-code" style={{ color: 'var(--text-muted)' }}>
            {r.service_request_id.slice(0, 8)}... &middot; {r.branch_name || 'No Branch'}
          </p>
        </div>
      ),
    },
    { key: 'worker', header: 'Assigned Specialist', render: (r) => r.worker_name },
    {
      key: 'schedule',
      header: 'Scheduled',
      render: (r) => formatDateTime(r.scheduled_at),
    },
    {
      key: 'price',
      header: 'Agreed Price',
      align: 'right',
      render: (r) => formatBdt(r.agreed_price),
    },
    {
      key: 'status',
      header: 'Status',
      render: (r) => <StatusBadge status={r.status} />,
    },
  ];

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Service Bookings & Dispatch</h1>
          <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
            Track scheduled service requests, reassign specialists, or intervene on stalled orders.
          </p>
        </div>

        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="rounded-lg border px-3 py-2 text-sm outline-none"
          style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
        >
          <option value="">All Statuses</option>
          <option value="Requested">Requested</option>
          <option value="Accepted">Accepted</option>
          <option value="In Progress">In Progress</option>
          <option value="Completed">Completed</option>
          <option value="Canceled">Canceled</option>
          <option value="Rejected">Rejected</option>
        </select>
      </div>

      {error && <ErrorPanel message={error} onRetry={() => void loadData()} />}
      {loading ? (
        <LoadingPanel />
      ) : (
        <DataTable
          columns={columns}
          rows={bookings}
          rowKey={(r) => r.service_request_id}
          onRowClick={(r) => {
            setSelected(r);
            setWorkerProfileId(r.worker_profile_id);
            setScheduledAtInput(
              r.scheduled_at ? r.scheduled_at.slice(0, 16) : ''
            );
          }}
        />
      )}

      <SideDrawer
        open={Boolean(selected)}
        title={`Booking · ${selected?.client_name || ''}`}
        subtitle={selected ? `${selected.branch_name || 'SKAVIA'} · ${selected.status}` : undefined}
        onClose={() => setSelected(null)}
      >
        {selected && (
          <div className="space-y-5 text-sm">
            <dl className="space-y-2">
              <div>
                <dt className="text-xs uppercase" style={{ color: 'var(--text-muted)' }}>
                  Service Notes
                </dt>
                <dd className="mt-0.5">{selected.service_notes || 'No client notes.'}</dd>
              </div>
              {selected.cancellation_reason && (
                <div>
                  <dt className="text-xs uppercase text-red-700">Cancellation Reason</dt>
                  <dd className="mt-0.5 text-red-700">{selected.cancellation_reason}</dd>
                </div>
              )}
            </dl>

            {canManage && (
              <form
                onSubmit={handleBookingMutation}
                className="rounded-xl border p-4 space-y-3"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                <p className="text-xs font-semibold uppercase" style={{ color: 'var(--text-muted)' }}>
                  Operational Action
                </p>
                <select
                  value={actionType}
                  onChange={(e) =>
                    setActionType(
                      e.target.value as 'assign_worker' | 'reschedule' | 'complete' | 'cancel'
                    )
                  }
                  className="w-full rounded-lg border px-3 py-2 text-sm"
                  style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                >
                  <option value="assign_worker">Reassign Specialist</option>
                  <option value="reschedule">Reschedule Date &amp; Time</option>
                  <option value="complete">Mark Completed</option>
                  <option value="cancel">Cancel Booking</option>
                </select>

                {actionType === 'assign_worker' && (
                  <select
                    value={workerProfileId}
                    onChange={(e) => setWorkerProfileId(e.target.value)}
                    className="w-full rounded-lg border px-3 py-2 text-sm"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  >
                    {workers.map((w) => (
                      <option key={w.worker_profile_id} value={w.worker_profile_id}>
                        {w.full_name} ({w.title})
                      </option>
                    ))}
                  </select>
                )}

                {actionType === 'reschedule' && (
                  <input
                    type="datetime-local"
                    required
                    value={scheduledAtInput}
                    onChange={(e) => setScheduledAtInput(e.target.value)}
                    className="w-full rounded-lg border px-3 py-2 text-sm"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  />
                )}

                <textarea
                  rows={2}
                  required
                  minLength={5}
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  placeholder="Document reason for reassignment/completion/cancellation..."
                  className="w-full rounded-lg border p-2.5 text-sm"
                  style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                />

                <button
                  type="submit"
                  disabled={submitting}
                  className="rounded-lg px-4 py-2 text-xs font-semibold text-white"
                  style={{ backgroundColor: '#003399' }}
                >
                  {submitting ? 'Applying...' : 'Apply Booking Action'}
                </button>
              </form>
            )}
          </div>
        )}
      </SideDrawer>
    </div>
  );
}

