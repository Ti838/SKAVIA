import { NextResponse } from 'next/server';
import { CustomerUpdateSchema } from '@/lib/contracts';
import { AuthorizationError, assertAuthorized } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function PATCH(
  req: Request,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params;
  return withAdminRoute(req, {}, async ({ session, repo, correlationId, ipAddress }) => {
    const input = CustomerUpdateSchema.parse(await req.json());
    const suspending =
      input.accountStatus === 'suspended' || input.accountStatus === 'deactivated';

    assertAuthorized(session, {
      permission: suspending ? 'customer.suspend' : 'customer.update',
      requireStepUp: suspending,
      targetUserId: id,
      disallowSelfAction: true,
    });

    if (session.branchScoped) {
      const visibleCustomers = await repo.listCustomers({
        branchFilter: session.assignedBranches.map((b) => b.branch_id),
      });
      if (!visibleCustomers.some((c) => c.user_id === id)) {
        throw new AuthorizationError(
          'BRANCH_SCOPE_VIOLATION',
          'Customer does not have bookings inside your assigned branches.',
          403
        );
      }
    }

    const customer = await repo.updateCustomer(id, {
      fullName: input.fullName,
      location: input.location,
      accountStatus: input.accountStatus,
    });

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: suspending ? 'customer.suspended' : 'customer.updated',
      entityType: 'user',
      entityId: id,
      details: {
        account_status: input.accountStatus ?? null,
        reason: input.reason ?? null,
      },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({ customer });
  });
}

