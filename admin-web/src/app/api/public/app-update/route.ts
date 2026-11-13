import { NextResponse } from 'next/server';
import {
  APP_RELEASE_CHANNELS,
  APP_RELEASE_PLATFORMS,
  PublicReleaseTelemetrySchema,
  type AppReleaseChannel,
  type AppReleasePlatform,
} from '@/lib/contracts';
import { getAdminRepository } from '@/server/db/store-factory';
import { jsonErrorResponse } from '@/server/http/guard';
import { resolvePublicRequestOrigin } from '@/server/http/origin';
import { evaluatePublicUpdateState } from '@/server/releases/release-validator';

export const dynamic = 'force-dynamic';
export const maxDuration = 30;

function isReleaseBackendUnavailableError(error: unknown): boolean {
  const msg =
    error instanceof Error
      ? error.message.toLowerCase()
      : String(error).toLowerCase();
  return (
    msg.includes('schema cache') ||
    msg.includes('does not exist') ||
    msg.includes('app_releases') ||
    msg.includes('app_release_events') ||
    msg.includes('pgrst') ||
    msg.includes('fetch failed') ||
    msg.includes('econnrefused') ||
    msg.includes('etimedout') ||
    msg.includes('network')
  );
}

export async function GET(req: Request) {
  const correlationId = req.headers.get('x-correlation-id') || crypto.randomUUID();
  try {
    const url = new URL(req.url);
    const rawPlatform = url.searchParams.get('platform')?.trim().toLowerCase() || 'android';
    const rawChannel = url.searchParams.get('channel')?.trim().toLowerCase() || 'stable';
    const rawBuild = url.searchParams.get('build');
    const rawVersion = url.searchParams.get('version')?.trim() || null;
    const rawDeviceHash = url.searchParams.get('deviceId')?.trim().slice(0, 64) || null;
    const rawApiLevel = url.searchParams.get('apiLevel');

    const platform: AppReleasePlatform = APP_RELEASE_PLATFORMS.includes(
      rawPlatform as AppReleasePlatform
    )
      ? (rawPlatform as AppReleasePlatform)
      : 'android';
    const channel: AppReleaseChannel = APP_RELEASE_CHANNELS.includes(
      rawChannel as AppReleaseChannel
    )
      ? (rawChannel as AppReleaseChannel)
      : 'stable';

    const installedBuild =
      rawBuild != null && /^\d+$/.test(rawBuild) ? Number(rawBuild) : null;
    const androidApiLevel =
      rawApiLevel != null && /^\d+$/.test(rawApiLevel) ? Number(rawApiLevel) : null;

    const repo = getAdminRepository();
    const [currentRelease, allChannelReleases] = await Promise.all([
      repo.getCurrentPublishedRelease({ platform, channel }),
      repo.listReleases({ platform, channel }),
    ]);

    const payload = evaluatePublicUpdateState({
      platform,
      channel,
      installedBuild,
      currentRelease,
      allChannelReleases,
      originBaseUrl: resolvePublicRequestOrigin(req),
    });

    if (installedBuild != null) {
      try {
        await repo.recordReleaseTelemetryEvent({
          releaseId: currentRelease?.release_id ?? null,
          platform,
          channel,
          installedBuild,
          installedVersion: rawVersion,
          targetBuild: currentRelease?.build_number ?? null,
          eventType: 'update_check',
          deviceFingerprintHash: rawDeviceHash,
          androidApiLevel,
          metadata: {
            updateStatus: payload.updateStatus,
          },
        });
      } catch {
        // Telemetry write failures must never block update check responses
      }
    }

    return NextResponse.json(payload, {
      headers: {
        'Cache-Control': 'no-store',
        'X-Correlation-Id': correlationId,
      },
    });
  } catch (error) {
    if (isReleaseBackendUnavailableError(error)) {
      return NextResponse.json(
        {
          error: {
            code: 'RELEASE_SERVICE_UNAVAILABLE',
            message: 'Release metadata service is temporarily unavailable.',
            correlationId,
          },
        },
        {
          status: 503,
          headers: {
            'Cache-Control': 'no-store',
            'X-Correlation-Id': correlationId,
          },
        }
      );
    }
    return jsonErrorResponse(error, correlationId);
  }
}

export async function POST(req: Request) {
  const correlationId = req.headers.get('x-correlation-id') || crypto.randomUUID();
  try {
    const body = await req.json();
    const input = PublicReleaseTelemetrySchema.parse(body);
    const repo = getAdminRepository();

    await repo.recordReleaseTelemetryEvent({
      releaseId: input.releaseId ?? null,
      platform: input.platform,
      channel: input.channel,
      installedBuild: input.installedBuild ?? null,
      installedVersion: input.installedVersion ?? null,
      targetBuild: input.targetBuild ?? null,
      eventType: input.eventType,
      deviceFingerprintHash: input.deviceFingerprintHash ?? null,
      androidApiLevel: input.androidApiLevel ?? null,
      metadata: input.metadata ?? {},
    });

    return NextResponse.json(
      { ok: true },
      { headers: { 'Cache-Control': 'no-store', 'X-Correlation-Id': correlationId } }
    );
  } catch (error) {
    if (isReleaseBackendUnavailableError(error)) {
      return NextResponse.json(
        {
          error: {
            code: 'RELEASE_SERVICE_UNAVAILABLE',
            message: 'Release telemetry storage is temporarily unavailable.',
            correlationId,
          },
        },
        {
          status: 503,
          headers: {
            'Cache-Control': 'no-store',
            'X-Correlation-Id': correlationId,
          },
        }
      );
    }
    return jsonErrorResponse(error, correlationId);
  }
}

