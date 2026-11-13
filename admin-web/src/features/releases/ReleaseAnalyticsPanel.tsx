'use client';

import type { AppReleaseAnalyticsDto } from '@/lib/types';
import { formatDateTime } from '@/lib/formatters';
import { KpiCard } from '@/components/ui/KpiCard';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { Activity, CheckCircle2, Download, ShieldAlert, Smartphone } from 'lucide-react';

export function ReleaseAnalyticsPanel({ analytics }: { analytics: AppReleaseAnalyticsDto | null }) {
  if (!analytics) {
    return (
      <div
        className="rounded-xl border p-6 text-xs"
        style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)', color: 'var(--text-muted)' }}
      >
        Release telemetry analytics unavailable.
      </div>
    );
  }

  const maxCheckIns = Math.max(
    1,
    ...analytics.versionDistribution.map((entry) => entry.checkIns)
  );

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <KpiCard
          label="Client Update Checks"
          value={analytics.totalCheckIns}
          subtitle="Real app startup/foreground checks"
          icon={<Activity className="h-4 w-4" />}
          tone="royal"
        />
        <KpiCard
          label="APK Downloads Started"
          value={analytics.totalDownloadsStarted}
          subtitle={`${analytics.totalDownloadsCompleted} client downloads completed`}
          icon={<Download className="h-4 w-4" />}
          tone="sky"
        />
        <KpiCard
          label="Checksum Verified"
          value={analytics.totalChecksumVerified}
          subtitle={`${analytics.totalInstallerLaunched} installer handoffs launched`}
          icon={<CheckCircle2 className="h-4 w-4" />}
          tone="aqua"
        />
        <KpiCard
          label="Integrity / Install Failures"
          value={analytics.totalChecksumFailed + analytics.totalInstallFailed}
          subtitle={`${analytics.totalChecksumFailed} checksum · ${analytics.totalInstallFailed} install`}
          icon={<ShieldAlert className="h-4 w-4" />}
          tone={analytics.totalChecksumFailed + analytics.totalInstallFailed > 0 ? 'danger' : 'neutral'}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <div
          className="lg:col-span-5 rounded-xl border p-5 space-y-4"
          style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
        >
          <div className="flex items-center gap-2">
            <Smartphone className="h-4 w-4 text-blue-600" />
            <h3 className="text-sm font-semibold">Observed App Version Distribution</h3>
          </div>
          {analytics.versionDistribution.length === 0 ? (
            <p className="text-xs leading-relaxed" style={{ color: 'var(--text-muted)' }}>
              No client telemetry events recorded yet. Live check-ins will appear automatically as Android devices check `/api/public/app-update`.
            </p>
          ) : (
            <div className="space-y-3">
              {analytics.versionDistribution.map((item) => {
                const widthPct = Math.round((item.checkIns / maxCheckIns) * 100);
                return (
                  <div key={`${item.installedBuild}-${item.installedVersion}`} className="space-y-1 text-xs">
                    <div className="flex justify-between font-medium">
                      <span>
                        v{item.installedVersion} (build #{item.installedBuild})
                      </span>
                      <span className="tabular-nums" style={{ color: 'var(--text-muted)' }}>
                        {item.checkIns} check-ins
                      </span>
                    </div>
                    <div className="h-2 rounded-full bg-slate-200 dark:bg-slate-800 overflow-hidden">
                      <div className="h-full bg-blue-600 rounded-full" style={{ width: `${widthPct}%` }} />
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        <div
          className="lg:col-span-7 rounded-xl border p-5 space-y-3"
          style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
        >
          <h3 className="text-sm font-semibold">Recent Real-Device Update Events</h3>
          {analytics.recentEvents.length === 0 ? (
            <p className="text-xs leading-relaxed" style={{ color: 'var(--text-muted)' }}>
              No real update events recorded yet. Events are logged strictly on genuine client update checks, APK downloads, checksum verification, and installer launches.
            </p>
          ) : (
            <div className="space-y-2 max-h-[360px] overflow-y-auto">
              {analytics.recentEvents.map((ev) => (
                <div
                  key={ev.event_id}
                  className="rounded-lg border p-3 text-xs flex flex-wrap items-center justify-between gap-2"
                  style={{ borderColor: 'var(--border-subtle)' }}
                >
                  <div className="space-y-0.5">
                    <div className="flex items-center gap-2">
                      <span className="font-mono-code font-semibold">{ev.event_type}</span>
                      <StatusBadge
                        status={ev.event_type.includes('failed') ? 'failed' : 'completed'}
                      />
                    </div>
                    <p style={{ color: 'var(--text-muted)' }}>
                      Channel: {ev.channel} · Installed: v{ev.installed_version || '—'} (#{ev.installed_build ?? '—'})
                      {ev.target_build ? ` → Target #${ev.target_build}` : ''}
                      {ev.android_api_level ? ` · API ${ev.android_api_level}` : ''}
                    </p>
                  </div>
                  <span style={{ color: 'var(--text-muted)' }}>{formatDateTime(ev.created_at)}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

