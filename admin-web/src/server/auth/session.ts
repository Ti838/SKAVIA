import { SignJWT, jwtVerify } from 'jose';
import { cookies, headers } from 'next/headers';
import type { AdminSessionContext } from '@/lib/contracts';
import { getServerEnvConfig } from '../config/env';
import type { AdminRepository } from '../db/repository';
import {
  AuthorizationError,
  computeEffectivePermissions,
  pickPrimaryAdminRole,
} from './rbac';
import {
  assertSurfaceRoleCompatibility,
  resolvePortalSurfaceFromRequest,
  surfaceToStrictPortal,
} from './surface';

export const ADMIN_SESSION_COOKIE = 'skavia_admin_session';
export const SESSION_MAX_AGE_SECONDS = 60 * 60 * 8; // 8 hours
export const STEP_UP_WINDOW_MS = 10 * 60 * 1000; // 10 minutes

export async function signSessionCookieValue(payload: {
  sessionId: string;
  userId: string;
}): Promise<string> {
  const { adminSessionSecret } = getServerEnvConfig();
  const key = new TextEncoder().encode(adminSessionSecret);
  return new SignJWT({ sid: payload.sessionId })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(payload.userId)
    .setIssuer('skavia-admin-web')
    .setIssuedAt()
    .setExpirationTime(`${SESSION_MAX_AGE_SECONDS}s`)
    .sign(key);
}

export async function verifySessionCookieValue(
  token: string
): Promise<{ sessionId: string; userId: string } | null> {
  try {
    const { adminSessionSecret } = getServerEnvConfig();
    const key = new TextEncoder().encode(adminSessionSecret);
    const { payload } = await jwtVerify(token, key, {
      issuer: 'skavia-admin-web',
    });
    const userId = typeof payload.sub === 'string' ? payload.sub : '';
    const sessionId = typeof payload.sid === 'string' ? payload.sid : '';
    if (!userId || !sessionId) return null;
    return { sessionId, userId };
  } catch {
    return null;
  }
}

export async function readSignedSessionFromRequest(
  req?: Request
): Promise<{ sessionId: string; userId: string } | null> {
  let rawCookie: string | undefined;

  if (req) {
    const cookieHeader = req.headers.get('cookie') || '';
    for (const part of cookieHeader.split(';')) {
      const [k, ...rest] = part.trim().split('=');
      if (k === ADMIN_SESSION_COOKIE) {
        rawCookie = decodeURIComponent(rest.join('='));
        break;
      }
    }
  } else {
    const store = await cookies();
    rawCookie = store.get(ADMIN_SESSION_COOKIE)?.value;
  }

  if (!rawCookie) return null;
  return verifySessionCookieValue(rawCookie);
}

export async function resolveVerifiedAdminSession(
  repo: AdminRepository,
  req?: Request
): Promise<AdminSessionContext> {
  const parsed = await readSignedSessionFromRequest(req);
  if (!parsed) {
    throw new AuthorizationError(
      'UNAUTHENTICATED',
      'Valid administrator session required.',
      401
    );
  }

  const session = await repo.getAdminSession(parsed.sessionId);
  if (!session || session.user_id !== parsed.userId) {
    throw new AuthorizationError(
      'SESSION_INVALID',
      'Administrator session not found.',
      401
    );
  }

  if (session.revoked_at) {
    throw new AuthorizationError(
      'SESSION_REVOKED',
      'This administrator session has been revoked.',
      401
    );
  }

  if (new Date(session.expires_at).getTime() <= Date.now()) {
    throw new AuthorizationError(
      'SESSION_EXPIRED',
      'Administrator session expired. Please sign in again.',
      401
    );
  }

  const identity = await repo.resolveAdminIdentity(parsed.userId);
  if (!identity) {
    throw new AuthorizationError(
      'ROLE_REVOKED',
      'Administrator privileges are no longer active for this account.',
      403
    );
  }

  if (
    identity.user.status !== 'Active' ||
    (identity.user.account_status && identity.user.account_status !== 'active')
  ) {
    throw new AuthorizationError(
      'ACCOUNT_SUSPENDED',
      'Administrator account is suspended or deactivated.',
      403
    );
  }

  if (identity.permissionVersion !== session.permission_version_snapshot) {
    throw new AuthorizationError(
      'PERMISSION_VERSION_CHANGED',
      'Your roles or permissions changed. Please sign in again.',
      401
    );
  }

  const primaryRole = pickPrimaryAdminRole(identity.roles);
  if (!primaryRole) {
    throw new AuthorizationError(
      'ADMIN_ROLE_REQUIRED',
      'Account does not hold an internal SKAVIA admin role.',
      403
    );
  }

  const hdrs = req ? req.headers : await headers();
  const resolvedSurface = resolvePortalSurfaceFromRequest({
    headers: hdrs,
    url: req?.url,
  });
  assertSurfaceRoleCompatibility({
    surface: resolvedSurface,
    primaryRole,
    roles: identity.roles,
    isPrimarySuperAdmin: identity.isPrimarySuperAdmin,
  });

  const effectivePermissions = computeEffectivePermissions(
    identity.rolePermissions,
    identity.overrides
  );

  return {
    sessionId: session.session_id,
    userId: identity.user.user_id,
    email: identity.user.email || '',
    fullName: identity.user.full_name,
    roles: identity.roles,
    primaryRole,
    isPrimarySuperAdmin: identity.isPrimarySuperAdmin,
    loginUsername: identity.loginUsername,
    portalSurface: surfaceToStrictPortal(resolvedSurface, primaryRole),
    effectivePermissions,
    branchScoped: primaryRole === 'Branch Manager' || identity.branchScoped,
    assignedBranches: identity.assignedBranches,
    permissionVersion: identity.permissionVersion,
    mfaVerified: true,
    mfaMethod: 'mfa',
    stepUpExpiresAt: session.step_up_expires_at,
    expiresAt: session.expires_at,
  };
}

