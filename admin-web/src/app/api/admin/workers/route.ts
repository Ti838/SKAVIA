import { NextResponse } from 'next/server';
import { resolveAuthorizedBranchFilter } from '@/server/auth/rbac';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(req, { permission: 'worker.view' }, async ({ session, repo }) => {
    const url = new URL(req.url);
    const branchFilter = resolveAuthorizedBranchFilter(
      session,
      url.searchParams.get('branchId')
    );
    const verificationStatus = url.searchParams.get('verificationStatus') || undefined;
    const search = url.searchParams.get('search') || undefined;

    const workers = await repo.listWorkers({
      branchFilter,
      verificationStatus,
      search,
    });
    return NextResponse.json({ workers });
  });
}

