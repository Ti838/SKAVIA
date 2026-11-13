import { NextResponse } from 'next/server';
import { ReleaseSigningPinSchema } from '@/lib/contracts';
import { withAdminRoute } from '@/server/http/guard';

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    {
      permission: 'release.publish',
      requireStepUp: true,
      requirePrimarySuperAdmin: true,
    },
    async ({ repo, session, ipAddress, correlationId }) => {
      const body = await req.json();
      const input = ReleaseSigningPinSchema.parse(body);

      const signingPolicy = await repo.upsertReleaseSigningPolicy({
        expectedPackageName: input.expectedPackageName,
        pinnedSigningCertSha256: input.pinnedSigningCertSha256,
        actorUserId: session.userId,
      });

      await repo.writeAuditLog({
        userId: session.userId,
        action: 'release.signing_policy.updated',
        entityType: 'system_setting',
        entityId: 'app_release_signing_policy',
        details: {
          correlation_id: correlationId,
          expected_package_name: signingPolicy.expectedPackageName,
          pinned_signing_cert_sha256: signingPolicy.pinnedSigningCertSha256,
          notes: input.notes ?? null,
        },
        ipAddress,
      });

      return NextResponse.json({ signingPolicy });
    }
  );
}

