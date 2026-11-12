import type {
  BookingListItem,
  DisputeItem,
  ProjectSummaryItem,
  ServiceTaxonomyItem,
} from '../repository';
import { firstJoined, type StoreDbClient } from './base';

export class SupabaseOperationsDispatchStore {
  constructor(private readonly db: StoreDbClient) {}

  async listBookings(filters: {
    branchFilter: string[] | null;
    status?: string;
    bookingId?: string;
  }): Promise<BookingListItem[]> {
    let q = this.db
      .from('service_requests')
      .select(
        'service_request_id, requirement_id, branch_id, client_id, worker_profile_id, status, scheduled_at, agreed_price, service_notes, cancellation_reason, created_at, branches(name), users!service_requests_client_id_fkey(full_name), worker_profiles(branch_id, users(full_name))'
      )
      .order('created_at', { ascending: false })
      .limit(200);

    if (filters.status) q = q.eq('status', filters.status);
    if (filters.bookingId) q = q.eq('service_request_id', filters.bookingId);

    const { data, error } = await q;
    if (error) throw new Error(`Failed reading bookings: ${error.message}`);

    const out: BookingListItem[] = [];
    for (const r of data ?? []) {
      const wp = firstJoined(r.worker_profiles);
      const effectiveBranchId = r.branch_id ?? wp?.branch_id ?? null;
      if (filters.branchFilter && (!effectiveBranchId || !filters.branchFilter.includes(effectiveBranchId))) {
        continue;
      }
      const b = firstJoined(r.branches);
      const rawRow = r as Record<string, unknown>;
      const joinedClient = rawRow['users!service_requests_client_id_fkey'] ?? rawRow.users;
      const c = Array.isArray(joinedClient) ? joinedClient[0] : joinedClient;
      const wu = firstJoined(wp?.users);

      out.push({
        service_request_id: r.service_request_id,
        requirement_id: r.requirement_id ?? null,
        branch_id: effectiveBranchId,
        branch_name: b?.name ?? null,
        client_id: r.client_id,
        client_name: (c as { full_name?: string } | null)?.full_name ?? 'Client',
        worker_profile_id: r.worker_profile_id,
        worker_name: wu?.full_name ?? 'Assigned Specialist',
        status: r.status,
        scheduled_at: r.scheduled_at ?? null,
        agreed_price: Number(r.agreed_price ?? 0),
        service_notes: r.service_notes ?? null,
        cancellation_reason: r.cancellation_reason ?? null,
        created_at: r.created_at,
      });
    }
    return out;
  }

  async updateBooking(
    bookingId: string,
    patch: {
      action: 'assign_worker' | 'reschedule' | 'cancel' | 'complete';
      workerProfileId?: string;
      scheduledAt?: string;
      reason: string;
      actorUserId: string;
    }
  ): Promise<BookingListItem> {
    const update: Record<string, unknown> = { updated_at: new Date().toISOString() };
    if (patch.action === 'assign_worker') {
      if (!patch.workerProfileId) throw new Error('workerProfileId is required');
      update.worker_profile_id = patch.workerProfileId;
      update.status = 'Accepted';
    } else if (patch.action === 'reschedule') {
      if (!patch.scheduledAt) throw new Error('scheduledAt is required');
      update.scheduled_at = patch.scheduledAt;
    } else if (patch.action === 'cancel') {
      update.status = 'Canceled';
      update.cancellation_reason = patch.reason;
      update.cancelled_by = patch.actorUserId;
    } else if (patch.action === 'complete') {
      update.status = 'Completed';
    }

    const { error } = await this.db
      .from('service_requests')
      .update(update)
      .eq('service_request_id', bookingId);
    if (error) throw new Error(error.message);

    const list = await this.listBookings({ branchFilter: null, bookingId });
    const found = list[0];
    if (!found) throw new Error('Booking not found');
    return found;
  }

  async listProjects(
    branchFilter: string[] | null,
    projectId?: string
  ): Promise<ProjectSummaryItem[]> {
    let q = this.db
      .from('projects')
      .select(
        'project_id, client_id, branch_id, title, description, status, deadline, total_budget, created_at, users(full_name), branches(name), teams(team_id, name, status, team_members(team_member_id, worker_profile_id, role_in_team, is_team_leader, worker_profiles(users(full_name)))), tasks(task_id, title, status, priority, deadline)'
      )
      .order('created_at', { ascending: false })
      .limit(100);

    if (branchFilter) q = q.in('branch_id', branchFilter);
    if (projectId) q = q.eq('project_id', projectId);
    const { data, error } = await q;
    if (error) throw new Error(`Failed reading projects: ${error.message}`);

    return (data ?? []).map((p) => {
      const u = firstJoined(p.users);
      const b = firstJoined(p.branches);
      return {
        project_id: p.project_id,
        client_id: p.client_id,
        client_name: u?.full_name ?? 'Enterprise Client',
        branch_id: p.branch_id ?? null,
        branch_name: b?.name ?? null,
        title: p.title,
        description: p.description ?? null,
        status: p.status,
        deadline: p.deadline ?? null,
        total_budget: Number(p.total_budget ?? 0),
        teams: ((p.teams ?? []) as Array<Record<string, unknown>>).map((t) => ({
          team_id: String(t.team_id),
          name: String(t.name),
          status: String(t.status),
          members: ((t.team_members as Array<Record<string, unknown>>) ?? []).map((m) => {
            const wp = Array.isArray(m.worker_profiles) ? m.worker_profiles[0] : m.worker_profiles;
            const wu =
              wp && Array.isArray((wp as Record<string, unknown>).users)
                ? ((wp as Record<string, unknown>).users as Array<{ full_name?: string }>)[0]
                : (wp as { users?: { full_name?: string } } | null)?.users;
            return {
              team_member_id: String(m.team_member_id),
              worker_profile_id: String(m.worker_profile_id),
              worker_name: wu?.full_name ?? 'Specialist',
              role_in_team: String(m.role_in_team),
              is_team_leader: Boolean(m.is_team_leader),
            };
          }),
        })),
        tasks: ((p.tasks ?? []) as Array<Record<string, unknown>>).map((tk) => ({
          task_id: String(tk.task_id),
          title: String(tk.title),
          status: String(tk.status),
          priority: String(tk.priority),
          deadline: tk.deadline ? String(tk.deadline) : null,
        })),
      };
    });
  }

  async assembleProjectTeam(input: {
    projectId: string;
    teamName: string;
    members: Array<{ workerProfileId: string; roleInTeam: string; isTeamLeader: boolean }>;
    initialTasks: Array<{
      title: string;
      description?: string;
      priority: 'Low' | 'Medium' | 'High';
      deadline?: string;
      assignedWorkerProfileId?: string;
    }>;
  }): Promise<ProjectSummaryItem> {
    const { data: team, error: teamErr } = await this.db
      .from('teams')
      .insert({ project_id: input.projectId, name: input.teamName, status: 'Active' })
      .select('team_id')
      .single();
    if (teamErr || !team) throw new Error(`Failed creating team: ${teamErr?.message ?? 'unknown'}`);

    const memberRows = input.members.map((m) => ({
      team_id: team.team_id,
      worker_profile_id: m.workerProfileId,
      role_in_team: m.roleInTeam,
      is_team_leader: m.isTeamLeader,
    }));

    const { data: insertedMembers, error: memErr } = await this.db
      .from('team_members')
      .insert(memberRows)
      .select('team_member_id, worker_profile_id');
    if (memErr) throw new Error(`Failed adding team members: ${memErr.message}`);

    const memberMap = new Map<string, string>();
    for (const row of insertedMembers ?? []) {
      memberMap.set(row.worker_profile_id, row.team_member_id);
    }

    if (input.initialTasks.length > 0) {
      const taskRows = input.initialTasks.map((t) => ({
        project_id: input.projectId,
        assigned_team_member_id: t.assignedWorkerProfileId
          ? memberMap.get(t.assignedWorkerProfileId) ?? null
          : null,
        title: t.title,
        description: t.description ?? null,
        priority: t.priority,
        deadline: t.deadline ?? null,
        status: 'Assigned',
      }));
      const { error: taskErr } = await this.db.from('tasks').insert(taskRows);
      if (taskErr) throw new Error(`Failed inserting project tasks: ${taskErr.message}`);
    }

    await this.db
      .from('projects')
      .update({ status: 'Team Formed', updated_at: new Date().toISOString() })
      .eq('project_id', input.projectId);

    const projects = await this.listProjects(null, input.projectId);
    const updated = projects[0];
    if (!updated) throw new Error('Project not found after team assembly');
    return updated;
  }

  async listDisputes(filters: {
    branchFilter: string[] | null;
    status?: string;
    disputeId?: string;
  }): Promise<DisputeItem[]> {
    let q = this.db
      .from('disputes')
      .select(
        'dispute_id, complaint_id, assigned_admin_id, status, resolution, resolved_at, created_at, complaints(branch_id, filed_by, service_request_id, category, description, branches(name), users!complaints_filed_by_fkey(full_name)), dispute_notes(note_id, author_id, note_type, content, created_at)'
      )
      .order('created_at', { ascending: false })
      .limit(100);

    if (filters.status) q = q.eq('status', filters.status);
    if (filters.disputeId) q = q.eq('dispute_id', filters.disputeId);

    const { data, error } = await q;
    if (error) throw new Error(`Failed listing disputes: ${error.message}`);

    const out: DisputeItem[] = [];
    for (const d of data ?? []) {
      const c = firstJoined(d.complaints);
      const bId = c?.branch_id ?? null;
      if (filters.branchFilter && (!bId || !filters.branchFilter.includes(bId))) continue;
      const br = firstJoined(c?.branches);
      const rawComplaint = (c ?? {}) as Record<string, unknown>;
      const joinedFiler = rawComplaint['users!complaints_filed_by_fkey'] ?? rawComplaint.users;
      const u = Array.isArray(joinedFiler) ? joinedFiler[0] : joinedFiler;

      out.push({
        dispute_id: d.dispute_id,
        complaint_id: d.complaint_id,
        branch_id: bId,
        branch_name: br?.name ?? null,
        filed_by: c?.filed_by ?? '',
        filed_by_name: (u as { full_name?: string } | null)?.full_name ?? 'User',
        service_request_id: c?.service_request_id ?? null,
        category: c?.category ?? 'General',
        complaint_description: c?.description ?? '',
        assigned_admin_id: d.assigned_admin_id ?? null,
        status: d.status,
        resolution: d.resolution ?? null,
        resolved_at: d.resolved_at ?? null,
        created_at: d.created_at,
        notes: ((d.dispute_notes ?? []) as Array<Record<string, unknown>>).map((n) => ({
          note_id: String(n.note_id),
          author_id: String(n.author_id),
          note_type: String(n.note_type),
          content: String(n.content),
          created_at: String(n.created_at),
        })),
      });
    }
    return out;
  }

  async resolveDispute(input: {
    disputeId: string;
    adminUserId: string;
    status: 'Resolved' | 'Dismissed';
    resolution: string;
    noteType: 'Internal' | 'Decision' | 'RefundRecommendation';
  }): Promise<DisputeItem> {
    const { error } = await this.db
      .from('disputes')
      .update({
        status: input.status,
        resolution: input.resolution,
        assigned_admin_id: input.adminUserId,
        resolved_at: new Date().toISOString(),
      })
      .eq('dispute_id', input.disputeId);
    if (error) throw new Error(error.message);

    await this.db.from('dispute_notes').insert({
      dispute_id: input.disputeId,
      author_id: input.adminUserId,
      note_type: input.noteType,
      content: input.resolution,
    });

    const list = await this.listDisputes({ branchFilter: null, disputeId: input.disputeId });
    const found = list[0];
    if (!found) throw new Error('Dispute not found after update');
    return found;
  }

  async getServiceTaxonomy(): Promise<ServiceTaxonomyItem> {
    const [cats, svcs, sks] = await Promise.all([
      this.db
        .from('categories')
        .select('category_id, branch_id, name, slug, icon_name, is_active, branches(name)')
        .order('name'),
      this.db
        .from('services')
        .select('service_id, category_id, name, description, base_price')
        .order('name'),
      this.db.from('skills').select('skill_id, category_id, service_id, name').order('name'),
    ]);

    return {
      categories: (cats.data ?? []).map((c) => {
        const b = firstJoined(c.branches);
        return {
          category_id: c.category_id,
          branch_id: c.branch_id ?? null,
          branch_name: b?.name ?? null,
          name: c.name,
          slug: c.slug,
          icon_name: c.icon_name,
          is_active: Boolean(c.is_active),
        };
      }),
      services: (svcs.data ?? []).map((s) => ({
        service_id: s.service_id,
        category_id: s.category_id,
        name: s.name,
        description: s.description ?? null,
        base_price: Number(s.base_price ?? 0),
      })),
      skills: (sks.data ?? []).map((k) => ({
        skill_id: k.skill_id,
        category_id: k.category_id ?? null,
        service_id: k.service_id ?? null,
        name: k.name,
      })),
    };
  }

  async mutateServiceTaxonomy(input: Record<string, unknown>): Promise<void> {
    const type = input.type as string;
    const action = input.action as string;

    if (type === 'category') {
      if (action === 'create') {
        const { error } = await this.db.from('categories').insert({
          branch_id: input.branchId ?? null,
          name: input.name,
          slug: input.slug,
          icon_name: input.iconName ?? 'build',
          description: input.description ?? null,
          is_active: true,
        });
        if (error) throw new Error(error.message);
      } else if (action === 'toggle' && input.id) {
        const { error } = await this.db
          .from('categories')
          .update({ is_active: Boolean(input.isActive) })
          .eq('category_id', input.id);
        if (error) throw new Error(error.message);
      } else if (action === 'update' && input.id) {
        const { error } = await this.db
          .from('categories')
          .update({
            name: input.name,
            description: input.description,
            branch_id: input.branchId,
          })
          .eq('category_id', input.id);
        if (error) throw new Error(error.message);
      }
    } else if (type === 'service') {
      if (action === 'create') {
        const { error } = await this.db.from('services').insert({
          category_id: input.categoryId,
          name: input.name,
          description: input.description ?? null,
          base_price: input.basePrice ?? 0,
        });
        if (error) throw new Error(error.message);
      } else if (action === 'update' && input.id) {
        const { error } = await this.db
          .from('services')
          .update({
            name: input.name,
            description: input.description,
            base_price: input.basePrice,
          })
          .eq('service_id', input.id);
        if (error) throw new Error(error.message);
      }
    } else if (type === 'skill' && action === 'create') {
      const { error } = await this.db.from('skills').insert({
        category_id: input.categoryId ?? null,
        name: input.name,
        description: input.description ?? null,
      });
      if (error) throw new Error(error.message);
    }
  }
}

