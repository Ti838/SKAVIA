import type {
  InvitableAdminRole,
  InvitationDeliveryStatus,
  InvitationStatus,
  PermissionKey,
} from '@/lib/contracts';
import type { AdminInvitationRecord } from '../repository';
import type { StoreDbClient } from './base';

const INVITATION_SELECT_COLUMNS =
  'invitation_id, full_name, email, role_name, assigned_branch_ids, permission_profile, note, token_hash, status, delivery_status, delivery_error, require_approval, invited_by, approved_by, activated_user_id, expires_at, sent_at, opened_at, setup_started_at, approved_at, activated_at, revoked_at, created_at';

export class SupabaseInvitationsStore {
  constructor(private readonly db: StoreDbClient) {}

  private async hydrateInvitations(
    rows: Array<Record<string, unknown>>
  ): Promise<AdminInvitationRecord[]> {
    if (rows.length === 0) return [];
    const { data: branches } = await this.db.from('branches').select('branch_id, name');
    const branchMap = new Map<string, string>();
    for (const b of branches ?? []) branchMap.set(b.branch_id, b.name);

    return rows.map((r) => {
      const branchIds = Array.isArray(r.assigned_branch_ids)
        ? (r.assigned_branch_ids as string[])
        : [];
      const rawStatus = String(r.status || 'Draft') as InvitationStatus;
      const isExpired =
        rawStatus !== 'Active' &&
        rawStatus !== 'Revoked' &&
        rawStatus !== 'Suspended' &&
        new Date(String(r.expires_at)).getTime() <= Date.now();
      return {
        invitation_id: String(r.invitation_id),
        full_name: String(r.full_name),
        email: String(r.email),
        role_name: String(r.role_name) as InvitableAdminRole,
        assigned_branch_ids: branchIds,
        assigned_branch_names: branchIds.map((id) => branchMap.get(id) || id),
        permission_profile: Array.isArray(r.permission_profile)
          ? (r.permission_profile as Array<{ permissionKey: PermissionKey; effect: 'ALLOW' | 'DENY' }>)
          : [],
        note: (r.note as string | null) ?? null,
        token_hash: String(r.token_hash),
        status: isExpired ? 'Expired' : rawStatus,
        delivery_status: String(r.delivery_status || 'Pending') as InvitationDeliveryStatus,
        delivery_error: (r.delivery_error as string | null) ?? null,
        require_approval: Boolean(r.require_approval),
        invited_by: String(r.invited_by),
        approved_by: (r.approved_by as string | null) ?? null,
        activated_user_id: (r.activated_user_id as string | null) ?? null,
        expires_at: String(r.expires_at),
        sent_at: (r.sent_at as string | null) ?? null,
        opened_at: (r.opened_at as string | null) ?? null,
        setup_started_at: (r.setup_started_at as string | null) ?? null,
        approved_at: (r.approved_at as string | null) ?? null,
        activated_at: (r.activated_at as string | null) ?? null,
        revoked_at: (r.revoked_at as string | null) ?? null,
        created_at: String(r.created_at),
      };
    });
  }

  async createAdminInvitation(input: {
    fullName: string;
    email: string;
    roleName: InvitableAdminRole;
    branchIds: string[];
    permissionProfile: Array<{ permissionKey: PermissionKey; effect: 'ALLOW' | 'DENY' }>;
    note?: string;
    tokenHash: string;
    requireApproval: boolean;
    expiresAt: string;
    invitedBy: string;
  }): Promise<AdminInvitationRecord> {
    const { data, error } = await this.db
      .from('admin_invitations')
      .insert({
        full_name: input.fullName,
        email: input.email.toLowerCase(),
        role_name: input.roleName,
        assigned_branch_ids: input.branchIds,
        permission_profile: input.permissionProfile,
        note: input.note ?? null,
        token_hash: input.tokenHash,
        status: 'Invited',
        delivery_status: 'Pending',
        require_approval: input.requireApproval,
        invited_by: input.invitedBy,
        expires_at: input.expiresAt,
      })
      .select(INVITATION_SELECT_COLUMNS)
      .single();

    if (error || !data) {
      throw new Error(`Failed creating invitation: ${error?.message ?? 'unknown'}`);
    }
    const hydrated = await this.hydrateInvitations([data as Record<string, unknown>]);
    const record = hydrated[0];
    if (!record) throw new Error('Failed hydrating created invitation');
    return record;
  }

  async listAdminInvitations(): Promise<AdminInvitationRecord[]> {
    const { data, error } = await this.db
      .from('admin_invitations')
      .select(INVITATION_SELECT_COLUMNS)
      .order('created_at', { ascending: false })
      .limit(200);
    if (error) throw new Error(`Failed reading invitations: ${error.message}`);
    return this.hydrateInvitations((data ?? []) as Array<Record<string, unknown>>);
  }

  async getInvitationById(invitationId: string): Promise<AdminInvitationRecord | null> {
    const { data, error } = await this.db
      .from('admin_invitations')
      .select(INVITATION_SELECT_COLUMNS)
      .eq('invitation_id', invitationId)
      .maybeSingle();
    if (error) throw new Error(`Failed reading invitation: ${error.message}`);
    if (!data) return null;
    const hydrated = await this.hydrateInvitations([data as Record<string, unknown>]);
    return hydrated[0] ?? null;
  }

  async getInvitationByTokenHash(tokenHash: string): Promise<AdminInvitationRecord | null> {
    const { data, error } = await this.db
      .from('admin_invitations')
      .select(INVITATION_SELECT_COLUMNS)
      .eq('token_hash', tokenHash)
      .maybeSingle();
    if (error) throw new Error(`Failed reading invitation by token: ${error.message}`);
    if (!data) return null;
    const hydrated = await this.hydrateInvitations([data as Record<string, unknown>]);
    return hydrated[0] ?? null;
  }

  async updateInvitationState(
    invitationId: string,
    patch: Partial<{
      token_hash: string;
      status: InvitationStatus;
      delivery_status: InvitationDeliveryStatus;
      delivery_error: string | null;
      approved_by: string | null;
      activated_user_id: string | null;
      expires_at: string;
      sent_at: string | null;
      opened_at: string | null;
      setup_started_at: string | null;
      approved_at: string | null;
      activated_at: string | null;
      revoked_at: string | null;
    }>
  ): Promise<AdminInvitationRecord> {
    const { data, error } = await this.db
      .from('admin_invitations')
      .update({ ...patch, updated_at: new Date().toISOString() })
      .eq('invitation_id', invitationId)
      .select(INVITATION_SELECT_COLUMNS)
      .single();
    if (error || !data) {
      throw new Error(`Failed updating invitation: ${error?.message ?? 'unknown'}`);
    }
    const hydrated = await this.hydrateInvitations([data as Record<string, unknown>]);
    const record = hydrated[0];
    if (!record) throw new Error('Failed hydrating updated invitation');
    return record;
  }

  async activateInvitedAdmin(input: {
    invitationId: string;
    userId: string;
    email: string;
    fullName: string;
    status: 'PendingApproval' | 'Active';
  }): Promise<void> {
    const inv = await this.getInvitationById(input.invitationId);
    if (!inv) throw new Error('Invitation not found');

    const active = input.status === 'Active';
    const [, roleRes] = await Promise.all([
      this.db.from('users').upsert(
        {
          user_id: input.userId,
          full_name: input.fullName,
          email: input.email.toLowerCase(),
          status: active ? 'Active' : 'Inactive',
          account_status: active ? 'active' : 'pending_approval',
          verification_status: 'Verified',
          active_mode: 'admin',
        },
        { onConflict: 'user_id' }
      ),
      this.db.from('roles').select('role_id').eq('role_name', inv.role_name).single(),
    ]);

    const role = roleRes.data;
    if (!role) throw new Error(`Role not found: ${inv.role_name}`);

    const now = new Date().toISOString();
    await Promise.all([
      this.db
        .from('user_roles')
        .upsert({ user_id: input.userId, role_id: role.role_id }, { onConflict: 'user_id,role_id' }),
      this.db.from('admin_profiles').upsert(
        {
          user_id: input.userId,
          mfa_enforced: true,
          permission_version: 1,
          is_primary_super_admin: false,
        },
        { onConflict: 'user_id' }
      ),
      this.db.from('admin_branch_assignments').delete().eq('user_id', input.userId),
    ]);

    const postTasks: PromiseLike<unknown>[] = [
      this.updateInvitationState(input.invitationId, {
        status: input.status,
        activated_user_id: input.userId,
        activated_at: active ? now : null,
        setup_started_at: inv.setup_started_at ?? now,
      }),
    ];

    if (inv.assigned_branch_ids.length > 0) {
      postTasks.push(
        this.db.from('admin_branch_assignments').insert(
          inv.assigned_branch_ids.map((bid, idx) => ({
            user_id: input.userId,
            branch_id: bid,
            is_primary: idx === 0,
            is_active: true,
            assigned_by: inv.invited_by,
          }))
        )
      );
    }

    if (inv.permission_profile.length > 0) {
      postTasks.push(
        this.db.from('user_permission_overrides').insert(
          inv.permission_profile.map((ov) => ({
            user_id: input.userId,
            permission_key: ov.permissionKey,
            effect: ov.effect,
            reason: `Invited profile (${inv.invitation_id})`,
            granted_by: inv.invited_by,
          }))
        )
      );
    }

    await Promise.all(postTasks);
  }
}

