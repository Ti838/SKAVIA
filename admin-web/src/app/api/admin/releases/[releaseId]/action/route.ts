import { NextResponse } from 'next/server';
import { ReleaseLifecycleActionSchema } from '@/lib/contracts';
import { assertAuthorized } from '@/server/auth/rbac';
import { withAdminRoute } from '@/server/http/guard';
import { inspectApkBuffer } from '@/server/releases/apk-inspector';
import {
  assertPublishSequenceAllowed,
  ReleaseValidationError,
} from '@/server/releases/release-validator';

export const dynamic = 'force-dynamic';
export const maxDuration = 60;

export async function POST(
  req: Request,
  context: { params: Promise<{ releaseId: string }> }
) {
  const { releaseId } = await context.params;

  return withAdminRoute(
    req,
    {
      permission: 'release.manage',
      requireStepUp: true,
      requirePrimarySuperAdmin: true,
    },
    async ({ repo, session, ipAddress, correlationId }) => {
      const body = await req.json();
      const input = ReleaseLifecycleActionSchema.parse(body);

      if (input.action !== 'validate') {
        assertAuthorized(session, {
          permission: 'release.publish',
          requireStepUp: true,
        });
      }

      const target = await repo.getReleaseById(releaseId);
      if (!target) {
        throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'Release not found.', 404);
      }

      if (input.action === 'validate') {
        const [bytes, signingPolicy] = await Promise.all([
          repo.readApkObjectBytes(target.storage_path),
          repo.getReleaseSigningPolicy(),
        ]);
        const inspected = inspectApkBuffer(bytes);
        if (inspected.packageName !== signingPolicy.expectedPackageName) {
          throw new ReleaseValidationError(
            'WRONG_PACKAGE_ID',
            `Expected ${signingPolicy.expectedPackageName}, got ${inspected.packageName}.`,
            422
          );
        }
        if (!inspected.signingCertSha256) {
          throw new ReleaseValidationError(
            'UNSIGNED_OR_INVALID_APK',
            'APK lacks a v2/v3 signing certificate.',
            422
          );
        }
        if (
          signingPolicy.pinnedSigningCertSha256 &&
          inspected.signingCertSha256 !== signingPolicy.pinnedSigningCertSha256.toLowerCase()
        ) {
          throw new ReleaseValidationError(
            'SIGNING_CERT_MISMATCH',
            'APK signing certificate does not match pinned certificate.',
            422
          );
        }
        if (!signingPolicy.pinnedSigningCertSha256 && input.allowInitialSigningPin) {
          await repo.upsertReleaseSigningPolicy({
            expectedPackageName: signingPolicy.expectedPackageName,
            pinnedSigningCertSha256: inspected.signingCertSha256,
            actorUserId: session.userId,
          });
        }

        const updated = await repo.markReleaseValidated({
          releaseId: target.release_id,
          packageName: inspected.packageName,
          versionName: inspected.versionName,
          buildNumber: inspected.buildNumber,
          minSdkVersion: inspected.minSdkVersion,
          targetSdkVersion: inspected.targetSdkVersion,
          fileSizeBytes: inspected.fileSizeBytes,
          sha256Checksum: inspected.sha256Checksum,
          signingCertSha256: inspected.signingCertSha256,
          signingSchemes: inspected.signingSchemes,
          actorUserId: session.userId,
        });

        await repo.writeAuditLog({
          userId: session.userId,
          action: 'release.validated',
          entityType: 'app_release',
          entityId: updated.release_id,
          details: {
            correlation_id: correlationId,
            sha256_checksum: updated.sha256_checksum,
            signing_cert_sha256: updated.signing_cert_sha256,
          },
          ipAddress,
        });

        return NextResponse.json({ release: updated });
      }

      if (input.action === 'publish') {
        const [allReleases, signingPolicy] = await Promise.all([
          repo.listReleases({ platform: target.platform }),
          repo.getReleaseSigningPolicy(),
        ]);

        assertPublishSequenceAllowed({
          target,
          existingReleases: allReleases,
          signingPolicy,
        });

        const result = await repo.publishRelease({
          releaseId: target.release_id,
          actorUserId: session.userId,
          notifyUsers: input.notifyUsers,
        });

        await repo.writeAuditLog({
          userId: session.userId,
          action: 'release.published',
          entityType: 'app_release',
          entityId: result.release.release_id,
          details: {
            correlation_id: correlationId,
            channel: result.release.channel,
            version_name: result.release.version_name,
            build_number: result.release.build_number,
            is_mandatory: result.release.is_mandatory,
            notified_users_count: result.notifiedUsersCount,
          },
          ipAddress,
        });

        return NextResponse.json(result);
      }

      if (input.action === 'suspend') {
        const suspended = await repo.suspendRelease({
          releaseId: target.release_id,
          actorUserId: session.userId,
          reason: input.reason,
        });

        await repo.writeAuditLog({
          userId: session.userId,
          action: 'release.suspended',
          entityType: 'app_release',
          entityId: suspended.release_id,
          details: {
            correlation_id: correlationId,
            reason: input.reason,
            build_number: suspended.build_number,
          },
          ipAddress,
        });

        return NextResponse.json({ release: suspended });
      }

      if (input.action === 'rollback') {
        const rollbackResult = await repo.rollbackRelease({
          targetReleaseId: input.targetReleaseId,
          actorUserId: session.userId,
          reason: input.reason,
        });

        await repo.writeAuditLog({
          userId: session.userId,
          action: 'release.rollback',
          entityType: 'app_release',
          entityId: rollbackResult.activeRelease.release_id,
          details: {
            correlation_id: correlationId,
            target_release_id: rollbackResult.activeRelease.release_id,
            target_build_number: rollbackResult.activeRelease.build_number,
            suspended_release_id: rollbackResult.suspendedReleaseId,
            reason: input.reason,
          },
          ipAddress,
        });

        return NextResponse.json(rollbackResult);
      }

      const archived = await repo.archiveRelease({
        releaseId: target.release_id,
        actorUserId: session.userId,
      });

      await repo.writeAuditLog({
        userId: session.userId,
        action: 'release.archived',
        entityType: 'app_release',
        entityId: archived.release_id,
        details: {
          correlation_id: correlationId,
          build_number: archived.build_number,
        },
        ipAddress,
      });

      return NextResponse.json({ release: archived });
    }
  );
}
