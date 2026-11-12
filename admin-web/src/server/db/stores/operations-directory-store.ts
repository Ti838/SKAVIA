import type { BranchSummary } from '@/lib/contracts';
import type {
  CustomerDirectoryItem,
  VerificationQueueItem,
  WorkerDirectoryItem,
} from '../repository';
import { firstJoined, type StoreDbClient } from './base';

export class SupabaseOperationsDirectoryStore {
  constructor(private readonly db: StoreDbClient) {}

  async listBranches(branchFilter: string[] | null): Promise<BranchSummary[]> {
    let q = this.db
      .from('branches')
      .select('branch_id, name, code, description, manager_id, is_active, created_at')
      .order('name', { ascending: true });
    if (branchFilter) q = q.in('branch_id', branchFilter);
    const { data, error } = await q;
    if (error) throw new Error(`Failed reading branches: ${error.message}`);
    return (data ?? []) as BranchSummary[];
  }

  async createBranch(input: {
    name: string;
    code: string;
    description?: string;
    managerId?: string | null;
  }): Promise<BranchSummary> {
    const { data, error } = await this.db
      .from('branches')
      .insert({
        name: input.name,
        code: input.code,
        description: input.description ?? null,
        manager_id: input.managerId ?? null,
      })
      .select('branch_id, name, code, description, manager_id, is_active, created_at')
      .single();
    if (error || !data) throw new Error(`Failed creating branch: ${error?.message ?? 'unknown'}`);
    return data as BranchSummary;
  }

  async updateBranch(
    branchId: string,
    patch: { name?: string; description?: string | null; isActive?: boolean; managerId?: string | null }
  ): Promise<BranchSummary> {
    const update: Record<string, unknown> = {};
    if (patch.name !== undefined) update.name = patch.name;
    if (patch.description !== undefined) update.description = patch.description;
    if (patch.isActive !== undefined) update.is_active = patch.isActive;
    if (patch.managerId !== undefined) update.manager_id = patch.managerId;

    const { data, error } = await this.db
      .from('branches')
      .update(update)
      .eq('branch_id', branchId)
      .select('branch_id, name, code, description, manager_id, is_active, created_at')
      .single();
    if (error || !data) throw new Error(`Failed updating branch: ${error?.message ?? 'unknown'}`);
    return data as BranchSummary;
  }

  async listCustomers(filters: {
    branchFilter: string[] | null;
    customerType?: string;
    search?: string;
    userId?: string;
  }): Promise<CustomerDirectoryItem[]> {
    let q = this.db
      .from('customer_profiles')
      .select(
        'user_id, customer_type, company_name, trade_license, created_at, users(user_id, full_name, email, phone, status, account_status, location, created_at)'
      )
      .order('created_at', { ascending: false })
      .limit(200);

    if (filters.userId) {
      q = q.eq('user_id', filters.userId);
    }

    const { data: profiles, error } = await q;
    if (error) throw new Error(`Failed reading customers: ${error.message}`);

    const profileRows = profiles ?? [];
    if (profileRows.length === 0) return [];

    const clientIds = profileRows.map((p) => String(p.user_id));
    const { data: srs } = await this.db
      .from('service_requests')
      .select('client_id, branch_id')
      .in('client_id', clientIds);

    const srByClient = new Map<string, { count: number; branches: Set<string> }>();
    for (const sr of srs ?? []) {
      const entry = srByClient.get(sr.client_id) ?? { count: 0, branches: new Set<string>() };
      entry.count += 1;
      if (sr.branch_id) entry.branches.add(sr.branch_id);
      srByClient.set(sr.client_id, entry);
    }

    const needle = filters.search?.trim().toLowerCase();
    const items: CustomerDirectoryItem[] = [];
    for (const row of profileRows) {
      const u = firstJoined(row.users);
      if (!u) continue;
      const stats = srByClient.get(u.user_id) ?? { count: 0, branches: new Set<string>() };
      const branchIds = Array.from(stats.branches);

      if (filters.branchFilter && !branchIds.some((id) => filters.branchFilter!.includes(id))) {
        continue;
      }
      const normalizedCustomerType =
        row.customer_type === 'Business' ? 'Business Client' : row.customer_type;
      if (filters.customerType && normalizedCustomerType !== filters.customerType) continue;
      if (needle) {
        const hay = `${u.full_name} ${u.email ?? ''} ${u.phone ?? ''} ${row.company_name ?? ''} ${u.user_id}`.toLowerCase();
        if (!hay.includes(needle)) continue;
      }

      items.push({
        user_id: u.user_id,
        full_name: u.full_name,
        email: u.email ?? null,
        phone: u.phone ?? null,
        status: u.status,
        account_status: u.account_status ?? 'active',
        location: u.location ?? null,
        customer_type: normalizedCustomerType as CustomerDirectoryItem['customer_type'],
        company_name: row.company_name ?? null,
        trade_license: row.trade_license ?? null,
        booking_count: stats.count,
        branch_ids: branchIds,
        created_at: u.created_at,
      });
    }
    return items;
  }

  async updateCustomer(
    customerId: string,
    patch: { fullName?: string; location?: string; accountStatus?: string }
  ): Promise<CustomerDirectoryItem> {
    const update: Record<string, unknown> = { updated_at: new Date().toISOString() };
    if (patch.fullName !== undefined) update.full_name = patch.fullName;
    if (patch.location !== undefined) update.location = patch.location;
    if (patch.accountStatus !== undefined) {
      update.account_status = patch.accountStatus;
      update.status = patch.accountStatus === 'active' ? 'Active' : 'Deactivated';
    }

    const { error } = await this.db.from('users').update(update).eq('user_id', customerId);
    if (error) throw new Error(`Failed updating customer: ${error.message}`);

    const list = await this.listCustomers({ branchFilter: null, userId: customerId });
    const found = list[0];
    if (!found) throw new Error('Customer not found after update');
    return found;
  }

  async listWorkers(filters: {
    branchFilter: string[] | null;
    verificationStatus?: string;
    search?: string;
    workerProfileId?: string;
  }): Promise<WorkerDirectoryItem[]> {
    let q = this.db
      .from('worker_profiles')
      .select(
        'worker_profile_id, user_id, branch_id, category_id, title, location, expected_rate, verification_status, rating_average, total_reviews, completed_jobs, is_available, created_at, users(full_name, email, phone, account_status), branches(name), categories(name), worker_skills(skills(name))'
      )
      .order('created_at', { ascending: false })
      .limit(200);

    if (filters.branchFilter) q = q.in('branch_id', filters.branchFilter);
    if (filters.verificationStatus) q = q.eq('verification_status', filters.verificationStatus);
    if (filters.workerProfileId) q = q.eq('worker_profile_id', filters.workerProfileId);

    const { data, error } = await q;
    if (error) throw new Error(`Failed listing workers: ${error.message}`);

    const needle = filters.search?.trim().toLowerCase();
    const out: WorkerDirectoryItem[] = [];
    for (const w of data ?? []) {
      const u = firstJoined(w.users);
      const b = firstJoined(w.branches);
      const c = firstJoined(w.categories);
      const skills: string[] = [];
      for (const ws of (w.worker_skills ?? []) as Array<{
        skills?: { name?: string } | Array<{ name?: string }>;
      }>) {
        const s = firstJoined(ws.skills);
        if (s?.name) skills.push(s.name);
      }

      const fullName = u?.full_name ?? 'Specialist';
      if (needle) {
        const hay = `${fullName} ${w.title} ${w.location} ${w.worker_profile_id} ${skills.join(' ')}`.toLowerCase();
        if (!hay.includes(needle)) continue;
      }

      out.push({
        worker_profile_id: w.worker_profile_id,
        user_id: w.user_id,
        full_name: fullName,
        email: u?.email ?? null,
        phone: u?.phone ?? null,
        branch_id: w.branch_id ?? null,
        branch_name: b?.name ?? null,
        category_id: w.category_id ?? null,
        category_name: c?.name ?? null,
        title: w.title,
        location: w.location,
        expected_rate: Number(w.expected_rate ?? 0),
        verification_status: w.verification_status,
        account_status: u?.account_status ?? 'active',
        rating_average: Number(w.rating_average ?? 5),
        total_reviews: Number(w.total_reviews ?? 0),
        completed_jobs: Number(w.completed_jobs ?? 0),
        is_available: Boolean(w.is_available),
        skills,
        created_at: w.created_at,
      });
    }
    return out;
  }

  async updateWorker(
    workerProfileId: string,
    action: 'suspend' | 'reactivate' | 'assign_branch',
    branchId?: string
  ): Promise<WorkerDirectoryItem> {
    const { data: wp, error: wpErr } = await this.db
      .from('worker_profiles')
      .select('worker_profile_id, user_id')
      .eq('worker_profile_id', workerProfileId)
      .single();
    if (wpErr || !wp) throw new Error('Worker profile not found');

    if (action === 'assign_branch') {
      if (!branchId) throw new Error('branchId required for assign_branch');
      const { error } = await this.db
        .from('worker_profiles')
        .update({ branch_id: branchId, updated_at: new Date().toISOString() })
        .eq('worker_profile_id', workerProfileId);
      if (error) throw new Error(error.message);
    } else {
      const nextAccount = action === 'suspend' ? 'suspended' : 'active';
      const nextStatus = action === 'suspend' ? 'Deactivated' : 'Active';
      await this.db
        .from('users')
        .update({ account_status: nextAccount, status: nextStatus, updated_at: new Date().toISOString() })
        .eq('user_id', wp.user_id);
      if (action === 'suspend') {
        await this.db
          .from('worker_profiles')
          .update({ is_available: false })
          .eq('worker_profile_id', workerProfileId);
      }
    }

    const updated = await this.listWorkers({ branchFilter: null, workerProfileId });
    const row = updated[0];
    if (!row) throw new Error('Worker not found after update');
    return row;
  }

  async listVerifications(filters: {
    branchFilter: string[] | null;
    status?: string;
    verificationId?: string;
  }): Promise<VerificationQueueItem[]> {
    let q = this.db
      .from('verifications')
      .select(
        'verification_id, worker_profile_id, document_type, document_number, document_file_url, status, reviewed_by, review_notes, reviewed_at, created_at, worker_profiles(user_id, branch_id, users(full_name), branches(name))'
      )
      .order('created_at', { ascending: false })
      .limit(200);

    if (filters.status) q = q.eq('status', filters.status);
    if (filters.verificationId) q = q.eq('verification_id', filters.verificationId);

    const { data, error } = await q;
    if (error) throw new Error(`Failed reading verifications: ${error.message}`);

    const out: VerificationQueueItem[] = [];
    for (const v of data ?? []) {
      const wp = firstJoined(v.worker_profiles);
      const bId = wp?.branch_id ?? null;
      if (filters.branchFilter && (!bId || !filters.branchFilter.includes(bId))) continue;
      const u = firstJoined(wp?.users);
      const b = firstJoined(wp?.branches);
      out.push({
        verification_id: v.verification_id,
        worker_profile_id: v.worker_profile_id,
        worker_user_id: wp?.user_id ?? '',
        worker_name: u?.full_name ?? 'Specialist',
        branch_id: bId,
        branch_name: b?.name ?? null,
        document_type: v.document_type,
        document_number: v.document_number,
        document_file_url: v.document_file_url,
        status: v.status as 'Pending' | 'Approved' | 'Rejected',
        reviewed_by: v.reviewed_by ?? null,
        review_notes: v.review_notes ?? null,
        reviewed_at: v.reviewed_at ?? null,
        created_at: v.created_at,
      });
    }
    return out;
  }

  async getVerificationById(verificationId: string): Promise<VerificationQueueItem | null> {
    const list = await this.listVerifications({ branchFilter: null, verificationId });
    return list[0] ?? null;
  }

  async decideVerification(input: {
    verificationId: string;
    adminUserId: string;
    decision: 'Approved' | 'Rejected';
    reviewNotes: string;
  }): Promise<VerificationQueueItem> {
    const { error } = await this.db.rpc('admin_review_verification', {
      p_verification_id: input.verificationId,
      p_admin_user_id: input.adminUserId,
      p_decision: input.decision,
      p_review_notes: input.reviewNotes,
    });
    if (error) throw new Error(error.message);
    const updated = await this.getVerificationById(input.verificationId);
    if (!updated) throw new Error('Verification record missing after update');
    return updated;
  }

  async createVerificationSignedUrl(fileUrlOrPath: string): Promise<string> {
    const marker = '/verifications/';
    const idx = fileUrlOrPath.indexOf(marker);
    const objectPath = idx >= 0 ? fileUrlOrPath.slice(idx + marker.length) : fileUrlOrPath;
    const { data, error } = await this.db.storage.from('verifications').createSignedUrl(objectPath, 60);
    if (error || !data?.signedUrl) {
      throw new Error(`Unable to issue private KYC signed URL: ${error?.message ?? 'missing object'}`);
    }
    return data.signedUrl;
  }
}

