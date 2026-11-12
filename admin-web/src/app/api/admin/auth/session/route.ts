import { NextResponse } from 'next/server';
import { SessionExchangeInputSchema } from '@/lib/contracts';
import { verifyFirebaseIdToken } from '@/server/auth/firebase-jwt';
import { issueVerifiedAdminSessionResponse } from '@/server/auth/issue-session';
import { AuthorizationError } from '@/server/auth/rbac';
import { getAdminRepository } from '@/server/db/store-factory';
import { extractClientIp } from '@/server/audit/logger';
import { getServerEnvConfig } from '@/server/config/env';
import { jsonErrorResponse, withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(req, {}, async ({ session }) => {
    return NextResponse.json({ session });
  });
}

export async function POST(req: Request) {
  const correlationId = req.headers.get('x-correlation-id') || crypto.randomUUID();
  const ipAddress = extractClientIp(req);
  const userAgent = req.headers.get('user-agent');

  try {
    const repo = getAdminRepository();
    const input = SessionExchangeInputSchema.parse(await req.json());

    let verified: Awaited<ReturnType<typeof verifyFirebaseIdToken>>;
    try {
      verified = await verifyFirebaseIdToken(input.idToken);
    } catch (err) {
      await repo.recordLoginEvent({
        userId: null,
        email: null,
        outcome: 'Failed',
        ipAddress,
        userAgent,
        failureReason: err instanceof Error ? err.message : 'Invalid ID token',
      });
      throw new AuthorizationError('INVALID_TOKEN', 'Invalid or expired Firebase ID token.', 401);
    }

    return await issueVerifiedAdminSessionResponse({
      req,
      repo,
      userId: verified.uid,
      verifiedEmail: verified.email,
      mfaVerified: verified.mfaVerified,
      mfaMethod: verified.mfaMethod,
      explicitSurface: input.surface ?? null,
      deviceLabel: input.deviceLabel,
      correlationId,
      ipAddress,
      userAgent,
      requireMfaConfig: getServerEnvConfig().requireMfa,
    });
  } catch (error) {
    const res = jsonErrorResponse(error, correlationId);
    res.headers.set('X-Correlation-Id', correlationId);
    res.headers.set('Cache-Control', 'no-store');
    return res;
  }
}
