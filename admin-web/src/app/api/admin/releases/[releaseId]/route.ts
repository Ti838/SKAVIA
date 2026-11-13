import { NextResponse } from 'next/server';
import { withAdminRoute } from '@/server/http/guard';

export async function DELETE(
  req: Request,
  context: { params: Promise<{ releaseId: string }> }
) {
  const { releaseId } = await context.params;
  return withAdminRoute(
    req,
    {
      permission: 'release.manage',
      requireStepUp: true,
      requirePrimarySuperAdmin: true,
    },
    async ({ repo, session, ipAddress, correlationId }) => {
      await repo.deleteDraftRelease({
        releaseId,
        actorUserId: session.userId,
      });

      await repo.writeAuditLog({
        userId: session.userId,
        action: 'release.draft.deleted',
        entityType: 'app_release',
        entityId: releaseId,
        details: { correlation_id: correlationId },
        ipAddress,
      });

      return NextResponse.json({ ok: true });
    }
  );
}

