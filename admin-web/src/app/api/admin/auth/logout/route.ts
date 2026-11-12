import { NextResponse } from 'next/server';
import {
  ADMIN_SESSION_COOKIE,
  readSignedSessionFromRequest,
} from '@/server/auth/session';
import { getAdminRepository } from '@/server/db/store-factory';
import { extractClientIp, recordAdminAudit } from '@/server/audit/logger';

export async function POST(req: Request) {
  const correlationId = req.headers.get('x-correlation-id') || crypto.randomUUID();
  const ipAddress = extractClientIp(req);

  try {
    const parsed = await readSignedSessionFromRequest(req);
    if (parsed) {
      const repo = getAdminRepository();
      await repo.revokeSession(parsed.sessionId, parsed.userId);
      await recordAdminAudit(repo, {
        userId: parsed.userId,
        action: 'admin.session.logout',
        entityType: 'user_session',
        entityId: parsed.sessionId,
        ipAddress,
        correlationId,
      });
    }
  } catch {
    // Still clear cookie cleanly even if session already expired or repo unavailable
  }

  const res = NextResponse.json({ loggedOut: true });
  res.cookies.set(ADMIN_SESSION_COOKIE, '', {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/',
    maxAge: 0,
  });
  res.headers.set('X-Correlation-Id', correlationId);
  res.headers.set('Cache-Control', 'no-store');
  return res;
}

