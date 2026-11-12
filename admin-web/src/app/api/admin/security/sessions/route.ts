import { NextResponse } from 'next/server';
import { z } from 'zod';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

const RevokeSessionSchema = z.object({
  sessionId: z.string().uuid(),
});

export async function GET(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'security.audit.view', requireStepUp: false },
    async ({ repo, session }) => {
      const url = new URL(req.url);
      const userId = url.searchParams.get('userId') || undefined;
      const canViewAll = session.effectivePermissions.includes('security.session.revoke');
      const sessions = await repo.listSessions(canViewAll ? userId : session.userId);
      return NextResponse.json({ sessions });
    }
  );
}

export async function DELETE(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'security.session.revoke', requireStepUp: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = RevokeSessionSchema.parse(await req.json());
      await repo.revokeSession(input.sessionId, session.userId);

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'security.session.revoked',
        entityType: 'user_session',
        entityId: input.sessionId,
        ipAddress,
        correlationId,
      });

      return NextResponse.json({ revoked: true, sessionId: input.sessionId });
    }
  );
}

