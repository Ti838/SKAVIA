import { NextResponse } from 'next/server';
import { RecoveryCodeConsumeSchema } from '@/lib/contracts';
import { extractClientIp, recordAdminAudit } from '@/server/audit/logger';
import {
  consumeRecoveryCodeHash,
  generateRecoveryCodes,
} from '@/server/auth/crypto-tokens';
import { verifyFirebaseIdToken } from '@/server/auth/firebase-jwt';
import { issueVerifiedAdminSessionResponse } from '@/server/auth/issue-session';
import { AuthorizationError } from '@/server/auth/rbac';
import { STEP_UP_WINDOW_MS } from '@/server/auth/session';
import { getAdminRepository } from '@/server/db/store-factory';
import { jsonErrorResponse, withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(req, {}, async ({ session, repo }) => {
    const { hashes, generatedAt } = await repo.getRecoveryCodeHashes(session.userId);
    return NextResponse.json({
      remainingCount: hashes.length,
      generatedAt,
    });
  });
}

export async function POST(req: Request) {
  return withAdminRoute(req, { requireStepUp: true }, async ({ session, repo, correlationId, ipAddress }) => {
    const { plaintextCodes, hashes } = generateRecoveryCodes(8);
    await repo.setRecoveryCodeHashes(session.userId, hashes);

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: 'admin.recovery_codes.regenerated',
      entityType: 'user',
      entityId: session.userId,
      details: { count: plaintextCodes.length },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({
      codes: plaintextCodes,
      generatedAt: new Date().toISOString(),
    });
  });
}

/**
 * Single-use emergency recovery code verification:
 * Requires valid primary Firebase authentication (`idToken`), checks and consumes
 * one recovery code hash for that UID, and issues/upgrades the session.
 */
export async function PUT(req: Request) {
  const correlationId = req.headers.get('x-correlation-id') || crypto.randomUUID();
  const ipAddress = extractClientIp(req);
  const userAgent = req.headers.get('user-agent');

  try {
    const repo = getAdminRepository();
    const input = RecoveryCodeConsumeSchema.parse(await req.json());
    const verified = await verifyFirebaseIdToken(input.idToken);

    const { hashes } = await repo.getRecoveryCodeHashes(verified.uid);
    const consumed = consumeRecoveryCodeHash(input.recoveryCode, hashes);
    if (!consumed.matched) {
      await repo.recordLoginEvent({
        userId: verified.uid,
        email: verified.email,
        surface: input.surface ?? null,
        outcome: 'Failed',
        mfaMethod: 'recovery_code',
        ipAddress,
        userAgent,
        failureReason: 'Invalid or already used recovery code',
      });
      throw new AuthorizationError(
        'INVALID_RECOVERY_CODE',
        'Recovery code is invalid or has already been used.',
        403
      );
    }

    await repo.setRecoveryCodeHashes(verified.uid, consumed.remainingHashes);

    await repo.recordLoginEvent({
      userId: verified.uid,
      email: verified.email,
      surface: input.surface ?? null,
      outcome: 'RecoveryCode_Used',
      mfaMethod: 'recovery_code',
      ipAddress,
      userAgent,
    });

    if (input.mode === 'step_up') {
      return withAdminRoute(req, {}, async ({ session }) => {
        if (session.userId !== verified.uid) {
          throw new AuthorizationError('USER_MISMATCH', 'Recovery code owner mismatch.', 403);
        }
        const stepUpExpiresAt = new Date(Date.now() + STEP_UP_WINDOW_MS).toISOString();
        await repo.refreshSessionStepUp(session.sessionId, stepUpExpiresAt);
        await recordAdminAudit(repo, {
          userId: session.userId,
          action: 'admin.recovery_code.step_up',
          entityType: 'user_session',
          entityId: session.sessionId,
          details: { remaining_codes: consumed.remainingHashes.length },
          ipAddress,
          correlationId,
        });
        return NextResponse.json({
          stepUpExpiresAt,
          remainingCount: consumed.remainingHashes.length,
        });
      });
    }

    return await issueVerifiedAdminSessionResponse({
      req,
      repo,
      userId: verified.uid,
      verifiedEmail: verified.email,
      mfaVerified: true,
      mfaMethod: 'recovery_code',
      explicitSurface: input.surface ?? null,
      deviceLabel: input.deviceLabel,
      correlationId,
      ipAddress,
      userAgent,
      requireMfaConfig: true,
    });
  } catch (error) {
    return jsonErrorResponse(error, correlationId);
  }
}

