'use client';

import { useCallback, useEffect, useState } from 'react';
import { CheckCircle2, CreditCard, RefreshCw, ShieldCheck, XCircle } from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatBdt, formatDateTime } from '@/lib/formatters';
import type { FinanceLedgerDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { KpiCard } from '@/components/ui/KpiCard';
import { DataTable, type TableColumn } from '@/components/ui/DataTable';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

export default function FinancePage() {
  const { session, selectedBranchId } = useAdminSession();
  const [finance, setFinance] = useState<FinanceLedgerDto | null>(null);
  const [actionType, setActionType] = useState<
    'PAYOUT_APPROVAL' | 'REFUND_APPROVAL' | 'COMMISSION_CHANGE'
  >('PAYOUT_APPROVAL');
  const [entityId, setEntityId] = useState('');
  const [amount, setAmount] = useState('');
  const [feePercent, setFeePercent] = useState('0.12');
  const [reason, setReason] = useState('');
  const [checkerNotes, setCheckerNotes] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const canRequest =
    session.effectivePermissions.includes('payout.request') ||
    session.effectivePermissions.includes('payment.refund.request') ||
    session.effectivePermissions.includes('commission.manage');
  const canApprove =
    session.effectivePermissions.includes('payout.approve') ||
    session.effectivePermissions.includes('payment.refund.approve') ||
    session.effectivePermissions.includes('commission.manage');

  const loadFinance = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const qs = selectedBranchId ? `?branchId=${encodeURIComponent(selectedBranchId)}` : '';
      const res = await apiFetch<{ finance: FinanceLedgerDto }>(`/api/admin/finance${qs}`);
      setFinance(res.finance);
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading finance ledger.');
    } finally {
      setLoading(false);
    }
  }, [selectedBranchId]);

  useEffect(() => {
    void loadFinance();
  }, [loadFinance]);

  async function handleSubmitMakerRequest(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await apiFetch('/api/admin/finance/approvals', {
        method: 'POST',
        body: JSON.stringify({
          actionType,
          entityId: entityId.trim(),
          reason: reason.trim(),
          idempotencyKey: `req-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
          amount: actionType !== 'COMMISSION_CHANGE' && amount ? Number(amount) : undefined,
          feePercent: actionType === 'COMMISSION_CHANGE' ? Number(feePercent) : undefined,
          branchId: selectedBranchId || null,
        }),
      });
      setEntityId('');
      setAmount('');
      setReason('');
      await loadFinance();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Maker request failed.');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleCheckerDecision(approvalId: string, decision: 'Approved' | 'Rejected') {
    setSubmitting(true);
    setError(null);
    try {
      await apiFetch('/api/admin/finance/approvals', {
        method: 'PATCH',
        body: JSON.stringify({
          approvalId,
          decision,
          checkerNotes:
            checkerNotes.trim().length >= 5
              ? checkerNotes.trim()
              : `${decision} after financial ledger & receipt verification.`,
        }),
      });
      setCheckerNotes('');
      await loadFinance();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Approval decision failed.');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleRunReconciliation() {
    setSubmitting(true);
    setError(null);
    try {
      await apiFetch('/api/admin/finance/reconcile', { method: 'POST', body: '{}' });
      await loadFinance();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Reconciliation failed.');
    } finally {
      setSubmitting(false);
    }
  }

  const paymentCols: TableColumn<FinanceLedgerDto['payments'][number]>[] = [
    {
      key: 'invoice',
      header: 'Invoice / Tx',
      render: (r) => (
        <div>
          <p className="font-mono-code font-semibold text-xs">
            {r.invoice_number || r.payment_id.slice(0, 8)}
          </p>
          <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
            {r.gateway_name || 'Manual'} {r.gateway_tx_id ? `· ${r.gateway_tx_id}` : ''}
          </p>
        </div>
      ),
    },
    { key: 'client', header: 'Client', render: (r) => r.client_name },
    {
      key: 'amount',
      header: 'Total (BDT)',
      align: 'right',
      render: (r) => formatBdt(r.total_amount),
    },
    {
      key: 'fee',
      header: 'SKAVIA Fee',
      align: 'right',
      render: (r) => `${formatBdt(r.skavia_fee)} (${Math.round(r.commission_percent_snapshot * 100)}%)`,
    },
    { key: 'status', header: 'Status', render: (r) => <StatusBadge status={r.status} /> },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Financial Operations & Maker-Checker</h1>
          <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
            Payments ledger, dual-control payout/refund approvals (Maker != Checker), and reconciliation.
          </p>
        </div>
        {canApprove && (
          <button
            type="button"
            disabled={submitting}
            onClick={() => void handleRunReconciliation()}
            className="inline-flex items-center gap-1.5 rounded-lg px-4 py-2 text-xs font-semibold text-white"
            style={{ backgroundColor: '#003399' }}
          >
            <RefreshCw className="h-3.5 w-3.5" />
            Run Ledger Reconciliation
          </button>
        )}
      </div>

      {error && <ErrorPanel message={error} onRetry={() => void loadFinance()} />}

      {loading || !finance ? (
        <LoadingPanel />
      ) : (
        <>
          <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <KpiCard
              label="Completed Volume"
              value={formatBdt(finance.summary.completedPaymentsTotal)}
              tone="royal"
              icon={<CreditCard className="h-4 w-4" />}
            />
            <KpiCard
              label="SKAVIA Platform Fee"
              value={formatBdt(finance.summary.skaviaFeeTotal)}
              tone="aqua"
            />
            <KpiCard
              label="Specialist Net Earnings"
              value={formatBdt(finance.summary.workerEarningsTotal)}
              tone="sky"
            />
            <KpiCard
              label="Pending Maker-Checker"
              value={finance.summary.pendingApprovalsCount}
              subtitle="Requires second admin verification"
              tone="peach"
              icon={<ShieldCheck className="h-4 w-4" />}
            />
          </section>

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
            {canRequest && (
              <form
                onSubmit={handleSubmitMakerRequest}
                className="lg:col-span-5 rounded-xl border p-5 space-y-3.5 h-fit"
                style={{
                  backgroundColor: 'var(--bg-surface)',
                  borderColor: 'var(--border-subtle)',
                }}
              >
                <h2 className="text-base font-semibold">Submit Maker Request (Step-Up)</h2>
                <select
                  value={actionType}
                  onChange={(e) =>
                    setActionType(
                      e.target.value as 'PAYOUT_APPROVAL' | 'REFUND_APPROVAL' | 'COMMISSION_CHANGE'
                    )
                  }
                  className="w-full rounded-lg border px-3 py-2 text-sm"
                  style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                >
                  <option value="PAYOUT_APPROVAL">Specialist Payout Request</option>
                  <option value="REFUND_APPROVAL">Customer Refund Request</option>
                  <option value="COMMISSION_CHANGE">Platform Commission Rule Change</option>
                </select>

                <input
                  type="text"
                  required
                  value={entityId}
                  onChange={(e) => setEntityId(e.target.value)}
                  placeholder="Target Payment / Worker / Rule UUID"
                  className="w-full rounded-lg border px-3 py-2 text-sm font-mono-code"
                  style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                />

                {actionType === 'COMMISSION_CHANGE' ? (
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    max="0.5"
                    required
                    value={feePercent}
                    onChange={(e) => setFeePercent(e.target.value)}
                    placeholder="Fee decimal (e.g. 0.12 for 12%)"
                    className="w-full rounded-lg border px-3 py-2 text-sm"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  />
                ) : (
                  <input
                    type="number"
                    min="1"
                    required
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    placeholder="Amount in BDT"
                    className="w-full rounded-lg border px-3 py-2 text-sm tabular-nums"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  />
                )}

                <textarea
                  rows={2}
                  required
                  minLength={8}
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  placeholder="Audit justification (min 8 chars)..."
                  className="w-full rounded-lg border p-2.5 text-sm"
                  style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                />

                <button
                  type="submit"
                  disabled={submitting}
                  className="w-full rounded-lg px-4 py-2 text-xs font-semibold text-white"
                  style={{ backgroundColor: '#003399' }}
                >
                  Submit For Second-Admin Approval
                </button>
              </form>
            )}

            <div className={`${canRequest ? 'lg:col-span-7' : 'lg:col-span-12'} space-y-3`}>
              <div className="flex flex-wrap items-center justify-between gap-2">
                <h2 className="text-base font-semibold">Dual-Control Approvals Queue</h2>
                {canApprove && (
                  <input
                    type="text"
                    value={checkerNotes}
                    onChange={(e) => setCheckerNotes(e.target.value)}
                    placeholder="Optional checker review note..."
                    className="rounded-lg border px-3 py-1.5 text-xs w-64"
                    style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
                  />
                )}
              </div>

              <div className="space-y-3">
                {finance.approvals.length === 0 ? (
                  <div
                    className="rounded-xl border p-6 text-xs"
                    style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)', color: 'var(--text-muted)' }}
                  >
                    No maker-checker approvals queued yet.
                  </div>
                ) : (
                  finance.approvals.map((app) => {
                    const isSelfMaker = app.maker_user_id === session.userId;
                    return (
                      <div
                        key={app.approval_id}
                        className="rounded-xl border p-4 space-y-2"
                        style={{
                          backgroundColor: 'var(--bg-surface)',
                          borderColor: 'var(--border-subtle)',
                        }}
                      >
                        <div className="flex flex-wrap items-center justify-between gap-2">
                          <div>
                            <span className="text-xs font-mono-code font-bold text-blue-700 dark:text-sky-400">
                              {app.action_type}
                            </span>{' '}
                            <span className="text-xs" style={{ color: 'var(--text-muted)' }}>
                              Entity {app.entity_id}
                            </span>
                          </div>
                          <StatusBadge status={app.status} />
                        </div>

                        <p className="text-sm">{app.maker_reason}</p>

                        <div className="flex flex-wrap items-center justify-between gap-2 pt-2 border-t text-xs" style={{ borderColor: 'var(--border-subtle)' }}>
                          <span style={{ color: 'var(--text-muted)' }}>
                            Maker: {app.maker_user_id} &middot; {formatDateTime(app.created_at)}
                          </span>

                          {app.status === 'Pending' && canApprove && (
                            isSelfMaker ? (
                              <span className="font-semibold text-amber-700">
                                Self-Approval Blocked (Maker != Checker)
                              </span>
                            ) : (
                              <div className="flex gap-2">
                                <button
                                  type="button"
                                  disabled={submitting}
                                  onClick={() => void handleCheckerDecision(app.approval_id, 'Rejected')}
                                  className="inline-flex items-center gap-1 rounded-lg bg-red-600 px-3 py-1 text-white font-semibold"
                                >
                                  <XCircle className="h-3.5 w-3.5" />
                                  Reject
                                </button>
                                <button
                                  type="button"
                                  disabled={submitting}
                                  onClick={() => void handleCheckerDecision(app.approval_id, 'Approved')}
                                  className="inline-flex items-center gap-1 rounded-lg bg-emerald-600 px-3 py-1 text-white font-semibold"
                                >
                                  <CheckCircle2 className="h-3.5 w-3.5" />
                                  Approve
                                </button>
                              </div>
                            )
                          )}
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            </div>
          </div>

          <section className="space-y-3">
            <h2 className="text-base font-semibold">Payments & Gateway Ledger</h2>
            <DataTable
              columns={paymentCols}
              rows={finance.payments}
              rowKey={(r) => r.payment_id}
            />
          </section>
        </>
      )}
    </div>
  );
}

