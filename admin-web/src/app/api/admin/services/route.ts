import { NextResponse } from 'next/server';
import { ServiceManageSchema } from '@/lib/contracts';
import { assertAuthorized, resolveAuthorizedBranchFilter } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(req, { permission: 'service.view' }, async ({ session, repo }) => {
    const url = new URL(req.url);
    const branchFilter = resolveAuthorizedBranchFilter(
      session,
      url.searchParams.get('branchId')
    );
    const taxonomy = await repo.getServiceTaxonomy();

    if (branchFilter) {
      return NextResponse.json({
        taxonomy: {
          ...taxonomy,
          categories: taxonomy.categories.filter(
            (c) => c.branch_id && branchFilter.includes(c.branch_id)
          ),
        },
      });
    }

    return NextResponse.json({ taxonomy });
  });
}

export async function POST(req: Request) {
  return withAdminRoute(req, { permission: 'service.view' }, async ({ session, repo, correlationId, ipAddress }) => {
    const input = ServiceManageSchema.parse(await req.json());

    if (input.type === 'category' && input.branchId) {
      assertAuthorized(session, {
        permission: session.branchScoped ? 'service.branch.manage' : 'service.manage',
        targetBranchId: input.branchId,
      });
    } else {
      assertAuthorized(session, { permission: 'service.manage' });
    }

    if (input.basePrice !== undefined && input.type === 'service') {
      assertAuthorized(session, {
        permission: 'pricing.manage',
        requireStepUp: true,
      });
    }

    await repo.mutateServiceTaxonomy(input);

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: `service.${input.type}.${input.action}`,
      entityType: input.type,
      entityId: input.id || input.name || null,
      details: input,
      ipAddress,
      correlationId,
    });

    const taxonomy = await repo.getServiceTaxonomy();
    return NextResponse.json({ taxonomy });
  });
}

