import { NextResponse } from 'next/server';
import { BranchUpdateSchema } from '@/lib/contracts';
import { assertAuthorized } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function PATCH(
  req: Request,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params;
  return withAdminRoute(
    req,
    { permission: 'branch.manage', requireStepUp: true, targetBranchId: id },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = BranchUpdateSchema.parse(await req.json());
      if (input.managerId !== undefined) {
        assertAuthorized(session, {
          permission: 'branch.staff.assign',
          requireStepUp: true,
          targetBranchId: id,
        });
      }

      const branch = await repo.updateBranch(id, input);

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'branch.updated',
        entityType: 'branch',
        entityId: branch.branch_id,
        details: input,
        ipAddress,
        correlationId,
      });

      return NextResponse.json({ branch });
    }
  );
}

