import { NextResponse } from 'next/server';
import { BranchCreateSchema } from '@/lib/contracts';
import { resolveAuthorizedBranchFilter } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(req, { permission: 'branch.view' }, async ({ session, repo }) => {
    const url = new URL(req.url);
    const branchFilter = resolveAuthorizedBranchFilter(
      session,
      url.searchParams.get('branchId')
    );
    const branches = await repo.listBranches(branchFilter);
    return NextResponse.json({ branches });
  });
}

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'branch.manage', requireStepUp: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = BranchCreateSchema.parse(await req.json());
      const branch = await repo.createBranch(input);

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'branch.created',
        entityType: 'branch',
        entityId: branch.branch_id,
        details: { name: branch.name, code: branch.code, manager_id: branch.manager_id },
        ipAddress,
        correlationId,
      });

      return NextResponse.json({ branch }, { status: 201 });
    }
  );
}

