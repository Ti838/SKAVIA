import { NextResponse } from 'next/server';
import { resolveAuthorizedBranchFilter } from '@/server/auth/rbac';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(req, { permission: 'branch.view' }, async ({ session, repo }) => {
    const url = new URL(req.url);
    const q = (url.searchParams.get('q') || '').trim();
    const requestedBranchId = url.searchParams.get('branchId');
    const branchFilter = resolveAuthorizedBranchFilter(session, requestedBranchId);

    if (q.length < 2) {
      return NextResponse.json({ results: [] });
    }

    const results = await repo.globalSearch(q, branchFilter);
    return NextResponse.json({ results });
  });
}

