import { NextResponse } from 'next/server';
import { resolveAuthorizedBranchFilter } from '@/server/auth/rbac';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'branch.analytics.view' },
    async ({ session, repo }) => {
      const url = new URL(req.url);
      const requestedBranchId = url.searchParams.get('branchId');
      const branchFilter = resolveAuthorizedBranchFilter(session, requestedBranchId);

      const metrics = await repo.getDashboardMetrics(branchFilter);
      return NextResponse.json({
        metrics,
        scope: {
          branchScoped: session.branchScoped,
          filteredBranchIds: branchFilter,
          assignedBranches: session.assignedBranches,
        },
      });
    }
  );
}

