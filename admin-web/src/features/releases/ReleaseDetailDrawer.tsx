'use client';

import {
  Archive,
  CheckCircle2,
  Copy,
  Download,
  RotateCcw,
  ShieldAlert,
  ShieldCheck,
  Trash2,
} from 'lucide-react';
import { formatBytes, formatDateTime } from '@/lib/formatters';
import type { AppReleaseDto } from '@/lib/types';
import { SideDrawer } from '@/components/ui/SideDrawer';
import { StatusBadge } from '@/components/ui/StatusBadge';

export interface PendingReleaseConfirm {
  release: AppReleaseDto;
  action: 'validate' | 'publish' | 'suspend' | 'rollback' | 'archive' | 'delete';
  title: string;
  description: string;
  confirmLabel: string;
  danger: boolean;
  requireReason: boolean;
}

export function ReleaseDetailDrawer({
  release,
  onClose,
  onRequestAction,
}: {
  release: AppReleaseDto | null;
  onClose: () => void;
  onRequestAction: (confirm: PendingReleaseConfirm) => void;
}) {
  return (
    <SideDrawer
      open={Boolean(release)}
      title={release ? `Release v${release.version_name} (#${release.build_number})` : ''}
      onClose={onClose}
    >
      {release && (
        <div className="space-y-5 text-xs">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <div className="flex items-center gap-2">
              <StatusBadge status={release.status} />
              <span
                className="rounded border px-2 py-0.5 font-medium capitalize"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                {release.channel}
              </span>
              {release.is_current && (
                <span className="rounded bg-blue-600 px-2 py-0.5 text-[11px] font-semibold text-white">
                  Active Channel Release
                </span>
              )}
            </div>
            {release.status === 'published' && (
              <a
                href={`/api/public/releases/${release.release_id}/download`}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 rounded-lg border px-3 py-1.5 font-semibold hover:bg-slate-50 dark:hover:bg-slate-800/50"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                <Download className="h-3.5 w-3.5 text-blue-600" />
                <span>Test Public APK URL</span>
              </a>
            )}
          </div>

          {release.suspension_reason && (
            <div className="rounded-lg border border-red-300 dark:border-red-800/70 bg-red-50 dark:bg-red-950/40 p-3 text-red-900 dark:text-red-200">
              <p className="font-semibold">Suspension Reason</p>
              <p className="mt-1">{release.suspension_reason}</p>
            </div>
          )}

          <div className="grid grid-cols-2 gap-3">
            <div className="rounded-lg border p-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <p style={{ color: 'var(--text-muted)' }}>Package ID</p>
              <p className="font-mono-code font-semibold mt-0.5">{release.package_name}</p>
            </div>
            <div className="rounded-lg border p-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <p style={{ color: 'var(--text-muted)' }}>Min Supported Build</p>
              <p className="font-semibold mt-0.5">
                #{release.min_supported_build} ({release.is_mandatory ? 'Mandatory' : 'Optional'})
              </p>
            </div>
            <div className="rounded-lg border p-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <p style={{ color: 'var(--text-muted)' }}>APK File</p>
              <p className="font-semibold mt-0.5 truncate">
                {release.file_name} ({formatBytes(release.file_size_bytes)})
              </p>
            </div>
            <div className="rounded-lg border p-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <p style={{ color: 'var(--text-muted)' }}>Android SDK Targets</p>
              <p className="font-semibold mt-0.5">
                minSdk {release.min_sdk_version ?? '—'} · targetSdk {release.target_sdk_version ?? '—'}
              </p>
            </div>
          </div>

          <div className="rounded-lg border p-3 space-y-2" style={{ borderColor: 'var(--border-subtle)' }}>
            <div className="flex items-center justify-between">
              <p className="font-semibold">APK SHA-256 Checksum</p>
              <button
                type="button"
                onClick={() => void navigator.clipboard?.writeText(release.sha256_checksum)}
                className="inline-flex items-center gap-1 text-blue-600 hover:underline"
              >
                <Copy className="h-3 w-3" /> Copy
              </button>
            </div>
            <p className="font-mono-code break-all" style={{ color: 'var(--text-secondary)' }}>
              {release.sha256_checksum}
            </p>
            <p className="font-semibold pt-1">
              Signing Certificate SHA-256 ({release.signing_schemes.join(', ') || 'Unknown'})
            </p>
            <p className="font-mono-code break-all" style={{ color: 'var(--text-secondary)' }}>
              {release.signing_cert_sha256 || '—'}
            </p>
          </div>

          <div className="rounded-lg border p-3 space-y-1.5" style={{ borderColor: 'var(--border-subtle)' }}>
            <p className="font-semibold">Release Notes</p>
            <p className="whitespace-pre-wrap leading-relaxed" style={{ color: 'var(--text-secondary)' }}>
              {release.release_notes}
            </p>
          </div>

          <div className="rounded-lg border p-3 space-y-1" style={{ borderColor: 'var(--border-subtle)', color: 'var(--text-muted)' }}>
            <p>Created: {formatDateTime(release.created_at)}</p>
            {release.validated_at && <p>Validated: {formatDateTime(release.validated_at)}</p>}
            {release.published_at && <p>Published: {formatDateTime(release.published_at)}</p>}
            {release.notifications_dispatched_at && (
              <p>Update notifications dispatched: {formatDateTime(release.notifications_dispatched_at)}</p>
            )}
            {release.suspended_at && <p>Suspended: {formatDateTime(release.suspended_at)}</p>}
            {release.archived_at && <p>Archived: {formatDateTime(release.archived_at)}</p>}
          </div>

          <div className="pt-2 border-t flex flex-wrap gap-2" style={{ borderColor: 'var(--border-subtle)' }}>
            {release.status === 'draft' && (
              <button
                type="button"
                onClick={() =>
                  onRequestAction({
                    release,
                    action: 'validate',
                    title: 'Re-Validate Draft Release?',
                    description: `Re-run cryptographic APK verification and signing policy checks for v${release.version_name} (#${release.build_number}).`,
                    confirmLabel: 'Validate APK',
                    danger: false,
                    requireReason: false,
                  })
                }
                className="inline-flex items-center gap-1.5 rounded-lg bg-sky-600 px-3 py-2 font-semibold text-white"
              >
                <ShieldCheck className="h-3.5 w-3.5" /> Validate Draft
              </button>
            )}

            {release.status === 'validated' && (
              <button
                type="button"
                onClick={() =>
                  onRequestAction({
                    release,
                    action: 'publish',
                    title: `Publish v${release.version_name} to ${release.channel}?`,
                    description:
                      release.channel === 'stable'
                        ? 'Publishing moves this APK into immutable release storage, updates the public SKAVIA website download immediately, and notifies Android users.'
                        : `Publishing activates v${release.version_name} (#${release.build_number}) on the ${release.channel} channel.`,
                    confirmLabel: 'Publish Release',
                    danger: false,
                    requireReason: false,
                  })
                }
                className="inline-flex items-center gap-1.5 rounded-lg px-3.5 py-2 font-semibold text-white"
                style={{ backgroundColor: '#003399' }}
              >
                <CheckCircle2 className="h-3.5 w-3.5" /> Publish Live
              </button>
            )}

            {release.status === 'published' && release.is_current && (
              <button
                type="button"
                onClick={() =>
                  onRequestAction({
                    release,
                    action: 'suspend',
                    title: `Suspend Live Release v${release.version_name}?`,
                    description:
                      'Suspending immediately stops public APK downloads and prevents Android apps from downloading this build.',
                    confirmLabel: 'Suspend Release',
                    danger: true,
                    requireReason: true,
                  })
                }
                className="inline-flex items-center gap-1.5 rounded-lg bg-red-600 px-3 py-2 font-semibold text-white"
              >
                <ShieldAlert className="h-3.5 w-3.5" /> Suspend
              </button>
            )}

            {!release.is_current &&
              (release.status === 'published' || release.status === 'archived') && (
                <button
                  type="button"
                  onClick={() =>
                    onRequestAction({
                      release,
                      action: 'rollback',
                      title: `Roll Back ${release.channel} Channel to v${release.version_name}?`,
                      description:
                        'New installs and un-upgraded devices will receive this build immediately. Note: Android prevents in-place APK downgrades on devices already running a higher build number—for those devices, upload a hotfix APK with a higher build number.',
                      confirmLabel: 'Confirm Rollback',
                      danger: true,
                      requireReason: true,
                    })
                  }
                  className="inline-flex items-center gap-1.5 rounded-lg bg-amber-600 px-3 py-2 font-semibold text-white"
                >
                  <RotateCcw className="h-3.5 w-3.5" /> Rollback to This Release
                </button>
              )}

            {release.status !== 'archived' && !release.is_current && (
              <button
                type="button"
                onClick={() =>
                  onRequestAction({
                    release,
                    action: 'archive',
                    title: `Archive Release v${release.version_name}?`,
                    description:
                      'Archiving preserves audit history and checksum records while removing this release from active rollout.',
                    confirmLabel: 'Archive',
                    danger: false,
                    requireReason: false,
                  })
                }
                className="inline-flex items-center gap-1.5 rounded-lg border px-3 py-2 font-semibold"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                <Archive className="h-3.5 w-3.5" /> Archive
              </button>
            )}

            {(release.status === 'draft' || release.status === 'validated') && (
              <button
                type="button"
                onClick={() =>
                  onRequestAction({
                    release,
                    action: 'delete',
                    title: `Delete Unpublished Release v${release.version_name}?`,
                    description:
                      'Deletes this unpublished staging release record and removes its staged APK artifact.',
                    confirmLabel: 'Delete Draft',
                    danger: true,
                    requireReason: false,
                  })
                }
                className="inline-flex items-center gap-1.5 rounded-lg border border-red-300 dark:border-red-800/70 px-3 py-2 font-semibold text-red-600 dark:text-red-400"
              >
                <Trash2 className="h-3.5 w-3.5" /> Delete
              </button>
            )}
          </div>
        </div>
      )}
    </SideDrawer>
  );
}

