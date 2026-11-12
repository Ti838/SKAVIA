'use client';

import { Suspense, useEffect, useState } from 'react';
import Image from 'next/image';
import { useRouter, useSearchParams } from 'next/navigation';
import { startAuthentication } from '@simplewebauthn/browser';
import type { PublicKeyCredentialRequestOptionsJSON } from '@simplewebauthn/server';
import type { MultiFactorResolver } from 'firebase/auth';
import {
  Fingerprint,
  KeyRound,
  Lock,
  ShieldAlert,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { MfaChallengeForm } from '@/features/auth/MfaChallengeForm';
import {
  completeTotpMfaChallenge,
  isFirebaseWebConfigured,
  signInAdminWithEmail,
  signInAdminWithGoogle,
  type FirebaseLoginResult,
} from '@/lib/firebase-client';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import type { AdminSessionContext } from '@/lib/types';

type SurfaceView = 'superadmin' | 'admin';

function LoginPortalContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const firebaseConfigured = isFirebaseWebConfigured();

  const [surfaceView, setSurfaceView] = useState<SurfaceView>('admin');
  const [isSingleHost, setIsSingleHost] = useState(false);

  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [totpCode, setTotpCode] = useState('');
  const [recoveryMode, setRecoveryMode] = useState(false);
  const [recoveryCode, setRecoveryCode] = useState('');
  const [mfaResolver, setMfaResolver] = useState<MultiFactorResolver | null>(null);
  const [mfaHintLabel, setMfaHintLabel] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    const host = window.location.hostname.toLowerCase();
    const qPortal = searchParams.get('portal')?.toLowerCase();
    const explicitSuperHost = (process.env.NEXT_PUBLIC_SUPERADMIN_HOST || '').trim().toLowerCase();
    const explicitAdminHost = (process.env.NEXT_PUBLIC_ADMIN_HOST || '').trim().toLowerCase();
    const isDedicatedSurface =
      host.startsWith('superadmin.') ||
      host.startsWith('admin.') ||
      (Boolean(explicitSuperHost) && host === explicitSuperHost) ||
      (Boolean(explicitAdminHost) && host === explicitAdminHost);
    setIsSingleHost(!isDedicatedSurface);

    if (host.startsWith('superadmin.') || (Boolean(explicitSuperHost) && host === explicitSuperHost) || qPortal === 'superadmin') {
      setSurfaceView('superadmin');
    } else {
      setSurfaceView('admin');
    }
  }, [searchParams]);

  async function exchangeTokenAndEnter(idToken: string) {
    const res = await apiFetch<{ session: AdminSessionContext }>(
      '/api/admin/auth/session',
      {
        method: 'POST',
        body: JSON.stringify({
          idToken,
          ...(isSingleHost ? {} : { surface: surfaceView }),
          deviceLabel: navigator.userAgent.slice(0, 100),
        }),
      }
    );
    if (res.session) {
      router.replace('/dashboard');
      router.refresh();
    }
  }

  function formatAuthError(err: unknown, fallback: string): string {
    if (err instanceof AdminApiError) return `${err.message} (${err.code})`;
    if (err instanceof Error) return err.message;
    return fallback;
  }

  async function resolveLoginEmail(rawIdentifier: string): Promise<string> {
    const trimmed = rawIdentifier.trim();
    if (trimmed.includes('@')) return trimmed.toLowerCase();
    const res = await apiFetch<{ email: string }>('/api/admin/auth/resolve-identifier', {
      method: 'POST',
      body: JSON.stringify({
        identifier: trimmed,
        surface: surfaceView,
      }),
    });
    return res.email;
  }

  async function finalizeFirebaseLogin(loginRes: FirebaseLoginResult) {
    if (loginRes.status === 'mfa_required' && loginRes.mfaResolver) {
      if (recoveryMode && recoveryCode.trim()) {
        throw new Error('Sign in with primary password/Google without TOTP to consume recovery code.');
      }
      setMfaResolver(loginRes.mfaResolver);
      setMfaHintLabel(loginRes.hintLabel || 'Authenticator App');
      return;
    }
    if (!loginRes.idToken) {
      throw new Error('Authentication did not return an ID token.');
    }

    if (recoveryMode && recoveryCode.trim()) {
      const res = await apiFetch<{ session: AdminSessionContext }>(
        '/api/admin/auth/recovery',
        {
          method: 'PUT',
          body: JSON.stringify({
            idToken: loginRes.idToken,
            recoveryCode: recoveryCode.trim(),
            ...(isSingleHost ? {} : { surface: surfaceView }),
            mode: 'login',
            deviceLabel: navigator.userAgent.slice(0, 100),
          }),
        }
      );
      if (res.session) {
        router.replace('/dashboard');
        router.refresh();
      }
      return;
    }

    await exchangeTokenAndEnter(loginRes.idToken);
  }

  async function handlePrimarySubmit(e: React.FormEvent) {
    e.preventDefault();
    setErrorMessage(null);
    setLoading(true);
    try {
      const resolvedEmail = await resolveLoginEmail(identifier);
      const loginRes = await signInAdminWithEmail(resolvedEmail, password);
      await finalizeFirebaseLogin(loginRes);
    } catch (err: unknown) {
      setErrorMessage(formatAuthError(err, 'Sign-in failed.'));
    } finally {
      setLoading(false);
    }
  }

  async function handleGoogleSignIn() {
    setErrorMessage(null);
    setLoading(true);
    try {
      const hintEmail = identifier.includes('@') ? identifier.trim() : undefined;
      const loginRes = await signInAdminWithGoogle(hintEmail);
      await finalizeFirebaseLogin(loginRes);
    } catch (err: unknown) {
      setErrorMessage(formatAuthError(err, 'Google sign-in failed.'));
    } finally {
      setLoading(false);
    }
  }

  async function handlePasskeySignIn() {
    setErrorMessage(null);
    setLoading(true);
    try {
      const startRes = await apiFetch<{
        challengeId: string;
        options: PublicKeyCredentialRequestOptionsJSON;
      }>('/api/admin/auth/passkey/auth-options', {
        method: 'POST',
        body: JSON.stringify({ mode: 'login' }),
      });

      const assertion = await startAuthentication({ optionsJSON: startRes.options });

      const verifyRes = await apiFetch<{ session: AdminSessionContext }>(
        '/api/admin/auth/passkey/auth-verify',
        {
          method: 'POST',
          body: JSON.stringify({
            challengeId: startRes.challengeId,
            mode: 'login',
            ...(isSingleHost ? {} : { surface: surfaceView }),
            deviceLabel: `Passkey (${navigator.platform || 'Device'})`,
            response: assertion,
          }),
        }
      );

      if (verifyRes.session) {
        router.replace('/dashboard');
        router.refresh();
      }
    } catch (err: unknown) {
      setErrorMessage(formatAuthError(err, 'Passkey / biometric sign-in failed.'));
    } finally {
      setLoading(false);
    }
  }

  async function handleMfaSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!mfaResolver) return;
    setErrorMessage(null);
    setLoading(true);
    try {
      const idToken = await completeTotpMfaChallenge(mfaResolver, totpCode);
      await exchangeTokenAndEnter(idToken);
    } catch (err: unknown) {
      setErrorMessage(formatAuthError(err, 'Invalid MFA code.'));
    } finally {
      setLoading(false);
    }
  }

  const isSuperAdminView = surfaceView === 'superadmin';

  return (
    <div
      className="min-h-screen flex items-center justify-center p-6"
      style={{
        background: isSuperAdminView
          ? 'linear-gradient(135deg, #090D16 0%, #0F172A 50%, #1E1B4B 100%)'
          : 'linear-gradient(135deg, #003399 0%, #0B1938 55%, #0F172A 100%)',
      }}
    >
      <div
        className="w-full max-w-md rounded-2xl border p-8 shadow-2xl"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        {isSingleHost && (
          <div className="mb-5 flex items-center gap-1 rounded-xl border p-1 text-xs" style={{ borderColor: 'var(--border-subtle)' }}>
            <button
              type="button"
              onClick={() => setSurfaceView('superadmin')}
              className={`flex-1 rounded-lg py-1.5 font-semibold transition ${
                isSuperAdminView ? 'bg-slate-900 text-white' : 'text-slate-500 hover:text-slate-900'
              }`}
            >
              Super Admin Portal
            </button>
            <button
              type="button"
              onClick={() => setSurfaceView('admin')}
              className={`flex-1 rounded-lg py-1.5 font-semibold transition ${
                !isSuperAdminView ? 'bg-[#003399] text-white' : 'text-slate-500 hover:text-slate-900'
              }`}
            >
              Internal Admin Portal
            </button>
          </div>
        )}

        <div className="flex items-center gap-3 mb-5">
          <div className="h-12 w-12 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 flex items-center justify-center p-1.5 shadow-sm shrink-0">
            <SkaviaBrandMark variant="emblem" size={38} priority />
          </div>
          <div>
            <span
              className={`inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-widest mb-1 ${
                isSuperAdminView
                  ? 'bg-indigo-100 text-indigo-800 dark:bg-indigo-950/60 dark:text-indigo-200'
                  : 'bg-blue-100 text-blue-800 dark:bg-blue-950/60 dark:text-blue-200'
              }`}
            >
              {isSuperAdminView ? 'Primary Super Admin Only' : 'Invitation-Only Admin Portal'}
            </span>
            <h1 className="text-xl font-bold tracking-tight" style={{ color: 'var(--text-primary)' }}>
              {isSuperAdminView ? 'SKAVIA Super Admin' : 'SKAVIA Admin Portal'}
            </h1>
            <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
              {isSuperAdminView
                ? 'Executive Root Governance · MFA & Passkey Enforced'
                : 'Company Admin & Branch Manager Operations'}
            </p>
          </div>
        </div>

        {!firebaseConfigured && (
          <div
            role="alert"
            className="mb-5 rounded-xl border border-amber-300 dark:border-amber-800 bg-amber-50 dark:bg-amber-950/40 p-4 text-xs text-amber-950 dark:text-amber-200"
          >
            <div className="flex items-center gap-2 font-semibold mb-1">
              <ShieldAlert className="h-4 w-4 text-amber-700 dark:text-amber-300" />
              External Firebase Web Config Missing
            </div>
            <p className="leading-relaxed">
              Set <code className="font-mono-code">NEXT_PUBLIC_FIREBASE_API_KEY</code>,{' '}
              <code className="font-mono-code">NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN</code>, and{' '}
              <code className="font-mono-code">NEXT_PUBLIC_FIREBASE_APP_ID</code> in{' '}
              <code className="font-mono-code">admin-web/.env.local</code>, alongside server{' '}
              <code className="font-mono-code">SUPABASE_SERVICE_ROLE_KEY</code> and{' '}
              <code className="font-mono-code">ADMIN_SESSION_SECRET</code>.
            </p>
          </div>
        )}

        {errorMessage && (
          <div
            role="alert"
            className="mb-5 rounded-xl border border-red-300 dark:border-red-800 bg-red-50 dark:bg-red-950/40 px-4 py-3 text-sm text-red-800 dark:text-red-200"
          >
            {errorMessage}
          </div>
        )}

        {!mfaResolver ? (
          <form onSubmit={handlePrimarySubmit} className="space-y-4">
            <div>
              <label
                htmlFor="admin-identifier"
                className="block text-xs font-semibold uppercase tracking-wider mb-1.5"
                style={{ color: 'var(--text-secondary)' }}
              >
                {isSuperAdminView ? 'Super Admin Username or Email' : 'Invited Admin Email'}
              </label>
              <input
                id="admin-identifier"
                type={isSuperAdminView ? 'text' : 'email'}
                required
                autoComplete="username"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                placeholder={isSuperAdminView ? 'tariq_superadmin or admin@skavia.com' : 'admin@skavia.com'}
                className="w-full rounded-lg border px-3.5 py-2.5 text-sm outline-none focus:ring-2 focus:ring-blue-500"
                style={{
                  backgroundColor: 'var(--bg-canvas)',
                  borderColor: 'var(--border-subtle)',
                  color: 'var(--text-primary)',
                }}
              />
            </div>

            <div>
              <label
                htmlFor="admin-password"
                className="block text-xs font-semibold uppercase tracking-wider mb-1.5"
                style={{ color: 'var(--text-secondary)' }}
              >
                Password
              </label>
              <input
                id="admin-password"
                type="password"
                required
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter administrator password"
                className="w-full rounded-lg border px-3.5 py-2.5 text-sm outline-none focus:ring-2 focus:ring-blue-500"
                style={{
                  backgroundColor: 'var(--bg-canvas)',
                  borderColor: 'var(--border-subtle)',
                  color: 'var(--text-primary)',
                }}
              />
            </div>

            {recoveryMode && (
              <div>
                <label
                  htmlFor="recovery-code"
                  className="block text-xs font-semibold uppercase tracking-wider mb-1.5"
                  style={{ color: 'var(--text-secondary)' }}
                >
                  Single-Use Recovery Code
                </label>
                <input
                  id="recovery-code"
                  type="text"
                  required
                  value={recoveryCode}
                  onChange={(e) => setRecoveryCode(e.target.value)}
                  placeholder="SKV-XXXX-XXXX"
                  className="w-full rounded-lg border px-3.5 py-2 text-sm font-mono-code uppercase"
                  style={{
                    backgroundColor: 'var(--bg-canvas)',
                    borderColor: 'var(--border-subtle)',
                    color: 'var(--text-primary)',
                  }}
                />
              </div>
            )}

            <button
              type="submit"
              disabled={loading || !firebaseConfigured}
              className="w-full flex items-center justify-center gap-2 rounded-lg px-4 py-2.5 text-sm font-semibold text-white transition disabled:opacity-50"
              style={{ backgroundColor: isSuperAdminView ? '#0F172A' : '#003399' }}
            >
              <Lock className="h-4 w-4" />
              {loading
                ? 'Verifying Credentials...'
                : isSuperAdminView
                  ? 'Sign In to Super Admin'
                  : 'Sign In to Admin Portal'}
            </button>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              <button
                type="button"
                onClick={handlePasskeySignIn}
                disabled={loading}
                className="flex items-center justify-center gap-2 rounded-lg border px-3.5 py-2.5 text-xs font-semibold transition hover:bg-slate-50 dark:hover:bg-slate-800 disabled:opacity-50"
                style={{
                  borderColor: 'var(--border-subtle)',
                  color: 'var(--text-primary)',
                  backgroundColor: 'var(--bg-canvas)',
                }}
              >
                <Fingerprint className="h-4 w-4 text-blue-600 dark:text-blue-400" />
                <span>Passkey / Biometric</span>
              </button>

              <button
                type="button"
                onClick={handleGoogleSignIn}
                disabled={loading || !firebaseConfigured}
                className="flex items-center justify-center gap-2 rounded-lg border px-3.5 py-2.5 text-xs font-semibold transition hover:bg-slate-50 dark:hover:bg-slate-800 disabled:opacity-50"
                style={{
                  borderColor: 'var(--border-subtle)',
                  color: 'var(--text-primary)',
                  backgroundColor: 'var(--bg-canvas)',
                }}
              >
                <Image
                  src="/images/google_logo.png"
                  alt=""
                  width={15}
                  height={15}
                  className="object-contain"
                />
                <span>Google Workspace</span>
              </button>
            </div>

            <div className="text-right">
              <button
                type="button"
                onClick={() => setRecoveryMode((prev) => !prev)}
                className="inline-flex items-center gap-1 text-[11px] font-medium text-blue-700 dark:text-blue-400 hover:underline"
              >
                <KeyRound className="h-3 w-3" />
                {recoveryMode ? 'Hide Recovery Code' : 'Use Emergency Recovery Code'}
              </button>
            </div>
          </form>
        ) : (
          <MfaChallengeForm
            hintLabel={mfaHintLabel}
            totpCode={totpCode}
            loading={loading}
            onChangeCode={setTotpCode}
            onCancel={() => {
              setMfaResolver(null);
              setTotpCode('');
            }}
            onSubmit={handleMfaSubmit}
          />
        )}

        <div
          className="mt-6 pt-4 border-t text-[11px] flex items-center justify-between"
          style={{ borderColor: 'var(--border-subtle)', color: 'var(--text-muted)' }}
        >
          <span>No Public Admin Registration</span>
          <span>Fail-Closed RBAC + ABAC</span>
        </div>
      </div>
    </div>
  );
}

export function LoginScreen() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen flex items-center justify-center bg-slate-950 text-slate-300 text-sm">
          Loading SKAVIA Authentication Portal...
        </div>
      }
    >
      <LoginPortalContent />
    </Suspense>
  );
}

