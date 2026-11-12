import { NextResponse } from 'next/server';
import { VerificationDecisionSchema } from '@/lib/contracts';
import { AuthorizationError, assertAuthorized } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function POST(
  req: Request,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params;
  return withAdminRoute(req, { permission: 'worker.verify' }, async ({ session, repo, correlationId, ipAddress }) => {
    const input = VerificationDecisionSchema.parse(await req.json());
    const item = await repo.getVerificationById(id);
    if (!item) {
      throw new AuthorizationError('NOT_FOUND', 'Verification record not found.', 404);
    }

    assertAuthorized(session, {
      permission: 'worker.verify',
      targetBranchId: item.branch_id,
      targetUserId: item.worker_user_id,
      disallowSelfAction: true,
    });

    const updated = await repo.decideVerification({
      verificationId: id,
      adminUserId: session.userId,
      decision: input.decision,
      reviewNotes: input.reviewNotes,
    });

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: `kyc.verification.${input.decision.toLowerCase()}`,
      entityType: 'verification',
      entityId: id,
      details: {
        worker_profile_id: item.worker_profile_id,
        worker_user_id: item.worker_user_id,
        branch_id: item.branch_id,
        checklist: input.checklist ?? null,
        review_notes: input.reviewNotes,
      },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({ verification: updated });
  });
}

