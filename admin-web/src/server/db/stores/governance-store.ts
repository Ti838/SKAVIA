import type { DashboardMetrics, SecurityIncidentItem } from '../repository';
import type { StoreDbClient } from './base';
import type { SupabaseIdentityStore } from './identity-store';
import type { SupabaseOperationsDirectoryStore } from './operations-directory-store';
import type { SupabaseOperationsDispatchStore } from './operations-dispatch-store';

const SECURITY_INCIDENT_COLUMNS =
  'incident_id, title, severity, status, source, affected_user_id, branch_id, summary, created_at, resolved_at';

export class SupabaseGovernanceStore {
  constructor(
    private readonly db: StoreDbClient,
    private readonly identity: SupabaseIdentityStore,
    private readonly directory: SupabaseOperationsDirectoryStore,
    private readonly dispatch: SupabaseOperationsDispatchStore
  ) {}

  async getDashboardMetrics(branchFilter: string[] | null): Promise<DashboardMetrics> {
    const [branchesRes, workersRes, bookingsRes, verifRes, disputesRes, paymentsRes, approvalsRes, incidentsRes, auditRes, custRes] =
      await Promise.all([
        this.directory.listBranches(branchFilter),
        this.directory.listWorkers({ branchFilter }),
        this.dispatch.listBookings({ branchFilter }),
        this.directory.listVerifications({ branchFilter, status: 'Pending' }),
        this.dispatch.listDisputes({ branchFilter, status: 'Investigating' }),
        this.db.from('payments').select('payment_id, branch_id, total_amount, status'),
        this.db.from('maker_checker_approvals').select('approval_id, branch_id').eq('status', 'Pending'),
        this.db.from('security_incidents').select('incident_id').in('status', ['Open', 'Investigating']),
        this.identity.listAuditLogs({ limit: 8 }),
        this.directory.listCustomers({ branchFilter }),
      ]);

    const filteredPayments = (paymentsRes.data ?? []).filter(
      (p) => !branchFilter || (p.branch_id && branchFilter.includes(p.branch_id))
    );
    const completedVolume = filteredPayments
      .filter((p) => p.status === 'Completed')
      .reduce((acc, p) => acc + Number(p.total_amount ?? 0), 0);

    const filteredApprovals = (approvalsRes.data ?? []).filter(
      (a) => !branchFilter || (a.branch_id && branchFilter.includes(a.branch_id))
    );

    const branchBreakdown = branchesRes.map((b) => {
      const bWorkers = workersRes.filter((w) => w.branch_id === b.branch_id).length;
      const bBookings = bookingsRes.filter(
        (bk) => bk.branch_id === b.branch_id && ['Requested', 'Accepted', 'In Progress'].includes(bk.status)
      ).length;
      const bVol = filteredPayments
        .filter((p) => p.branch_id === b.branch_id && p.status === 'Completed')
        .reduce((acc, p) => acc + Number(p.total_amount ?? 0), 0);
      return {
        branch_id: b.branch_id,
        code: b.code,
        name: b.name,
        activeBookings: bBookings,
        workersCount: bWorkers,
        volumeBdt: bVol,
      };
    });

    return {
      totalCustomers: custRes.length,
      totalWorkers: workersRes.length,
      verifiedWorkers: workersRes.filter((w) => w.verification_status === 'Verified').length,
      pendingVerifications: verifRes.length,
      activeBookings: bookingsRes.filter((b) => ['Requested', 'Accepted', 'In Progress'].includes(b.status)).length,
      openDisputes: disputesRes.length,
      completedPaymentsVolume: completedVolume,
      pendingFinancialApprovals: filteredApprovals.length,
      openSecurityIncidents: (incidentsRes.data ?? []).length,
      branchBreakdown,
      recentAuditLogs: auditRes,
    };
  }

  async globalSearch(query: string, branchFilter: string[] | null) {
    const q = query.trim().toLowerCase();
    if (!q) return [];
    const [customers, workers, bookings, branches] = await Promise.all([
      this.directory.listCustomers({ branchFilter, search: q }),
      this.directory.listWorkers({ branchFilter, search: q }),
      this.dispatch.listBookings({ branchFilter }),
      this.directory.listBranches(branchFilter),
    ]);

    const hits: Array<{ type: 'customer' | 'worker' | 'booking' | 'branch'; id: string; title: string; subtitle: string; href: string }> = [];
    for (const c of customers.slice(0, 4)) {
      hits.push({ type: 'customer', id: c.user_id, title: c.full_name, subtitle: `${c.customer_type} • ${c.email ?? c.user_id}`, href: `/customers?q=${encodeURIComponent(c.user_id)}` });
    }
    for (const w of workers.slice(0, 4)) {
      hits.push({ type: 'worker', id: w.worker_profile_id, title: w.full_name, subtitle: `${w.title} • ${w.branch_name ?? 'Unassigned'}`, href: `/workers?q=${encodeURIComponent(w.worker_profile_id)}` });
    }
    for (const b of bookings.filter((x) => x.service_request_id.toLowerCase().includes(q) || x.client_name.toLowerCase().includes(q)).slice(0, 4)) {
      hits.push({ type: 'booking', id: b.service_request_id, title: `Booking ${b.service_request_id.slice(0, 8)}`, subtitle: `${b.client_name} -> ${b.worker_name} (${b.status})`, href: `/bookings?id=${encodeURIComponent(b.service_request_id)}` });
    }
    for (const br of branches.filter((x) => x.name.toLowerCase().includes(q) || x.code.toLowerCase().includes(q))) {
      hits.push({ type: 'branch', id: br.branch_id, title: br.name, subtitle: `Branch Code: ${br.code}`, href: `/branches` });
    }
    return hits.slice(0, 12);
  }

  async listIncidents(): Promise<SecurityIncidentItem[]> {
    const { data, error } = await this.db
      .from('security_incidents')
      .select(SECURITY_INCIDENT_COLUMNS)
      .order('created_at', { ascending: false })
      .limit(100);
    if (error) throw new Error(error.message);
    return (data ?? []) as SecurityIncidentItem[];
  }

  async createIncident(input: { title: string; severity: string; summary: string; affectedUserId?: string; branchId?: string }): Promise<SecurityIncidentItem> {
    const { data, error } = await this.db
      .from('security_incidents')
      .insert({
        title: input.title,
        severity: input.severity,
        status: 'Open',
        source: 'Manual',
        affected_user_id: input.affectedUserId ?? null,
        branch_id: input.branchId ?? null,
        summary: input.summary,
      })
      .select(SECURITY_INCIDENT_COLUMNS)
      .single();
    if (error || !data) throw new Error(error?.message ?? 'Failed creating incident');
    return data as SecurityIncidentItem;
  }

  async updateIncident(input: { incidentId: string; status: string }): Promise<SecurityIncidentItem> {
    const resolvedAt = input.status === 'Resolved' || input.status === 'Closed' ? new Date().toISOString() : null;
    const { data, error } = await this.db
      .from('security_incidents')
      .update({ status: input.status, resolved_at: resolvedAt })
      .eq('incident_id', input.incidentId)
      .select(SECURITY_INCIDENT_COLUMNS)
      .single();
    if (error || !data) throw new Error(error?.message ?? 'Failed updating incident');
    return data as SecurityIncidentItem;
  }

  async getSystemSettings() {
    const { data, error } = await this.db
      .from('system_settings')
      .select('setting_key, setting_value, description, updated_at')
      .order('setting_key');
    if (error) throw new Error(error.message);
    return data ?? [];
  }

  async upsertSystemSetting(key: string, value: unknown, actorUserId: string) {
    const { error } = await this.db.from('system_settings').upsert({
      setting_key: key,
      setting_value: value,
      updated_by: actorUserId,
      updated_at: new Date().toISOString(),
    }, { onConflict: 'setting_key' });
    if (error) throw new Error(error.message);
  }

  async listBackupLogs() {
    const { data, error } = await this.db
      .from('backup_verification_logs')
      .select('verification_id, environment, restore_target, status, verified_at, rpo_minutes, rto_minutes')
      .order('verified_at', { ascending: false })
      .limit(25);
    if (error) throw new Error(error.message);
    return data ?? [];
  }
}

