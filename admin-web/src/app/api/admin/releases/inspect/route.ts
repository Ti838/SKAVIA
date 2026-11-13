import { NextResponse } from 'next/server';
import { z } from 'zod';
import { APP_RELEASE_CHANNELS } from '@/lib/contracts';
import { withAdminRoute } from '@/server/http/guard';
import { inspectApkBuffer } from '@/server/releases/apk-inspector';

export const dynamic = 'force-dynamic';
export const maxDuration = 60;

const InspectSchema = z.object({
  storagePath: z.string().trim().min(5).max(300),
  channel: z.enum(APP_RELEASE_CHANNELS).default('stable'),
});

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    {
      permission: 'release.manage',
      requireStepUp: true,
      requirePrimarySuperAdmin: true,
    },
    async ({ repo }) => {
      const body = await req.json();
      const input = InspectSchema.parse(body);

      const [bytes, signingPolicy, existingReleases] = await Promise.all([
        repo.readApkObjectBytes(input.storagePath),
        repo.getReleaseSigningPolicy(),
        repo.listReleases({ platform: 'android', channel: input.channel }),
      ]);

      const inspected = inspectApkBuffer(bytes);
      const effectivePin =
        signingPolicy.pinnedSigningCertSha256?.toLowerCase() ||
        process.env.SKAVIA_APK_SIGNING_CERT_SHA256?.trim().toLowerCase() ||
        null;

      const highestBuild = existingReleases.reduce(
        (max, r) => Math.max(max, r.build_number),
        0
      );
      const duplicateBuild = existingReleases.some(
        (r) => r.build_number === inspected.buildNumber
      );

      const warnings: string[] = [];
      const blockers: string[] = [];

      if (inspected.packageName !== signingPolicy.expectedPackageName) {
        blockers.push(
          `Wrong package ID "${inspected.packageName}". Expected "${signingPolicy.expectedPackageName}".`
        );
      }
      if (!inspected.signingCertSha256) {
        blockers.push('APK lacks a verified APK Signature Scheme v2/v3 X.509 signing certificate.');
      } else if (effectivePin && inspected.signingCertSha256 !== effectivePin) {
        blockers.push(
          `Signing certificate mismatch (${inspected.signingCertSha256.slice(0, 12)}... vs pinned ${effectivePin.slice(0, 12)}...).`
        );
      } else if (!effectivePin && inspected.signingCertSha256) {
        warnings.push(
          'No certificate pin configured yet. Publishing/saving this release can pin this signing certificate automatically.'
        );
      }
      if (duplicateBuild) {
        blockers.push(`Build #${inspected.buildNumber} already exists in channel "${input.channel}".`);
      } else if (highestBuild > 0 && inspected.buildNumber <= highestBuild) {
        blockers.push(
          `Build #${inspected.buildNumber} does not advance past latest build #${highestBuild} on "${input.channel}".`
        );
      }

      return NextResponse.json({
        inspected,
        signingPolicy,
        compatibility: {
          canSaveDraft: blockers.length === 0,
          requiresInitialPinConfirmation: !effectivePin && Boolean(inspected.signingCertSha256),
          blockers,
          warnings,
          highestExistingBuild: highestBuild,
        },
      });
    }
  );
}

