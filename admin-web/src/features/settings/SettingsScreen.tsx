'use client';

import { useCallback, useEffect, useState } from 'react';
import { startRegistration } from '@simplewebauthn/browser';
import type { PublicKeyCredentialCreationOptionsJSON } from '@simplewebauthn/server';
import {
  Copy,
  Fingerprint,
  KeyRound,
  ShieldCheck,
  Trash2,
} from 'lucide-react';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatDateTime } from '@/lib/formatters';
import type { AdminPasskeyDto, AdminSessionDto } from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';

export default function SettingsPage() {
  const { session, openStepUp } = useAdminSession();
  const [sessions, setSessions] = useState<AdminSessionDto[]>([]);
  const [passkeys, setPasskeys] = useState<AdminPasskeyDto[]>([]);
  const [recoveryInfo, setRecoveryInfo] = useState<{
    remainingCount: number;
    generatedAt: string | null;
  }>({ remainingCount: 0, generatedAt: null });
  const [generatedCodes, setGeneratedCodes] = useState<string[] | null>(null);

  const [friendlyName, setFriendlyName] = useState('');
  const [passkeyBusy, setPasskeyBusy] = useState(false);
  const [recoveryBusy, setRecoveryBusy] = useState(false);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadSettingsData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [sRes, pRes, rRes] = await Promise.all([
        apiFetch<{ sessions: AdminSessionDto[] }>('/api/admin/auth/sessions'),
        apiFetch<{ credentials: AdminPasskeyDto[] }>('/api/admin/auth/passkey/credentials'),
        apiFetch<{ remainingCount: number; generatedAt: string | null }>(
          '/api/admin/auth/recovery'
        ),
      ]);
      setSessions(sRes.sessions);
      setPasskeys(pRes.credentials);
      setRecoveryInfo(rRes);
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed loading security settings.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadSettingsData();
  }, [loadSettingsData]);

  async function handleEnrollPasskey(e: React.FormEvent) {
    e.preventDefault();
    setPasskeyBusy(true);
    setError(null);
    try {
      const start = await apiFetch<{
        challengeId: string;
        options: PublicKeyCredentialCreationOptionsJSON;
      }>('/api/admin/auth/passkey/register-options', {
        method: 'POST',
      });

      const attestation = await startRegistration({ optionsJSON: start.options });

      await apiFetch('/api/admin/auth/passkey/register-verify', {
        method: 'POST',
        body: JSON.stringify({
          challengeId: start.challengeId,
          friendlyName: friendlyName.trim() || 'Primary Device Biometric Passkey',
          response: attestation,
        }),
      });

      setFriendlyName('');
      await loadSettingsData();
    } catch (err) {
      setError(
        err instanceof AdminApiError
          ? err.message
          : err instanceof Error
            ? err.message
            : 'Passkey registration cancelled or failed.'
      );
    } finally {
      setPasskeyBusy(false);
    }
  }

  async function handleRevokePasskey(credentialId: string) {
    setError(null);
    try {
      await apiFetch(`/api/admin/auth/passkey/credentials/${encodeURIComponent(credentialId)}`, {
        method: 'DELETE',
      });
      await loadSettingsData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed revoking passkey.');
    }
  }

  async function handleGenerateRecoveryCodes() {
    setRecoveryBusy(true);
    setError(null);
    try {
      const res = await apiFetch<{ codes: string[]; generatedAt: string }>(
        '/api/admin/auth/recovery',
        { method: 'POST' }
      );
      setGeneratedCodes(res.codes);
      await loadSettingsData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed generating recovery codes.');
    } finally {
      setRecoveryBusy(false);
    }
  }

  async function handleRevokeOwnSession(sessionId: string) {
    setError(null);
    try {
      await apiFetch('/api/admin/auth/sessions', {
        method: 'DELETE',
        body: JSON.stringify({ sessionId }),
      });
      await loadSettingsData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Failed revoking session.');
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">My Security, Passkeys &amp; Profile</h1>
        <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
          Enroll WebAuthn biometric passkeys (public-key cryptography only), manage recovery codes, and inspect active sessions.
        </p>
      </div>

      {/* Identity Overview */}
      <section
        className="rounded-xl border p-5 space-y-3"
        style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
      >
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-base font-semibold">{session.fullName}</h2>
              {session.isPrimarySuperAdmin && (
                <span className="rounded bg-indigo-100 dark:bg-indigo-950/70 px-2 py-0.5 text-[10px] font-bold text-indigo-800 dark:text-indigo-200">
                  PRIMARY SUPER ADMIN
                </span>
              )}
            </div>
            <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
              {session.email} &middot; {session.primaryRole} &middot; Surface: {session.portalSurface} &middot; Permission v
              {session.permissionVersion}
            </p>
          </div>
          <button
            type="button"
            onClick={openStepUp}
            className="inline-flex items-center gap-1.5 rounded-lg px-4 py-2 text-xs font-semibold text-white"
            style={{ backgroundColor: '#003399' }}
          >
            <ShieldCheck className="h-4 w-4" />
            Refresh Step-Up MFA
          </button>
        </div>

        <div className="pt-2">
          <p className="text-xs uppercase font-semibold mb-1.5" style={{ color: 'var(--text-muted)' }}>
            Effective Permissions ({session.effectivePermissions.length})
          </p>
          <div className="flex flex-wrap gap-1.5">
            {session.effectivePermissions.map((p) => (
              <span
                key={p}
                className="rounded-md border px-2 py-0.5 text-[11px] font-mono-code"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                {p}
              </span>
            ))}
          </div>
        </div>
      </section>

      {error && <ErrorPanel message={error} onRetry={() => void loadSettingsData()} />}

      {/* WebAuthn / Biometric Passkey Manager */}
      <section
        className="rounded-xl border p-5 space-y-4"
        style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
      >
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h2 className="text-base font-semibold flex items-center gap-2">
              <Fingerprint className="h-4 w-4 text-blue-600" />
              WebAuthn / FIDO2 Biometric Passkeys
            </h2>
            <p className="text-xs mt-0.5" style={{ color: 'var(--text-muted)' }}>
              Uses device hardware biometrics (Touch ID, Windows Hello, Face ID). Zero raw biometric data leaves your device.
            </p>
          </div>
        </div>

        <form onSubmit={handleEnrollPasskey} className="flex flex-wrap gap-2">
          <input
            type="text"
            value={friendlyName}
            onChange={(e) => setFriendlyName(e.target.value)}
            placeholder="Passkey label (e.g. MacBook Touch ID / Windows Hello)"
            className="flex-1 min-w-[240px] rounded-lg border px-3 py-2 text-sm"
            style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
          />
          <button
            type="submit"
            disabled={passkeyBusy}
            className="inline-flex items-center gap-1.5 rounded-lg px-4 py-2 text-xs font-semibold text-white"
            style={{ backgroundColor: '#003399' }}
          >
            <Fingerprint className="h-4 w-4" />
            {passkeyBusy ? 'Waiting for Device Prompt...' : 'Enroll New Passkey'}
          </button>
        </form>

        <div className="space-y-2">
          {passkeys.length === 0 ? (
            <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
              No Passkeys enrolled yet on this device or account.
            </p>
          ) : (
            passkeys.map((pk) => (
              <div
                key={pk.credential_id}
                className="flex flex-wrap items-center justify-between gap-3 rounded-lg border px-3.5 py-2.5 text-xs"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                <div>
                  <p className="font-semibold">{pk.friendly_name}</p>
                  <p style={{ color: 'var(--text-muted)' }}>
                    {pk.device_type} &middot; Created {formatDateTime(pk.created_at)}
                    {pk.last_used_at ? ` · Last used ${formatDateTime(pk.last_used_at)}` : ''}
                  </p>
                </div>
                {pk.revoked_at ? (
                  <StatusBadge status="Revoked" />
                ) : (
                  <button
                    type="button"
                    onClick={() => void handleRevokePasskey(pk.credential_id)}
                    className="inline-flex items-center gap-1 rounded bg-red-600 px-2.5 py-1 text-[11px] font-semibold text-white"
                  >
                    <Trash2 className="h-3 w-3" />
                    Revoke
                  </button>
                )}
              </div>
            ))
          )}
        </div>
      </section>

      {/* Single-Use Emergency Recovery Codes */}
      <section
        className="rounded-xl border p-5 space-y-3"
        style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
      >
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h2 className="text-base font-semibold flex items-center gap-2">
              <KeyRound className="h-4 w-4 text-amber-600" />
              Emergency Single-Use Recovery Codes
            </h2>
            <p className="text-xs mt-0.5" style={{ color: 'var(--text-muted)' }}>
              Remaining unused codes: <strong>{recoveryInfo.remainingCount}</strong>
              {recoveryInfo.generatedAt
                ? ` · Last generated ${formatDateTime(recoveryInfo.generatedAt)}`
                : ''}
            </p>
          </div>
          <button
            type="button"
            disabled={recoveryBusy}
            onClick={() => void handleGenerateRecoveryCodes()}
            className="rounded-lg border px-3.5 py-2 text-xs font-semibold hover:bg-slate-50 dark:hover:bg-slate-800"
            style={{ borderColor: 'var(--border-subtle)' }}
          >
            {recoveryBusy ? 'Generating...' : 'Regenerate 8 Recovery Codes'}
          </button>
        </div>

        {generatedCodes && (
          <div className="rounded-xl border border-amber-300 dark:border-amber-800/70 bg-amber-50 dark:bg-amber-950/40 p-4 text-xs text-amber-950 dark:text-amber-100 space-y-2">
            <div className="flex items-center justify-between gap-2">
              <p className="font-bold">Store these one-time codes offline. They will never be shown again:</p>
              <button
                type="button"
                onClick={() => void navigator.clipboard.writeText(generatedCodes.join('\n'))}
                className="inline-flex items-center gap-1 rounded bg-amber-800 px-2.5 py-1 text-white font-semibold shrink-0"
              >
                <Copy className="h-3 w-3" />
                Copy All
              </button>
            </div>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 font-mono-code pt-1">
              {generatedCodes.map((c) => (
                <div
                  key={c}
                  className="rounded bg-white dark:bg-slate-900 px-2.5 py-1.5 border border-amber-200 dark:border-amber-800/70 text-center font-semibold"
                >
                  {c}
                </div>
              ))}
            </div>
          </div>
        )}
      </section>

      {/* Active Sessions */}
      <section className="space-y-3">
        <h2 className="text-base font-semibold">My Active Admin Sessions</h2>
        {loading ? (
          <LoadingPanel />
        ) : (
          <div className="space-y-2">
            {sessions.map((s) => (
              <div
                key={s.session_id}
                className="rounded-xl border p-4 flex flex-wrap items-center justify-between gap-3"
                style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
              >
                <div>
                  <div className="flex items-center gap-2">
                    <p className="text-sm font-semibold">{s.device_label || 'Admin Browser Session'}</p>
                    {s.session_id === session.sessionId && (
                      <StatusBadge status="Current Session" variant="info" />
                    )}
                    <StatusBadge status={s.revoked_at ? 'Revoked' : 'Active'} />
                  </div>
                  <p className="text-xs mt-0.5" style={{ color: 'var(--text-muted)' }}>
                    IP: {s.ip_address || 'Unknown'} &middot; Created {formatDateTime(s.created_at)} &middot; Expires {formatDateTime(s.expires_at)}
                  </p>
                </div>

                {!s.revoked_at && (
                  <button
                    type="button"
                    onClick={() => void handleRevokeOwnSession(s.session_id)}
                    className="rounded-lg bg-red-600 px-3 py-1.5 text-xs font-semibold text-white"
                  >
                    Revoke Session
                  </button>
                )}
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
