'use client';

import { useState } from 'react';
import Image from 'next/image';
import { startAuthentication } from '@simplewebauthn/browser';
import type { PublicKeyCredentialRequestOptionsJSON } from '@simplewebauthn/server';
import type { MultiFactorResolver } from 'firebase/auth';
import { Fingerprint, ShieldCheck, X } from 'lucide-react';
import {
  completeTotpMfaChallenge,
  isFirebaseWebConfigured,
  signInAdminWithEmail,
  signInAdminWithGoogle,
} from '@/lib/firebase-client';
import { AdminApiError, apiFetch } from '@/lib/api-client';

export function StepUpModal({
  open,
  email,
  onClose,
  onVerified,
}: {
  open: boolean;
  email: string;
  onClose: () => void;
  onVerified: (stepUpExpiresAt: string) => void;
}) {
  const [password, setPassword] = useState('');
  const [totpCode, setTotpCode] = useState('');
  const [mfaResolver, setMfaResolver] = useState<MultiFactorResolver | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!open) return null;

  async function submitStepUpToken(idToken: string) {
    const res = await apiFetch<{ stepUpExpiresAt: string }>(
      '/api/admin/auth/step-up',
      {
        method: 'POST',
        body: JSON.stringify({ idToken }),
      }
    );
    setPassword('');
    setTotpCode('');
    setMfaResolver(null);
    onVerified(res.stepUpExpiresAt);
  }

  async function handlePasswordStep(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const res = await signInAdminWithEmail(email, password);
      if (res.status === 'mfa_required' && res.mfaResolver) {
        setMfaResolver(res.mfaResolver);
        return;
      }
      if (!res.idToken) throw new Error('Missing Firebase ID token.');
      await submitStepUpToken(res.idToken);
    } catch (err: unknown) {
      if (err instanceof AdminApiError) {
        setError(`${err.message} (${err.code})`);
      } else if (err instanceof Error) {
        setError(err.message);
      } else {
        setError('Step-up verification failed.');
      }
    } finally {
      setLoading(false);
    }
  }

  async function handleGoogleStep() {
    setError(null);
    setLoading(true);
    try {
      const res = await signInAdminWithGoogle(email);
      if (res.status === 'mfa_required' && res.mfaResolver) {
        setMfaResolver(res.mfaResolver);
        return;
      }
      if (!res.idToken) throw new Error('Missing Firebase ID token.');
      await submitStepUpToken(res.idToken);
    } catch (err: unknown) {
      if (err instanceof AdminApiError) {
        setError(`${err.message} (${err.code})`);
      } else if (err instanceof Error) {
        setError(err.message);
      } else {
        setError('Google step-up verification failed.');
      }
    } finally {
      setLoading(false);
    }
  }

  async function handlePasskeyStep() {
    setError(null);
    setLoading(true);
    try {
      const startRes = await apiFetch<{
        challengeId: string;
        options: PublicKeyCredentialRequestOptionsJSON;
      }>('/api/admin/auth/passkey/auth-options', {
        method: 'POST',
        body: JSON.stringify({ mode: 'step_up' }),
      });
      const assertion = await startAuthentication({ optionsJSON: startRes.options });
      const verifyRes = await apiFetch<{ stepUpExpiresAt: string }>(
        '/api/admin/auth/passkey/auth-verify',
        {
          method: 'POST',
          body: JSON.stringify({
            challengeId: startRes.challengeId,
            mode: 'step_up',
            response: assertion,
          }),
        }
      );
      onVerified(verifyRes.stepUpExpiresAt);
    } catch (err: unknown) {
      if (err instanceof AdminApiError) {
        setError(`${err.message} (${err.code})`);
      } else if (err instanceof Error) {
        setError(err.message);
      } else {
        setError('Passkey step-up failed.');
      }
    } finally {
      setLoading(false);
    }
  }

  async function handleMfaStep(e: React.FormEvent) {
    e.preventDefault();
    if (!mfaResolver) return;
    setError(null);
    setLoading(true);
    try {
      const idToken = await completeTotpMfaChallenge(mfaResolver, totpCode);
      await submitStepUpToken(idToken);
    } catch (err: unknown) {
      if (err instanceof AdminApiError) {
        setError(`${err.message} (${err.code})`);
      } else if (err instanceof Error) {
        setError(err.message);
      } else {
        setError('Invalid MFA verification code.');
      }
    } finally {
      setLoading(false);
    }
  }

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/65"
      role="dialog"
      aria-modal="true"
      aria-label="Step-Up MFA Verification"
    >
      <div
        className="w-full max-w-md rounded-xl border p-6 shadow-2xl"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div className="flex items-start justify-between gap-3 mb-4">
          <div className="flex items-center gap-2.5">
            <div className="h-9 w-9 rounded-lg bg-blue-50 dark:bg-blue-950/60 text-blue-700 dark:text-sky-400 flex items-center justify-center">
              <ShieldCheck className="h-5 w-5" />
            </div>
            <div>
              <h3 className="text-base font-semibold" style={{ color: 'var(--text-primary)' }}>
                Step-Up Verification Required
              </h3>
              <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                Re-verify <span className="font-mono-code">{email}</span> for critical actions
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="Close step-up modal"
            className="p-1 rounded hover:bg-slate-100 dark:hover:bg-slate-800"
          >
            <X className="h-4 w-4" style={{ color: 'var(--text-muted)' }} />
          </button>
        </div>

        {error && (
          <div className="mb-4 rounded-lg border border-red-300 dark:border-red-800/70 bg-red-50 dark:bg-red-950/50 px-3 py-2 text-xs text-red-800 dark:text-red-200">
            {error}
          </div>
        )}

        {!isFirebaseWebConfigured() ? (
          <p className="text-xs leading-relaxed" style={{ color: 'var(--text-secondary)' }}>
            Firebase Web SDK variables are not configured on this host, so interactive client
            re-authentication cannot run until Firebase Web keys are set.
          </p>
        ) : !mfaResolver ? (
          <form onSubmit={handlePasswordStep} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider mb-1">
                Confirm Password
              </label>
              <input
                type="password"
                required
                autoFocus
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full rounded-lg border px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500"
                style={{
                  backgroundColor: 'var(--bg-canvas)',
                  borderColor: 'var(--border-subtle)',
                }}
              />
            </div>
            <div className="flex flex-wrap items-center justify-between gap-2 pt-1">
              <div className="flex flex-wrap gap-2">
                <button
                  type="button"
                  onClick={handlePasskeyStep}
                  disabled={loading}
                  className="inline-flex items-center gap-1.5 rounded-lg border px-3 py-2 text-xs font-semibold hover:bg-slate-50 dark:hover:bg-slate-800/50 disabled:opacity-50"
                  style={{ borderColor: 'var(--border-subtle)' }}
                >
                  <Fingerprint className="h-3.5 w-3.5 text-blue-600" />
                  <span>Passkey</span>
                </button>
                <button
                  type="button"
                  onClick={handleGoogleStep}
                  disabled={loading}
                  className="inline-flex items-center gap-1.5 rounded-lg border px-3 py-2 text-xs font-semibold hover:bg-slate-50 dark:hover:bg-slate-800/50 disabled:opacity-50"
                  style={{ borderColor: 'var(--border-subtle)' }}
                >
                  <Image
                    src="/images/google_logo.png"
                    alt=""
                    width={14}
                    height={14}
                    className="object-contain"
                  />
                  <span>Google</span>
                </button>
              </div>
              <div className="flex justify-end gap-2">
                <button
                  type="button"
                  onClick={onClose}
                  className="rounded-lg border px-4 py-2 text-xs font-medium"
                  style={{ borderColor: 'var(--border-subtle)' }}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={loading}
                  className="rounded-lg px-4 py-2 text-xs font-semibold text-white disabled:opacity-50"
                  style={{ backgroundColor: '#003399' }}
                >
                  {loading ? 'Checking...' : 'Verify Identity'}
                </button>
              </div>
            </div>
          </form>
        ) : (
          <form onSubmit={handleMfaStep} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider mb-1">
                Authenticator 6-Digit Code
              </label>
              <input
                type="text"
                inputMode="numeric"
                pattern="[0-9]{6}"
                required
                autoFocus
                value={totpCode}
                onChange={(e) => setTotpCode(e.target.value)}
                className="w-full rounded-lg border px-3 py-2 text-center font-mono-code text-base tracking-widest outline-none focus:ring-2 focus:ring-blue-500"
                style={{
                  backgroundColor: 'var(--bg-canvas)',
                  borderColor: 'var(--border-subtle)',
                }}
              />
            </div>
            <div className="flex justify-end gap-2">
              <button
                type="button"
                onClick={() => setMfaResolver(null)}
                className="rounded-lg border px-4 py-2 text-xs font-medium"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                Back
              </button>
              <button
                type="submit"
                disabled={loading}
                className="rounded-lg px-4 py-2 text-xs font-semibold text-white disabled:opacity-50"
                style={{ backgroundColor: '#003399' }}
              >
                {loading ? 'Confirming MFA...' : 'Complete Step-Up'}
              </button>
            </div>
          </form>
        )}
      </div>
    </div>
  );
}

