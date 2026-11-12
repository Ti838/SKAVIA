import { NextResponse } from 'next/server';
import { AdminProvisionSchema } from '@/lib/contracts';
import { recordAdminAudit } from '@/server/audit/logger';
import { AuthorizationError } from '@/server/auth/rbac';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'admin.view', requirePrimarySuperAdmin: true },
    async ({ repo }) => {
      const admins = await repo.listAdmins();
      return NextResponse.json({ admins });
    }
  );
}

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'admin.create', requireStepUp: true, requirePrimarySuperAdmin: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = AdminProvisionSchema.parse(await req.json());
      if (input.roleName === 'Super Admin') {
        throw new AuthorizationError(
          'SINGLE_SUPERADMIN_ENFORCED',
          'SKAVIA allows only one primary Super Admin. Provision Company Admin or Branch Manager instead.',
          403
        );
      }

      const admin = await repo.provisionAdmin({
        ...input,
        actorUserId: session.userId,
      });

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'admin.account.provisioned',
        entityType: 'user',
        entityId: input.userId,
        details: {
          email: input.email,
          role: input.roleName,
          branch_ids: input.branchIds,
        },
        ipAddress,
        correlationId,
      });

      return NextResponse.json({ admin }, { status: 201 });
    }
  );
}
