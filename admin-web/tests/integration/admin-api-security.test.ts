import { beforeEach, describe, expect, it } from 'vitest';
import { SignJWT } from 'jose';
import { setTestAdminRepository } from '@/server/db/store-factory';
import { InMemoryAdminRepository, TEST_IDS } from '../helpers/in-memory-store';

// API Route Handlers under test
import { POST as loginExchange, GET as getSession } from '@/app/api/admin/auth/session/route';
import { POST as stepUpRoute } from '@/app/api/admin/auth/step-up/route';
import { GET as dashboardRoute } from '@/app/api/admin/dashboard/route';
import { GET as financeRoute } from '@/app/api/admin/finance/route';
import {
  POST as requestApprovalRoute,
  PATCH as decideApprovalRoute,
} from '@/app/api/admin/finance/approvals/route';
import { GET as verificationDocRoute } from '@/app/api/admin/verifications/[id]/document/route';
import { POST as verificationDecideRoute } from '@/app/api/admin/verifications/[id]/decision/route';
import { PATCH as updateAdminRoute } from '@/app/api/admin/admins/[id]/route';
import { PATCH as updateBookingRoute } from '@/app/api/admin/bookings/[id]/route';
import { PATCH as updateCustomerRoute } from '@/app/api/admin/customers/[id]/route';
import {
  POST as createIncidentRoute,
  PATCH as updateIncidentRoute,
} from '@/app/api/admin/security/incidents/route';
import { DELETE as revokeSessionRoute } from '@/app/api/admin/security/sessions/route';
import { POST as mutateServiceRoute } from '@/app/api/admin/services/route';
import { POST as assembleTeamRoute } from '@/app/api/admin/teams/route';
import { GET as reportsRoute } from '@/app/api/admin/reports/route';
import { PATCH as updateWorkerRoute } from '@/app/api/admin/workers/[id]/route';
import { GET as publicDistributionRoute } from '@/app/api/public/distribution/route';

const TEST_SECRET = 'vitest-admin-session-secret-minimum-32-chars-ok';

async function makeTestFirebaseToken(uid: string, email: string, mfaMethod?: string) {
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
    .setExpirationTime('10m')
    .sign(key);
  return `test-harness.${jwt}`;
}

async function loginAs(
  uid: string,
  email: string,
  mfaMethod?: string
): Promise<{ cookie: string; session: { sessionId: string } }> {
  const idToken = await makeTestFirebaseToken(uid, email, mfaMethod);
  const req = new Request('http://localhost:3001/api/admin/auth/session', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ idToken, deviceLabel: 'Vitest Security Suite' }),
  });
  const res = await loginExchange(req);
  expect(res.status).toBe(200);
  const setCookie = res.headers.get('set-cookie') || '';
  const cookiePair = setCookie.split(';')[0] || '';
  const body = (await res.json()) as { session: { sessionId: string } };
  return { cookie: cookiePair, session: body.session };
}

describe('Admin Portal API Security, RBAC/ABAC & End-to-End Workflows', () => {
  let repo: InMemoryAdminRepository;

  beforeEach(() => {
    process.env.SKAVIA_TEST_MODE = 'harness';
    process.env.ADMIN_SESSION_SECRET = TEST_SECRET;
    process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID = 'skavia-113a3';
    repo = new InMemoryAdminRepository();
    setTestAdminRepository(repo);
  });

  it('rejects unauthenticated requests & non-admin accounts cleanly', async () => {
    const unauthRes = await getSession(new Request('http://localhost:3001/api/admin/auth/session'));
    expect(unauthRes.status).toBe(401);

    const custToken = await makeTestFirebaseToken(
      TEST_IDS.users.customerIndividual,
      'arif@example.com'
    );
    const exchangeRes = await loginExchange(
      new Request('http://localhost:3001/api/admin/auth/session', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ idToken: custToken }),
      })
    );
    expect(exchangeRes.status).toBe(403);
    expect(repo.loginEvents.some((e) => e.outcome === 'Blocked_NoAdminRole')).toBe(true);
  });

  it('enforces MFA requirement for MFA-enforced admins and blocks suspended admins', async () => {
    const superTokenNoMfa = await makeTestFirebaseToken(
      TEST_IDS.users.superAdmin,
      'superadmin@skavia.com'
    );
    const noMfaRes = await loginExchange(
      new Request('http://localhost:3001/api/admin/auth/session', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ idToken: superTokenNoMfa }),
      })
    );
    expect(noMfaRes.status).toBe(403);
    expect(repo.loginEvents.some((e) => e.outcome === 'Blocked_NoMFA')).toBe(true);

    const suspendedToken = await makeTestFirebaseToken(
      TEST_IDS.users.suspendedAdmin,
      'suspended@skavia.com'
    );
    const suspRes = await loginExchange(
      new Request('http://localhost:3001/api/admin/auth/session', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ idToken: suspendedToken }),
      })
    );
    expect(suspRes.status).toBe(403);
    expect(repo.loginEvents.some((e) => e.outcome === 'Blocked_Suspended')).toBe(true);
  });

  it('strictly enforces Branch Manager branch isolation and blocks cross-branch IDOR', async () => {
    const { cookie } = await loginAs(
      TEST_IDS.users.branchManagerTech,
      'tech.manager@skavia.com',
      'totp'
    );

    // Allowed: TECH dashboard
    const okDash = await dashboardRoute(
      new Request(`http://localhost:3001/api/admin/dashboard?branchId=${TEST_IDS.branches.TECH}`, {
        headers: { cookie },
      })
    );
    expect(okDash.status).toBe(200);
    const dashBody = (await okDash.json()) as { metrics: { branchBreakdown: Array<{ code: string }> } };
    expect(dashBody.metrics.branchBreakdown.map((b) => b.code)).toEqual(['TECH']);

    // Forbidden: HOME dashboard IDOR
    const badDash = await dashboardRoute(
      new Request(`http://localhost:3001/api/admin/dashboard?branchId=${TEST_IDS.branches.HOME}`, {
        headers: { cookie },
      })
    );
    expect(badDash.status).toBe(403);
    expect(repo.auditLogs.some((l) => l.action === 'security.access.denied')).toBe(true);

    // Forbidden: Global Finance page for Branch Manager
    const finRes = await financeRoute(
      new Request('http://localhost:3001/api/admin/finance', { headers: { cookie } })
    );
    expect(finRes.status).toBe(403);

    // Allowed: TECH KYC document signed URL & audit log
    const techDoc = await verificationDocRoute(
      new Request(
        `http://localhost:3001/api/admin/verifications/${TEST_IDS.verifications.techPending}/document`,
        { headers: { cookie } }
      ),
      { params: Promise.resolve({ id: TEST_IDS.verifications.techPending }) }
    );
    expect(techDoc.status).toBe(200);
    expect(repo.auditLogs.some((l) => l.action === 'kyc.document.viewed')).toBe(true);

    // Forbidden: HOME KYC document & decision IDOR
    const homeDoc = await verificationDocRoute(
      new Request(
        `http://localhost:3001/api/admin/verifications/${TEST_IDS.verifications.homePending}/document`,
        { headers: { cookie } }
      ),
      { params: Promise.resolve({ id: TEST_IDS.verifications.homePending }) }
    );
    expect(homeDoc.status).toBe(403);

    const homeDecide = await verificationDecideRoute(
      new Request(
        `http://localhost:3001/api/admin/verifications/${TEST_IDS.verifications.homePending}/decision`,
        {
          method: 'POST',
          headers: { cookie, 'content-type': 'application/json' },
          body: JSON.stringify({
            decision: 'Approved',
            reviewNotes: 'Attempting cross-branch approval',
          }),
        }
      ),
      { params: Promise.resolve({ id: TEST_IDS.verifications.homePending }) }
    );
    expect(homeDecide.status).toBe(403);
  });

  it('enforces Maker != Checker financial separation & Step-Up verification', async () => {
    const company = await loginAs(
      TEST_IDS.users.companyAdmin,
      'ops@skavia.com',
      'totp'
    );
    const superAdmin = await loginAs(
      TEST_IDS.users.superAdmin,
      'superadmin@skavia.com',
      'totp'
    );

    // Company Admin creates Maker request
    const makerRes = await requestApprovalRoute(
      new Request('http://localhost:3001/api/admin/finance/approvals', {
        method: 'POST',
        headers: { cookie: company.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          actionType: 'PAYOUT_APPROVAL',
          entityId: TEST_IDS.workerProfiles.tech,
          amount: 12000,
          reason: 'Monthly specialist settlement payout request',
          idempotencyKey: 'payout-key-0001-abcdef',
          branchId: TEST_IDS.branches.TECH,
        }),
      })
    );
    expect(makerRes.status).toBe(201);
    const { approval } = (await makerRes.json()) as { approval: { approval_id: string } };

    // Company Admin lacks payout.approve (403) AND even with temporary ALLOW cannot self-approve
    repo.users.get(TEST_IDS.users.companyAdmin)?.overrides.push({
      permission_key: 'payout.approve',
      effect: 'ALLOW',
      expires_at: null,
    });
    const selfApproveRes = await decideApprovalRoute(
      new Request('http://localhost:3001/api/admin/finance/approvals', {
        method: 'PATCH',
        headers: { cookie: company.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          approvalId: approval.approval_id,
          decision: 'Approved',
          checkerNotes: 'Trying to self-approve my own payout request',
        }),
      })
    );
    expect(selfApproveRes.status).toBe(403);

    // Expired step-up on Super Admin returns 401 STEP_UP_REQUIRED
    await repo.refreshSessionStepUp(
      superAdmin.session.sessionId,
      new Date(Date.now() - 5000).toISOString()
    );
    const staleRes = await decideApprovalRoute(
      new Request('http://localhost:3001/api/admin/finance/approvals', {
        method: 'PATCH',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          approvalId: approval.approval_id,
          decision: 'Approved',
          checkerNotes: 'Checker approval after verifying settlement',
        }),
      })
    );
    expect(staleRes.status).toBe(401);
    const staleBody = (await staleRes.json()) as { error: { code: string } };
    expect(staleBody.error.code).toBe('STEP_UP_REQUIRED');

    // Refresh Step-Up via real endpoint then succeed!
    const freshToken = await makeTestFirebaseToken(
      TEST_IDS.users.superAdmin,
      'superadmin@skavia.com',
      'totp'
    );
    const stepUpRes = await stepUpRoute(
      new Request('http://localhost:3001/api/admin/auth/step-up', {
        method: 'POST',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({ idToken: freshToken }),
      })
    );
    expect(stepUpRes.status).toBe(200);

    const approveRes = await decideApprovalRoute(
      new Request('http://localhost:3001/api/admin/finance/approvals', {
        method: 'PATCH',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          approvalId: approval.approval_id,
          decision: 'Approved',
          checkerNotes: 'Verified SSLCommerz settlement ledger and approved payout.',
        }),
      })
    );
    expect(approveRes.status).toBe(200);
    const decBody = (await approveRes.json()) as { approval: { status: string } };
    expect(decBody.approval.status).toBe('Approved');
  });

  it('prevents self-IAM modification, bumps permission version & enforces instant session revocation', async () => {
    const superAdmin = await loginAs(
      TEST_IDS.users.superAdmin,
      'superadmin@skavia.com',
      'totp'
    );
    const techBm = await loginAs(
      TEST_IDS.users.branchManagerTech,
      'tech.manager@skavia.com',
      'totp'
    );

    // Super Admin cannot suspend self
    const selfMod = await updateAdminRoute(
      new Request(`http://localhost:3001/api/admin/admins/${TEST_IDS.users.superAdmin}`, {
        method: 'PATCH',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({ suspendReason: 'Should never be allowed on self' }),
      }),
      { params: Promise.resolve({ id: TEST_IDS.users.superAdmin }) }
    );
    expect(selfMod.status).toBe(403);

    // Super Admin updates Branch Manager override -> permissionVersion bumps -> BM cookie invalidated (401)
    const permRes = await updateAdminRoute(
      new Request(`http://localhost:3001/api/admin/admins/${TEST_IDS.users.branchManagerTech}`, {
        method: 'PATCH',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          override: {
            permissionKey: 'worker.verify',
            effect: 'DENY',
            reason: 'Temporary freeze during branch audit',
          },
        }),
      }),
      { params: Promise.resolve({ id: TEST_IDS.users.branchManagerTech }) }
    );
    expect(permRes.status).toBe(200);

    const staleBmDash = await dashboardRoute(
      new Request('http://localhost:3001/api/admin/dashboard', {
        headers: { cookie: techBm.cookie },
      })
    );
    expect(staleBmDash.status).toBe(401);

    // Re-login Company Admin & immediately revoke session
    const comp = await loginAs(TEST_IDS.users.companyAdmin, 'ops@skavia.com', 'totp');
    const revokeRes = await revokeSessionRoute(
      new Request('http://localhost:3001/api/admin/security/sessions', {
        method: 'DELETE',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({ sessionId: comp.session.sessionId }),
      })
    );
    expect(revokeRes.status).toBe(200);

    const revokedCheck = await getSession(
      new Request('http://localhost:3001/api/admin/auth/session', {
        headers: { cookie: comp.cookie },
      })
    );
    expect(revokedCheck.status).toBe(401);
  });

  it('assembles Turnkey teams inside branch scope, blocks cross-branch team IDOR, and escapes CSV safely', async () => {
    const techBm = await loginAs(
      TEST_IDS.users.branchManagerTech,
      'tech.manager@skavia.com',
      'totp'
    );

    const okTeam = await assembleTeamRoute(
      new Request('http://localhost:3001/api/admin/teams', {
        method: 'POST',
        headers: { cookie: techBm.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          projectId: TEST_IDS.projects.techProject,
          teamName: 'Line-2 Retrofit Crew',
          members: [
            {
              workerProfileId: TEST_IDS.workerProfiles.tech,
              roleInTeam: 'Team Lead',
              isTeamLeader: true,
            },
          ],
          initialTasks: [{ title: 'Commission HVAC panel', priority: 'High' }],
        }),
      })
    );
    expect(okTeam.status).toBe(201);

    // Cross-branch HOME project blocked
    const idorTeam = await assembleTeamRoute(
      new Request('http://localhost:3001/api/admin/teams', {
        method: 'POST',
        headers: { cookie: techBm.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          projectId: TEST_IDS.projects.homeProject,
          teamName: 'Unauthorized Squad',
          members: [
            {
              workerProfileId: TEST_IDS.workerProfiles.home,
              roleInTeam: 'Team Lead',
              isTeamLeader: true,
            },
          ],
          initialTasks: [],
        }),
      })
    );
    expect(idorTeam.status).toBe(403);

    // CSV formula neutralization check
    repo.branches.push({
      branch_id: 'b4444444-4444-4444-8444-444444444444',
      name: '=cmd|calc!A0',
      code: '+EVIL',
      description: null,
      manager_id: null,
      is_active: true,
      created_at: '2026-11-11T00:00:00Z',
    });
    const superAdmin = await loginAs(
      TEST_IDS.users.superAdmin,
      'superadmin@skavia.com',
      'totp'
    );
    const csvRes = await reportsRoute(
      new Request('http://localhost:3001/api/admin/reports?format=csv', {
        headers: { cookie: superAdmin.cookie },
      })
    );
    expect(csvRes.status).toBe(200);
    const csvText = await csvRes.text();
    expect(csvText).toContain("'+EVIL");
    expect(csvText).toContain("'=cmd|calc!A0");
  });

  it('enforces branch scoping and step-up checks on bookings, workers, customers, services, incidents & distribution', async () => {
    const techBm = await loginAs(
      TEST_IDS.users.branchManagerTech,
      'tech.manager@skavia.com',
      'totp'
    );
    const superAdmin = await loginAs(
      TEST_IDS.users.superAdmin,
      'superadmin@skavia.com',
      'totp'
    );

    // 1. Bookings: Tech BM can reschedule TECH booking, blocked from HOME booking IDOR, and Company Admin cancels cleanly with Canceled
    const reschedOk = await updateBookingRoute(
      new Request(`http://localhost:3001/api/admin/bookings/${TEST_IDS.bookings.techBooking}`, {
        method: 'PATCH',
        headers: { cookie: techBm.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          action: 'reschedule',
          scheduledAt: '2026-11-15T14:30:00.000Z',
          reason: 'Customer requested afternoon technical inspection window',
        }),
      }),
      { params: Promise.resolve({ id: TEST_IDS.bookings.techBooking }) }
    );
    expect(reschedOk.status).toBe(200);
    const reschedBody = (await reschedOk.json()) as { booking: { scheduled_at: string } };
    expect(reschedBody.booking.scheduled_at).toBe('2026-11-15T14:30:00.000Z');

    const homeBookingIdor = await updateBookingRoute(
      new Request(`http://localhost:3001/api/admin/bookings/${TEST_IDS.bookings.homeBooking}`, {
        method: 'PATCH',
        headers: { cookie: techBm.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          action: 'cancel',
          reason: 'Cross-branch tamper attempt',
        }),
      }),
      { params: Promise.resolve({ id: TEST_IDS.bookings.homeBooking }) }
    );
    expect(homeBookingIdor.status).toBe(403);

    const cancelOk = await updateBookingRoute(
      new Request(`http://localhost:3001/api/admin/bookings/${TEST_IDS.bookings.homeBooking}`, {
        method: 'PATCH',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          action: 'cancel',
          reason: 'Duplicate service request closed by operations',
        }),
      }),
      { params: Promise.resolve({ id: TEST_IDS.bookings.homeBooking }) }
    );
    expect(cancelOk.status).toBe(200);
    const cancelBody = (await cancelOk.json()) as { booking: { status: string } };
    expect(cancelBody.booking.status).toBe('Canceled');

    // 2. Workers & Customers: suspend/reactivate with audit trail
    const suspendWorkerOk = await updateWorkerRoute(
      new Request(`http://localhost:3001/api/admin/workers/${TEST_IDS.workerProfiles.tech}`, {
        method: 'PATCH',
        headers: { cookie: techBm.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          action: 'suspend',
          reason: 'Safety recertification pending inspection',
        }),
      }),
      { params: Promise.resolve({ id: TEST_IDS.workerProfiles.tech }) }
    );
    expect(suspendWorkerOk.status).toBe(200);
    expect(((await suspendWorkerOk.json()) as { worker: { account_status: string } }).worker.account_status).toBe('suspended');

    const suspendCustomerOk = await updateCustomerRoute(
      new Request(`http://localhost:3001/api/admin/customers/${TEST_IDS.users.customerBusiness}`, {
        method: 'PATCH',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          accountStatus: 'suspended',
          reason: 'Compliance verification hold requested',
        }),
      }),
      { params: Promise.resolve({ id: TEST_IDS.users.customerBusiness }) }
    );
    expect(suspendCustomerOk.status).toBe(200);
    expect(((await suspendCustomerOk.json()) as { customer: { account_status: string } }).customer.account_status).toBe('suspended');

    // 3. Services taxonomy: create skill & toggle category
    const addSkillRes = await mutateServiceRoute(
      new Request('http://localhost:3001/api/admin/services', {
        method: 'POST',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          type: 'skill',
          action: 'create',
          categoryId: TEST_IDS.categories.hvac,
          name: 'Ammonia Leak Detection',
        }),
      })
    );
    expect(addSkillRes.status).toBe(200);
    const taxBody = (await addSkillRes.json()) as { taxonomy: { skills: Array<{ name: string }> } };
    expect(taxBody.taxonomy.skills.some((s) => s.name === 'Ammonia Leak Detection')).toBe(true);

    const toggleCatRes = await mutateServiceRoute(
      new Request('http://localhost:3001/api/admin/services', {
        method: 'POST',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          type: 'category',
          action: 'toggle',
          id: TEST_IDS.categories.home,
          branchId: TEST_IDS.branches.HOME,
          isActive: false,
        }),
      })
    );
    expect(toggleCatRes.status).toBe(200);
    const toggledTax = (await toggleCatRes.json()) as {
      taxonomy: { categories: Array<{ category_id: string; is_active: boolean }> };
    };
    expect(toggledTax.taxonomy.categories.find((c) => c.category_id === TEST_IDS.categories.home)?.is_active).toBe(false);

    // 4. Security incident create & transition lifecycle
    const incCreateRes = await createIncidentRoute(
      new Request('http://localhost:3001/api/admin/security/incidents', {
        method: 'POST',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          title: 'Suspicious API burst detected',
          severity: 'High',
          summary: 'Multiple invalid token requests rejected at edge firewall.',
        }),
      })
    );
    expect(incCreateRes.status).toBe(201);
    const createdInc = (await incCreateRes.json()) as { incident: { incident_id: string } };

    const incPatchRes = await updateIncidentRoute(
      new Request('http://localhost:3001/api/admin/security/incidents', {
        method: 'PATCH',
        headers: { cookie: superAdmin.cookie, 'content-type': 'application/json' },
        body: JSON.stringify({
          incidentId: createdInc.incident.incident_id,
          status: 'Contained',
          containmentNote: 'Source IP range blocked at edge gateway',
        }),
      })
    );
    expect(incPatchRes.status).toBe(200);
    expect(((await incPatchRes.json()) as { incident: { status: string } }).incident.status).toBe('Contained');

    // 5. Public distribution endpoint reports honest publication status
    const distRes = await publicDistributionRoute(
      new Request('http://localhost:3001/api/public/distribution')
    );
    expect(distRes.status).toBe(200);
    const distBody = (await distRes.json()) as { android: { published: boolean }; ios: { published: boolean } };
    expect(typeof distBody.android.published).toBe('boolean');
    expect(typeof distBody.ios.published).toBe('boolean');
  });
});

