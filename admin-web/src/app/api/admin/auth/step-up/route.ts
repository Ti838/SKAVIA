import { NextResponse } from 'next/server';
import { StepUpInputSchema } from '@/lib/contracts';
import { STEP_UP_WINDOW_MS } from '@/server/auth/session';
import { verifyFirebaseIdToken } from '@/server/auth/firebase-jwt';
import { AuthorizationError } from '@/server/auth/rbac';
import { getServerEnvConfig } from '@/server/config/env';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function POST(req: Request) {
  return withAdminRoute(req, {}, async ({ session, repo, correlationId, ipAddress }) => {
    const input = StepUpInputSchema.parse(await req.json());
    let verified: Awaited<ReturnType<typeof verifyFirebaseIdToken>>;
    try {
      verified = await verifyFirebaseIdToken(input.idToken);
    } catch {
      throw new AuthorizationError(
        'INVALID_TOKEN',
        'Step-up re-authentication token is invalid or expired.',
        401
      );
    }

    if (verified.uid !== session.userId) {
      throw new AuthorizationError(
        'USER_MISMATCH',
        'Step-up identity does not match the active administrator session.',
        403
      );
    }

    const identity = await repo.resolveAdminIdentity(session.userId);
    const requireMfa = getServerEnvConfig().requireMfa && Boolean(identity?.mfaEnforced);
    if (requireMfa && !verified.mfaVerified) {
      throw new AuthorizationError(
        'MFA_REQUIRED',
        'Fresh MFA verification is required to complete step-up authorization.',
        403
      );
    }

    const stepUpExpiresAt = new Date(Date.now() + STEP_UP_WINDOW_MS).toISOString();
    await repo.refreshSessionStepUp(session.sessionId, stepUpExpiresAt);

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: 'admin.session.step_up',
      entityType: 'user_session',
      entityId: session.sessionId,
      details: {
        mfa_method: verified.mfaMethod,
        step_up_expires_at: stepUpExpiresAt,
      },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({ stepUpExpiresAt });
  });
}

