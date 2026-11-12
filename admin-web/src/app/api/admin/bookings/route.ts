import { NextResponse } from 'next/server';
import { resolveAuthorizedBranchFilter } from '@/server/auth/rbac';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(req, { permission: 'booking.view' }, async ({ session, repo }) => {
    const url = new URL(req.url);
    const branchFilter = resolveAuthorizedBranchFilter(
      session,
      url.searchParams.get('branchId')
    );
    const status = url.searchParams.get('status') || undefined;
    const bookings = await repo.listBookings({ branchFilter, status });
    return NextResponse.json({ bookings });
  });
}

