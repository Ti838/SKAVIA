import type {
  AppReleaseChannel,
  AppReleasePlatform,
  ReleaseTelemetryEventType,
} from '@/lib/contracts';
import type { AppReleaseAnalyticsDto } from '@/lib/types';
import type { StoreDbClient } from './base';

const RELEASE_BUCKET = 'app-releases';

export class SupabaseReleasesTelemetryStore {
  constructor(private readonly db: StoreDbClient) {}

  async createPublishedApkSignedUrl(storagePath: string, fileName?: string): Promise<string> {
    const { data, error } = await this.db.storage
      .from(RELEASE_BUCKET)
      .createSignedUrl(storagePath, 600, fileName ? { download: fileName } : undefined);
    if (error || !data?.signedUrl) {
      throw new Error(error?.message ?? 'Failed generating short-lived signed APK download URL.');
    }
    return data.signedUrl;
  }

  async recordReleaseTelemetryEvent(input: {
    releaseId?: string | null;
    platform: AppReleasePlatform;
    channel: AppReleaseChannel;
    installedBuild?: number | null;
    installedVersion?: string | null;
    targetBuild?: number | null;
    eventType: ReleaseTelemetryEventType;
    deviceFingerprintHash?: string | null;
    androidApiLevel?: number | null;
    userId?: string | null;
    metadata?: Record<string, unknown>;
  }): Promise<void> {
    const { error } = await this.db.from('app_release_events').insert({
      release_id: input.releaseId ?? null,
      platform: input.platform,
      channel: input.channel,
      installed_build: input.installedBuild ?? null,
      installed_version: input.installedVersion ?? null,
      target_build: input.targetBuild ?? null,
      event_type: input.eventType,
      device_fingerprint_hash: input.deviceFingerprintHash ?? null,
      android_api_level: input.androidApiLevel ?? null,
      user_id: input.userId ?? null,
      metadata: input.metadata ?? {},
    });
    if (error) {
      console.warn('[AppReleaseEvents] telemetry insert warning:', error.message);
    }
  }

  async getReleaseAnalytics(filters?: {
    platform?: AppReleasePlatform;
    channel?: AppReleaseChannel;
  }): Promise<AppReleaseAnalyticsDto> {
    let query = this.db
      .from('app_release_events')
      .select(
        'event_id, release_id, channel, installed_build, installed_version, target_build, event_type, android_api_level, created_at'
      )
      .order('created_at', { ascending: false })
      .limit(1000);

    if (filters?.platform) query = query.eq('platform', filters.platform);
    if (filters?.channel) query = query.eq('channel', filters.channel);

    const { data, error } = await query;
    if (error) throw new Error(error.message);

    const events = (data ?? []) as AppReleaseAnalyticsDto['recentEvents'];
    const versionMap = new Map<string, { installedBuild: number; installedVersion: string; checkIns: number }>();

    let totalCheckIns = 0;
    let totalDownloadsStarted = 0;
    let totalDownloadsCompleted = 0;
    let totalChecksumVerified = 0;
    let totalChecksumFailed = 0;
    let totalInstallerLaunched = 0;
    let totalInstallFailed = 0;

    for (const ev of events) {
      if (ev.event_type === 'update_check' || ev.event_type === 'app_active') {
        totalCheckIns++;
        if (ev.installed_build != null) {
          const ver = ev.installed_version || `build-${ev.installed_build}`;
          const key = `${ev.installed_build}::${ver}`;
          const cur = versionMap.get(key) ?? {
            installedBuild: ev.installed_build,
            installedVersion: ver,
            checkIns: 0,
          };
          cur.checkIns += 1;
          versionMap.set(key, cur);
        }
      } else if (ev.event_type === 'download_started') {
        totalDownloadsStarted++;
      } else if (ev.event_type === 'download_completed') {
        totalDownloadsCompleted++;
      } else if (ev.event_type === 'checksum_verified') {
        totalChecksumVerified++;
      } else if (ev.event_type === 'checksum_failed') {
        totalChecksumFailed++;
      } else if (ev.event_type === 'installer_launched') {
        totalInstallerLaunched++;
      } else if (ev.event_type === 'install_failed') {
        totalInstallFailed++;
      }
    }

    return {
      totalCheckIns,
      totalDownloadsStarted,
      totalDownloadsCompleted,
      totalChecksumVerified,
      totalChecksumFailed,
      totalInstallerLaunched,
      totalInstallFailed,
      recentEvents: events.slice(0, 50),
      versionDistribution: Array.from(versionMap.values()).sort(
        (a, b) => b.installedBuild - a.installedBuild
      ),
    };
  }
}

