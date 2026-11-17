'use client';

import { useState } from 'react';
import {
  AlertTriangle,
  CheckCircle2,
  FileCheck2,
  KeyRound,
  Lock,
  ShieldAlert,
  UploadCloud,
} from 'lucide-react';
import type { AppReleaseChannel } from '@/lib/contracts';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatBytes, shortFingerprint } from '@/lib/formatters';
import { SakugaButton, SakugaProgress, useSakugaToast } from '@/components/sakuga';
import { sakugaCelebrate } from '@/lib/sakuga/sakuga-core';
import type { ApkInspectionSummaryDto, AppReleaseDto, ReleaseSigningPolicyDto } from '@/lib/types';

interface InspectApiResponse {
  inspected: ApkInspectionSummaryDto;
  signingPolicy: ReleaseSigningPolicyDto;
  compatibility: {
    canSaveDraft: boolean;
    requiresInitialPinConfirmation: boolean;
    blockers: string[];
    warnings: string[];
    highestExistingBuild: number;
  };
}

function uploadFileWithProgress(params: {
  file: File;
  storagePath: string;
  signedUploadUrl: string;
  onProgress: (percent: number) => void;
}): Promise<void> {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    const isMemoryProxy = params.signedUploadUrl.startsWith('memory://');
    const targetUrl = isMemoryProxy
      ? `/api/admin/releases/upload-proxy?storagePath=${encodeURIComponent(params.storagePath)}`
      : params.signedUploadUrl;

    xhr.open('PUT', targetUrl);
    if (isMemoryProxy) {
      xhr.withCredentials = true;
      xhr.setRequestHeader('Content-Type', 'application/vnd.android.package-archive');
    } else {
      xhr.setRequestHeader('x-upsert', 'false');
    }

    xhr.upload.onprogress = (ev) => {
      if (ev.lengthComputable && ev.total > 0) {
        const pct = Math.min(100, Math.round((ev.loaded / ev.total) * 100));
        params.onProgress(pct);
      }
    };

    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        params.onProgress(100);
        resolve();
        return;
      }
      let message = `APK upload failed (HTTP ${xhr.status}).`;
      try {
        const parsed = JSON.parse(xhr.responseText) as { error?: { message?: string }; message?: string };
        message = parsed.error?.message || parsed.message || message;
      } catch {
        // non-JSON upload response
      }
      reject(new Error(message));
    };

    xhr.onerror = () => {
      reject(new Error('Network error while uploading APK binary.'));
    };

    if (isMemoryProxy) {
      xhr.send(params.file);
    } else {
      const formData = new FormData();
      formData.append('cacheControl', '3600');
      formData.append('', params.file);
      xhr.send(formData);
    }
  });
}

export function PublishReleasePanel({
  signingPolicy,
  onCreated,
  onSigningPolicyUpdated,
}: {
  signingPolicy: ReleaseSigningPolicyDto | null;
  onCreated: (result: { release: AppReleaseDto; notifiedUsersCount: number }) => void;
  onSigningPolicyUpdated?: (updated: ReleaseSigningPolicyDto) => void;
}) {
  const [channel, setChannel] = useState<AppReleaseChannel>('stable');
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [storagePath, setStoragePath] = useState<string | null>(null);
  const [uploadProgress, setUploadProgress] = useState<number>(0);
  const [uploading, setUploading] = useState(false);

  const [inspection, setInspection] = useState<InspectApiResponse | null>(null);
  const [minSupportedBuild, setMinSupportedBuild] = useState<string>('1');
  const [releaseNotes, setReleaseNotes] = useState<string>('');
  const [isMandatory, setIsMandatory] = useState<boolean>(false);
  const [notifyUsers, setNotifyUsers] = useState<boolean>(true);
  const [allowInitialSigningPin, setAllowInitialSigningPin] = useState<boolean>(false);
  const [publishImmediately, setPublishImmediately] = useState<boolean>(true);

  const [reviewConfirmed, setReviewConfirmed] = useState<boolean>(false);
  const [submitting, setSubmitting] = useState<boolean>(false);
  const [updatingPin, setUpdatingPin] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const { showToast } = useSakugaToast();

  async function handleFileSelectAndUpload(file: File | null) {
    setError(null);
    setInspection(null);
    setStoragePath(null);
    setUploadProgress(0);
    setReviewConfirmed(false);
    setAllowInitialSigningPin(false);
    setSelectedFile(file);
    if (!file) return;

    if (!file.name.toLowerCase().endsWith('.apk')) {
      setError('Only signed Android .apk packages are accepted.');
      return;
    }

    setUploading(true);
    try {
      const res = await apiFetch<{
        uploadSession?: {
          storagePath: string;
          signedUploadUrl: string;
          token: string;
          bucket: string;
        };
        storagePath?: string;
        signedUploadUrl?: string;
        token?: string;
        bucket?: string;
      }>('/api/admin/releases/upload-session', {
        method: 'POST',
        body: JSON.stringify({
          fileName: file.name,
          fileSizeBytes: file.size,
          channel,
        }),
      });

      const uploadSession = res.uploadSession ?? {
        storagePath: res.storagePath ?? '',
        signedUploadUrl: res.signedUploadUrl ?? '',
        token: res.token ?? '',
        bucket: res.bucket ?? 'app-releases',
      };

      if (!uploadSession.storagePath || !uploadSession.signedUploadUrl) {
        throw new Error('Upload session did not return a valid signed URL.');
      }

      await uploadFileWithProgress({
        file,
        storagePath: uploadSession.storagePath,
        signedUploadUrl: uploadSession.signedUploadUrl,
        onProgress: setUploadProgress,
      });

      const inspectRes = await apiFetch<InspectApiResponse>('/api/admin/releases/inspect', {
        method: 'POST',
        body: JSON.stringify({
          storagePath: uploadSession.storagePath,
          channel,
        }),
      });

      setStoragePath(uploadSession.storagePath);
      setInspection(inspectRes);
      setMinSupportedBuild(String(Math.min(1, inspectRes.inspected.buildNumber)));
    } catch (err) {
      if (err instanceof AdminApiError && err.code === 'STEP_UP_REQUIRED') {
        setError('Step-Up verification opened. Complete verification, then re-select the APK.');
      } else if (err instanceof Error) {
        setError(err.message);
      } else {
        setError('Failed uploading and inspecting APK package.');
      }
    } finally {
      setUploading(false);
    }
  }

  async function handleSubmitRelease(e: React.FormEvent) {
    e.preventDefault();
    if (!inspection || !storagePath || !selectedFile) return;

    setError(null);
    const minBuildInt = Number.parseInt(minSupportedBuild, 10);
    if (!Number.isFinite(minBuildInt) || minBuildInt < 1 || minBuildInt > inspection.inspected.buildNumber) {
      setError(`Minimum supported build must be between 1 and ${inspection.inspected.buildNumber}.`);
      return;
    }

    if (inspection.compatibility.requiresInitialPinConfirmation && !allowInitialSigningPin) {
      setError('Confirm pinning the APK signing certificate before saving or publishing.');
      return;
    }

    setSubmitting(true);
    try {
      const result = await apiFetch<{ release: AppReleaseDto; notifiedUsersCount?: number }>(
        '/api/admin/releases',
        {
          method: 'POST',
          body: JSON.stringify({
            channel,
            versionName: inspection.inspected.versionName,
            buildNumber: inspection.inspected.buildNumber,
            minSupportedBuild: minBuildInt,
            releaseNotes: releaseNotes.trim(),
            isMandatory,
            notifyUsers,
            publishImmediately,
            storagePath,
            fileName: selectedFile.name,
            allowInitialSigningPin,
          }),
        }
      );

      setSelectedFile(null);
      setStoragePath(null);
      setInspection(null);
      setReleaseNotes('');
      setReviewConfirmed(false);
      setAllowInitialSigningPin(false);
      if (typeof window !== 'undefined') {
        sakugaCelebrate(window.innerWidth / 2 + window.scrollX, window.innerHeight / 2 + window.scrollY, { r: 48 });
      }
      showToast(
        publishImmediately
          ? `Release v${result.release.version_name} published cleanly.`
          : `Validated draft v${result.release.version_name} saved.`,
        'success',
      );
      onCreated({
        release: result.release,
        notifiedUsersCount: result.notifiedUsersCount ?? 0,
      });
    } catch (err) {
      if (err instanceof AdminApiError && err.code === 'STEP_UP_REQUIRED') {
        setError('Step-Up verification is required. Complete verification in the modal and submit again.');
      } else if (err instanceof Error) {
        setError(err.message);
      } else {
        setError('Failed creating release record.');
      }
    } finally {
      setSubmitting(false);
    }
  }

  async function handleRotateSigningPinToUploadedApk() {
    if (!inspection?.inspected.signingCertSha256 || !storagePath) return;
    setError(null);
    setUpdatingPin(true);
    try {
      const targetCert = inspection.inspected.signingCertSha256.trim().toLowerCase();
      const updatedPolicyRes = await apiFetch<{ signingPolicy: ReleaseSigningPolicyDto }>(
        '/api/admin/releases/signing-policy',
        {
          method: 'POST',
          body: JSON.stringify({
            expectedPackageName:
              inspection.signingPolicy.expectedPackageName || inspection.inspected.packageName,
            pinnedSigningCertSha256: targetCert,
            notes: `Rotated signing pin inline while publishing v${inspection.inspected.versionName} (#${inspection.inspected.buildNumber}).`,
            confirmed: true,
          }),
        }
      );

      const reInspected = await apiFetch<InspectApiResponse>('/api/admin/releases/inspect', {
        method: 'POST',
        body: JSON.stringify({
          storagePath,
          channel,
        }),
      });

      setInspection(reInspected);
      onSigningPolicyUpdated?.(updatedPolicyRes.signingPolicy);
      showToast('Signing certificate pin updated & APK re-verified.', 'success');
    } catch (err) {
      if (err instanceof AdminApiError && err.code === 'STEP_UP_REQUIRED') {
        setError('Step-Up verification opened. Complete verification, then click Update Signing Pin again.');
      } else if (err instanceof Error) {
        setError(err.message);
      } else {
        setError('Failed updating signing certificate pin.');
      }
    } finally {
      setUpdatingPin(false);
    }
  }

  const uploadedCertSha256 = inspection?.inspected.signingCertSha256?.toLowerCase() ?? null;
  const activePinnedCertSha256 =
    inspection?.signingPolicy.pinnedSigningCertSha256?.toLowerCase() ??
    signingPolicy?.pinnedSigningCertSha256?.toLowerCase() ??
    null;
  const hasCertMismatch = Boolean(
    uploadedCertSha256 && activePinnedCertSha256 && uploadedCertSha256 !== activePinnedCertSha256
  );
  const hasBlockers = (inspection?.compatibility.blockers.length ?? 0) > 0;
  const canSubmit =
    Boolean(inspection && storagePath && selectedFile) &&
    !hasBlockers &&
    releaseNotes.trim().length >= 10 &&
    reviewConfirmed &&
    (!inspection?.compatibility.requiresInitialPinConfirmation || allowInitialSigningPin);

  return (
    <form onSubmit={handleSubmitRelease} className="space-y-6">
      <div
        className="rounded-xl border p-5 space-y-4"
        style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
      >
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h2 className="text-base font-semibold">1. Upload Signed Android APK</h2>
            <p className="text-xs mt-0.5" style={{ color: 'var(--text-muted)' }}>
              APK manifest, version code, SHA-256 checksum, and signing certificate are extracted and verified server-side.
            </p>
          </div>
          <div className="flex items-center gap-2">
            <label className="text-xs font-semibold uppercase tracking-wider" htmlFor="release-channel">
              Channel
            </label>
            <select
              id="release-channel"
              value={channel}
              disabled={uploading || submitting}
              onChange={(e) => {
                setChannel(e.target.value as AppReleaseChannel);
                setInspection(null);
                setStoragePath(null);
              }}
              className="rounded-lg border px-3 py-1.5 text-xs font-medium"
              style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
            >
              <option value="stable">stable (Public & In-App)</option>
              <option value="beta">beta (Opt-In Testers)</option>
              <option value="internal">internal (Staging QA)</option>
            </select>
          </div>
        </div>

        <label
          className="flex flex-col items-center justify-center rounded-xl border-2 border-dashed p-6 cursor-pointer transition hover:border-blue-500"
          style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
        >
          <UploadCloud className="h-8 w-8 text-blue-600 mb-2" />
          <p className="text-sm font-semibold">
            {selectedFile ? selectedFile.name : 'Choose a signed SKAVIA .apk file to upload'}
          </p>
          <p className="text-xs mt-1" style={{ color: 'var(--text-muted)' }}>
            Expected package: <span className="font-mono-code">{signingPolicy?.expectedPackageName ?? 'com.example.skavia'}</span>
            {signingPolicy?.pinnedSigningCertSha256
              ? ` · Pinned Cert: ${shortFingerprint(signingPolicy.pinnedSigningCertSha256)}`
              : ' · Signing pin will lock on first release'}
          </p>
          <input
            type="file"
            accept=".apk,application/vnd.android.package-archive"
            className="hidden"
            disabled={uploading || submitting}
            onChange={(e) => void handleFileSelectAndUpload(e.target.files?.[0] ?? null)}
          />
        </label>

        {uploading && (
          <SakugaProgress
            value={uploadProgress}
            label="Uploading to private release staging & running cryptographic inspection…"
          />
        )}

        {error && (
          <div className="rounded-lg border border-red-300 dark:border-red-800/70 bg-red-50 dark:bg-red-950/40 px-4 py-3 text-xs text-red-800 dark:text-red-200">
            {error}
          </div>
        )}
      </div>

      {inspection && (
        <div
          className="rounded-xl border p-5 space-y-4"
          style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
        >
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-2">
              {hasBlockers ? (
                <ShieldAlert className="h-5 w-5 text-red-600" />
              ) : (
                <FileCheck2 className="h-5 w-5 text-emerald-600" />
              )}
              <h2 className="text-base font-semibold">2. Server-Verified APK Identity & Metadata</h2>
            </div>
            <span
              className={`rounded-full px-2.5 py-0.5 text-xs font-semibold ${
                hasBlockers
                  ? 'bg-red-100 text-red-800 dark:bg-red-950/60 dark:text-red-200'
                  : 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-200'
              }`}
            >
              {hasBlockers ? 'Verification Blocked' : 'Cryptographically Verified'}
            </span>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs">
            <div className="rounded-lg border p-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <p style={{ color: 'var(--text-muted)' }}>Package ID</p>
              <p className="font-mono-code font-semibold mt-0.5 truncate">{inspection.inspected.packageName}</p>
            </div>
            <div className="rounded-lg border p-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <p style={{ color: 'var(--text-muted)' }}>Version & Build</p>
              <p className="font-semibold mt-0.5">
                v{inspection.inspected.versionName} (build #{inspection.inspected.buildNumber})
              </p>
            </div>
            <div className="rounded-lg border p-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <p style={{ color: 'var(--text-muted)' }}>Android SDK</p>
              <p className="font-semibold mt-0.5">
                minSdk {inspection.inspected.minSdkVersion ?? '—'} · targetSdk {inspection.inspected.targetSdkVersion ?? '—'}
              </p>
            </div>
            <div className="rounded-lg border p-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <p style={{ color: 'var(--text-muted)' }}>Binary Size</p>
              <p className="font-semibold mt-0.5">{formatBytes(inspection.inspected.fileSizeBytes)}</p>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-3 text-xs">
            <div className="rounded-lg border p-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <p style={{ color: 'var(--text-muted)' }}>APK File SHA-256</p>
              <p className="font-mono-code break-all mt-0.5">{inspection.inspected.sha256Checksum}</p>
            </div>
            <div className="rounded-lg border p-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <p style={{ color: 'var(--text-muted)' }}>
                Signing Certificate SHA-256 ({inspection.inspected.signingSchemes.join(', ') || 'None'})
              </p>
              <p className="font-mono-code break-all mt-0.5">
                {inspection.inspected.signingCertSha256 ?? 'Missing verified X.509 certificate'}
              </p>
            </div>
          </div>

          {inspection.compatibility.blockers.map((blocker) => (
            <div
              key={blocker}
              className="rounded-lg border border-red-300 dark:border-red-800/70 bg-red-50 dark:bg-red-950/40 px-3.5 py-2.5 text-xs text-red-800 dark:text-red-200 flex items-start gap-2"
            >
              <ShieldAlert className="h-4 w-4 shrink-0 mt-0.5" />
              <span>{blocker}</span>
            </div>
          ))}

          {hasCertMismatch && (
            <div className="rounded-lg border border-amber-300 dark:border-amber-700/70 bg-amber-50/80 dark:bg-amber-950/40 p-3.5 text-xs text-amber-950 dark:text-amber-100 space-y-2.5">
              <div className="flex items-start gap-2">
                <KeyRound className="h-4 w-4 shrink-0 mt-0.5 text-amber-700 dark:text-amber-300" />
                <div className="space-y-1">
                  <p className="font-semibold">
                    Signed with a different keystore? (Team Keystore Rotation)
                  </p>
                  <p className="opacity-90">
                    If you intentionally switched to the shared SKAVIA team keystore (
                    <span className="font-mono-code">skavia-release.jks</span>) or rotated keys, you can update the trusted signing pin directly to this APK&apos;s certificate and re-verify without re-uploading. Note: Android devices running a build signed by the old key will need a one-time reinstall; after switching to one shared team keystore, all teammates&apos; builds will upgrade seamlessly in-place.
                  </p>
                </div>
              </div>
              <div className="flex justify-end">
                <SakugaButton
                  type="button"
                  variant="secondary"
                  intensity="subtle"
                  disabled={updatingPin || uploading || submitting}
                  onClick={() => void handleRotateSigningPinToUploadedApk()}
                  className="px-3.5 py-2 text-xs"
                >
                  <KeyRound className="h-3.5 w-3.5" />
                  <span>
                    {updatingPin ? 'Updating Signing Pin…' : 'Update Signing Pin to This APK & Re-Verify'}
                  </span>
                </SakugaButton>
              </div>
            </div>
          )}

          {inspection.compatibility.warnings.map((warning) => (
            <div
              key={warning}
              className="rounded-lg border border-amber-300 dark:border-amber-800/70 bg-amber-50 dark:bg-amber-950/40 px-3.5 py-2.5 text-xs text-amber-800 dark:text-amber-200 flex items-start gap-2"
            >
              <AlertTriangle className="h-4 w-4 shrink-0 mt-0.5" />
              <span>{warning}</span>
            </div>
          ))}

          {inspection.compatibility.requiresInitialPinConfirmation && !hasBlockers && (
            <label className="flex items-start gap-2.5 rounded-lg border border-amber-300 dark:border-amber-700/60 bg-amber-50/70 dark:bg-amber-950/30 p-3 text-xs cursor-pointer">
              <input
                type="checkbox"
                checked={allowInitialSigningPin}
                onChange={(e) => setAllowInitialSigningPin(e.target.checked)}
                className="mt-0.5"
              />
              <span>
                <strong className="inline-flex items-center gap-1">
                  <Lock className="h-3.5 w-3.5" /> Lock Initial Certificate Pin:
                </strong>{' '}
                Confirm this APK was signed with the official SKAVIA keystore. Future releases will be rejected if signed by a different certificate.
              </span>
            </label>
          )}
        </div>
      )}

      {inspection && !hasBlockers && (
        <div
          className="rounded-xl border p-5 space-y-4"
          style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
        >
          <h2 className="text-base font-semibold">3. Release Policy, Changelog & Publication</h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider mb-1">
                Minimum Supported Build
              </label>
              <input
                type="number"
                min={1}
                max={inspection.inspected.buildNumber}
                value={minSupportedBuild}
                onChange={(e) => setMinSupportedBuild(e.target.value)}
                required
                className="w-full rounded-lg border px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500"
                style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
              />
              <p className="text-[11px] mt-1" style={{ color: 'var(--text-muted)' }}>
                Devices installed below build #{minSupportedBuild || '1'} will be required to upgrade immediately.
              </p>
            </div>

            <div className="space-y-2.5 pt-1">
              <label className="flex items-start gap-2.5 text-xs cursor-pointer">
                <input
                  type="checkbox"
                  checked={isMandatory}
                  onChange={(e) => setIsMandatory(e.target.checked)}
                  className="mt-0.5"
                />
                <span>
                  <strong>Mandatory Update</strong> — Remove &quot;Later&quot; dismissal in the Android app and require upgrade to this build.
                </span>
              </label>

              <label className="flex items-start gap-2.5 text-xs cursor-pointer">
                <input
                  type="checkbox"
                  checked={notifyUsers}
                  onChange={(e) => setNotifyUsers(e.target.checked)}
                  className="mt-0.5"
                />
                <span>
                  <strong>Broadcast In-App Notification</strong> — Deliver update notifications into users&apos; SKAVIA Notification Center on publish.
                </span>
              </label>

              <label className="flex items-start gap-2.5 text-xs cursor-pointer">
                <input
                  type="checkbox"
                  checked={publishImmediately}
                  onChange={(e) => setPublishImmediately(e.target.checked)}
                  className="mt-0.5"
                />
                <span>
                  <strong>Publish Immediately</strong> — Uncheck to save as a validated draft for staged rollout review first.
                </span>
              </label>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider mb-1">
              Release Notes (shown in app update modal &amp; public SKAVIA website)
            </label>
            <textarea
              rows={4}
              required
              minLength={10}
              value={releaseNotes}
              onChange={(e) => setReleaseNotes(e.target.value)}
              placeholder="- Improved worker dispatch stability&#10;- Added biometric session verification&#10;- Critical security and performance fixes"
              className="w-full rounded-lg border p-3 text-sm outline-none focus:ring-2 focus:ring-blue-500"
              style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
            />
          </div>

          <label className="flex items-start gap-2.5 rounded-lg border p-3 text-xs cursor-pointer" style={{ borderColor: 'var(--border-subtle)' }}>
            <input
              type="checkbox"
              checked={reviewConfirmed}
              onChange={(e) => setReviewConfirmed(e.target.checked)}
              className="mt-0.5"
            />
            <span>
              I have reviewed the version (<strong>v{inspection.inspected.versionName}</strong>, build{' '}
              <strong>#{inspection.inspected.buildNumber}</strong>), target channel (<strong>{channel}</strong>), and SHA-256 checksum before committing this release.
            </span>
          </label>

          <div className="flex justify-end gap-3">
            <SakugaButton
              type="submit"
              variant="primary"
              intensity="medium"
              disabled={!canSubmit || submitting}
              className="px-5 py-2.5"
            >
              <CheckCircle2 className="h-4 w-4" />
              <span>
                {submitting
                  ? 'Processing Release…'
                  : publishImmediately
                    ? `Publish v${inspection.inspected.versionName} (${channel})`
                    : 'Save Validated Draft'}
              </span>
            </SakugaButton>
          </div>
        </div>
      )}
    </form>
  );
}

