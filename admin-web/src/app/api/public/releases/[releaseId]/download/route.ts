import { NextResponse } from 'next/server';
import { getAdminRepository } from '@/server/db/store-factory';

export const dynamic = 'force-dynamic';
export const maxDuration = 60;

export async function GET(
  _req: Request,
  context: { params: Promise<{ releaseId: string }> }
) {
  const { releaseId } = await context.params;
  if (!/^[0-9a-f-]{36}$/i.test(releaseId)) {
    return NextResponse.json(
      { error: { code: 'INVALID_RELEASE_ID', message: 'Invalid release identifier.' } },
      { status: 400 }
    );
  }

  const repo = getAdminRepository();
  const release = await repo.getReleaseById(releaseId);

  if (!release) {
    return NextResponse.json(
      { error: { code: 'RELEASE_NOT_FOUND', message: 'App release not found.' } },
      { status: 404 }
    );
  }

  if (release.status !== 'published') {
    return NextResponse.json(
      {
        error: {
          code: 'RELEASE_NOT_PUBLICLY_AVAILABLE',
          message: `Release status "${release.status}" is not cleared for public APK download.`,
        },
      },
      { status: 403 }
    );
  }

  const signedOrMemoryUrl = await repo.createPublishedApkSignedUrl(
    release.storage_path,
    release.file_name
  );

  try {
    await repo.recordReleaseTelemetryEvent({
      releaseId: release.release_id,
      platform: release.platform,
      channel: release.channel,
      targetBuild: release.build_number,
      eventType: 'download_started',
      metadata: { via: 'public_download_route' },
    });
  } catch {
    // Best-effort telemetry; never block APK download delivery
  }

  if (signedOrMemoryUrl.startsWith('memory://')) {
    const bytes = await repo.readApkObjectBytes(release.storage_path);
    return new NextResponse(new Uint8Array(bytes), {
      status: 200,
      headers: {
        'Content-Type': 'application/vnd.android.package-archive',
        'Content-Length': String(bytes.length),
        'Content-Disposition': `attachment; filename="${release.file_name}"`,
        'X-Content-Sha256': release.sha256_checksum,
        'Cache-Control': 'no-store',
      },
    });
  }

  const redirect = NextResponse.redirect(signedOrMemoryUrl, { status: 302 });
  redirect.headers.set('X-Content-Sha256', release.sha256_checksum);
  redirect.headers.set('Cache-Control', 'no-store');
  return redirect;
}
