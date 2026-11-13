import { describe, expect, it } from 'vitest';
import type { AdminSessionContext } from '@/lib/contracts';
import {
  AuthorizationError,
  DEFAULT_ROLE_PERMISSION_TEMPLATES,
  assertAuthorized,
  assertMakerCheckerSeparation,
  computeEffectivePermissions,
  pickPrimaryAdminRole,
  resolveAuthorizedBranchFilter,
} from '@/server/auth/rbac';
import { TEST_IDS } from '../helpers/in-memory-store';

function buildSession(overrides: Partial<AdminSessionContext>): AdminSessionContext {
  return {
    sessionId: 'sess-1',
    userId: TEST_IDS.users.branchManagerTech,
    email: 'tech.manager@skavia.com',
    fullName: 'Kamal TechManager',
    roles: ['Branch Manager'],
    primaryRole: 'Branch Manager',
    isPrimarySuperAdmin: false,
    portalSurface: 'admin',
    effectivePermissions: [...DEFAULT_ROLE_PERMISSION_TEMPLATES['Branch Manager'].permissions],
    branchScoped: true,
    assignedBranches: [
      {
        branch_id: TEST_IDS.branches.TECH,
        name: 'SKAVIA Technical',
        code: 'TECH',
        description: null,
        manager_id: TEST_IDS.users.branchManagerTech,
        is_active: true,
        created_at: '2026-11-11T00:00:00Z',
      },
    ],
    permissionVersion: 1,
    mfaVerified: true,
    mfaMethod: 'totp',
    stepUpExpiresAt: new Date(Date.now() + 60_000).toISOString(),
    expiresAt: new Date(Date.now() + 3_600_000).toISOString(),
    ...overrides,
  };
}

describe('RBAC & ABAC Authorization Engine', () => {
  it('picks highest priority internal SKAVIA role or rejects non-admin roles', () => {
    expect(pickPrimaryAdminRole(['Client', 'Branch Manager', 'Company Admin'])).toBe(
      'Company Admin'
    );
    expect(pickPrimaryAdminRole(['Branch Manager', 'Super Admin'])).toBe('Super Admin');
    expect(pickPrimaryAdminRole(['Client', 'Worker'])).toBeNull();
  });

  it('computes effective permissions with explicit DENY precedence and expiry checks', () => {
    const base = [...DEFAULT_ROLE_PERMISSION_TEMPLATES['Company Admin'].permissions];
    const effective = computeEffectivePermissions(base, [
      { permission_key: 'payout.approve', effect: 'ALLOW', expires_at: null },
      { permission_key: 'worker.verify', effect: 'DENY', expires_at: null },
      {
        permission_key: 'customer.suspend',
        effect: 'DENY',
        expires_at: '2020-01-01T00:00:00Z', // expired deny must not apply
      },
      {
        permission_key: 'admin.view',
        effect: 'ALLOW',
        expires_at: '2020-01-01T00:00:00Z', // expired allow must not apply
      },
    ]);

    expect(effective).toContain('payout.approve');
    expect(effective).not.toContain('worker.verify');
    expect(effective).toContain('customer.suspend');
    expect(effective).not.toContain('admin.view');
  });

  it('enforces Branch Manager branch isolation & blocks unassigned/cross-branch IDOR', () => {
    const techBm = buildSession({});

    expect(resolveAuthorizedBranchFilter(techBm, null)).toEqual([TEST_IDS.branches.TECH]);
    expect(resolveAuthorizedBranchFilter(techBm, TEST_IDS.branches.TECH)).toEqual([
      TEST_IDS.branches.TECH,
    ]);

    expect(() => resolveAuthorizedBranchFilter(techBm, TEST_IDS.branches.HOME)).toThrow(
      AuthorizationError
    );

    expect(() =>
      assertAuthorized(techBm, {
        permission: 'worker.verify',
        targetBranchId: TEST_IDS.branches.HOME,
      })
    ).toThrow(/outside your assigned SKAVIA branch scope/i);

    const unassignedBm = buildSession({ assignedBranches: [] });
    expect(() =>
      assertAuthorized(unassignedBm, { permission: 'worker.verify' })
    ).toThrow(/zero active branch assignments/i);
  });

  it('blocks self-modification and enforces Maker != Checker separation of duties', () => {
    const superAdmin = buildSession({
      userId: TEST_IDS.users.superAdmin,
      primaryRole: 'Super Admin',
      roles: ['Super Admin'],
      branchScoped: false,
      effectivePermissions: [...DEFAULT_ROLE_PERMISSION_TEMPLATES['Super Admin'].permissions],
    });

    expect(() =>
      assertAuthorized(superAdmin, {
        permission: 'admin.suspend',
        targetUserId: TEST_IDS.users.superAdmin,
        disallowSelfAction: true,
      })
    ).toThrow(/SELF_ACTION_PROHIBITED|cannot perform this sensitive mutation on their own account/i);

    expect(() =>
      assertMakerCheckerSeparation(TEST_IDS.users.companyAdmin, TEST_IDS.users.companyAdmin)
    ).toThrow(/Maker/i);

    expect(() =>
      assertMakerCheckerSeparation(TEST_IDS.users.companyAdmin, TEST_IDS.users.superAdmin)
    ).not.toThrow();
  });

  it('requires valid Step-Up MFA window on sensitive operations', () => {
    const staleSession = buildSession({
      stepUpExpiresAt: new Date(Date.now() - 1000).toISOString(),
    });

    expect(() =>
      assertAuthorized(staleSession, {
        permission: 'worker.suspend',
        targetBranchId: TEST_IDS.branches.TECH,
      })
    ).toThrow(/Step-up verification window expired/i);
  });
});

