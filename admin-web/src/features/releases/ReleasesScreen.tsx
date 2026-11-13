'use client';

import { useCallback, useEffect, useState } from 'react';
import dynamic from 'next/dynamic';
import {
  CheckCircle2,
  KeyRound,
  Layers,
  PackageCheck,
  RefreshCw,
  ShieldCheck,
  UploadCloud,
} from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatDateTime } from '@/lib/formatters';
import type {
  AppReleaseAnalyticsDto,
  AppReleaseDto,
  ReleaseSigningPolicyDto,
} from '@/lib/types';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { DataTable, type TableColumn } from '@/components/ui/DataTable';
import { KpiCard } from '@/components/ui/KpiCard';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';
import { StatusBadge } from '@/components/ui/StatusBadge';
import {
  ReleaseDetailDrawer,
  type PendingReleaseConfirm,
} from './ReleaseDetailDrawer';
import { formatBytes, shortFingerprint } from '@/lib/formatters';

const PublishReleasePanel = dynamic(
  () => import('./PublishReleasePanel').then((m) => m.PublishReleasePanel),
  { loading: () => <LoadingPanel /> }
);

const ReleaseAnalyticsPanel = dynamic(
  () => import('./ReleaseAnalyticsPanel').then((m) => m.ReleaseAnalyticsPanel),
  { loading: () => <LoadingPanel /> }
);

type ReleaseTab = 'releases' | 'publish' | 'analytics';

export default function ReleasesScreen() {
  const [tab, setTab] = useState<ReleaseTab>('releases');
  const [channelFilter, setChannelFilter] = useState<'all' | 'stable' | 'beta' | 'internal'>('all');
  const [releases, setReleases] = useState<AppReleaseDto[]>([]);
  const [currentStable, setCurrentStable] = useState<AppReleaseDto | null>(null);
  const [signingPolicy, setSigningPolicy] = useState<ReleaseSigningPolicyDto | null>(null);
  const [analytics, setAnalytics] = useState<AppReleaseAnalyticsDto | null>(null);

  const [selectedRelease, setSelectedRelease] = useState<AppReleaseDto | null>(null);
  const [pendingConfirm, setPendingConfirm] = useState<PendingReleaseConfirm | null>(null);
  const [actionLoading, setActionLoading] = useState(false);

  const [editingPolicy, setEditingPolicy] = useState(false);
  const [policyPackage, setPolicyPackage] = useState('com.example.skavia');
  const [policyCertPin, setPolicyCertPin] = useState('');
  const [policySaving, setPolicySaving] = useState(false);

  const [banner, setBanner] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadReleases = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await apiFetch<{
        releases: AppReleaseDto[];
        currentStable: AppReleaseDto | null;
        signingPolicy: ReleaseSigningPolicyDto;
        analytics: AppReleaseAnalyticsDto;
      }>('/api/admin/releases');

      setReleases(res.releases);
      setCurrentStable(res.currentStable);
      setSigningPolicy(res.signingPolicy);
      setAnalytics(res.analytics);
      setPolicyPackage(res.signingPolicy.expectedPackageName);
      setPolicyCertPin(res.signingPolicy.pinnedSigningCertSha256 ?? '');

      setSelectedRelease((prev) =>
        prev ? res.releases.find((r) => r.release_id === prev.release_id) ?? null : null
      );
    } catch (err) {
      setError(
        err instanceof AdminApiError ? err.message : 'Failed loading app release management console.'
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadReleases();
  }, [loadReleases]);

  async function handleConfirmedAction(reason: string) {
    if (!pendingConfirm) return;
    setActionLoading(true);
    setError(null);
    setBanner(null);

    const { release, action } = pendingConfirm;
    try {
      if (action === 'delete') {
        await apiFetch(`/api/admin/releases/${release.release_id}`, {
          method: 'DELETE',
        });
        setSelectedRelease(null);
        setBanner(`Deleted draft release v${release.version_name} (#${release.build_number}).`);
      } else {
        const payload: Record<string, unknown> =
          action === 'publish'
            ? {
                action: 'publish',
                notifyUsers: release.notify_users,
                confirmed: true,
              }
            : action === 'suspend'
              ? {
                  action: 'suspend',
                  reason: reason.trim(),
                  confirmed: true,
                }
              : action === 'rollback'
                ? {
                    action: 'rollback',
                    targetReleaseId: release.release_id,
                    reason: reason.trim(),
                    confirmed: true,
                  }
                : action === 'archive'
                  ? {
                      action: 'archive',
                      confirmed: true,
                    }
                  : {
                      action: 'validate',
                    };

        const res = await apiFetch<{ release: AppReleaseDto; notifiedUsersCount?: number }>(
          `/api/admin/releases/${release.release_id}/action`,
          {
            method: 'POST',
            body: JSON.stringify(payload),
          }
        );
        setSelectedRelease(res.release);
        const notifyNote =
          typeof res.notifiedUsersCount === 'number' && res.notifiedUsersCount > 0
            ? ` Notified ${res.notifiedUsersCount} active user accounts.`
            : '';
        setBanner(
          `Release v${res.release.version_name} (#${res.release.build_number}) transitioned via "${action}".${notifyNote}`
        );
      }

      setPendingConfirm(null);
      await loadReleases();
    } catch (err) {
      if (err instanceof AdminApiError && err.code === 'STEP_UP_REQUIRED') {
        setError('Step-Up verification opened. Complete verification and retry the action.');
      } else {
        setError(err instanceof AdminApiError ? err.message : 'Failed executing release lifecycle action.');
      }
      setPendingConfirm(null);
    } finally {
      setActionLoading(false);
    }
  }

  async function handleSavePolicy(e: React.FormEvent) {
    e.preventDefault();
    setPolicySaving(true);
    setError(null);
    setBanner(null);
    try {
      const cleanedPin = policyCertPin.trim().toLowerCase();
      if (!/^[a-f0-9]{64}$/.test(cleanedPin)) {
        setError('Signing certificate fingerprint must be a 64-character lowercase SHA-256 hex digest.');
        setPolicySaving(false);
        return;
      }
      await apiFetch<{ signingPolicy: ReleaseSigningPolicyDto }>(
        '/api/admin/releases/signing-policy',
        {
          method: 'POST',
          body: JSON.stringify({
            expectedPackageName: policyPackage.trim(),
            pinnedSigningCertSha256: cleanedPin,
            confirmed: true,
          }),
        }
      );
      setEditingPolicy(false);
      setBanner('Updated Android APK identity & signing certificate pin policy.');
      await loadReleases();
    } catch (err) {
      setError(
        err instanceof AdminApiError
          ? err.message
          : 'Failed updating release signing certificate policy.'
      );
    } finally {
      setPolicySaving(false);
    }
  }

  const latestOverall = releases[0] ?? null;
  const filteredReleases =
    channelFilter === 'all' ? releases : releases.filter((r) => r.channel === channelFilter);

  const columns: TableColumn<AppReleaseDto>[] = [
    {
      key: 'version',
      header: 'Version & Build',
      render: (r) => (
        <div>
          <div className="flex items-center gap-2">
            <span className="font-semibold">v{r.version_name}</span>
            <span className="font-mono-code text-xs" style={{ color: 'var(--text-muted)' }}>
              #{r.build_number}
            </span>
            {r.is_current && (
              <span className="rounded-full bg-blue-600/15 text-blue-600 dark:text-sky-400 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider">
                Live
              </span>
            )}
          </div>
          <p className="text-[11px] font-mono-code" style={{ color: 'var(--text-muted)' }}>
            {r.package_name}
          </p>
        </div>
      ),
    },
    {
      key: 'channel',
      header: 'Channel',
      render: (r) => (
        <span className="rounded-md border px-2 py-0.5 text-xs font-medium capitalize" style={{ borderColor: 'var(--border-subtle)' }}>
          {r.channel}
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (r) => <StatusBadge status={r.status} />,
    },
    {
      key: 'policy',
      header: 'Update Policy',
      render: (r) => (
        <div className="text-xs">
          <span className={r.is_mandatory ? 'font-semibold text-red-600 dark:text-red-400' : ''}>
            {r.is_mandatory ? 'Mandatory' : 'Optional'}
          </span>
          <p className="text-[11px]" style={{ color: 'var(--text-muted)' }}>
            Min supported build #{r.min_supported_build}
          </p>
        </div>
      ),
    },
    {
      key: 'binary',
      header: 'APK Size & Checksum',
      render: (r) => (
        <div className="text-xs">
          <span>{formatBytes(r.file_size_bytes)}</span>
          <p className="text-[11px] font-mono-code" style={{ color: 'var(--text-muted)' }}>
            {shortFingerprint(r.sha256_checksum, 10, 6)}
          </p>
        </div>
      ),
    },
    {
      key: 'published',
      header: 'Published',
      render: (r) => (
        <span className="text-xs" style={{ color: 'var(--text-secondary)' }}>
          {r.published_at ? formatDateTime(r.published_at) : `Draft ${formatDateTime(r.created_at)}`}
        </span>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">App Release &amp; APK Distribution</h1>
          <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
            Cryptographically verified Android release lifecycle, website APK delivery, and live in-app updates.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button
            type="button"
            onClick={() => void loadReleases()}
            className="inline-flex items-center gap-1.5 rounded-lg border px-3 py-2 text-xs font-semibold hover:bg-slate-50 dark:hover:bg-slate-800/50"
            style={{ borderColor: 'var(--border-subtle)' }}
          >
            <RefreshCw className="h-3.5 w-3.5" />
            <span>Refresh</span>
          </button>
          <button
            type="button"
            onClick={() => setTab('publish')}
            className="inline-flex items-center gap-1.5 rounded-lg px-4 py-2 text-xs font-semibold text-white"
            style={{ backgroundColor: '#003399' }}
          >
            <UploadCloud className="h-3.5 w-3.5" />
            <span>Publish New Release</span>
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <KpiCard
          label="Live Stable Version"
          value={currentStable ? `v${currentStable.version_name}` : 'None Published'}
          subtitle={
            currentStable
              ? `Build #${currentStable.build_number} · ${formatBytes(currentStable.file_size_bytes)}`
              : 'Publish an APK to activate website & app downloads'
          }
          icon={<PackageCheck className="h-4 w-4" />}
          tone="royal"
        />
        <KpiCard
          label="Minimum Supported Build"
          value={currentStable ? `#${currentStable.min_supported_build}` : '—'}
          subtitle={
            currentStable
              ? currentStable.is_mandatory
                ? 'Active mandatory upgrade gate'
                : 'Optional upgrade available'
              : 'No active version floor'
          }
          icon={<ShieldCheck className="h-4 w-4" />}
          tone={currentStable?.is_mandatory ? 'danger' : 'aqua'}
        />
        <KpiCard
          label="Latest Uploaded Build"
          value={latestOverall ? `v${latestOverall.version_name} (#${latestOverall.build_number})` : '—'}
          subtitle={latestOverall ? `${latestOverall.channel} · ${latestOverall.status}` : '0 releases uploaded'}
          icon={<Layers className="h-4 w-4" />}
          tone="sky"
        />
        <KpiCard
          label="Total Releases"
          value={releases.length}
          subtitle={`${releases.filter((r) => r.status === 'published').length} published · ${releases.filter((r) => r.status === 'suspended').length} suspended`}
          icon={<KeyRound className="h-4 w-4" />}
          tone="neutral"
        />
      </div>

      {/* Signing Certificate & Package Identity Pin Policy */}
      <div
        className="rounded-xl border p-4 flex flex-wrap items-center justify-between gap-4"
        style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
      >
        <div className="space-y-1 text-xs">
          <p className="font-semibold flex items-center gap-1.5">
            <KeyRound className="h-4 w-4 text-blue-600" />
            <span>Android Package &amp; Signing Certificate Pin</span>
          </p>
          <p style={{ color: 'var(--text-secondary)' }}>
            Package ID:{' '}
            <span className="font-mono-code font-semibold">
              {signingPolicy?.expectedPackageName ?? 'com.example.skavia'}
            </span>{' '}
            · Pinned Cert SHA-256:{' '}
            <span className="font-mono-code font-semibold">
              {signingPolicy?.pinnedSigningCertSha256
                ? shortFingerprint(signingPolicy.pinnedSigningCertSha256, 16, 12)
                : 'Unpinned (will lock on first verified release)'}
            </span>
          </p>
        </div>
        <button
          type="button"
          onClick={() => setEditingPolicy((prev) => !prev)}
          className="rounded-lg border px-3 py-1.5 text-xs font-semibold hover:bg-slate-50 dark:hover:bg-slate-800/50"
          style={{ borderColor: 'var(--border-subtle)' }}
        >
          {editingPolicy ? 'Close Policy Editor' : 'Configure Signing Pin'}
        </button>
      </div>

      {editingPolicy && (
        <form
          onSubmit={handleSavePolicy}
          className="rounded-xl border p-5 space-y-4"
          style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
        >
          <h2 className="text-sm font-semibold">Update Signing Verification Policy</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider mb-1">
                Expected Android Application ID
              </label>
              <input
                type="text"
                required
                value={policyPackage}
                onChange={(e) => setPolicyPackage(e.target.value)}
                className="w-full rounded-lg border px-3 py-2 text-sm font-mono-code"
                style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
              />
            </div>
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider mb-1">
                Pinned Signing Certificate SHA-256 (64 hex chars, required)
              </label>
              <input
                type="text"
                required
                value={policyCertPin}
                onChange={(e) => setPolicyCertPin(e.target.value)}
                placeholder="Enter 64-char SHA-256 hex fingerprint from your upload keystore"
                className="w-full rounded-lg border px-3 py-2 text-xs font-mono-code"
                style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
              />
            </div>
          </div>
          <div className="flex justify-end gap-2">
            <button
              type="button"
              onClick={() => setEditingPolicy(false)}
              className="rounded-lg border px-3 py-2 text-xs font-medium"
              style={{ borderColor: 'var(--border-subtle)' }}
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={policySaving}
              className="rounded-lg px-4 py-2 text-xs font-semibold text-white disabled:opacity-50"
              style={{ backgroundColor: '#003399' }}
            >
              {policySaving ? 'Saving…' : 'Save Signing Policy'}
            </button>
          </div>
        </form>
      )}

      {banner && (
        <div className="rounded-xl border border-emerald-300 dark:border-emerald-800/70 bg-emerald-50 dark:bg-emerald-950/40 px-4 py-3 text-xs text-emerald-900 dark:text-emerald-200 flex items-center justify-between gap-2">
          <span className="flex items-center gap-2">
            <CheckCircle2 className="h-4 w-4 shrink-0" />
            {banner}
          </span>
          <button type="button" onClick={() => setBanner(null)} className="font-semibold underline">
            Dismiss
          </button>
        </div>
      )}

      {error && <ErrorPanel message={error} onRetry={() => void loadReleases()} />}

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex flex-wrap gap-2">
          {(
            [
              ['releases', `Release History (${releases.length})`],
              ['publish', 'Publish New APK'],
              ['analytics', 'Update Telemetry'],
            ] as const
          ).map(([key, label]) => (
            <button
              key={key}
              type="button"
              onClick={() => setTab(key)}
              className={`rounded-lg px-3.5 py-2 text-xs font-semibold border ${
                tab === key ? 'bg-blue-700 text-white border-blue-700' : ''
              }`}
              style={tab !== key ? { borderColor: 'var(--border-subtle)' } : undefined}
            >
              {label}
            </button>
          ))}
        </div>

        {tab === 'releases' && (
          <div className="flex items-center gap-1.5 text-xs">
            {(['all', 'stable', 'beta', 'internal'] as const).map((ch) => (
              <button
                key={ch}
                type="button"
                onClick={() => setChannelFilter(ch)}
                className={`rounded-md px-2.5 py-1 capitalize border ${
                  channelFilter === ch ? 'bg-slate-800 text-white border-slate-800 dark:bg-slate-200 dark:text-slate-900' : ''
                }`}
                style={channelFilter !== ch ? { borderColor: 'var(--border-subtle)' } : undefined}
              >
                {ch}
              </button>
            ))}
          </div>
        )}
      </div>

      {loading ? (
        <LoadingPanel />
      ) : tab === 'publish' ? (
        <PublishReleasePanel
          signingPolicy={signingPolicy}
          onCreated={({ release, notifiedUsersCount }) => {
            const msg =
              release.status === 'published'
                ? `Published v${release.version_name} (#${release.build_number}) to ${release.channel} channel.${notifiedUsersCount > 0 ? ` Notified ${notifiedUsersCount} user accounts.` : ''}`
                : `Saved validated draft v${release.version_name} (#${release.build_number}).`;
            setBanner(msg);
            setTab('releases');
            void loadReleases();
          }}
        />
      ) : tab === 'analytics' ? (
        <ReleaseAnalyticsPanel analytics={analytics} />
      ) : (
        <DataTable
          columns={columns}
          rows={filteredReleases}
          rowKey={(r) => r.release_id}
          onRowClick={(r) => setSelectedRelease(r)}
        />
      )}

      <ReleaseDetailDrawer
        release={selectedRelease}
        onClose={() => setSelectedRelease(null)}
        onRequestAction={setPendingConfirm}
      />

      <ConfirmModal
        key={pendingConfirm ? `${pendingConfirm.release.release_id}-${pendingConfirm.action}` : 'closed'}
        open={Boolean(pendingConfirm)}
        title={pendingConfirm?.title ?? ''}
        description={pendingConfirm?.description ?? ''}
        confirmLabel={pendingConfirm?.confirmLabel ?? 'Confirm'}
        danger={pendingConfirm?.danger ?? false}
        requireReason={pendingConfirm?.requireReason ?? false}
        loading={actionLoading}
        onCancel={() => setPendingConfirm(null)}
        onConfirm={(reason) => void handleConfirmedAction(reason)}
      />
    </div>
  );
}

