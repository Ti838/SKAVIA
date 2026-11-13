'use client';

import { useCallback, useEffect, useState } from 'react';
import { Search } from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatDateTime } from '@/lib/formatters';
import type { CustomerDirectoryDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { DataTable, type TableColumn } from '@/components/ui/DataTable';
import { SideDrawer } from '@/components/ui/SideDrawer';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

const CUSTOMER_TYPES = ['All', 'Individual', 'Business Client', 'Organization'] as const;

export default function CustomersPage() {
  const { session, selectedBranchId } = useAdminSession();
  const [customers, setCustomers] = useState<CustomerDirectoryDto[]>([]);
  const [customerType, setCustomerType] = useState<string>('All');
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selected, setSelected] = useState<CustomerDirectoryDto | null>(null);
  const [confirmSuspend, setConfirmSuspend] = useState<'suspend' | 'activate' | null>(null);
  const [mutating, setMutating] = useState(false);

  const canSuspend = session.effectivePermissions.includes('customer.suspend');

  const loadCustomers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const qs = new URLSearchParams();
      if (selectedBranchId) qs.set('branchId', selectedBranchId);
      if (customerType !== 'All') qs.set('type', customerType);
      if (search.trim()) qs.set('search', search.trim());
      const res = await apiFetch<{ customers: CustomerDirectoryDto[] }>(
        `/api/admin/customers?${qs.toString()}`
      );
      setCustomers(res.customers);
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading customers.');
    } finally {
      setLoading(false);
    }
  }, [selectedBranchId, customerType, search]);

  useEffect(() => {
    void loadCustomers();
  }, [loadCustomers]);

  async function handleAccountStatusChange(reason: string) {
    if (!selected || !confirmSuspend) return;
    setMutating(true);
    try {
      const nextStatus = confirmSuspend === 'suspend' ? 'suspended' : 'active';
      const res = await apiFetch<{ customer: CustomerDirectoryDto }>(
        `/api/admin/customers/${selected.user_id}`,
        {
          method: 'PATCH',
          body: JSON.stringify({
            accountStatus: nextStatus,
            reason,
          }),
        }
      );
      setSelected(res.customer);
      setConfirmSuspend(null);
      await loadCustomers();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed updating customer.');
    } finally {
      setMutating(false);
    }
  }

  const columns: TableColumn<CustomerDirectoryDto>[] = [
    {
      key: 'name',
      header: 'Customer',
      render: (r) => (
        <div>
          <p className="font-medium">{r.full_name}</p>
          <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
            {r.email || r.phone || r.user_id}
          </p>
        </div>
      ),
    },
    {
      key: 'segment',
      header: 'Segment',
      render: (r) => <StatusBadge status={r.customer_type} variant="info" />,
    },
    {
      key: 'company',
      header: 'Company / Org',
      render: (r) => r.company_name || '—',
    },
    {
      key: 'bookings',
      header: 'Bookings',
      align: 'right',
      render: (r) => r.booking_count,
    },
    {
      key: 'status',
      header: 'Status',
      render: (r) => <StatusBadge status={r.account_status || r.status} />,
    },
  ];

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Customer Directory</h1>
        <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
          External Individual Customers, Business Clients, and Organizations served by SKAVIA.
        </p>
      </div>

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex flex-wrap gap-1.5">
          {CUSTOMER_TYPES.map((type) => (
            <button
              key={type}
              type="button"
              onClick={() => setCustomerType(type)}
              className={`rounded-lg px-3 py-1.5 text-xs font-semibold border transition ${
                customerType === type
                  ? 'bg-blue-700 text-white border-blue-700'
                  : 'hover:bg-slate-100 dark:hover:bg-slate-800'
              }`}
              style={
                customerType !== type
                  ? { borderColor: 'var(--border-subtle)', color: 'var(--text-secondary)' }
                  : undefined
              }
            >
              {type}
            </button>
          ))}
        </div>

        <div className="relative w-full sm:w-72">
          <Search className="h-4 w-4 absolute left-3 top-2.5" style={{ color: 'var(--text-muted)' }} />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search name, email, company..."
            className="w-full rounded-lg border pl-9 pr-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
            }}
          />
        </div>
      </div>

      {error && <ErrorPanel message={error} onRetry={() => void loadCustomers()} />}
      {loading ? (
        <LoadingPanel />
      ) : (
        <DataTable
          columns={columns}
          rows={customers}
          rowKey={(r) => r.user_id}
          onRowClick={(r) => setSelected(r)}
        />
      )}

      <SideDrawer
        open={Boolean(selected)}
        title={selected?.full_name || 'Customer'}
        subtitle={selected ? `${selected.customer_type} · ${selected.user_id}` : undefined}
        onClose={() => setSelected(null)}
        footer={
          selected &&
          canSuspend && (
            <button
              type="button"
              onClick={() =>
                setConfirmSuspend(
                  selected.account_status === 'suspended' ? 'activate' : 'suspend'
                )
              }
              className="rounded-lg px-4 py-2 text-xs font-semibold text-white"
              style={{
                backgroundColor:
                  selected.account_status === 'suspended' ? '#16A34A' : '#DC2626',
              }}
            >
              {selected.account_status === 'suspended'
                ? 'Reactivate Customer'
                : 'Suspend Customer'}
            </button>
          )
        }
      >
        {selected && (
          <dl className="space-y-3 text-sm">
            <div>
              <dt className="text-xs uppercase" style={{ color: 'var(--text-muted)' }}>
                Email & Phone
              </dt>
              <dd className="font-medium mt-0.5">
                {selected.email || '—'} &middot; {selected.phone || '—'}
              </dd>
            </div>
            <div>
              <dt className="text-xs uppercase" style={{ color: 'var(--text-muted)' }}>
                Location
              </dt>
              <dd className="font-medium mt-0.5">{selected.location || 'Not set'}</dd>
            </div>
            <div>
              <dt className="text-xs uppercase" style={{ color: 'var(--text-muted)' }}>
                Business / Organization Info
              </dt>
              <dd className="font-medium mt-0.5">
                {selected.company_name || 'Personal Account'}{' '}
                {selected.trade_license ? `(Trade License: ${selected.trade_license})` : ''}
              </dd>
            </div>
            <div>
              <dt className="text-xs uppercase" style={{ color: 'var(--text-muted)' }}>
                Joined SKAVIA
              </dt>
              <dd className="font-medium mt-0.5">{formatDateTime(selected.created_at)}</dd>
            </div>
          </dl>
        )}
      </SideDrawer>

      <ConfirmModal
        open={Boolean(confirmSuspend)}
        danger={confirmSuspend === 'suspend'}
        requireReason
        loading={mutating}
        title={
          confirmSuspend === 'suspend'
            ? 'Suspend Customer Account'
            : 'Reactivate Customer Account'
        }
        description="This action immediately updates the customer's access status and writes an immutable entry to audit_logs (Step-Up MFA verified)."
        confirmLabel={confirmSuspend === 'suspend' ? 'Suspend Account' : 'Reactivate'}
        onCancel={() => setConfirmSuspend(null)}
        onConfirm={(reason) => void handleAccountStatusChange(reason)}
      />
    </div>
  );
}

