import { NextResponse } from 'next/server';
import { DisputeResolveSchema } from '@/lib/contracts';
import { AuthorizationError, assertAuthorized } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function POST(
  req: Request,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params;
  return withAdminRoute(
    req,
    { permission: 'dispute.resolve', requireStepUp: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = DisputeResolveSchema.parse(await req.json());
      const disputes = await repo.listDisputes({ branchFilter: null });
      const target = disputes.find((d) => d.dispute_id === id);

      if (!target) {
        throw new AuthorizationError('NOT_FOUND', 'Dispute case not found.', 404);
      }

      assertAuthorized(session, {
        permission: 'dispute.resolve',
        requireStepUp: true,
        targetBranchId: target.branch_id,
      });

      const updated = await repo.resolveDispute({
        disputeId: id,
        adminUserId: session.userId,
        status: input.status,
        resolution: input.resolution,
        noteType: input.noteType,
      });

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: `dispute.${input.status.toLowerCase()}`,
        entityType: 'dispute',
        entityId: id,
        details: {
          branch_id: target.branch_id,
          note_type: input.noteType,
          recommended_refund_amount: input.recommendedRefundAmount ?? null,
          resolution: input.resolution,
        },
        ipAddress,
        correlationId,
      });

      return NextResponse.json({ dispute: updated });
    }
  );
}

