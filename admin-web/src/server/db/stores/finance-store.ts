import type { FinanceLedgerSnapshot } from '../repository';
import { firstJoined, type StoreDbClient } from './base';

export class SupabaseFinanceStore {
  constructor(private readonly db: StoreDbClient) {}

  async getFinanceSnapshot(branchFilter: string[] | null): Promise<FinanceLedgerSnapshot> {
    const [payRes, appRes, rulesRes, earnRes, payoutsRes, refundsRes] = await Promise.all([
      this.db
        .from('payments')
        .select('payment_id, branch_id, client_id, total_amount, skavia_fee, commission_percent_snapshot, status, paid_at, created_at, users(full_name), transactions(gateway_name, gateway_tx_id), invoices(invoice_number)')
        .order('created_at', { ascending: false })
        .limit(150),
      this.db
        .from('maker_checker_approvals')
        .select(
          'approval_id, action_type, entity_type, entity_id, branch_id, payload, idempotency_key, status, maker_user_id, checker_user_id, maker_reason, checker_notes, created_at, decided_at'
        )
        .order('created_at', { ascending: false })
        .limit(100),
      this.db
        .from('commission_rules')
        .select('rule_id, branch_id, category_id, fee_percent, is_active, effective_from, approved_by')
        .order('created_at', { ascending: false }),
      this.db.from('worker_earnings').select('amount, status'),
      this.db.from('payout_requests').select('amount, status').in('status', ['Requested', 'PendingApproval']),
      this.db.from('refund_requests').select('refund_amount, status').eq('status', 'Requested'),
    ]);

    const payments = (payRes.data ?? [])
      .filter((p) => !branchFilter || (p.branch_id && branchFilter.includes(p.branch_id)))
      .map((p) => {
        const u = firstJoined(p.users);
        const tx = firstJoined(p.transactions);
        const inv = firstJoined(p.invoices);
        return {
          payment_id: p.payment_id,
          branch_id: p.branch_id ?? null,
          client_id: p.client_id,
          client_name: u?.full_name ?? 'Client',
          total_amount: Number(p.total_amount ?? 0),
          skavia_fee: Number(p.skavia_fee ?? 0),
          commission_percent_snapshot: Number(p.commission_percent_snapshot ?? 0.15),
          status: p.status,
          paid_at: p.paid_at ?? null,
          created_at: p.created_at,
          gateway_name: (tx as { gateway_name?: string } | null)?.gateway_name ?? null,
          gateway_tx_id: (tx as { gateway_tx_id?: string } | null)?.gateway_tx_id ?? null,
          invoice_number: (inv as { invoice_number?: string } | null)?.invoice_number ?? null,
        };
      });

    const completedPayments = payments.filter((p) => p.status === 'Completed');
    const approvals = (appRes.data ?? []).filter(
      (a) => !branchFilter || (a.branch_id && branchFilter.includes(a.branch_id))
    );

    return {
      summary: {
        completedPaymentsTotal: completedPayments.reduce((s, p) => s + p.total_amount, 0),
        skaviaFeeTotal: completedPayments.reduce((s, p) => s + p.skavia_fee, 0),
        workerEarningsTotal: (earnRes.data ?? []).reduce((s, e) => s + Number(e.amount ?? 0), 0),
        pendingApprovalsCount: approvals.filter((a) => a.status === 'Pending').length,
        pendingPayoutsAmount: (payoutsRes.data ?? []).reduce((s, r) => s + Number(r.amount ?? 0), 0),
        pendingRefundsAmount: (refundsRes.data ?? []).reduce((s, r) => s + Number(r.refund_amount ?? 0), 0),
      },
      payments,
      approvals: approvals as FinanceLedgerSnapshot['approvals'],
      commissionRules: (rulesRes.data ?? []) as FinanceLedgerSnapshot['commissionRules'],
    };
  }

  async createApprovalRequest(input: {
    actionType: 'PAYOUT_APPROVAL' | 'REFUND_APPROVAL' | 'COMMISSION_CHANGE' | 'SYSTEM_CONFIG';
    entityType: string;
    entityId: string;
    branchId: string | null;
    payload: Record<string, unknown>;
    idempotencyKey: string;
    makerUserId: string;
    makerReason: string;
  }) {
    const { data, error } = await this.db
      .from('maker_checker_approvals')
      .insert({
        action_type: input.actionType,
        entity_type: input.entityType,
        entity_id: input.entityId,
        branch_id: input.branchId,
        payload: input.payload,
        idempotency_key: input.idempotencyKey,
        status: 'Pending',
        maker_user_id: input.makerUserId,
        maker_reason: input.makerReason,
      })
      .select('approval_id, status')
      .single();

    if (error || !data) throw new Error(error?.message ?? 'Failed creating approval request');
    return data;
  }

  async decideApprovalRequest(input: {
    approvalId: string;
    checkerUserId: string;
    decision: 'Approved' | 'Rejected';
    checkerNotes: string;
  }) {
    const { data: existing, error: fetchErr } = await this.db
      .from('maker_checker_approvals')
      .select('approval_id, status, maker_user_id, action_type, branch_id, payload')
      .eq('approval_id', input.approvalId)
      .single();

    if (fetchErr || !existing) throw new Error('Approval request not found');
    if (existing.status !== 'Pending') {
      throw new Error(`Approval already finalized as ${existing.status}`);
    }
    if (existing.maker_user_id === input.checkerUserId) {
      throw new Error('Maker-Checker violation: requester cannot approve own request');
    }

    const { error: updErr } = await this.db
      .from('maker_checker_approvals')
      .update({
        status: input.decision,
        checker_user_id: input.checkerUserId,
        checker_notes: input.checkerNotes,
        decided_at: new Date().toISOString(),
        executed_at: input.decision === 'Approved' ? new Date().toISOString() : null,
      })
      .eq('approval_id', input.approvalId)
      .eq('status', 'Pending');

    if (updErr) throw new Error(updErr.message);

    if (input.decision === 'Approved') {
      if (existing.action_type === 'COMMISSION_CHANGE') {
        const feePercent = Number((existing.payload as { feePercent?: number })?.feePercent ?? 0.15);
        await this.db.from('commission_rules').insert({
          branch_id: existing.branch_id,
          fee_percent: feePercent,
          is_active: true,
          approved_by: input.checkerUserId,
          approval_id: input.approvalId,
        });
      } else if (existing.action_type === 'REFUND_APPROVAL') {
        await this.db.from('refund_requests').update({ status: 'Approved' }).eq('approval_id', input.approvalId);
      } else if (existing.action_type === 'PAYOUT_APPROVAL') {
        await this.db.from('payout_requests').update({ status: 'Approved' }).eq('approval_id', input.approvalId);
      }
    }

    return { approval_id: input.approvalId, status: input.decision };
  }

  async runReconciliation(actorUserId: string) {
    const { data: payments } = await this.db
      .from('payments')
      .select('payment_id, total_amount, skavia_fee, status')
      .eq('status', 'Completed');
    const { data: invoices } = await this.db
      .from('invoices')
      .select('payment_id, worker_amount, skavia_fee, total_amount');

    const totalPayments = (payments ?? []).reduce((s, p) => s + Number(p.total_amount ?? 0), 0);
    const totalSkaviaFee = (payments ?? []).reduce((s, p) => s + Number(p.skavia_fee ?? 0), 0);
    const totalInvoices = (invoices ?? []).reduce((s, i) => s + Number(i.total_amount ?? 0), 0);
    const variance = Number(Math.abs(totalPayments - totalInvoices).toFixed(2));
    const status = variance <= 0.01 ? 'Matched' : 'VarianceDetected';

    const { data, error } = await this.db
      .from('reconciliation_runs')
      .insert({
        period_start: new Date(Date.now() - 30 * 86400 * 1000).toISOString(),
        period_end: new Date().toISOString(),
        total_payments: totalPayments,
        total_worker_earnings: totalPayments - totalSkaviaFee,
        total_skavia_fee: totalSkaviaFee,
        variance_amount: variance,
        status,
        run_by: actorUserId,
        notes: status === 'Matched' ? 'Completed payments match settled invoices.' : 'Variance detected between payments and invoices.',
      })
      .select('run_id, status, variance_amount')
      .single();

    if (error || !data) throw new Error(error?.message ?? 'Failed recording reconciliation run');
    return { run_id: data.run_id, status: data.status, variance_amount: Number(data.variance_amount) };
  }
}

