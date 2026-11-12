import { NextResponse } from 'next/server';
import { AdminPermissionUpdateSchema } from '@/lib/contracts';
import {
  assertAuthorized,
  assertNotPrimarySuperAdminMutation,
  AuthorizationError,
} from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function PATCH(
  req: Request,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params;
  return withAdminRoute(
    req,
    { permission: 'admin.view', requirePrimarySuperAdmin: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = AdminPermissionUpdateSchema.parse(await req.json());
      const isSuspensionChange = Boolean(input.suspendReason || input.reactivate);

      const targetIdentity = await repo.resolveAdminIdentity(id);
      if (!targetIdentity) {
        throw new AuthorizationError('NOT_FOUND', 'Target administrator account not found.', 404);
      }

      assertNotPrimarySuperAdminMutation(
        targetIdentity.isPrimarySuperAdmin,
        id,
        session.userId
      );

      assertAuthorized(session, {
        permission: isSuspensionChange ? 'admin.suspend' : 'admin.permission.update',
        requireStepUp: true,
        targetUserId: id,
        disallowSelfAction: true,
      });

      const updated = await repo.updateAdminPermissions(id, input, session.userId);

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: isSuspensionChange ? 'admin.account.status_changed' : 'admin.permissions.updated',
        entityType: 'user',
        entityId: id,
        details: input,
        ipAddress,
        correlationId,
      });

      return NextResponse.json({ admin: updated });
    }
  );
}
