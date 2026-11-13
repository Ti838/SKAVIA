import { NextResponse } from 'next/server';
import { ReleaseCreateSchema } from '@/lib/contracts';
import { withAdminRoute } from '@/server/http/guard';
import { inspectApkBuffer } from '@/server/releases/apk-inspector';
import { assertReleaseMatchesApkAndPolicy } from '@/server/releases/release-validator';

export const dynamic = 'force-dynamic';
export const maxDuration = 60;

export async function GET(req: Request) {
  return withAdminRoute(
    req,
    {
      permission: 'release.view',
      requirePrimarySuperAdmin: true,
    },
    async ({ repo }) => {
      const [releases, signingPolicy, analytics] = await Promise.all([
        repo.listReleases({ platform: 'android' }),
        repo.getReleaseSigningPolicy(),
        repo.getReleaseAnalytics({ platform: 'android' }),
      ]);

      const currentStable =
        releases.find(
          (r) => r.channel === 'stable' && r.status === 'published' && r.is_current
        ) ?? null;

      return NextResponse.json({
        releases,
        currentStable,
        signingPolicy,
        analytics,
      });
    }
  );
}

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    {
      permission: 'release.manage',
      requireStepUp: true,
      requirePrimarySuperAdmin: true,
    },
    async ({ repo, session, ipAddress, correlationId }) => {
      const body = await req.json();
      const input = ReleaseCreateSchema.parse(body);

      const [existingReleases, signingPolicy, apkBytes] = await Promise.all([
        repo.listReleases({ platform: 'android' }),
        repo.getReleaseSigningPolicy(),
        repo.readApkObjectBytes(input.storagePath),
      ]);

      const inspected = inspectApkBuffer(apkBytes);

      assertReleaseMatchesApkAndPolicy({
        inspected,
        input: {
          versionName: input.versionName,
          buildNumber: input.buildNumber,
          channel: input.channel,
          allowInitialSigningPin: input.allowInitialSigningPin,
        },
        existingReleases,
        signingPolicy,
      });

      // Automatically lock the first verified certificate pin if explicitly confirmed and unset
      if (!signingPolicy.pinnedSigningCertSha256 && inspected.signingCertSha256 && input.allowInitialSigningPin) {
        await repo.upsertReleaseSigningPolicy({
          expectedPackageName: signingPolicy.expectedPackageName,
          pinnedSigningCertSha256: inspected.signingCertSha256,
          actorUserId: session.userId,
        });
      }

      const created = await repo.createReleaseRecord({
        platform: 'android',
        channel: input.channel,
        packageName: inspected.packageName,
        versionName: inspected.versionName,
        buildNumber: inspected.buildNumber,
        minSupportedBuild: input.minSupportedBuild,
        minSdkVersion: inspected.minSdkVersion,
        targetSdkVersion: inspected.targetSdkVersion,
        releaseNotes: input.releaseNotes,
        isMandatory: input.isMandatory,
        notifyUsers: input.notifyUsers,
        status: 'validated',
        storagePath: input.storagePath,
        fileName: input.fileName,
        fileSizeBytes: inspected.fileSizeBytes,
        sha256Checksum: inspected.sha256Checksum,
        signingCertSha256: inspected.signingCertSha256 ?? '',
        signingSchemes: inspected.signingSchemes,
        actorUserId: session.userId,
      });

      await repo.writeAuditLog({
        userId: session.userId,
        action: 'release.draft.validated',
        entityType: 'app_release',
        entityId: created.release_id,
        details: {
          correlation_id: correlationId,
          channel: created.channel,
          version_name: created.version_name,
          build_number: created.build_number,
          sha256_checksum: created.sha256_checksum,
          signing_cert_sha256: created.signing_cert_sha256,
        },
        ipAddress,
      });

      if (!input.publishImmediately) {
        return NextResponse.json({ release: created, notifiedUsersCount: 0 }, { status: 201 });
      }

      const publishedResult = await repo.publishRelease({
        releaseId: created.release_id,
        actorUserId: session.userId,
        notifyUsers: input.notifyUsers,
      });

      await repo.writeAuditLog({
        userId: session.userId,
        action: 'release.published',
        entityType: 'app_release',
        entityId: publishedResult.release.release_id,
        details: {
          correlation_id: correlationId,
          channel: publishedResult.release.channel,
          version_name: publishedResult.release.version_name,
          build_number: publishedResult.release.build_number,
          is_mandatory: publishedResult.release.is_mandatory,
          notified_users_count: publishedResult.notifiedUsersCount,
        },
        ipAddress,
      });

      return NextResponse.json(publishedResult, { status: 201 });
    }
  );
}

