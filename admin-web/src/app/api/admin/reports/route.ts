import { NextResponse } from 'next/server';
import { resolveAuthorizedBranchFilter } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

function escapeCsvCell(value: unknown): string {
  const raw = String(value ?? '');
  // Neutralize CSV formula injection in Excel/Sheets
  const safe = /^[=+\-@\t\r]/.test(raw) ? `'${raw}` : raw;
  if (/[",\n\r]/.test(safe)) {
    return `"${safe.replace(/"/g, '""')}"`;
  }
  return safe;
}

export async function GET(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'report.view' },
    async ({ session, repo, correlationId, ipAddress }) => {
      const url = new URL(req.url);
      const requestedBranchId = url.searchParams.get('branchId');
      const format = url.searchParams.get('format') || 'json';
      const branchFilter = resolveAuthorizedBranchFilter(session, requestedBranchId);

      const [metrics, finance] = await Promise.all([
        repo.getDashboardMetrics(branchFilter),
        session.effectivePermissions.includes('payment.view')
          ? repo.getFinanceSnapshot(branchFilter)
          : Promise.resolve(null),
      ]);

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: format === 'csv' ? 'report.export.csv' : 'report.view',
        entityType: 'report',
        entityId: requestedBranchId || 'all-authorized-branches',
        details: { branch_filter: branchFilter, format },
        ipAddress,
        correlationId,
      });

      if (format === 'csv') {
        const header = ['Branch Code', 'Branch Name', 'Active Bookings', 'Workers Count', 'Volume (BDT)'];
        const rows = metrics.branchBreakdown.map((b) => [
          b.code,
          b.name,
          b.activeBookings,
          b.workersCount,
          b.volumeBdt.toFixed(2),
        ]);
        const csv = [header, ...rows]
          .map((row) => row.map(escapeCsvCell).join(','))
          .join('\r\n');

        return new NextResponse(csv, {
          status: 200,
          headers: {
            'Content-Type': 'text/csv; charset=utf-8',
            'Content-Disposition': `attachment; filename="skavia-branch-report-${new Date().toISOString().slice(0, 10)}.csv"`,
            'X-Correlation-Id': correlationId,
            'Cache-Control': 'no-store',
          },
        });
      }

      return NextResponse.json({
        generatedAt: new Date().toISOString(),
        metrics,
        financeSummary: finance?.summary ?? null,
      });
    }
  );
}

