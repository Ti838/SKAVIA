import { NextResponse } from 'next/server';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'payout.approve', requireStepUp: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const result = await repo.runReconciliation(session.userId);

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'finance.reconciliation.executed',
        entityType: 'reconciliation_run',
        entityId: result.run_id,
        details: result,
        ipAddress,
        correlationId,
      });

      return NextResponse.json({ reconciliation: result });
    }
  );
}

