import {
  ADMIN_ROLE_NAMES,
  AdminRoleName,
  AdminSessionContext,
  PERMISSION_KEYS,
  PermissionKey,
  PermissionOverrideRecord,
  STEP_UP_REQUIRED_PERMISSIONS,
} from '@/lib/contracts';

export class AuthorizationError extends Error {
  public readonly statusCode: number;
  public readonly code: string;

  constructor(code: string, message: string, statusCode = 403) {
    super(message);
    this.name = 'AuthorizationError';
    this.code = code;
    this.statusCode = statusCode;
  }
}

export const DEFAULT_ROLE_PERMISSION_TEMPLATES: Record<
  AdminRoleName,
  { permissions: readonly PermissionKey[]; branchScoped: boolean }
> = {
  'Super Admin': {
    permissions: PERMISSION_KEYS,
    branchScoped: false,
  },
  'Company Admin': {
    permissions: [
      'analytics.global.view',
      'branch.analytics.view',
      'branch.view',
      'customer.view',
      'customer.update',
      'customer.suspend',
      'worker.view',
      'worker.verify',
      'worker.suspend',
      'worker.branch.assign',
      'worker.availability.view',
      'service.view',
      'service.manage',
      'service.branch.manage',
      'booking.view',
      'booking.manage',
      'project.team.manage',
      'complaint.view',
      'complaint.manage',
      'dispute.view',
      'dispute.resolve',
      'payment.view',
      'payment.refund.request',
      'payout.view',
      'payout.request',
      'report.view',
    ],
    branchScoped: false,
  },
  'Branch Manager': {
    permissions: [
      'branch.analytics.view',
      'branch.view',
      'customer.view',
      'worker.view',
      'worker.verify',
      'worker.suspend',
      'worker.availability.view',
      'service.view',
      'service.branch.manage',
      'booking.view',
      'booking.manage',
      'project.team.manage',
      'complaint.view',
      'complaint.manage',
      'dispute.view',
      'report.view',
    ],
    branchScoped: true,
  },
};

export function pickPrimaryAdminRole(roles: string[]): AdminRoleName | null {
  for (const candidate of ADMIN_ROLE_NAMES) {
    if (roles.includes(candidate)) return candidate;
  }
  return null;
}

export function computeEffectivePermissions(
  rolePermissions: PermissionKey[],
  overrides: PermissionOverrideRecord[],
  now = new Date()
): PermissionKey[] {
  const allowed = new Set<PermissionKey>(rolePermissions);
  const denied = new Set<PermissionKey>();

  for (const ov of overrides) {
    if (ov.expires_at) {
      const exp = new Date(ov.expires_at);
      if (Number.isNaN(exp.getTime()) || exp <= now) {
        continue;
      }
    }
    if (ov.effect === 'DENY') {
      denied.add(ov.permission_key);
    } else if (ov.effect === 'ALLOW') {
      allowed.add(ov.permission_key);
    }
  }

  for (const key of denied) {
    allowed.delete(key);
  }
  return Array.from(allowed);
}

export interface GuardRequirement {
  permission: PermissionKey;
  targetBranchId?: string | null;
  requireStepUp?: boolean;
  targetUserId?: string | null;
  disallowSelfAction?: boolean;
}

export function assertAuthorized(
  ctx: AdminSessionContext,
  req: GuardRequirement,
  now = new Date()
): void {
  if (!ctx.effectivePermissions.includes(req.permission)) {
    throw new AuthorizationError(
      'PERMISSION_DENIED',
      `Missing required permission: ${req.permission}`,
      403
    );
  }

  if (req.disallowSelfAction && req.targetUserId && req.targetUserId === ctx.userId) {
    throw new AuthorizationError(
      'SELF_ACTION_PROHIBITED',
      'Separation of duties: administrators cannot perform this sensitive mutation on their own account.',
      403
    );
  }

  if (ctx.branchScoped) {
    const allowedIds = new Set(ctx.assignedBranches.map((b) => b.branch_id));
    if (allowedIds.size === 0) {
      throw new AuthorizationError(
        'BRANCH_SCOPE_UNASSIGNED',
        'Branch Manager has zero active branch assignments.',
        403
      );
    }
    if (req.targetBranchId && !allowedIds.has(req.targetBranchId)) {
      throw new AuthorizationError(
        'BRANCH_SCOPE_VIOLATION',
        'Access denied: target resource lies outside your assigned SKAVIA branch scope.',
        403
      );
    }
  }

  const needsStepUp =
    req.requireStepUp ?? STEP_UP_REQUIRED_PERMISSIONS.has(req.permission);
  if (needsStepUp) {
    if (!ctx.stepUpExpiresAt) {
      throw new AuthorizationError(
        'STEP_UP_REQUIRED',
        'Recent MFA step-up verification is required before completing this sensitive operation.',
        401
      );
    }
    const exp = new Date(ctx.stepUpExpiresAt);
    if (Number.isNaN(exp.getTime()) || exp <= now) {
      throw new AuthorizationError(
        'STEP_UP_REQUIRED',
        'Step-up verification window expired. Please re-authenticate to continue.',
        401
      );
    }
  }
}

export function resolveAuthorizedBranchFilter(
  ctx: AdminSessionContext,
  requestedBranchId?: string | null
): string[] | null {
  if (!ctx.branchScoped) {
    return requestedBranchId ? [requestedBranchId] : null;
  }

  const assignedIds = ctx.assignedBranches.map((b) => b.branch_id);
  if (assignedIds.length === 0) {
    throw new AuthorizationError(
      'BRANCH_SCOPE_UNASSIGNED',
      'Branch Manager has no active assigned branches.',
      403
    );
  }

  if (requestedBranchId) {
    if (!assignedIds.includes(requestedBranchId)) {
      throw new AuthorizationError(
        'BRANCH_SCOPE_VIOLATION',
        'Requested branch is outside your authorized scope.',
        403
      );
    }
    return [requestedBranchId];
  }

  return assignedIds;
}

export function assertPrimarySuperAdminOnly(ctx: AdminSessionContext): void {
  if (ctx.primaryRole !== 'Super Admin' || !ctx.isPrimarySuperAdmin) {
    throw new AuthorizationError(
      'PRIMARY_SUPERADMIN_ONLY',
      'Only the single primary Super Admin can perform this governance action.',
      403
    );
  }
}

export function assertNotPrimarySuperAdminMutation(
  targetIsPrimarySuperAdmin: boolean,
  targetUserId: string,
  actorUserId: string
): void {
  if (targetIsPrimarySuperAdmin && actorUserId !== targetUserId) {
    throw new AuthorizationError(
      'PRIMARY_SUPERADMIN_PROTECTED',
      'The primary Super Admin account cannot be modified, demoted, suspended, or deleted by another administrator.',
      403
    );
  }
  if (targetIsPrimarySuperAdmin) {
    throw new AuthorizationError(
      'PRIMARY_SUPERADMIN_PROTECTED',
      'Primary Super Admin role and status are immutable through delegation controls.',
      403
    );
  }
}

export function assertMakerCheckerSeparation(
  makerUserId: string,
  checkerUserId: string
): void {
  if (makerUserId === checkerUserId) {
    throw new AuthorizationError(
      'MAKER_CHECKER_VIOLATION',
      'Separation of duties: requester (Maker) cannot approve or reject their own financial/governance request.',
      403
    );
  }
}

