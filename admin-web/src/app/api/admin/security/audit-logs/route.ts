import { NextResponse } from 'next/server';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'security.audit.view', requireStepUp: false },
    async ({ repo }) => {
      const url = new URL(req.url);
      const action = url.searchParams.get('action') || undefined;
      const userId = url.searchParams.get('userId') || undefined;
      const limitParam = Number(url.searchParams.get('limit') || '100');
      const limit = Number.isFinite(limitParam) ? Math.min(Math.max(limitParam, 1), 250) : 100;

      const logs = await repo.listAuditLogs({ action, userId, limit });
      return NextResponse.json({ logs });
    }
  );
}

