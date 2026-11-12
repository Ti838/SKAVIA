import { NextResponse } from 'next/server';
import { WorkerActionSchema } from '@/lib/contracts';
import { AuthorizationError, assertAuthorized } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function PATCH(
  req: Request,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params;
  return withAdminRoute(req, { permission: 'worker.view' }, async ({ session, repo, correlationId, ipAddress }) => {
    const input = WorkerActionSchema.parse(await req.json());
    const allWorkers = await repo.listWorkers({ branchFilter: null });
    const targetWorker = allWorkers.find((w) => w.worker_profile_id === id);

    if (!targetWorker) {
      throw new AuthorizationError('NOT_FOUND', 'Worker profile not found.', 404);
    }

    if (input.action === 'assign_branch') {
      assertAuthorized(session, {
        permission: 'worker.branch.assign',
        targetBranchId: input.branchId || targetWorker.branch_id,
      });
    } else {
      assertAuthorized(session, {
        permission: 'worker.suspend',
        requireStepUp: true,
        targetBranchId: targetWorker.branch_id,
        targetUserId: targetWorker.user_id,
        disallowSelfAction: true,
      });
    }

    const updated = await repo.updateWorker(id, input.action, input.branchId);

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: `worker.${input.action}`,
      entityType: 'worker_profile',
      entityId: id,
      details: {
        worker_user_id: targetWorker.user_id,
        branch_id: input.branchId ?? targetWorker.branch_id,
        reason: input.reason,
      },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({ worker: updated });
  });
}

