import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { SignJWT } from 'jose';
import { GET as listAdmins, POST as createAdmin } from '@/app/api/admin/admins/route';
import { PATCH as patchAdmin } from '@/app/api/admin/admins/[id]/route';
import { POST as resolveIdentifier } from '@/app/api/admin/auth/resolve-identifier/route';
import {
  GET as getRecoveryStatus,
  POST as generateRecovery,
  PUT as consumeRecovery,
} from '@/app/api/admin/auth/recovery/route';
import { POST as loginSession } from '@/app/api/admin/auth/session/route';
import { POST as verifyStepUp } from '@/app/api/admin/auth/step-up/route';
import {
  GET as listInvitations,
  POST as createInvitation,
} from '@/app/api/admin/invitations/route';
import { POST as mutateInvitation } from '@/app/api/admin/invitations/[id]/route';
import { GET as getSecurityOverview } from '@/app/api/admin/security/overview/route';
import { POST as activateInvitation } from '@/app/api/public/invitations/activate/route';
import { GET as verifyInvitation } from '@/app/api/public/invitations/verify/route';
import { setTestAdminRepository } from '@/server/db/store-factory';
import { InMemoryAdminRepository, TEST_IDS } from '../helpers/in-memory-store';

const TEST_SECRET = 'vitest-admin-session-secret-minimum-32-chars-ok';

async function makeTestFirebaseToken(
  uid: string,
  email: string,
  mfaMethod: string | null = 'totp'
): Promise<string> {
  const key = new TextEncoder().encode(TEST_SECRET);
  const jwt = await new SignJWT({
    email,
    ...(mfaMethod ? { mfa_method: mfaMethod } : {}),
  })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(uid)
    .setIssuer('skavia-test-harness')
    .setAudience('skavia-113a3')
    .setIssuedAt()
    .setExpirationTime('1h')
    .sign(key);

  return `test-harness.${jwt}`;
}

function extractCookieHeader(res: Response): string {
  const raw = res.headers.get('set-cookie') || '';
  return raw.split(';')[0] || '';
}

async function loginOnSurface(options: {
  uid: string;
  email: string;
  host: string;
  surface?: 'superadmin' | 'admin' | 'public';
  mfaMethod?: string | null;
}) {
  const idToken = await makeTestFirebaseToken(
    options.uid,
    options.email,
    options.mfaMethod ?? 'totp'
  );
  const req = new Request(`https://${options.host}/api/admin/auth/session`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      host: options.host,
    },
    body: JSON.stringify({
      idToken,
      ...(options.surface ? { surface: options.surface } : {}),
    }),
  });
  const res = await loginSession(req);
  const cookie = extractCookieHeader(res);
  return { res, cookie, body: await res.json() };
}

async function performStepUp(cookie: string, host: string, uid: string, email: string) {
  const idToken = await makeTestFirebaseToken(uid, email, 'totp');
  const req = new Request(`https://${host}/api/admin/auth/step-up`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      host,
      cookie,
    },
    body: JSON.stringify({ idToken }),
  });
  const res = await verifyStepUp(req);
  expect(res.status).toBe(200);
}

describe('SKAVIA 4-Surface Isolation, Primary Super Admin Protection, Invitations & Recovery', () => {
  let repo: InMemoryAdminRepository;

  beforeEach(() => {
    process.env.SKAVIA_TEST_HARNESS = 'true';
    process.env.ADMIN_SESSION_SECRET = TEST_SECRET;
    process.env.FIREBASE_PROJECT_ID = 'skavia-113a3';
    process.env.ADMIN_REQUIRE_MFA = 'true';
    process.env.ADMIN_PORTAL_PUBLIC_HOST = 'www.skavia.com';
    process.env.ADMIN_PORTAL_INTERNAL_HOST = 'admin.skavia.com';
    process.env.ADMIN_PORTAL_SUPERADMIN_HOST = 'superadmin.skavia.com';
    process.env.PRIMARY_SUPER_ADMIN_UID = TEST_IDS.users.superAdmin;
    repo = new InMemoryAdminRepository();
    setTestAdminRepository(repo);
  });

  afterEach(() => {
    setTestAdminRepository(null);
  });

  it('enforces strict portal hostname isolation across www, superadmin, and admin hosts', async () => {
    // 1. Primary Super Admin logs in cleanly on superadmin.skavia.com
    const superOk = await loginOnSurface({
      uid: TEST_IDS.users.superAdmin,
      email: 'superadmin@skavia.com',
      host: 'superadmin.skavia.com',
    });
    expect(superOk.res.status).toBe(200);
    expect(superOk.body.session.isPrimarySuperAdmin).toBe(true);
    expect(superOk.body.session.portalSurface).toBe('superadmin');

    // 2. Company Admin & Branch Manager cannot log in on superadmin.skavia.com
    const companyOnSuper = await loginOnSurface({
      uid: TEST_IDS.users.companyAdmin,
      email: 'ops@skavia.com',
      host: 'superadmin.skavia.com',
    });
    expect(companyOnSuper.res.status).toBe(403);
    expect(companyOnSuper.body.error.code).toBe('SUPERADMIN_SURFACE_REQUIRED');

    const bmOnSuper = await loginOnSurface({
      uid: TEST_IDS.users.branchManagerTech,
      email: 'tech.manager@skavia.com',
      host: 'superadmin.skavia.com',
    });
    expect(bmOnSuper.res.status).toBe(403);
    expect(bmOnSuper.body.error.code).toBe('SUPERADMIN_SURFACE_REQUIRED');

    // 3. Primary Super Admin cannot sign in on admin.skavia.com (must use superadmin host)
    const superOnAdmin = await loginOnSurface({
      uid: TEST_IDS.users.superAdmin,
      email: 'superadmin@skavia.com',
      host: 'admin.skavia.com',
    });
    expect(superOnAdmin.res.status).toBe(403);
    expect(superOnAdmin.body.error.code).toBe('USE_SUPERADMIN_PORTAL');

    // 4. Company Admin logs in cleanly on admin.skavia.com, but is denied /api/admin/admins & /api/admin/security/overview
    const companyOnAdmin = await loginOnSurface({
      uid: TEST_IDS.users.companyAdmin,
      email: 'ops@skavia.com',
      host: 'admin.skavia.com',
    });
    expect(companyOnAdmin.res.status).toBe(200);
    expect(companyOnAdmin.body.session.portalSurface).toBe('admin');

    const adminsRes = await listAdmins(
      new Request('https://admin.skavia.com/api/admin/admins', {
        headers: { host: 'admin.skavia.com', cookie: companyOnAdmin.cookie },
      })
    );
    expect(adminsRes.status).toBe(403);

    const securityRes = await getSecurityOverview(
      new Request('https://admin.skavia.com/api/admin/security/overview', {
        headers: { host: 'admin.skavia.com', cookie: companyOnAdmin.cookie },
      })
    );
    expect(securityRes.status).toBe(403);

    // 5. Public website host (www.skavia.com) rejects any admin login attempt
    const wwwLogin = await loginOnSurface({
      uid: TEST_IDS.users.superAdmin,
      email: 'superadmin@skavia.com',
      host: 'www.skavia.com',
    });
    expect(wwwLogin.res.status).toBe(403);
    expect(wwwLogin.body.error.code).toBe('WRONG_PORTAL_SURFACE');
  });

  it('resolves Primary Super Admin username exclusively on superadmin/local surface without leaking internal emails', async () => {
    // Super Admin username resolves on superadmin.skavia.com
    const okRes = await resolveIdentifier(
      new Request('https://superadmin.skavia.com/api/admin/auth/resolve-identifier', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
        },
        body: JSON.stringify({ identifier: 'tariq_superadmin' }),
      })
    );
    expect(okRes.status).toBe(200);
    const okBody = await okRes.json();
    expect(okBody).toEqual({ email: 'superadmin@skavia.com', isUsername: true });

    // Rejected on internal admin surface
    const adminSurfaceRes = await resolveIdentifier(
      new Request('https://admin.skavia.com/api/admin/auth/resolve-identifier', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'admin.skavia.com',
        },
        body: JSON.stringify({ identifier: 'tariq_superadmin' }),
      })
    );
    expect(adminSurfaceRes.status).toBe(403);

    // Non-primary / unknown usernames fail closed with 401
    const unknownRes = await resolveIdentifier(
      new Request('https://superadmin.skavia.com/api/admin/auth/resolve-identifier', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
        },
        body: JSON.stringify({ identifier: 'unknown_user' }),
      })
    );
    expect(unknownRes.status).toBe(401);
  });

  it('protects Primary Super Admin from demotion/suspension and prevents provisioning a second Super Admin', async () => {
    const superOk = await loginOnSurface({
      uid: TEST_IDS.users.superAdmin,
      email: 'superadmin@skavia.com',
      host: 'superadmin.skavia.com',
    });
    expect(superOk.res.status).toBe(200);
    await performStepUp(
      superOk.cookie,
      'superadmin.skavia.com',
      TEST_IDS.users.superAdmin,
      'superadmin@skavia.com'
    );

    const patchSelfRes = await patchAdmin(
      new Request(`https://superadmin.skavia.com/api/admin/admins/${TEST_IDS.users.superAdmin}`, {
        method: 'PATCH',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
          cookie: superOk.cookie,
        },
        body: JSON.stringify({ suspendReason: 'Attempt tamper' }),
      }),
      { params: Promise.resolve({ id: TEST_IDS.users.superAdmin }) }
    );
    expect(patchSelfRes.status).toBe(403);
    const patchBody = await patchSelfRes.json();
    expect(patchBody.error.code).toBe('PRIMARY_SUPERADMIN_PROTECTED');

    const secondSuperRes = await createAdmin(
      new Request('https://superadmin.skavia.com/api/admin/admins', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
          cookie: superOk.cookie,
        },
        body: JSON.stringify({
          userId: 'duplicate-super-002',
          fullName: 'Duplicate Super',
          email: 'dup.super@skavia.com',
          roleName: 'Super Admin',
          branchIds: [],
        }),
      })
    );
    expect(secondSuperRes.status).toBe(403);
    const secondBody = await secondSuperRes.json();
    expect(secondBody.error.code).toBe('SINGLE_SUPERADMIN_ENFORCED');
  });

  it('enforces the full Invitation -> Verify -> Activate -> PendingApproval -> Approve -> Login lifecycle', async () => {
    // Company Admin cannot invite
    const companyAuth = await loginOnSurface({
      uid: TEST_IDS.users.companyAdmin,
      email: 'ops@skavia.com',
      host: 'admin.skavia.com',
    });
    const forbiddenInvite = await createInvitation(
      new Request('https://admin.skavia.com/api/admin/invitations', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'admin.skavia.com',
          cookie: companyAuth.cookie,
        },
        body: JSON.stringify({
          fullName: 'Forbidden Invitee',
          email: 'nope@skavia.com',
          roleName: 'Company Admin',
          branchIds: [],
        }),
      })
    );
    expect(forbiddenInvite.status).toBe(403);

    // Super Admin authenticates + completes step-up
    const superAuth = await loginOnSurface({
      uid: TEST_IDS.users.superAdmin,
      email: 'superadmin@skavia.com',
      host: 'superadmin.skavia.com',
    });
    await performStepUp(
      superAuth.cookie,
      'superadmin.skavia.com',
      TEST_IDS.users.superAdmin,
      'superadmin@skavia.com'
    );

    // Branch Manager without branchIds rejected with 400
    const missingBranchInvite = await createInvitation(
      new Request('https://superadmin.skavia.com/api/admin/invitations', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
          cookie: superAuth.cookie,
        },
        body: JSON.stringify({
          fullName: 'Unassigned Manager',
          email: 'bm.no.branch@skavia.com',
          roleName: 'Branch Manager',
          branchIds: [],
        }),
      })
    );
    expect(missingBranchInvite.status).toBe(400);

    // Valid Branch Manager invitation created (honest NotConfigured email delivery)
    const inviteRes = await createInvitation(
      new Request('https://superadmin.skavia.com/api/admin/invitations', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
          cookie: superAuth.cookie,
        },
        body: JSON.stringify({
          fullName: 'Rashedul Home Manager',
          email: 'rashedul.home@skavia.com',
          roleName: 'Branch Manager',
          branchIds: [TEST_IDS.branches.HOME],
          requireApproval: true,
          expiresInHours: 24,
        }),
      })
    );
    expect(inviteRes.status).toBe(201);
    const inviteData = await inviteRes.json();
    expect(inviteData.emailDelivery.status).toBe('NotConfigured');
    expect(inviteData.manualActivationUrl).toContain('/activate?token=');
    const invId: string = inviteData.invitation.invitation_id;
    const rawToken = new URL(inviteData.manualActivationUrl).searchParams.get('token')!;
    expect(rawToken.length).toBeGreaterThan(24);

    // Raw token is NOT stored in repository
    const storedInv = await repo.getInvitationById(invId);
    expect(storedInv?.token_hash).not.toBe(rawToken);

    // Verify transitions state to Opened
    const verifyRes = await verifyInvitation(
      new Request(`https://admin.skavia.com/api/public/invitations/verify?token=${rawToken}`)
    );
    expect(verifyRes.status).toBe(200);
    const verifyBody = await verifyRes.json();
    expect(verifyBody.invitation.status).toBe('Opened');
    expect(verifyBody.invitation.maskedEmail).toBe('ra***@skavia.com');
    expect(verifyBody.invitation.maskedEmail).not.toBe('rashedul.home@skavia.com');

    // Activation fails if signed-in Firebase email mismatches invited email
    const wrongEmailToken = await makeTestFirebaseToken('invited-uid-001', 'wrong@skavia.com', null);
    const mismatchRes = await activateInvitation(
      new Request('https://admin.skavia.com/api/public/invitations/activate', {
        method: 'POST',
        headers: { 'content-type': 'application/json', host: 'admin.skavia.com' },
        body: JSON.stringify({
          token: rawToken,
          idToken: wrongEmailToken,
          fullName: 'Rashedul Home Manager',
          acceptedTerms: true,
        }),
      })
    );
    expect(mismatchRes.status).toBe(403);

    // Activation succeeds with matching Firebase email -> status becomes PendingApproval
    const invitedUid = 'invited-home-uid-001';
    const matchingToken = await makeTestFirebaseToken(invitedUid, 'rashedul.home@skavia.com', null);
    const activateRes = await activateInvitation(
      new Request('https://admin.skavia.com/api/public/invitations/activate', {
        method: 'POST',
        headers: { 'content-type': 'application/json', host: 'admin.skavia.com' },
        body: JSON.stringify({
          token: rawToken,
          idToken: matchingToken,
          fullName: 'Rashedul Home Manager',
          acceptedTerms: true,
        }),
      })
    );
    expect(activateRes.status).toBe(200);
    const activateBody = await activateRes.json();
    expect(activateBody.status).toBe('PendingApproval');

    // Single-use token replay is rejected (409)
    const replayRes = await activateInvitation(
      new Request('https://admin.skavia.com/api/public/invitations/activate', {
        method: 'POST',
        headers: { 'content-type': 'application/json', host: 'admin.skavia.com' },
        body: JSON.stringify({
          token: rawToken,
          idToken: matchingToken,
          fullName: 'Rashedul Home Manager',
          acceptedTerms: true,
        }),
      })
    );
    expect(replayRes.status).toBe(409);

    // Login is blocked while PendingApproval
    const blockedLogin = await loginOnSurface({
      uid: invitedUid,
      email: 'rashedul.home@skavia.com',
      host: 'admin.skavia.com',
      mfaMethod: 'totp',
    });
    expect(blockedLogin.res.status).toBe(403);
    expect(blockedLogin.body.error.code).toBe('PENDING_SUPERADMIN_APPROVAL');

    // Primary Super Admin approves invitation -> Active
    const approveRes = await mutateInvitation(
      new Request(`https://superadmin.skavia.com/api/admin/invitations/${invId}`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
          cookie: superAuth.cookie,
        },
        body: JSON.stringify({ action: 'approve' }),
      }),
      { params: Promise.resolve({ id: invId }) }
    );
    expect(approveRes.status).toBe(200);
    const approveBody = await approveRes.json();
    expect(approveBody.invitation.status).toBe('Active');

    // Now login on admin.skavia.com succeeds cleanly
    const activeLogin = await loginOnSurface({
      uid: invitedUid,
      email: 'rashedul.home@skavia.com',
      host: 'admin.skavia.com',
      mfaMethod: 'totp',
    });
    expect(activeLogin.res.status).toBe(200);
    expect(activeLogin.body.session.roles).toContain('Branch Manager');

    // Resend & revoke lifecycle on a second invite
    const inv2Res = await createInvitation(
      new Request('https://superadmin.skavia.com/api/admin/invitations', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
          cookie: superAuth.cookie,
        },
        body: JSON.stringify({
          fullName: 'Temp Ops',
          email: 'temp.ops@skavia.com',
          roleName: 'Company Admin',
          branchIds: [],
        }),
      })
    );
    const inv2Body = await inv2Res.json();
    const inv2Id: string = inv2Body.invitation.invitation_id;

    const resendRes = await mutateInvitation(
      new Request(`https://superadmin.skavia.com/api/admin/invitations/${inv2Id}`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
          cookie: superAuth.cookie,
        },
        body: JSON.stringify({ action: 'resend', expiresInHours: 48 }),
      }),
      { params: Promise.resolve({ id: inv2Id }) }
    );
    expect(resendRes.status).toBe(200);

    const revokeRes = await mutateInvitation(
      new Request(`https://superadmin.skavia.com/api/admin/invitations/${inv2Id}`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
          cookie: superAuth.cookie,
        },
        body: JSON.stringify({ action: 'revoke' }),
      }),
      { params: Promise.resolve({ id: inv2Id }) }
    );
    expect(revokeRes.status).toBe(200);
    expect((await revokeRes.json()).invitation.status).toBe('Revoked');

    // Super Admin can list all invitations safely without exposing token_hash
    const listRes = await listInvitations(
      new Request('https://superadmin.skavia.com/api/admin/invitations', {
        headers: { host: 'superadmin.skavia.com', cookie: superAuth.cookie },
      })
    );
    expect(listRes.status).toBe(200);
    const listBody = await listRes.json();
    expect(listBody.invitations.length).toBe(2);
    expect(listBody.invitations[0].token_hash).toBeUndefined();
  });

  it('generates and single-use consumes emergency recovery codes with replay rejection', async () => {
    const superAuth = await loginOnSurface({
      uid: TEST_IDS.users.superAdmin,
      email: 'superadmin@skavia.com',
      host: 'superadmin.skavia.com',
    });
    await performStepUp(
      superAuth.cookie,
      'superadmin.skavia.com',
      TEST_IDS.users.superAdmin,
      'superadmin@skavia.com'
    );

    const genRes = await generateRecovery(
      new Request('https://superadmin.skavia.com/api/admin/auth/recovery', {
        method: 'POST',
        headers: { host: 'superadmin.skavia.com', cookie: superAuth.cookie },
      })
    );
    expect(genRes.status).toBe(200);
    const genBody = await genRes.json();
    expect(genBody.codes).toHaveLength(8);
    const codeOne: string = genBody.codes[0];

    const statusBefore = await getRecoveryStatus(
      new Request('https://superadmin.skavia.com/api/admin/auth/recovery', {
        headers: { host: 'superadmin.skavia.com', cookie: superAuth.cookie },
      })
    );
    expect((await statusBefore.json()).remainingCount).toBe(8);

    // Login using first-factor token + recovery code
    const primaryToken = await makeTestFirebaseToken(
      TEST_IDS.users.superAdmin,
      'superadmin@skavia.com',
      null
    );
    const consumeRes = await consumeRecovery(
      new Request('https://superadmin.skavia.com/api/admin/auth/recovery', {
        method: 'PUT',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
        },
        body: JSON.stringify({
          idToken: primaryToken,
          recoveryCode: codeOne,
          mode: 'login',
          surface: 'superadmin',
        }),
      })
    );
    expect(consumeRes.status).toBe(200);
    expect(extractCookieHeader(consumeRes)).toContain('skavia_admin_session=');

    // Replaying same recovery code fails closed with 403
    const replayRes = await consumeRecovery(
      new Request('https://superadmin.skavia.com/api/admin/auth/recovery', {
        method: 'PUT',
        headers: {
          'content-type': 'application/json',
          host: 'superadmin.skavia.com',
        },
        body: JSON.stringify({
          idToken: primaryToken,
          recoveryCode: codeOne,
          mode: 'login',
          surface: 'superadmin',
        }),
      })
    );
    expect(replayRes.status).toBe(403);

    const statusAfter = await getRecoveryStatus(
      new Request('https://superadmin.skavia.com/api/admin/auth/recovery', {
        headers: { host: 'superadmin.skavia.com', cookie: superAuth.cookie },
      })
    );
    expect((await statusAfter.json()).remainingCount).toBe(7);
  });
});
