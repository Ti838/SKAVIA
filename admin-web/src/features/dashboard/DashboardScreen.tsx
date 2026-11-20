'use client';

import { useCallback, useEffect, useState } from 'react';
import {
  AlertTriangle,
  BadgeCheck,
  Building2,
  CalendarClock,
  CreditCard,
  Scale,
  ShieldAlert,
  Users,
} from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatBdt, formatDateTime } from '@/lib/formatters';
import type { DashboardMetricsDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import { KpiCard } from '@/components/ui/KpiCard';
import { DataTable, type TableColumn } from '@/components/ui/DataTable';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';
import { StatusBadge } from '@/components/ui/StatusBadge';

export default function DashboardPage() {
  const { session, selectedBranchId } = useAdminSession();
  const { isBengali } = useTranslation();
  const [metrics, setMetrics] = useState<DashboardMetricsDto | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<{ message: string; code?: string; correlationId?: string } | null>(
    null
  );

  const loadMetrics = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const qs = selectedBranchId
        ? `?branchId=${encodeURIComponent(selectedBranchId)}`
        : '';
      const res = await apiFetch<{ metrics: DashboardMetricsDto }>(
        `/api/admin/dashboard${qs}`
      );
      setMetrics(res.metrics);
    } catch (err) {
      if (err instanceof AdminApiError) {
        setError({
          message: err.message,
          code: err.code,
          correlationId: err.correlationId,
        });
      } else {
        setError({
          message: err instanceof Error ? err.message : 'Failed loading dashboard.',
        });
      }
    } finally {
      setLoading(false);
    }
  }, [selectedBranchId]);

  useEffect(() => {
    void loadMetrics();
  }, [loadMetrics]);

  const isSuper = session.primaryRole === 'Super Admin';
  const canSeeGlobalFinance = session.effectivePermissions.includes('payment.view');
  const canSeeAudit = session.effectivePermissions.includes('security.audit.view');

  const branchCols: TableColumn<DashboardMetricsDto['branchBreakdown'][number]>[] = [
    {
      key: 'code',
      header: isBengali ? 'কোড' : 'Code',
      render: (r) => <span className="font-mono-code font-semibold">{r.code}</span>,
    },
    { key: 'name', header: isBengali ? 'শাখার নাম' : 'Branch Name', render: (r) => r.name },
    {
      key: 'workers',
      header: isBengali ? 'স্পেশালিস্ট' : 'Specialists',
      align: 'right',
      render: (r) => r.workersCount,
    },
    {
      key: 'bookings',
      header: isBengali ? 'সক্রিয় বুকিং' : 'Active Bookings',
      align: 'right',
      render: (r) => r.activeBookings,
    },
    {
      key: 'volume',
      header: isBengali ? 'সম্পন্ন ভলিউম' : 'Completed Volume',
      align: 'right',
      render: (r) => formatBdt(r.volumeBdt),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight" style={{ color: 'var(--text-primary)' }}>
            {session.primaryRole === 'Super Admin'
              ? isBengali
                ? 'এক্সিকিউটিভ গভর্নেন্স ও প্ল্যাটফর্ম ওভারভিউ'
                : 'Executive Governance & Platform Overview'
              : session.primaryRole === 'Company Admin'
                ? isBengali
                  ? 'কোম্পানি-ওয়াইড অপারেশনস কনসোল'
                  : 'Company-Wide Operations Console'
                : isBengali
                  ? 'নির্ধারিত শাখা অপারেশনস কনসোল'
                  : 'Assigned Branch Operations Console'}
          </h1>
          <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
            {isBengali ? `${session.fullName} হিসেবে লগইনকৃত` : `Signed in as ${session.fullName}`} ({session.primaryRole})
          </p>
        </div>

        <StatusBadge
          status={
            session.branchScoped
              ? isBengali
                ? 'শাখা ভিত্তিক সীমাবদ্ধ'
                : 'Branch Scoped'
              : isBengali
                ? 'কোম্পানি ওয়াইড'
                : 'Company Wide'
          }
          variant="info"
        />
      </div>

      {loading && <LoadingPanel />}
      {error && (
        <ErrorPanel
          message={error.message}
          code={error.code}
          correlationId={error.correlationId}
          onRetry={() => void loadMetrics()}
        />
      )}

      {!loading && !error && metrics && (
        <>
          <section className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
            <KpiCard
              label={isBengali ? 'সক্রিয় বুকিং' : 'Active Bookings'}
              value={metrics.activeBookings}
              subtitle={isBengali ? 'অনুরোধকৃত, গৃহীত ও চলমান' : 'Requested, Accepted & In Progress'}
              href="/bookings"
              tone="royal"
              icon={<CalendarClock className="h-4 w-4" />}
            />
            <KpiCard
              label={isBengali ? 'অপেক্ষমান কেওয়াইসি রিভিউ' : 'Pending KYC Reviews'}
              value={metrics.pendingVerifications}
              subtitle={
                isBengali
                  ? `${metrics.verifiedWorkers} যাচাইকৃত / ${metrics.totalWorkers} স্পেশালিস্ট`
                  : `${metrics.verifiedWorkers} verified / ${metrics.totalWorkers} specialists`
              }
              href="/verifications"
              tone="peach"
              icon={<BadgeCheck className="h-4 w-4" />}
            />
            <KpiCard
              label={isBengali ? 'উন্মুক্ত বিরোধ' : 'Open Disputes'}
              value={metrics.openDisputes}
              subtitle={isBengali ? 'মধ্যস্থতা পর্যালোচনা প্রয়োজন' : 'Requires mediation review'}
              href="/disputes"
              tone={metrics.openDisputes > 0 ? 'danger' : 'neutral'}
              icon={<Scale className="h-4 w-4" />}
            />
            {canSeeGlobalFinance ? (
              <KpiCard
                label={isBengali ? 'সম্পন্ন ভলিউম' : 'Completed Volume'}
                value={formatBdt(metrics.completedPaymentsVolume)}
                subtitle={
                  isBengali
                    ? `${metrics.pendingFinancialApprovals} মেকার-চেকার অনুমোদন অপেক্ষমান`
                    : `${metrics.pendingFinancialApprovals} maker-checker approvals pending`
                }
                href="/finance"
                tone="aqua"
                icon={<CreditCard className="h-4 w-4" />}
              />
            ) : (
              <KpiCard
                label={isBengali ? 'দৃশ্যমান গ্রাহক' : 'Visible Customers'}
                value={metrics.totalCustomers}
                subtitle={
                  isBengali
                    ? 'আপনার শাখার আওতাধীন গ্রাহকবৃন্দ'
                    : 'Customers served within your branch scope'
                }
                href="/customers"
                tone="sky"
                icon={<Users className="h-4 w-4" />}
              />
            )}
          </section>

          {isSuper && (
            <section className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <KpiCard
                label={isBengali ? 'মোট গ্রাহক' : 'Total Customers'}
                value={metrics.totalCustomers}
                subtitle={
                  isBengali
                    ? 'ব্যক্তিগত, বিজনেস ও সংস্থা'
                    : 'Individual, Business Client & Organization'
                }
                href="/customers"
                tone="sky"
                icon={<Users className="h-4 w-4" />}
              />
              <KpiCard
                label={isBengali ? 'পেন্ডিং মেকার-চেকার' : 'Pending Maker-Checker'}
                value={metrics.pendingFinancialApprovals}
                subtitle={isBengali ? 'পেআউট, রিফান্ড ও কমিশন' : 'Payouts, Refunds & Commission Rules'}
                href="/finance"
                tone="peach"
                icon={<AlertTriangle className="h-4 w-4" />}
              />
              <KpiCard
                label={isBengali ? 'উন্মুক্ত সিকিউরিটি ইনসিডেন্ট' : 'Open Security Incidents'}
                value={metrics.openSecurityIncidents}
                subtitle={isBengali ? 'সক্রিয় তদন্ত ও নিয়ন্ত্রণ' : 'Active containment / investigation'}
                href="/security"
                tone={metrics.openSecurityIncidents > 0 ? 'danger' : 'aqua'}
                icon={<ShieldAlert className="h-4 w-4" />}
              />
            </section>
          )}

          <section className="space-y-3">
            <div className="flex items-center gap-2">
              <Building2 className="h-4 w-4 text-blue-600" />
              <h2 className="text-base font-semibold" style={{ color: 'var(--text-primary)' }}>
                {isBengali ? 'অভ্যন্তরীণ স্ক্যাভিয়া শাখা পারফরম্যান্স' : 'Internal SKAVIA Branch Performance'}
              </h2>
            </div>
            <DataTable
              columns={branchCols}
              rows={metrics.branchBreakdown}
              rowKey={(r) => r.branch_id}
              emptyTitle={isBengali ? 'অনুমোদিত কোনো শাখা পাওয়া যায়নি' : 'No authorized branches found'}
              emptyDescription={
                isBengali
                  ? 'অ্যাডমিন শাখা দায়িত্ব অথবা ফিল্টার চেক করুন।'
                  : 'Check admin_branch_assignments or branch scope filter.'
              }
            />
          </section>

          {canSeeAudit && (
            <section className="space-y-3">
              <h2 className="text-base font-semibold" style={{ color: 'var(--text-primary)' }}>
                {isBengali
                  ? 'সাম্প্রতিক অপরিবর্তনীয় নিরাপত্তা ও অপারেশনস অডিট ট্রেইল'
                  : 'Recent Immutable Security & Operations Audit Trail'}
              </h2>
              <div
                className="rounded-xl border divide-y"
                style={{
                  backgroundColor: 'var(--bg-surface)',
                  borderColor: 'var(--border-subtle)',
                }}
              >
                {metrics.recentAuditLogs.length === 0 ? (
                  <p className="p-6 text-xs" style={{ color: 'var(--text-muted)' }}>
                    {isBengali
                      ? 'এখনও কোনো অডিট ইভেন্ট রেকর্ড করা হয়নি।'
                      : 'No audit events recorded yet.'}
                  </p>
                ) : (
                  metrics.recentAuditLogs.map((log) => (
                    <div
                      key={log.audit_id}
                      className="px-4 py-3 flex flex-wrap items-center justify-between gap-2 text-xs"
                    >
                      <div className="min-w-0">
                        <span className="font-mono-code font-semibold text-blue-700 dark:text-sky-400">
                          {log.action}
                        </span>{' '}
                        <span style={{ color: 'var(--text-secondary)' }}>
                          on {log.entity_type} {log.entity_id ? `(${log.entity_id})` : ''}
                        </span>
                      </div>
                      <span className="tabular-nums" style={{ color: 'var(--text-muted)' }}>
                        {formatDateTime(log.created_at)}
                      </span>
                    </div>
                  ))
                )}
              </div>
            </section>
          )}
        </>
      )}
    </div>
  );
}

