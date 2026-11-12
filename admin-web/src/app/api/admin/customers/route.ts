import { NextResponse } from 'next/server';
import { resolveAuthorizedBranchFilter } from '@/server/auth/rbac';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(req, { permission: 'customer.view' }, async ({ session, repo }) => {
    const url = new URL(req.url);
    const branchFilter = resolveAuthorizedBranchFilter(
      session,
      url.searchParams.get('branchId')
    );
    const customerType = url.searchParams.get('type') || undefined;
    const search = url.searchParams.get('search') || undefined;

    const customers = await repo.listCustomers({
      branchFilter,
      customerType,
      search,
    });
    return NextResponse.json({ customers });
  });
}

