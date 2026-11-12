import { NextResponse } from 'next/server';
import { AuthorizationError, assertAuthorized } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(
  req: Request,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params;
  return withAdminRoute(req, { permission: 'worker.verify' }, async ({ session, repo, correlationId, ipAddress }) => {
    const item = await repo.getVerificationById(id);
    if (!item) {
      throw new AuthorizationError('NOT_FOUND', 'Verification record not found.', 404);
    }

    assertAuthorized(session, {
      permission: 'worker.verify',
      targetBranchId: item.branch_id,
    });

    const signedUrl = await repo.createVerificationSignedUrl(item.document_file_url);

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: 'kyc.document.viewed',
      entityType: 'verification',
      entityId: id,
      details: {
        worker_profile_id: item.worker_profile_id,
        document_type: item.document_type,
        ttl_seconds: 60,
      },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({ signedUrl, expiresInSeconds: 60 });
  });
}

