import { NextResponse } from 'next/server';
import { z } from 'zod';
import { AuthorizationError } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

const SelfRevokeSchema = z.object({
  sessionId: z.string().uuid(),
});

export async function GET(req: Request) {
  return withAdminRoute(req, {}, async ({ session, repo }) => {
    const sessions = await repo.listSessions(session.userId);
    return NextResponse.json({ sessions });
  });
}

export async function DELETE(req: Request) {
  return withAdminRoute(req, {}, async ({ session, repo, correlationId, ipAddress }) => {
    const input = SelfRevokeSchema.parse(await req.json());
    const target = await repo.getAdminSession(input.sessionId);
    if (!target || target.user_id !== session.userId) {
      throw new AuthorizationError(
        'FORBIDDEN',
        'You can only revoke sessions belonging to your own account.',
        403
      );
    }
    await repo.revokeSession(input.sessionId, session.userId);
    await recordAdminAudit(repo, {
      userId: session.userId,
      action: 'admin.session.self_revoked',
      entityType: 'user_session',
      entityId: input.sessionId,
      ipAddress,
      correlationId,
    });
    return NextResponse.json({ revoked: true, sessionId: input.sessionId });
  });
}

