'use client';

import { useCallback, useEffect, useState } from 'react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatDateTime } from '@/lib/formatters';
import type {
  AdminLoginEventDto,
  AdminPasskeyDto,
  AdminSessionDto,
  AuditLogDto,
  SecurityIncidentDto,
} from '@/lib/types';
import { DataTable, type TableColumn } from '@/components/ui/DataTable';
import { SideDrawer } from '@/components/ui/SideDrawer';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

interface SystemSettingRow {
  setting_key: string;
  setting_value: unknown;
  description: string | null;
  updated_at: string;
}

interface BackupLogRow {
  verification_id: string;
  environment: string;
  restore_target: string;
  status: string;
  verified_at: string;
  rpo_minutes: number | null;
  rto_minutes: number | null;
}

export default function SecurityPage() {
  const [tab, setTab] = useState<'audit' | 'telemetry' | 'incidents' | 'sessions' | 'backups'>('audit');
  const [logs, setLogs] = useState<AuditLogDto[]>([]);
  const [loginEvents, setLoginEvents] = useState<AdminLoginEventDto[]>([]);
  const [passkeys, setPasskeys] = useState<AdminPasskeyDto[]>([]);
  const [incidents, setIncidents] = useState<SecurityIncidentDto[]>([]);
  const [sessions, setSessions] = useState<AdminSessionDto[]>([]);
  const [settings, setSettings] = useState<SystemSettingRow[]>([]);
  const [backups, setBackups] = useState<BackupLogRow[]>([]);
  const [selectedLog, setSelectedLog] = useState<AuditLogDto | null>(null);

  const [incTitle, setIncTitle] = useState('');
  const [incSeverity, setIncSeverity] = useState<'Low' | 'Medium' | 'High' | 'Critical'>('High');
  const [incSummary, setIncSummary] = useState('');
  const [updatingIncidentId, setUpdatingIncidentId] = useState<string | null>(null);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadSecurityData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [lRes, iRes, sRes, cfgRes, ovRes] = await Promise.all([
        apiFetch<{ logs: AuditLogDto[] }>('/api/admin/security/audit-logs?limit=150'),
        apiFetch<{ incidents: SecurityIncidentDto[] }>('/api/admin/security/incidents'),
        apiFetch<{ sessions: AdminSessionDto[] }>('/api/admin/security/sessions'),
        apiFetch<{ settings: SystemSettingRow[]; backups: BackupLogRow[] }>(
          '/api/admin/security/settings'
        ),
        apiFetch<{ loginEvents: AdminLoginEventDto[]; passkeys: AdminPasskeyDto[] }>(
          '/api/admin/security/overview'
        ).catch(() => ({ loginEvents: [], passkeys: [] })),
      ]);
      setLogs(lRes.logs);
      setIncidents(iRes.incidents);
      setSessions(sRes.sessions);
      setSettings(cfgRes.settings);
      setBackups(cfgRes.backups);
      setLoginEvents(ovRes.loginEvents);
      setPasskeys(ovRes.passkeys);
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading security center.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadSecurityData();
  }, [loadSecurityData]);

  async function handleCreateIncident(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    try {
      await apiFetch('/api/admin/security/incidents', {
        method: 'POST',
        body: JSON.stringify({
          title: incTitle.trim(),
          severity: incSeverity,
          summary: incSummary.trim(),
        }),
      });
      setIncTitle('');
      setIncSummary('');
      await loadSecurityData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed logging incident.');
    }
  }

  async function handleUpdateIncidentStatus(
    incidentId: string,
    status: 'Investigating' | 'Contained' | 'Resolved' | 'Closed'
  ) {
    setError(null);
    setUpdatingIncidentId(incidentId);
    try {
      await apiFetch('/api/admin/security/incidents', {
        method: 'PATCH',
        body: JSON.stringify({
          incidentId,
          status,
          containmentNote: `Transitioned to ${status} via Security Center`,
        }),
      });
      await loadSecurityData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed updating incident status.');
    } finally {
      setUpdatingIncidentId(null);
    }
  }

  async function handleRevokeSession(sessionId: string) {
    setError(null);
    try {
      await apiFetch('/api/admin/security/sessions', {
        method: 'DELETE',
        body: JSON.stringify({ sessionId }),
      });
      await loadSecurityData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed revoking session.');
    }
  }

  const auditCols: TableColumn<AuditLogDto>[] = [
    {
      key: 'action',
      header: 'Action',
      render: (r) => <span className="font-mono-code text-xs font-semibold">{r.action}</span>,
    },
    {
      key: 'entity',
      header: 'Target Entity',
      render: (r) => `${r.entity_type} ${r.entity_id ? `(${r.entity_id.slice(0, 12)})` : ''}`,
    },
    { key: 'actor', header: 'Actor', render: (r) => r.user_id || 'System' },
    { key: 'ip', header: 'IP', render: (r) => r.ip_address || '—' },
    { key: 'time', header: 'Timestamp', render: (r) => formatDateTime(r.created_at) },
  ];

  const sessionCols: TableColumn<AdminSessionDto>[] = [
    { key: 'user', header: 'Admin UID', render: (r) => <span className="font-mono-code text-xs">{r.user_id}</span> },
    { key: 'device', header: 'Device', render: (r) => r.device_label || 'Web' },
    { key: 'ip', header: 'IP', render: (r) => r.ip_address || '—' },
    {
      key: 'status',
      header: 'State',
      render: (r) => <StatusBadge status={r.revoked_at ? 'Revoked' : 'Active'} />,
    },
    {
      key: 'action',
      header: 'Control',
      align: 'right',
      render: (r) =>
        !r.revoked_at ? (
          <button
            type="button"
            onClick={() => void handleRevokeSession(r.session_id)}
            className="rounded-lg bg-red-600 px-3 py-1 text-xs font-semibold text-white"
          >
            Force Revoke
          </button>
        ) : (
          <span className="text-xs" style={{ color: 'var(--text-muted)' }}>
            Revoked {formatDateTime(r.revoked_at)}
          </span>
        ),
    },
  ];

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Security Operations & Audit Center</h1>
        <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
          Append-only audit trail, incident containment, live session revocation, and backup verification.
        </p>
      </div>

      <div className="flex flex-wrap gap-2">
        {(
          [
            ['audit', 'Immutable Audit Logs'],
            ['telemetry', `Login Telemetry & Passkeys (${loginEvents.length})`],
            ['incidents', 'Security Incidents'],
            ['sessions', 'Active Admin Sessions'],
            ['backups', 'Backups & System Settings'],
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

      {error && <ErrorPanel message={error} onRetry={() => void loadSecurityData()} />}

      {loading ? (
        <LoadingPanel />
      ) : tab === 'audit' ? (
        <DataTable
          columns={auditCols}
          rows={logs}
          rowKey={(r) => r.audit_id}
          onRowClick={(r) => setSelectedLog(r)}
        />
      ) : tab === 'telemetry' ? (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div
            className="lg:col-span-8 rounded-xl border p-5 space-y-3"
            style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
          >
            <h2 className="text-base font-semibold">Authentication &amp; Surface Attempt Telemetry</h2>
            {loginEvents.length === 0 ? (
              <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                No authentication telemetry logged yet.
              </p>
            ) : (
              <div className="space-y-2 max-h-[480px] overflow-y-auto">
                {loginEvents.map((ev) => (
                  <div
                    key={ev.event_id}
                    className="rounded-lg border p-3 text-xs flex flex-wrap items-center justify-between gap-2"
                    style={{ borderColor: 'var(--border-subtle)' }}
                  >
                    <div>
                      <p className="font-semibold">
                        {ev.email || ev.user_id || 'Unknown Actor'}{' '}
                        {ev.surface ? `(${ev.surface})` : ''}
                      </p>
                      <p style={{ color: 'var(--text-muted)' }}>
                        IP: {ev.ip_address || '—'} &middot; Method: {ev.mfa_method || 'password'} &middot; {formatDateTime(ev.created_at)}
                      </p>
                      {ev.failure_reason && (
                        <p className="text-red-600 mt-0.5">{ev.failure_reason}</p>
                      )}
                    </div>
                    <StatusBadge status={ev.outcome} />
                  </div>
                ))}
              </div>
            )}
          </div>

          <div
            className="lg:col-span-4 rounded-xl border p-5 space-y-3"
            style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
          >
            <h2 className="text-base font-semibold">Enrolled Admin Passkeys ({passkeys.length})</h2>
            {passkeys.length === 0 ? (
              <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                No WebAuthn passkeys registered yet.
              </p>
            ) : (
              passkeys.map((pk) => (
                <div key={pk.credential_id} className="rounded-lg border p-3 text-xs space-y-1" style={{ borderColor: 'var(--border-subtle)' }}>
                  <div className="flex items-center justify-between">
                    <span className="font-semibold">{pk.friendly_name}</span>
                    <StatusBadge status={pk.revoked_at ? 'Revoked' : 'Active'} />
                  </div>
                  <p className="font-mono-code text-[10px]" style={{ color: 'var(--text-muted)' }}>
                    UID: {pk.user_id}
                  </p>
                </div>
              ))
            )}
          </div>
        </div>
      ) : tab === 'sessions' ? (
        <DataTable
          columns={sessionCols}
          rows={sessions}
          rowKey={(r) => r.session_id}
        />
      ) : tab === 'incidents' ? (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <form
            onSubmit={handleCreateIncident}
            className="lg:col-span-4 rounded-xl border p-5 space-y-3 h-fit"
            style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
          >
            <h2 className="text-base font-semibold">Log Security Incident</h2>
            <input
              type="text"
              required
              minLength={5}
              value={incTitle}
              onChange={(e) => setIncTitle(e.target.value)}
              placeholder="Incident Title"
              className="w-full rounded-lg border px-3 py-2 text-sm"
              style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
            />
            <select
              value={incSeverity}
              onChange={(e) =>
                setIncSeverity(e.target.value as 'Low' | 'Medium' | 'High' | 'Critical')
              }
              className="w-full rounded-lg border px-3 py-2 text-sm"
              style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
            >
              <option value="Low">Low</option>
              <option value="Medium">Medium</option>
              <option value="High">High</option>
              <option value="Critical">Critical</option>
            </select>
            <textarea
              rows={3}
              required
              minLength={10}
              value={incSummary}
              onChange={(e) => setIncSummary(e.target.value)}
              placeholder="Containment observations and affected scope..."
              className="w-full rounded-lg border p-2.5 text-sm"
              style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
            />
            <button
              type="submit"
              className="w-full rounded-lg px-4 py-2 text-xs font-semibold text-white"
              style={{ backgroundColor: '#DC2626' }}
            >
              Open Incident Ticket
            </button>
          </form>

          <div className="lg:col-span-8 space-y-3">
            {incidents.length === 0 ? (
              <div
                className="rounded-xl border p-6 text-xs"
                style={{
                  backgroundColor: 'var(--bg-surface)',
                  borderColor: 'var(--border-subtle)',
                  color: 'var(--text-muted)',
                }}
              >
                No security incidents logged. Use the form on the left to open an audited ticket.
              </div>
            ) : (
              incidents.map((inc) => (
                <div
                  key={inc.incident_id}
                  className="rounded-xl border p-4 space-y-2.5"
                  style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
                >
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <p className="font-semibold text-sm">{inc.title}</p>
                    <div className="flex gap-1.5">
                      <StatusBadge status={inc.severity} />
                      <StatusBadge status={inc.status} />
                    </div>
                  </div>
                  <p className="text-xs leading-relaxed" style={{ color: 'var(--text-secondary)' }}>
                    {inc.summary}
                  </p>
                  {inc.status !== 'Closed' && (
                    <div
                      className="pt-2 border-t flex flex-wrap items-center justify-between gap-2 text-xs"
                      style={{ borderColor: 'var(--border-subtle)' }}
                    >
                      <span style={{ color: 'var(--text-muted)' }}>
                        Transition state (Step-Up MFA):
                      </span>
                      <div className="flex flex-wrap gap-1.5">
                        {(['Investigating', 'Contained', 'Resolved', 'Closed'] as const)
                          .filter((s) => s !== inc.status)
                          .map((nextStatus) => (
                            <button
                              key={nextStatus}
                              type="button"
                              disabled={updatingIncidentId === inc.incident_id}
                              onClick={() => void handleUpdateIncidentStatus(inc.incident_id, nextStatus)}
                              className="rounded-md border px-2.5 py-1 text-[11px] font-semibold hover:bg-slate-100 dark:hover:bg-slate-800 disabled:opacity-50"
                              style={{ borderColor: 'var(--border-subtle)' }}
                            >
                              {nextStatus}
                            </button>
                          ))}
                      </div>
                    </div>
                  )}
                </div>
              ))
            )}
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div
            className="rounded-xl border p-5 space-y-3"
            style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
          >
            <h2 className="text-base font-semibold">Restore & Backup Verification Log</h2>
            {backups.length === 0 ? (
              <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                No backup restore drills recorded yet.
              </p>
            ) : (
              backups.map((b) => (
                <div key={b.verification_id} className="flex items-center justify-between text-xs py-2 border-b" style={{ borderColor: 'var(--border-subtle)' }}>
                  <div>
                    <p className="font-semibold">{b.environment} · {b.restore_target}</p>
                    <p style={{ color: 'var(--text-muted)' }}>{formatDateTime(b.verified_at)}</p>
                  </div>
                  <StatusBadge status={b.status} />
                </div>
              ))
            )}
          </div>

          <div
            className="rounded-xl border p-5 space-y-3"
            style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
          >
            <h2 className="text-base font-semibold">Governance System Settings</h2>
            {settings.map((s) => (
              <div key={s.setting_key} className="text-xs py-2 border-b space-y-1" style={{ borderColor: 'var(--border-subtle)' }}>
                <p className="font-mono-code font-semibold">{s.setting_key}</p>
                <p style={{ color: 'var(--text-muted)' }}>{s.description || 'System parameter'}</p>
                <pre className="rounded bg-slate-900 text-slate-100 p-2 overflow-x-auto">
                  {JSON.stringify(s.setting_value, null, 2)}
                </pre>
              </div>
            ))}
          </div>
        </div>
      )}

      <SideDrawer
        open={Boolean(selectedLog)}
        title={selectedLog?.action || 'Audit Entry'}
        subtitle={selectedLog ? formatDateTime(selectedLog.created_at) : undefined}
        onClose={() => setSelectedLog(null)}
      >
        {selectedLog && (
          <pre className="rounded-xl bg-slate-950 text-slate-100 p-4 text-xs font-mono-code overflow-x-auto">
            {JSON.stringify(selectedLog, null, 2)}
          </pre>
        )}
      </SideDrawer>
    </div>
  );
}

