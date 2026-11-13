'use client';

import { useCallback, useEffect, useState } from 'react';
import { Download } from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatBdt } from '@/lib/formatters';
import type { DashboardMetricsDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { DataTable, type TableColumn } from '@/components/ui/DataTable';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

export default function ReportsPage() {
  const { selectedBranchId } = useAdminSession();
  const [metrics, setMetrics] = useState<DashboardMetricsDto | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadReports = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const qs = selectedBranchId ? `?branchId=${encodeURIComponent(selectedBranchId)}` : '';
      const res = await apiFetch<{ metrics: DashboardMetricsDto }>(`/api/admin/reports${qs}`);
      setMetrics(res.metrics);
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading reports.');
    } finally {
      setLoading(false);
    }
  }, [selectedBranchId]);

  useEffect(() => {
    void loadReports();
  }, [loadReports]);

  const exportUrl = `/api/admin/reports?format=csv${
    selectedBranchId ? `&branchId=${encodeURIComponent(selectedBranchId)}` : ''
  }`;

  const columns: TableColumn<DashboardMetricsDto['branchBreakdown'][number]>[] = [
    { key: 'code', header: 'Code', render: (r) => <span className="font-mono-code">{r.code}</span> },
    { key: 'name', header: 'Branch', render: (r) => r.name },
    { key: 'workers', header: 'Specialists', align: 'right', render: (r) => r.workersCount },
    { key: 'bookings', header: 'Active Bookings', align: 'right', render: (r) => r.activeBookings },
    { key: 'volume', header: 'Revenue Volume', align: 'right', render: (r) => formatBdt(r.volumeBdt) },
  ];

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Operational & Financial Reports</h1>
          <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
            Audited CSV export respects branch isolation and escapes formula prefixes.
          </p>
        </div>

        <a
          href={exportUrl}
          className="inline-flex items-center gap-1.5 rounded-lg px-4 py-2 text-xs font-semibold text-white"
          style={{ backgroundColor: '#003399' }}
        >
          <Download className="h-4 w-4" />
          Export Authorized CSV
        </a>
      </div>

      {error && <ErrorPanel message={error} onRetry={() => void loadReports()} />}

      {loading || !metrics ? (
        <LoadingPanel />
      ) : (
        <DataTable
          columns={columns}
          rows={metrics.branchBreakdown}
          rowKey={(r) => r.branch_id}
        />
      )}
    </div>
  );
}

