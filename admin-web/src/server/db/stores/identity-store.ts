import type {
  AdminRoleName,
  BranchSummary,
  PermissionKey,
  PermissionOverrideRecord,
} from '@/lib/contracts';
import { getServerEnvConfig } from '../../config/env';
import {
  AuthorizationError,
  DEFAULT_ROLE_PERMISSION_TEMPLATES,
  pickPrimaryAdminRole,
} from '../../auth/rbac';
import type {
  AdminAccountRecord,
  AdminLoginEventRecord,
  AdminSessionRecord,
  AuditLogEntry,
  AuditWriteInput,
  LoginEventOutcome,
  UserIdentityRecord,
} from '../repository';
import {
  firstJoined,
  mapSessionRow,
  SESSION_SELECT_COLUMNS,
  type SessionRowShape,
  type StoreDbClient,
} from './base';

interface RegisteredDeviceEntry {
  fingerprint: string;
  label: string;
  ip: string;
  firstSeenAt: string;
  lastSeenAt: string;
}

export class SupabaseIdentityStore {
  constructor(private readonly db: StoreDbClient) {}

  async resolveAdminIdentity(userId: string) {
    const [
      userRes,
      userRolesRes,
      ovRes,
      branchAssignRes,
      adminProfileRes,
      passkeyCountRes,
    ] = await Promise.all([
      this.db
        .from('users')
        .select(
          'user_id, full_name, email, phone, status, account_status, verification_status, active_mode, location, created_at'
        )
        .eq('user_id', userId)
        .maybeSingle(),
      this.db
        .from('user_roles')
        .select('role_id, roles(role_id, role_name)')
        .eq('user_id', userId),
      this.db
        .from('user_permission_overrides')
        .select('permission_key, effect, expires_at')
        .eq('user_id', userId),
      this.db
        .from('admin_branch_assignments')
        .select('branch_id, branches(branch_id, name, code, description, manager_id, is_active, created_at)')
        .eq('user_id', userId)
        .eq('is_active', true),
      this.db
        .from('admin_profiles')
        .select(
          'permission_version, mfa_enforced, is_primary_super_admin, login_username, last_login_at, last_login_ip'
        )
        .eq('user_id', userId)
        .maybeSingle(),
      this.db
        .from('admin_passkeys')
        .select('credential_id', { count: 'exact', head: true })
        .eq('user_id', userId)
        .is('revoked_at', null),
    ]);

    if (userRes.error) {
      throw new Error(`Failed reading user identity: ${userRes.error.message}`);
    }
    const user = userRes.data;
    if (!user) return null;

    if (userRolesRes.error) {
      throw new Error(`Failed reading user roles: ${userRolesRes.error.message}`);
    }

    const roleIds: string[] = [];
    const roleNames: AdminRoleName[] = [];
    for (const row of userRolesRes.data ?? []) {
      const r = firstJoined(row.roles);
      const name = r?.role_name as string | undefined;
      if (name === 'Super Admin' || name === 'Company Admin' || name === 'Branch Manager') {
        roleNames.push(name);
        if (typeof row.role_id === 'string') roleIds.push(row.role_id);
      }
    }

    const primaryRole = pickPrimaryAdminRole(roleNames);
    if (!primaryRole) return null;

    const assignedBranches: BranchSummary[] = [];
    for (const row of branchAssignRes.data ?? []) {
      const b = firstJoined(row.branches);
      if (b) assignedBranches.push(b as BranchSummary);
    }

    const needsManagedBranchLookup =
      assignedBranches.length === 0 && primaryRole === 'Branch Manager';

    const [rpRes, managedRes] = await Promise.all([
      roleIds.length > 0
        ? this.db
            .from('role_permissions')
            .select('permission_key, branch_scoped')
            .in('role_id', roleIds)
        : Promise.resolve({ data: null }),
      needsManagedBranchLookup
        ? this.db
            .from('branches')
            .select('branch_id, name, code, description, manager_id, is_active, created_at')
            .eq('manager_id', userId)
            .eq('is_active', true)
        : Promise.resolve({ data: null }),
    ]);

    const permSet = new Set<PermissionKey>();
    let branchScoped = primaryRole === 'Branch Manager';

    if (roleIds.length > 0) {
      const rpRows = rpRes.data;
      if (rpRows && rpRows.length > 0) {
        for (const rp of rpRows) {
          permSet.add(rp.permission_key as PermissionKey);
          if (rp.branch_scoped) branchScoped = true;
        }
      } else {
        for (const r of roleNames) {
          const tpl = DEFAULT_ROLE_PERMISSION_TEMPLATES[r];
          for (const p of tpl.permissions) permSet.add(p);
          if (tpl.branchScoped) branchScoped = true;
        }
      }
    }

    if (primaryRole === 'Super Admin') {
      for (const p of DEFAULT_ROLE_PERMISSION_TEMPLATES['Super Admin'].permissions) {
        permSet.add(p);
      }
      branchScoped = false;
    }

    if (managedRes.data) {
      for (const b of managedRes.data) assignedBranches.push(b as BranchSummary);
    }

    const overrides: PermissionOverrideRecord[] = (ovRes.data ?? []).map((o) => ({
      permission_key: o.permission_key as PermissionKey,
      effect: o.effect as 'ALLOW' | 'DENY',
      expires_at: o.expires_at ?? null,
    }));

    const adminProfile = adminProfileRes.data;
    const passkeyCount = passkeyCountRes.count;

    let cfgPrimaryUid = '';
    try {
      cfgPrimaryUid = getServerEnvConfig().primarySuperAdminUid;
    } catch {
      cfgPrimaryUid = '';
    }

    const isPrimarySuperAdmin =
      roleNames.includes('Super Admin') &&
      (Boolean(adminProfile?.is_primary_super_admin) ||
        (cfgPrimaryUid !== '' && cfgPrimaryUid === userId));

    return {
      user: user as UserIdentityRecord,
      roles: roleNames,
      isPrimarySuperAdmin,
      loginUsername: (adminProfile?.login_username as string | null) ?? null,
      rolePermissions: Array.from(permSet),
      branchScoped,
      assignedBranches,
      overrides,
      permissionVersion: adminProfile?.permission_version ?? 1,
      mfaEnforced: adminProfile?.mfa_enforced ?? true,
      lastLoginAt: (adminProfile?.last_login_at as string | null) ?? null,
      lastLoginIp: (adminProfile?.last_login_ip as string | null) ?? null,
      passkeyCount: passkeyCount ?? 0,
    };
  }

  async lookupPrimarySuperAdminByUsername(username: string) {
    const clean = username.trim().toLowerCase();
    if (!clean) return null;

    const { data: prof } = await this.db
      .from('admin_profiles')
      .select('user_id, login_username, is_primary_super_admin')
      .eq('is_primary_super_admin', true)
      .ilike('login_username', clean)
      .maybeSingle();

    if (!prof?.user_id) return null;

    const { data: user } = await this.db
      .from('users')
      .select('user_id, email, status, account_status')
      .eq('user_id', prof.user_id)
      .maybeSingle();

    if (!user?.email || user.status !== 'Active') return null;

    return {
      userId: user.user_id as string,
      email: user.email as string,
      loginUsername: (prof.login_username as string) || clean,
    };
  }

  async recordLoginEvent(event: {
    userId: string | null;
    email: string | null;
    surface?: string | null;
    outcome: LoginEventOutcome;
    mfaMethod?: string | null;
    ipAddress?: string | null;
    userAgent?: string | null;
    failureReason?: string | null;
  }): Promise<void> {
    await this.db.from('admin_login_events').insert({
      user_id: event.userId,
      email: event.email,
      surface: event.surface ?? null,
      outcome: event.outcome,
      mfa_method: event.mfaMethod ?? null,
      ip_address: event.ipAddress ?? null,
      user_agent: event.userAgent ?? null,
      failure_reason: event.failureReason ?? null,
    });
  }

  async listLoginEvents(limit = 100): Promise<AdminLoginEventRecord[]> {
    const { data, error } = await this.db
      .from('admin_login_events')
      .select('event_id, user_id, email, surface, outcome, mfa_method, ip_address, user_agent, failure_reason, created_at')
      .order('created_at', { ascending: false })
      .limit(limit);
    if (error) throw new Error(`Failed reading login events: ${error.message}`);
    return (data ?? []) as AdminLoginEventRecord[];
  }

  async checkAndRegisterDevice(input: {
    userId: string;
    fingerprint: string;
    deviceLabel: string;
    ipAddress: string;
  }): Promise<{ isNewDevice: boolean }> {
    const { data: prof } = await this.db
      .from('admin_profiles')
      .select('registered_devices')
      .eq('user_id', input.userId)
      .maybeSingle();

    const existing = Array.isArray(prof?.registered_devices)
      ? (prof.registered_devices as RegisteredDeviceEntry[])
      : [];
    const now = new Date().toISOString();
    const match = existing.find((d) => d.fingerprint === input.fingerprint);
    const isNewDevice = existing.length > 0 && !match;

    const updated: RegisteredDeviceEntry[] = match
      ? existing.map((d) =>
          d.fingerprint === input.fingerprint
            ? { ...d, label: input.deviceLabel, ip: input.ipAddress, lastSeenAt: now }
            : d
        )
      : [
          {
            fingerprint: input.fingerprint,
            label: input.deviceLabel,
            ip: input.ipAddress,
            firstSeenAt: now,
            lastSeenAt: now,
          },
          ...existing,
        ].slice(0, 15);

    await this.db.from('admin_profiles').upsert(
      {
        user_id: input.userId,
        registered_devices: updated,
        updated_at: now,
      },
      { onConflict: 'user_id' }
    );

    return { isNewDevice };
  }

  async createAdminSession(input: {
    userId: string;
    deviceLabel?: string;
    ipAddress?: string | null;
    permissionVersion: number;
    stepUpExpiresAt: string | null;
    expiresAt: string;
  }): Promise<AdminSessionRecord> {
    const now = new Date().toISOString();
    const { data, error } = await this.db
      .from('user_sessions')
      .insert({
        user_id: input.userId,
        app_scope: 'admin_web',
        device_info: input.deviceLabel ?? 'Admin Web Browser',
        ip_address: input.ipAddress ?? null,
        permission_version_snapshot: input.permissionVersion,
        step_up_expires_at: input.stepUpExpiresAt,
        expires_at: input.expiresAt,
      })
      .select(SESSION_SELECT_COLUMNS)
      .single();

    if (error || !data) {
      throw new Error(`Failed creating admin session: ${error?.message ?? 'unknown'}`);
    }

    await this.db.from('admin_profiles').upsert(
      {
        user_id: input.userId,
        last_login_at: now,
        last_login_ip: input.ipAddress ?? null,
        updated_at: now,
      },
      { onConflict: 'user_id' }
    );

    return mapSessionRow(data as SessionRowShape);
  }

  async getAdminSession(sessionId: string): Promise<AdminSessionRecord | null> {
    const { data, error } = await this.db
      .from('user_sessions')
      .select(SESSION_SELECT_COLUMNS)
      .eq('session_id', sessionId)
      .maybeSingle();

    if (error) throw new Error(`Failed reading session: ${error.message}`);
    if (!data) return null;
    return mapSessionRow(data as SessionRowShape);
  }

  async refreshSessionStepUp(sessionId: string, stepUpExpiresAt: string): Promise<void> {
    const { error } = await this.db
      .from('user_sessions')
      .update({ step_up_expires_at: stepUpExpiresAt })
      .eq('session_id', sessionId);
    if (error) throw new Error(`Failed refreshing step-up window: ${error.message}`);
  }

  async revokeSession(sessionId: string, revokedBy: string): Promise<void> {
    const { error } = await this.db
      .from('user_sessions')
      .update({
        revoked_at: new Date().toISOString(),
        revoked_by: revokedBy,
      })
      .eq('session_id', sessionId);
    if (error) throw new Error(`Failed revoking session: ${error.message}`);
  }

  async listSessions(userId?: string): Promise<AdminSessionRecord[]> {
    let query = this.db
      .from('user_sessions')
      .select(SESSION_SELECT_COLUMNS)
      .eq('app_scope', 'admin_web')
      .order('created_at', { ascending: false })
      .limit(100);
    if (userId) query = query.eq('user_id', userId);

    const { data, error } = await query;
    if (error) throw new Error(`Failed listing sessions: ${error.message}`);
    return (data ?? []).map((row) => mapSessionRow(row as SessionRowShape));
  }

  async writeAuditLog(entry: AuditWriteInput): Promise<void> {
    const { error } = await this.db.from('audit_logs').insert({
      user_id: entry.userId,
      action: entry.action,
      entity_type: entry.entityType,
      entity_id: entry.entityId ?? null,
      details: entry.details ?? {},
      ip_address: entry.ipAddress ?? null,
    });
    if (error) {
      throw new Error(`Audit persistence failed: ${error.message}`);
    }
  }

  async listAuditLogs(filters: { action?: string; userId?: string; limit?: number }): Promise<AuditLogEntry[]> {
    let q = this.db
      .from('audit_logs')
      .select('audit_id, user_id, action, entity_type, entity_id, details, ip_address, created_at')
      .order('created_at', { ascending: false })
      .limit(filters.limit ?? 100);

    if (filters.action) q = q.ilike('action', `%${filters.action}%`);
    if (filters.userId) q = q.eq('user_id', filters.userId);

    const { data, error } = await q;
    if (error) throw new Error(`Failed listing audit logs: ${error.message}`);
    return (data ?? []) as AuditLogEntry[];
  }

  async listAdmins(): Promise<AdminAccountRecord[]> {
    const { data, error } = await this.db
      .from('user_roles')
      .select('user_id, roles(role_name)')
      .limit(200);
    if (error) throw new Error(`Failed reading admins: ${error.message}`);

    const uniqueIds = new Set<string>();
    for (const r of data ?? []) {
      const roleObj = firstJoined(r.roles);
      const roleName = roleObj?.role_name;
      if (roleName === 'Super Admin' || roleName === 'Company Admin' || roleName === 'Branch Manager') {
        uniqueIds.add(r.user_id);
      }
    }

    const identities = await Promise.all(
      Array.from(uniqueIds).map((uid) => this.resolveAdminIdentity(uid))
    );

    const out: AdminAccountRecord[] = [];
    for (const identity of identities) {
      if (!identity) continue;
      out.push({
        ...identity.user,
        roles: identity.roles,
        isPrimarySuperAdmin: identity.isPrimarySuperAdmin,
        loginUsername: identity.loginUsername,
        assignedBranches: identity.assignedBranches,
        permissionVersion: identity.permissionVersion,
        mfaEnforced: identity.mfaEnforced,
        passkeyEnrolled: identity.passkeyCount > 0,
        lastLoginAt: identity.lastLoginAt,
        lastLoginIp: identity.lastLoginIp,
        overrides: identity.overrides,
      });
    }
    return out;
  }

  async provisionAdmin(input: {
    userId: string;
    email: string;
    fullName: string;
    roleName: AdminRoleName;
    branchIds: string[];
    actorUserId: string;
  }): Promise<AdminAccountRecord> {
    if (input.roleName === 'Super Admin') {
      throw new AuthorizationError(
        'SINGLE_SUPERADMIN_ENFORCED',
        'Additional Super Admin accounts cannot be provisioned. Only Company Admin and Branch Manager can be delegated.',
        403
      );
    }

    const [, roleRes] = await Promise.all([
      this.db.from('users').upsert(
        {
          user_id: input.userId,
          full_name: input.fullName,
          email: input.email,
          status: 'Active',
          account_status: 'active',
          active_mode: 'admin',
        },
        { onConflict: 'user_id' }
      ),
      this.db.from('roles').select('role_id').eq('role_name', input.roleName).single(),
    ]);

    const role = roleRes.data;
    if (!role) throw new Error(`Seeded role not found: ${input.roleName}`);

    const writes: PromiseLike<unknown>[] = [
      this.db.from('user_roles').upsert({ user_id: input.userId, role_id: role.role_id }, { onConflict: 'user_id,role_id' }),
      this.db.from('admin_profiles').upsert(
        { user_id: input.userId, mfa_enforced: true, permission_version: 1, is_primary_super_admin: false },
        { onConflict: 'user_id' }
      ),
    ];

    if (input.branchIds.length > 0) {
      writes.push(
        this.db.from('admin_branch_assignments').upsert(
          input.branchIds.map((bid, idx) => ({
            user_id: input.userId,
            branch_id: bid,
            is_primary: idx === 0,
            is_active: true,
            assigned_by: input.actorUserId,
          })),
          { onConflict: 'user_id,branch_id' }
        )
      );
    }

    await Promise.all(writes);
    const admins = await this.listAdmins();
    const created = admins.find((a) => a.user_id === input.userId);
    if (!created) throw new Error('Failed resolving newly provisioned admin');
    return created;
  }

  async updateAdminPermissions(targetUserId: string, input: Record<string, unknown>, actorUserId: string): Promise<AdminAccountRecord> {
    const target = await this.resolveAdminIdentity(targetUserId);
    if (!target) throw new Error('Target admin account not found');
    if (target.isPrimarySuperAdmin) {
      throw new AuthorizationError(
        'PRIMARY_SUPERADMIN_PROTECTED',
        'The primary Super Admin account cannot be modified, demoted, suspended, or deleted.',
        403
      );
    }

    if (input.roleName === 'Super Admin') {
      throw new AuthorizationError(
        'SINGLE_SUPERADMIN_ENFORCED',
        'Cannot escalate internal admin accounts to Super Admin.',
        403
      );
    }

    if (input.roleName) {
      const [{ data: role }, { data: adminRoles }] = await Promise.all([
        this.db.from('roles').select('role_id').eq('role_name', input.roleName).single(),
        this.db.from('roles').select('role_id').in('role_name', ['Super Admin', 'Company Admin', 'Branch Manager']),
      ]);
      if (!role) throw new Error(`Role not found: ${String(input.roleName)}`);
      const adminRoleIds = (adminRoles ?? []).map((r) => r.role_id);
      if (adminRoleIds.length > 0) {
        await this.db.from('user_roles').delete().eq('user_id', targetUserId).in('role_id', adminRoleIds);
      }
      await this.db.from('user_roles').insert({ user_id: targetUserId, role_id: role.role_id });
    }

    const tasks: PromiseLike<unknown>[] = [];

    if (Array.isArray(input.branchIds)) {
      await this.db.from('admin_branch_assignments').delete().eq('user_id', targetUserId);
      if (input.branchIds.length > 0) {
        tasks.push(
          this.db.from('admin_branch_assignments').insert(
            (input.branchIds as string[]).map((bid, i) => ({
              user_id: targetUserId,
              branch_id: bid,
              is_primary: i === 0,
              is_active: true,
              assigned_by: actorUserId,
            }))
          )
        );
      }
    }

    if (input.override && typeof input.override === 'object') {
      const ov = input.override as { permissionKey: string; effect: string; reason: string; expiresAt?: string | null };
      tasks.push(
        this.db.from('user_permission_overrides').insert({
          user_id: targetUserId,
          permission_key: ov.permissionKey,
          effect: ov.effect,
          reason: ov.reason,
          granted_by: actorUserId,
          expires_at: ov.expiresAt ?? null,
        })
      );
    }

    if (typeof input.suspendReason === 'string') {
      tasks.push(
        this.db.from('users').update({ status: 'Deactivated', account_status: 'suspended' }).eq('user_id', targetUserId),
        this.db
          .from('user_sessions')
          .update({ revoked_at: new Date().toISOString(), revoked_by: actorUserId })
          .eq('user_id', targetUserId)
          .is('revoked_at', null)
      );
    } else if (input.reactivate === true) {
      tasks.push(this.db.from('users').update({ status: 'Active', account_status: 'active' }).eq('user_id', targetUserId));
    }

    await Promise.all(tasks);

    const { data: prof } = await this.db
      .from('admin_profiles')
      .select('permission_version')
      .eq('user_id', targetUserId)
      .maybeSingle();
    await this.db.from('admin_profiles').upsert(
      {
        user_id: targetUserId,
        permission_version: (prof?.permission_version ?? 1) + 1,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id' }
    );

    const admins = await this.listAdmins();
    const found = admins.find((a) => a.user_id === targetUserId);
    if (!found) throw new Error('Admin not found after update');
    return found;
  }
}
