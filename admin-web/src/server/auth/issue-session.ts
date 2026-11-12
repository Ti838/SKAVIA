import { createHash } from 'node:crypto';
import { NextResponse } from 'next/server';
import type { AdminSessionContext, PortalSurface } from '@/lib/contracts';
import type { AdminRepository } from '../db/repository';
import { recordAdminAudit } from '../audit/logger';
import { sendNewDeviceSecurityAlert } from '../services/email';
import {
  AuthorizationError,
  computeEffectivePermissions,
  pickPrimaryAdminRole,
} from './rbac';
import {
  ADMIN_SESSION_COOKIE,
  SESSION_MAX_AGE_SECONDS,
  STEP_UP_WINDOW_MS,
  signSessionCookieValue,
} from './session';
import {
  assertSurfaceRoleCompatibility,
  resolvePortalSurfaceFromRequest,
  surfaceToStrictPortal,
} from './surface';

export async function issueVerifiedAdminSessionResponse(params: {
  req: Request;
  repo: AdminRepository;
  userId: string;
  verifiedEmail: string | null;
  mfaVerified: boolean;
  mfaMethod: string | null;
  explicitSurface?: PortalSurface | null;
  deviceLabel?: string;
  correlationId: string;
  ipAddress: string;
  userAgent: string | null;
  requireMfaConfig: boolean;
}): Promise<NextResponse> {
  const {
    req,
    repo,
    userId,
    verifiedEmail,
    mfaVerified,
    mfaMethod,
    explicitSurface,
    deviceLabel,
    correlationId,
    ipAddress,
    userAgent,
    requireMfaConfig,
  } = params;

  const surface = resolvePortalSurfaceFromRequest(req, explicitSurface);
  const identity = await repo.resolveAdminIdentity(userId);

  if (!identity) {
    await repo.recordLoginEvent({
      userId,
      email: verifiedEmail,
      surface,
      outcome: 'Blocked_NoAdminRole',
      ipAddress,
      userAgent,
      failureReason: 'No internal SKAVIA admin role assigned',
    });
    throw new AuthorizationError(
      'ADMIN_ROLE_REQUIRED',
      'This account does not have an internal SKAVIA admin role.',
      403
    );
  }

  if (identity.user.account_status === 'pending_approval') {
    await repo.recordLoginEvent({
      userId: identity.user.user_id,
      email: identity.user.email,
      surface,
      outcome: 'Blocked_PendingApproval',
      ipAddress,
      userAgent,
      failureReason: 'Invited admin awaiting primary Super Admin approval',
    });
    throw new AuthorizationError(
      'PENDING_SUPERADMIN_APPROVAL',
      'Your account activation is awaiting final Super Admin approval.',
      403
    );
  }

  if (
    identity.user.status !== 'Active' ||
    (identity.user.account_status && identity.user.account_status !== 'active')
  ) {
    await repo.recordLoginEvent({
      userId: identity.user.user_id,
      email: identity.user.email,
      surface,
      outcome: 'Blocked_Suspended',
      ipAddress,
      userAgent,
      failureReason: 'Admin account suspended or deactivated',
    });
    throw new AuthorizationError(
      'ACCOUNT_SUSPENDED',
      'Administrator account is suspended or deactivated.',
      403
    );
  }

  const primaryRole = pickPrimaryAdminRole(identity.roles);
  if (!primaryRole) {
    await repo.recordLoginEvent({
      userId: identity.user.user_id,
      email: identity.user.email,
      surface,
      outcome: 'Blocked_NoAdminRole',
      ipAddress,
      userAgent,
      failureReason: 'Primary role not among allowed internal admin roles',
    });
    throw new AuthorizationError(
      'ADMIN_ROLE_REQUIRED',
      'Administrator role is invalid.',
      403
    );
  }

  try {
    assertSurfaceRoleCompatibility({
      surface,
      primaryRole,
      roles: identity.roles,
      isPrimarySuperAdmin: identity.isPrimarySuperAdmin,
    });
  } catch (err) {
    await repo.recordLoginEvent({
      userId: identity.user.user_id,
      email: identity.user.email,
      surface,
      outcome: 'Blocked_WrongSurface',
      ipAddress,
      userAgent,
      failureReason: err instanceof Error ? err.message : 'Surface violation',
    });
    throw err;
  }

  const requireMfa = requireMfaConfig && identity.mfaEnforced;
  if (requireMfa && !mfaVerified) {
    await repo.recordLoginEvent({
      userId: identity.user.user_id,
      email: identity.user.email,
      surface,
      outcome: 'Blocked_NoMFA',
      mfaMethod,
      ipAddress,
      userAgent,
      failureReason: 'MFA claim absent on admin token',
    });
    throw new AuthorizationError(
      'MFA_REQUIRED',
      'Multi-factor authentication or Passkey is required for SKAVIA administrator accounts.',
      403
    );
  }

  const fingerprintSource = `${deviceLabel || userAgent || 'browser'}|${ipAddress}`;
  const fingerprint = createHash('sha256')
    .update(fingerprintSource)
    .digest('hex')
    .slice(0, 24);
  const { isNewDevice } = await repo.checkAndRegisterDevice({
    userId: identity.user.user_id,
    fingerprint,
    deviceLabel: deviceLabel || userAgent || 'Admin Web Browser',
    ipAddress,
  });

  if (isNewDevice) {
    await repo.recordLoginEvent({
      userId: identity.user.user_id,
      email: identity.user.email,
      surface,
      outcome: 'New_Device_Detected',
      mfaMethod,
      ipAddress,
      userAgent,
      failureReason: 'Sign-in from an unrecognized browser/device fingerprint',
    });
    if (identity.user.email) {
      await sendNewDeviceSecurityAlert({
        to: identity.user.email,
        fullName: identity.user.full_name,
        roleName: primaryRole,
        surface: surfaceToStrictPortal(surface, primaryRole),
        ipAddress,
        userAgent: deviceLabel || userAgent || 'Unknown Browser',
      }).catch(() => undefined);
    }
  }

  const nowMs = Date.now();
  const expiresAt = new Date(nowMs + SESSION_MAX_AGE_SECONDS * 1000).toISOString();
  const stepUpExpiresAt = mfaVerified
    ? new Date(nowMs + STEP_UP_WINDOW_MS).toISOString()
    : null;

  const sessionRecord = await repo.createAdminSession({
    userId: identity.user.user_id,
    deviceLabel: deviceLabel || 'Admin Web Browser',
    ipAddress,
    permissionVersion: identity.permissionVersion,
    stepUpExpiresAt,
    expiresAt,
  });

  await repo.recordLoginEvent({
    userId: identity.user.user_id,
    email: identity.user.email,
    surface,
    outcome: mfaMethod === 'webauthn' ? 'Passkey_Success' : 'Success',
    mfaMethod: mfaMethod || 'password',
    ipAddress,
    userAgent,
  });

  const portalSurface = surfaceToStrictPortal(surface, primaryRole);

  await recordAdminAudit(repo, {
    userId: identity.user.user_id,
    action: 'admin.session.login',
    entityType: 'user_session',
    entityId: sessionRecord.session_id,
    details: {
      role: primaryRole,
      surface: portalSurface,
      is_primary_super_admin: identity.isPrimarySuperAdmin,
      new_device_detected: isNewDevice,
      mfa_method: mfaMethod,
      branch_scoped: primaryRole === 'Branch Manager' || identity.branchScoped,
    },
    ipAddress,
    correlationId,
  });

  const cookieValue = await signSessionCookieValue({
    sessionId: sessionRecord.session_id,
    userId: identity.user.user_id,
  });

  const effectivePermissions = computeEffectivePermissions(
    identity.rolePermissions,
    identity.overrides
  );

  const sessionPayload: AdminSessionContext = {
    sessionId: sessionRecord.session_id,
    userId: identity.user.user_id,
    email: identity.user.email || verifiedEmail || '',
    fullName: identity.user.full_name,
    roles: identity.roles,
    primaryRole,
    isPrimarySuperAdmin: identity.isPrimarySuperAdmin,
    loginUsername: identity.loginUsername,
    portalSurface,
    effectivePermissions,
    branchScoped: primaryRole === 'Branch Manager' || identity.branchScoped,
    assignedBranches: identity.assignedBranches,
    permissionVersion: identity.permissionVersion,
    mfaVerified,
    mfaMethod,
    stepUpExpiresAt,
    expiresAt,
  };

  const response = NextResponse.json({
    session: sessionPayload,
    newDeviceAlert: isNewDevice,
  });

  response.cookies.set(ADMIN_SESSION_COOKIE, cookieValue, {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/',
    maxAge: SESSION_MAX_AGE_SECONDS,
  });
  response.headers.set('X-Correlation-Id', correlationId);
  response.headers.set('Cache-Control', 'no-store');
  return response;
}

