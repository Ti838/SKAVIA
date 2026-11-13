import { randomUUID } from 'node:crypto';
import type {
  AppReleaseChannel,
  AppReleasePlatform,
  AppReleaseStatus,
} from '@/lib/contracts';
import type {
  AppReleaseDto,
  ReleaseSigningPolicyDto,
} from '@/lib/types';
import {
  DEFAULT_SKAVIA_PACKAGE_NAME,
  ReleaseValidationError,
} from '@/server/releases/release-validator';
import type { StoreDbClient } from './base';

const RELEASE_BUCKET = 'app-releases';
const SIGNING_POLICY_KEY = 'app_release_signing_policy';
const APP_RELEASE_SELECT_COLUMNS =
  'release_id, platform, channel, package_name, version_name, build_number, min_supported_build, min_sdk_version, target_sdk_version, release_notes, is_mandatory, status, is_current, storage_bucket, storage_path, file_name, file_size_bytes, sha256_checksum, signing_cert_sha256, signing_schemes, notify_users, notifications_dispatched_at, rolled_back_from_release_id, suspension_reason, created_by, validated_by, published_by, validated_at, published_at, suspended_at, archived_at, created_at, updated_at';

function sanitizeFileName(raw: string): string {
  return raw
    .trim()
    .replace(/[^A-Za-z0-9._-]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .slice(0, 120);
}

export class SupabaseReleasesStore {
  constructor(private readonly db: StoreDbClient) {}

  async getReleaseSigningPolicy(): Promise<ReleaseSigningPolicyDto> {
    const { data } = await this.db
      .from('system_settings')
      .select('setting_value, updated_by, updated_at')
      .eq('setting_key', SIGNING_POLICY_KEY)
      .maybeSingle();

    const envPin = process.env.SKAVIA_APK_SIGNING_CERT_SHA256?.trim().toLowerCase() || null;
    const val = (data?.setting_value ?? null) as Record<string, unknown> | null;

    return {
      expectedPackageName:
        typeof val?.expectedPackageName === 'string' && val.expectedPackageName.trim()
          ? val.expectedPackageName.trim()
          : DEFAULT_SKAVIA_PACKAGE_NAME,
      pinnedSigningCertSha256:
        typeof val?.pinnedSigningCertSha256 === 'string' && val.pinnedSigningCertSha256.trim()
          ? val.pinnedSigningCertSha256.trim().toLowerCase()
          : envPin,
      updatedAt: (data?.updated_at as string | undefined) ?? null,
      updatedBy: (data?.updated_by as string | undefined) ?? null,
    };
  }

  async upsertReleaseSigningPolicy(input: {
    expectedPackageName: string;
    pinnedSigningCertSha256: string | null;
    actorUserId: string;
  }): Promise<ReleaseSigningPolicyDto> {
    const now = new Date().toISOString();
    const settingValue = {
      expectedPackageName: input.expectedPackageName.trim() || DEFAULT_SKAVIA_PACKAGE_NAME,
      pinnedSigningCertSha256: input.pinnedSigningCertSha256
        ? input.pinnedSigningCertSha256.trim().toLowerCase()
        : null,
    };

    const { error } = await this.db.from('system_settings').upsert(
      {
        setting_key: SIGNING_POLICY_KEY,
        setting_value: settingValue,
        description: 'Expected Android package ID and APK signing certificate SHA-256 fingerprint pin',
        updated_by: input.actorUserId,
        updated_at: now,
      },
      { onConflict: 'setting_key' }
    );
    if (error) throw new Error(error.message);

    return {
      ...settingValue,
      updatedAt: now,
      updatedBy: input.actorUserId,
    };
  }

  async createApkUploadSession(input: {
    fileName: string;
    channel: AppReleaseChannel;
  }): Promise<{
    storagePath: string;
    signedUploadUrl: string;
    token: string;
    bucket: string;
  }> {
    const safeName = sanitizeFileName(input.fileName) || 'skavia-release.apk';
    const storagePath = `staging/${input.channel}/${Date.now()}-${randomUUID()}-${safeName}`;

    const { data, error } = await this.db.storage
      .from(RELEASE_BUCKET)
      .createSignedUploadUrl(storagePath);

    if (error || !data?.signedUrl) {
      throw new Error(
        error?.message ?? 'Failed generating signed APK upload session in Supabase Storage.'
      );
    }

    return {
      storagePath: data.path || storagePath,
      signedUploadUrl: data.signedUrl,
      token: data.token,
      bucket: RELEASE_BUCKET,
    };
  }

  async uploadApkObjectDirect(input: {
    storagePath: string;
    bytes: Buffer;
    contentType?: string;
  }): Promise<void> {
    const { error } = await this.db.storage
      .from(RELEASE_BUCKET)
      .upload(input.storagePath, input.bytes, {
        contentType: input.contentType || 'application/vnd.android.package-archive',
        upsert: false,
      });
    if (error) throw new Error(error.message);
  }

  async readApkObjectBytes(storagePath: string): Promise<Buffer> {
    const { data, error } = await this.db.storage
      .from(RELEASE_BUCKET)
      .download(storagePath);
    if (error || !data) {
      throw new ReleaseValidationError(
        'APK_OBJECT_NOT_FOUND',
        error?.message ?? 'Uploaded APK binary was not found in private storage.',
        404
      );
    }
    const arr = await data.arrayBuffer();
    return Buffer.from(arr);
  }

  async listReleases(filters?: {
    platform?: AppReleasePlatform;
    channel?: AppReleaseChannel;
    status?: AppReleaseStatus;
  }): Promise<AppReleaseDto[]> {
    let query = this.db
      .from('app_releases')
      .select(APP_RELEASE_SELECT_COLUMNS)
      .order('build_number', { ascending: false })
      .order('created_at', { ascending: false });

    if (filters?.platform) query = query.eq('platform', filters.platform);
    if (filters?.channel) query = query.eq('channel', filters.channel);
    if (filters?.status) query = query.eq('status', filters.status);

    const { data, error } = await query;
    if (error) throw new Error(error.message);
    return (data ?? []) as AppReleaseDto[];
  }

  async getReleaseById(releaseId: string): Promise<AppReleaseDto | null> {
    const { data, error } = await this.db
      .from('app_releases')
      .select(APP_RELEASE_SELECT_COLUMNS)
      .eq('release_id', releaseId)
      .maybeSingle();
    if (error) throw new Error(error.message);
    return (data as AppReleaseDto | null) ?? null;
  }

  async getCurrentPublishedRelease(params: {
    platform: AppReleasePlatform;
    channel: AppReleaseChannel;
  }): Promise<AppReleaseDto | null> {
    const { data, error } = await this.db
      .from('app_releases')
      .select(APP_RELEASE_SELECT_COLUMNS)
      .eq('platform', params.platform)
      .eq('channel', params.channel)
      .eq('status', 'published')
      .eq('is_current', true)
      .maybeSingle();
    if (error) throw new Error(error.message);
    return (data as AppReleaseDto | null) ?? null;
  }

  async createReleaseRecord(input: {
    platform: AppReleasePlatform;
    channel: AppReleaseChannel;
    packageName: string;
    versionName: string;
    buildNumber: number;
    minSupportedBuild: number;
    minSdkVersion: number | null;
    targetSdkVersion: number | null;
    releaseNotes: string;
    isMandatory: boolean;
    notifyUsers: boolean;
    status: AppReleaseStatus;
    storagePath: string;
    fileName: string;
    fileSizeBytes: number;
    sha256Checksum: string;
    signingCertSha256: string;
    signingSchemes: string[];
    actorUserId: string;
  }): Promise<AppReleaseDto> {
    const now = new Date().toISOString();
    const { data, error } = await this.db
      .from('app_releases')
      .insert({
        platform: input.platform,
        channel: input.channel,
        package_name: input.packageName,
        version_name: input.versionName,
        build_number: input.buildNumber,
        min_supported_build: input.minSupportedBuild,
        min_sdk_version: input.minSdkVersion,
        target_sdk_version: input.targetSdkVersion,
        release_notes: input.releaseNotes,
        is_mandatory: input.isMandatory,
        notify_users: input.notifyUsers,
        status: input.status,
        is_current: false,
        storage_bucket: RELEASE_BUCKET,
        storage_path: input.storagePath,
        file_name: input.fileName,
        file_size_bytes: input.fileSizeBytes,
        sha256_checksum: input.sha256Checksum,
        signing_cert_sha256: input.signingCertSha256,
        signing_schemes: input.signingSchemes,
        created_by: input.actorUserId,
        validated_by: input.status === 'validated' ? input.actorUserId : null,
        validated_at: input.status === 'validated' ? now : null,
        created_at: now,
        updated_at: now,
      })
      .select(APP_RELEASE_SELECT_COLUMNS)
      .single();

    if (error || !data) {
      throw new Error(error?.message ?? 'Failed creating app release record.');
    }

    return data as AppReleaseDto;
  }

  async markReleaseValidated(input: {
    releaseId: string;
    packageName: string;
    versionName: string;
    buildNumber: number;
    minSdkVersion: number | null;
    targetSdkVersion: number | null;
    fileSizeBytes: number;
    sha256Checksum: string;
    signingCertSha256: string;
    signingSchemes: string[];
    actorUserId: string;
  }): Promise<AppReleaseDto> {
    const now = new Date().toISOString();
    const { data, error } = await this.db
      .from('app_releases')
      .update({
        package_name: input.packageName,
        version_name: input.versionName,
        build_number: input.buildNumber,
        min_sdk_version: input.minSdkVersion,
        target_sdk_version: input.targetSdkVersion,
        file_size_bytes: input.fileSizeBytes,
        sha256_checksum: input.sha256Checksum,
        signing_cert_sha256: input.signingCertSha256,
        signing_schemes: input.signingSchemes,
        status: 'validated',
        validated_by: input.actorUserId,
        validated_at: now,
        updated_at: now,
      })
      .eq('release_id', input.releaseId)
      .select(APP_RELEASE_SELECT_COLUMNS)
      .single();

    if (error || !data) {
      throw new Error(error?.message ?? 'Failed validating release record.');
    }
    return data as AppReleaseDto;
  }

  async publishRelease(input: {
    releaseId: string;
    actorUserId: string;
    notifyUsers?: boolean;
  }): Promise<{ release: AppReleaseDto; notifiedUsersCount: number }> {
    const target = await this.getReleaseById(input.releaseId);
    if (!target) {
      throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'App release not found.', 404);
    }

    const now = new Date().toISOString();

    // Clear previous active current pointer on the same platform/channel without deleting history
    const { error: clearErr } = await this.db
      .from('app_releases')
      .update({ is_current: false, updated_at: now })
      .eq('platform', target.platform)
      .eq('channel', target.channel)
      .eq('is_current', true)
      .neq('release_id', target.release_id);
    if (clearErr) throw new Error(clearErr.message);

    // Promote storage object to immutable releases path if currently in staging
    let finalStoragePath = target.storage_path;
    if (target.storage_path.startsWith('staging/')) {
      const destPath = `releases/${target.platform}/${target.channel}/v${target.version_name}-b${target.build_number}/${target.release_id}.apk`;
      const { error: copyErr } = await this.db.storage
        .from(RELEASE_BUCKET)
        .copy(target.storage_path, destPath);
      if (!copyErr) {
        finalStoragePath = destPath;
        await this.db.storage.from(RELEASE_BUCKET).remove([target.storage_path]).catch(() => undefined);
      }
    }

    const shouldNotify = input.notifyUsers ?? target.notify_users;
    const { data, error } = await this.db
      .from('app_releases')
      .update({
        status: 'published',
        is_current: true,
        storage_path: finalStoragePath,
        notify_users: shouldNotify,
        published_by: input.actorUserId,
        published_at: target.published_at ?? now,
        updated_at: now,
      })
      .eq('release_id', target.release_id)
      .select(APP_RELEASE_SELECT_COLUMNS)
      .single();

    if (error || !data) {
      throw new Error(error?.message ?? 'Failed publishing release.');
    }

    const published = data as AppReleaseDto;
    let notifiedUsersCount = 0;

    if (shouldNotify && !published.notifications_dispatched_at) {
      notifiedUsersCount = await this.dispatchMobileUpdateNotifications(published);
      if (notifiedUsersCount >= 0) {
        await this.db
          .from('app_releases')
          .update({ notifications_dispatched_at: now })
          .eq('release_id', published.release_id);
        published.notifications_dispatched_at = now;
      }
    }

    return { release: published, notifiedUsersCount };
  }

  private async dispatchMobileUpdateNotifications(release: AppReleaseDto): Promise<number> {
    const { data: users, error } = await this.db
      .from('users')
      .select('user_id, active_mode')
      .neq('account_status', 'deleted');
    if (error || !users) return 0;

    const mobileUsers = users.filter((u) => {
      const mode = String(u.active_mode ?? '').toLowerCase();
      return mode !== 'admin';
    });

    if (mobileUsers.length === 0) return 0;

    const title = release.is_mandatory
      ? `Required Update: SKAVIA v${release.version_name}`
      : `SKAVIA v${release.version_name} Available`;
    const body = release.is_mandatory
      ? `Build #${release.build_number} includes required security and platform updates. Tap to update now.`
      : `A new SKAVIA Android update (Build #${release.build_number}) is ready. Tap to review release notes and install.`;

    const rows = mobileUsers.map((u) => ({
      user_id: u.user_id,
      dedup_key: `app_update_${release.release_id}_${u.user_id}`,
      title,
      body,
      category: release.is_mandatory ? 'urgent' : 'system',
      action_route: '/app-update',
      metadata: {
        releaseId: release.release_id,
        versionName: release.version_name,
        buildNumber: release.build_number,
        channel: release.channel,
        isMandatory: release.is_mandatory,
      },
      is_read: false,
    }));

    let insertedCount = 0;
    const batchSize = 200;
    for (let i = 0; i < rows.length; i += batchSize) {
      const chunk = rows.slice(i, i + batchSize);
      const { error: insertErr } = await this.db
        .from('user_notifications')
        .upsert(chunk, { onConflict: 'dedup_key', ignoreDuplicates: true });
      if (!insertErr) {
        insertedCount += chunk.length;
      }
    }
    return insertedCount;
  }

  async suspendRelease(input: {
    releaseId: string;
    actorUserId: string;
    reason: string;
  }): Promise<AppReleaseDto> {
    const now = new Date().toISOString();
    const { data, error } = await this.db
      .from('app_releases')
      .update({
        status: 'suspended',
        is_current: false,
        suspension_reason: input.reason,
        suspended_at: now,
        updated_at: now,
      })
      .eq('release_id', input.releaseId)
      .select(APP_RELEASE_SELECT_COLUMNS)
      .single();
    if (error || !data) throw new Error(error?.message ?? 'Failed suspending release.');
    return data as AppReleaseDto;
  }

  async rollbackRelease(input: {
    targetReleaseId: string;
    actorUserId: string;
    reason: string;
  }): Promise<{ activeRelease: AppReleaseDto; suspendedReleaseId: string | null }> {
    const target = await this.getReleaseById(input.targetReleaseId);
    if (!target) {
      throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'Target rollback release not found.', 404);
    }
    if (!target.signing_cert_sha256 || !target.sha256_checksum) {
      throw new ReleaseValidationError(
        'ROLLBACK_TARGET_INCOMPLETE',
        'Target release lacks verified checksum/signing metadata.',
        422
      );
    }
    if (target.status === 'draft') {
      throw new ReleaseValidationError(
        'ROLLBACK_TARGET_UNVALIDATED',
        'Cannot rollback to an unvalidated draft release.',
        422
      );
    }

    const now = new Date().toISOString();
    const current = await this.getCurrentPublishedRelease({
      platform: target.platform,
      channel: target.channel,
    });

    if (current && current.release_id === target.release_id) {
      return { activeRelease: target, suspendedReleaseId: null };
    }

    if (current) {
      const { error: suspErr } = await this.db
        .from('app_releases')
        .update({
          status: 'suspended',
          is_current: false,
          suspension_reason: `Rolled back to v${target.version_name} (#${target.build_number}): ${input.reason}`,
          suspended_at: now,
          updated_at: now,
        })
        .eq('release_id', current.release_id);
      if (suspErr) throw new Error(suspErr.message);
    }

    const { data, error } = await this.db
      .from('app_releases')
      .update({
        status: 'published',
        is_current: true,
        rolled_back_from_release_id: current?.release_id ?? null,
        published_by: input.actorUserId,
        published_at: target.published_at ?? now,
        updated_at: now,
      })
      .eq('release_id', target.release_id)
      .select(APP_RELEASE_SELECT_COLUMNS)
      .single();
    if (error || !data) throw new Error(error?.message ?? 'Failed activating rollback release.');

    return {
      activeRelease: data as AppReleaseDto,
      suspendedReleaseId: current?.release_id ?? null,
    };
  }

  async archiveRelease(input: {
    releaseId: string;
  }): Promise<AppReleaseDto> {
    const existing = await this.getReleaseById(input.releaseId);
    if (!existing) {
      throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'Release not found.', 404);
    }
    if (existing.is_current && existing.status === 'published') {
      throw new ReleaseValidationError(
        'CANNOT_ARCHIVE_ACTIVE_RELEASE',
        'Publish another release or suspend this release before archiving it.',
        409
      );
    }

    const now = new Date().toISOString();
    const { data, error } = await this.db
      .from('app_releases')
      .update({
        status: 'archived',
        is_current: false,
        archived_at: now,
        updated_at: now,
      })
      .eq('release_id', input.releaseId)
      .select(APP_RELEASE_SELECT_COLUMNS)
      .single();
    if (error || !data) throw new Error(error?.message ?? 'Failed archiving release.');
    return data as AppReleaseDto;
  }

  async deleteDraftRelease(input: { releaseId: string }): Promise<void> {
    const existing = await this.getReleaseById(input.releaseId);
    if (!existing) {
      throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'Release not found.', 404);
    }
    if (existing.status !== 'draft' && existing.status !== 'validated') {
      throw new ReleaseValidationError(
        'CANNOT_DELETE_HISTORICAL_RELEASE',
        'Published, suspended, or archived releases cannot be deleted to preserve audit history.',
        409
      );
    }

    if (existing.storage_path) {
      await this.db.storage.from(RELEASE_BUCKET).remove([existing.storage_path]).catch(() => undefined);
    }

    const { error } = await this.db
      .from('app_releases')
      .delete()
      .eq('release_id', input.releaseId);
    if (error) throw new Error(error.message);
  }
}
