import { NextResponse } from 'next/server';
import type { AuthenticationResponseJSON } from '@simplewebauthn/server';
import { z } from 'zod';
import { extractClientIp, recordAdminAudit } from '@/server/audit/logger';
import { issueVerifiedAdminSessionResponse } from '@/server/auth/issue-session';
import { AuthorizationError } from '@/server/auth/rbac';
import { resolveVerifiedAdminSession, STEP_UP_WINDOW_MS } from '@/server/auth/session';
import {
  resolveWebAuthnRp,
  verifyPasskeyAssertion,
} from '@/server/auth/webauthn';
import { getAdminRepository } from '@/server/db/store-factory';
import { jsonErrorResponse } from '@/server/http/guard';

const AuthVerifySchema = z.object({
  challengeId: z.string().uuid(),
  mode: z.enum(['login', 'step_up']).default('login'),
  surface: z.enum(['superadmin', 'admin']).optional(),
  deviceLabel: z.string().max(120).optional(),
  response: z.custom<AuthenticationResponseJSON>(
    (v) => Boolean(v && typeof v === 'object' && 'id' in v && 'response' in v),
    'Valid WebAuthn assertion payload required.'
  ),
});

export async function POST(req: Request) {
  const correlationId = req.headers.get('x-correlation-id') || crypto.randomUUID();
  const ipAddress = extractClientIp(req);
  const userAgent = req.headers.get('user-agent');

  try {
    const repo = getAdminRepository();
    const input = AuthVerifySchema.parse(await req.json());
    const purpose = input.mode === 'step_up' ? 'step_up' : 'authenticate';

    const challengeRec = await repo.consumeWebAuthnChallenge(input.challengeId, purpose);
    if (!challengeRec) {
      throw new AuthorizationError(
        'CHALLENGE_INVALID',
        'Passkey authentication challenge expired or already used.',
        400
      );
    }

    const cred = await repo.getPasskeyById(input.response.id);
    if (!cred) {
      await repo.recordLoginEvent({
        userId: challengeRec.user_id,
        email: null,
        surface: input.surface ?? null,
        outcome: 'Passkey_Failed',
        mfaMethod: 'webauthn',
        ipAddress,
        userAgent,
        failureReason: 'Unknown or revoked passkey credential',
      });
      throw new AuthorizationError(
        'PASSKEY_NOT_FOUND',
        'Recognized active Passkey not found for this device.',
        401
      );
    }

    if (input.mode === 'step_up') {
      const session = await resolveVerifiedAdminSession(repo, req);
      if (cred.user_id !== session.userId) {
        throw new AuthorizationError('USER_MISMATCH', 'Passkey does not belong to current session user.', 403);
      }
    }

    const { rpID, expectedOrigin } = resolveWebAuthnRp(req);
    const verification = await verifyPasskeyAssertion({
      response: input.response,
      expectedChallenge: challengeRec.challenge,
      expectedOrigin,
      expectedRPID: rpID,
      credential: cred,
    });

    if (!verification.verified) {
      await repo.recordLoginEvent({
        userId: cred.user_id,
        email: null,
        surface: input.surface ?? null,
        outcome: 'Passkey_Failed',
        mfaMethod: 'webauthn',
        ipAddress,
        userAgent,
        failureReason: 'WebAuthn signature assertion verification returned false',
      });
      throw new AuthorizationError('PASSKEY_INVALID', 'Biometric/Passkey signature failed.', 401);
    }

    await repo.touchPasskeyUsage(cred.credential_id, verification.authenticationInfo.newCounter);

    if (input.mode === 'step_up') {
      const session = await resolveVerifiedAdminSession(repo, req);
      const stepUpExpiresAt = new Date(Date.now() + STEP_UP_WINDOW_MS).toISOString();
      await repo.refreshSessionStepUp(session.sessionId, stepUpExpiresAt);
      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'admin.passkey.step_up',
        entityType: 'user_session',
        entityId: session.sessionId,
        details: { credential_id: cred.credential_id, step_up_expires_at: stepUpExpiresAt },
        ipAddress,
        correlationId,
      });
      return NextResponse.json({ stepUpExpiresAt });
    }

    return await issueVerifiedAdminSessionResponse({
      req,
      repo,
      userId: cred.user_id,
      verifiedEmail: null,
      mfaVerified: true,
      mfaMethod: 'webauthn',
      explicitSurface: input.surface ?? null,
      deviceLabel: input.deviceLabel || cred.friendly_name,
      correlationId,
      ipAddress,
      userAgent,
      requireMfaConfig: true,
    });
  } catch (error) {
    return jsonErrorResponse(error, correlationId);
  }
}

