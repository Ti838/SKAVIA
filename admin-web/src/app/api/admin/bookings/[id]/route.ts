import { NextResponse } from 'next/server';
import { BookingActionSchema } from '@/lib/contracts';
import { AuthorizationError, assertAuthorized } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function PATCH(
  req: Request,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params;
  return withAdminRoute(req, { permission: 'booking.manage' }, async ({ session, repo, correlationId, ipAddress }) => {
    const input = BookingActionSchema.parse(await req.json());
    const allBookings = await repo.listBookings({ branchFilter: null });
    const target = allBookings.find((b) => b.service_request_id === id);

    if (!target) {
      throw new AuthorizationError('NOT_FOUND', 'Booking not found.', 404);
    }

    assertAuthorized(session, {
      permission: 'booking.manage',
      targetBranchId: target.branch_id,
    });

    const updated = await repo.updateBooking(id, {
      action: input.action,
      workerProfileId: input.workerProfileId,
      scheduledAt: input.scheduledAt,
      reason: input.reason,
      actorUserId: session.userId,
    });

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: `booking.${input.action}`,
      entityType: 'service_request',
      entityId: id,
      details: {
        branch_id: target.branch_id,
        worker_profile_id: input.workerProfileId ?? null,
        scheduled_at: input.scheduledAt ?? null,
        reason: input.reason,
      },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({ booking: updated });
  });
}

