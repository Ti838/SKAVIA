'use client';

import { Suspense, useEffect, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { startAuthentication } from '@simplewebauthn/browser';
import type { PublicKeyCredentialRequestOptionsJSON } from '@simplewebauthn/server';
import type { MultiFactorResolver } from 'firebase/auth';
import {
  ArrowLeft,
  Eye,
  EyeOff,
  Fingerprint,
  KeyRound,
  Laptop,
  Lock,
  Moon,
  ShieldAlert,
  ShieldCheck,
  Sun,
  UserCheck,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { LanguageSwitcher } from '@/components/navigation/LanguageSwitcher';
import { useTranslation } from '@/lib/l10n/LanguageContext';
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
  const { isBengali } = useTranslation();
  const firebaseConfigured = isFirebaseWebConfigured();

  const [surfaceView, setSurfaceView] = useState<SurfaceView>('admin');
  const [isSingleHost, setIsSingleHost] = useState(false);

  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [totpCode, setTotpCode] = useState('');
  const [recoveryMode, setRecoveryMode] = useState(false);
  const [recoveryCode, setRecoveryCode] = useState('');
  const [mfaResolver, setMfaResolver] = useState<MultiFactorResolver | null>(null);
  const [mfaHintLabel, setMfaHintLabel] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // Theme support
  const [themePreference, setThemePreference] = useState<'system' | 'light' | 'dark'>('system');
  const [isSystemDark, setIsSystemDark] = useState<boolean>(true);

  useEffect(() => {
    try {
      const savedTheme = localStorage.getItem('skavia-theme');
      if (savedTheme === 'light' || savedTheme === 'dark' || savedTheme === 'system') {
        setThemePreference(savedTheme);
      }
      if (window.matchMedia) {
        setIsSystemDark(window.matchMedia('(prefers-color-scheme: dark)').matches);
      }
    } catch {}

    const mediaQuery = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;
    const handleChange = (e: MediaQueryListEvent) => {
      setIsSystemDark(e.matches);
    };

    mediaQuery?.addEventListener('change', handleChange);
    return () => mediaQuery?.removeEventListener('change', handleChange);
  }, []);

  const effectiveDark =
    themePreference === 'system' ? isSystemDark : themePreference === 'dark';

  useEffect(() => {
    try {
      if (effectiveDark) {
        document.documentElement.classList.add('dark');
        document.documentElement.setAttribute('data-theme', 'dark');
      } else {
        document.documentElement.classList.remove('dark');
        document.documentElement.setAttribute('data-theme', 'light');
      }
    } catch {}
  }, [effectiveDark]);

  const handleCycleTheme = () => {
    let nextPreference: 'system' | 'light' | 'dark';
    if (themePreference === 'system') {
      nextPreference = 'light';
    } else if (themePreference === 'light') {
      nextPreference = 'dark';
    } else {
      nextPreference = 'system';
    }
    setThemePreference(nextPreference);
    try {
      localStorage.setItem('skavia-theme', nextPreference);
    } catch {}
  };

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

    if (
      host.startsWith('superadmin.') ||
      (Boolean(explicitSuperHost) && host === explicitSuperHost) ||
      qPortal === 'superadmin'
    ) {
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
          surface: surfaceView,
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
        throw new Error(
          isBengali
            ? 'রিকভারি কোড ব্যবহার করতে TOTP ব্যতিরেকে পাসওয়ার্ড বা গুগল দিয়ে সাইন ইন করুন।'
            : 'Sign in with primary password/Google without TOTP to consume recovery code.'
        );
      }
      setMfaResolver(loginRes.mfaResolver);
      setMfaHintLabel(loginRes.hintLabel || (isBengali ? 'অথেন্টিকেটর অ্যাপ' : 'Authenticator App'));
      return;
    }
    if (!loginRes.idToken) {
      throw new Error(
        isBengali
          ? 'অথেনটিকেশন সফল হলেও টোকেন পাওয়া যায়নি।'
          : 'Authentication did not return an ID token.'
      );
    }

    if (recoveryMode && recoveryCode.trim()) {
      const res = await apiFetch<{ session: AdminSessionContext }>(
        '/api/admin/auth/recovery',
        {
          method: 'PUT',
          body: JSON.stringify({
            idToken: loginRes.idToken,
            recoveryCode: recoveryCode.trim(),
            surface: surfaceView,
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
      setErrorMessage(
        formatAuthError(
          err,
          isBengali ? 'সাইন ইন ব্যর্থ হয়েছে। পরিচয়পত্র পরীক্ষা করুন।' : 'Sign-in failed. Please verify credentials.'
        )
      );
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
      setErrorMessage(
        formatAuthError(
          err,
          isBengali ? 'গুগল সাইন ইন সম্পন্ন করা যায়নি।' : 'Google sign-in failed.'
        )
      );
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
            surface: surfaceView,
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
      setErrorMessage(
        formatAuthError(
          err,
          isBengali ? 'পাসকি / বায়োমেট্রিক সাইন ইন ব্যর্থ হয়েছে।' : 'Passkey / biometric sign-in failed.'
        )
      );
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
      setErrorMessage(
        formatAuthError(
          err,
          isBengali ? 'প্রদত্ত এমএফএ ওটিপি সঠিক নয়।' : 'Invalid MFA code.'
        )
      );
    } finally {
      setLoading(false);
    }
  }

  const isSuperAdminView = surfaceView === 'superadmin';

  return (
    <div
      className={`min-h-screen relative flex flex-col justify-between p-4 sm:p-6 transition-colors duration-300 ${
        effectiveDark
          ? 'bg-[#05080F] text-slate-100 skavia-subtle-mesh-dark'
          : 'bg-[#F8FAFC] text-slate-900 skavia-subtle-mesh-light'
      }`}
    >
      {/* Seamless Ambient Lighting with Zero-Banding Falloff */}
      <div 
        className="absolute inset-0 pointer-events-none select-none overflow-hidden" 
        style={{
          background: effectiveDark
            ? 'radial-gradient(ellipse 85% 55% at 50% 0%, rgba(0, 51, 153, 0.25) 0%, rgba(21, 231, 202, 0.08) 45%, transparent 100%)'
            : 'radial-gradient(ellipse 85% 55% at 50% 0%, rgba(0, 51, 153, 0.08) 0%, rgba(56, 152, 236, 0.05) 45%, transparent 100%)'
        }}
        aria-hidden="true"
      />

      {/* Top Header / Bar */}
      <header className="relative z-10 w-full max-w-5xl mx-auto flex items-center justify-between py-2 sm:py-4">
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-xs font-semibold px-3 py-1.5 rounded-full border transition hover:border-[#3898EC]"
          style={{
            borderColor: 'var(--border-subtle)',
            backgroundColor: 'var(--bg-surface)',
            color: 'var(--text-secondary)',
          }}
        >
          <ArrowLeft className="h-3.5 w-3.5 text-blue-500" />
          <span>{isBengali ? 'হোমপেজে ফিরুন' : 'Back to Website'}</span>
        </Link>

        {/* Center Emblem on larger screens */}
        <Link href="/" className="hidden sm:flex items-center gap-2">
          <SkaviaBrandMark variant="emblem" size={26} />
          <span className="font-heading font-extrabold text-sm tracking-tight text-slate-900 dark:text-white">
            SKAVIA
          </span>
        </Link>

        {/* Right utility buttons */}
        <div className="flex items-center gap-2">
          <LanguageSwitcher />

          <button
            type="button"
            onClick={handleCycleTheme}
            aria-label="Toggle theme"
            className="inline-flex items-center justify-center h-8 w-8 rounded-full border text-xs transition"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
              color: 'var(--text-secondary)',
            }}
          >
            {themePreference === 'system' ? (
              <Laptop className="h-3.5 w-3.5 text-[#3898EC]" />
            ) : themePreference === 'light' ? (
              <Sun className="h-3.5 w-3.5 text-amber-500" />
            ) : (
              <Moon className="h-3.5 w-3.5 text-indigo-400" />
            )}
          </button>
        </div>
      </header>

      {/* Main Authentication Box */}
      <main className="relative z-10 w-full max-w-md mx-auto my-auto py-6 sm:py-8">
        <div
          className="rounded-3xl border p-6 sm:p-8 shadow-2xl backdrop-blur-xl space-y-6"
          style={{
            backgroundColor: 'var(--bg-surface)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          {/* Surface Toggle Tabs (if on single host or query param) */}
          {isSingleHost && (
            <div
              className="flex items-center gap-1 rounded-2xl border p-1 text-xs"
              style={{
                borderColor: 'var(--border-subtle)',
                backgroundColor: 'var(--bg-surface-subtle)',
              }}
            >
              <button
                type="button"
                onClick={() => setSurfaceView('admin')}
                className={`flex-1 rounded-xl py-2 text-center text-xs font-semibold transition ${
                  !isSuperAdminView
                    ? 'bg-[#003399] text-white shadow-md'
                    : 'text-slate-500 hover:text-slate-900 dark:hover:text-white'
                }`}
              >
                {isBengali ? 'এডমিন পোর্টাল' : 'Admin Portal'}
              </button>
              <button
                type="button"
                onClick={() => setSurfaceView('superadmin')}
                className={`flex-1 rounded-xl py-2 text-center text-xs font-semibold transition ${
                  isSuperAdminView
                    ? 'bg-slate-900 text-white dark:bg-slate-800 shadow-md ring-1 ring-[#15E7CA]/40'
                    : 'text-slate-500 hover:text-slate-900 dark:hover:text-white'
                }`}
              >
                {isBengali ? 'সুপার এডমিন (রুট)' : 'Super Admin (Root)'}
              </button>
            </div>
          )}

          {/* Header Typography */}
          <div className="text-center space-y-2">
            <div className="inline-flex items-center gap-2 rounded-full px-3 py-1 text-[11px] font-mono-code font-semibold border"
              style={{
                borderColor: isSuperAdminView ? 'rgba(21, 231, 202, 0.3)' : 'var(--border-subtle)',
                backgroundColor: 'var(--bg-surface-subtle)',
                color: isSuperAdminView ? '#15E7CA' : '#003399',
              }}
            >
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
              <span>
                {isSuperAdminView
                  ? (isBengali ? 'রুট গভর্ন্যান্স গেটওয়ে' : 'Root Governance Gateway')
                  : (isBengali ? 'আমন্ত্রিত এডমিন এক্সেস' : 'Invitation-Only Gateway')}
              </span>
            </div>

            <h1 className="font-heading text-2xl sm:text-3xl font-extrabold tracking-tight" style={{ color: 'var(--text-primary)' }}>
              {isSuperAdminView
                ? (isBengali ? 'স্ক্যাভিয়া সুপার এডমিন' : 'SKAVIA Super Admin')
                : (isBengali ? 'স্ক্যাভিয়া এডমিন পোর্টাল' : 'SKAVIA Admin Portal')}
            </h1>

            <p className="text-xs max-w-sm mx-auto leading-relaxed" style={{ color: 'var(--text-secondary)' }}>
              {isSuperAdminView
                ? (isBengali
                    ? 'এক্সিকিউটিভ রুট গভর্ন্যান্স · এমএফএ, পাসকি ও আইপি রেস্ট্রিকশন সুরক্ষিত।'
                    : 'Executive Root Governance · Enforced MFA, WebAuthn Passkeys & Audit Logging.')
                : (isBengali
                    ? 'কোম্পানি এডমিন, শাখা ব্যবস্থাপক ও অপারেশনাল ভেরিফিকেশন প্যানেল।'
                    : 'Company Operations, Branch Management, KYC Verification & Release Dispatch.')}
            </p>
          </div>

          {/* Config Warnings */}
          {!firebaseConfigured && (
            <div
              role="alert"
              className="rounded-xl border border-amber-300 dark:border-amber-800 bg-amber-50 dark:bg-amber-950/40 p-4 text-xs text-amber-950 dark:text-amber-200"
            >
              <div className="flex items-center gap-2 font-semibold mb-1">
                <ShieldAlert className="h-4 w-4 text-amber-700 dark:text-amber-300" />
                {isBengali ? 'ফায়ারবেস কনফিগারেশন অনুপস্থিত' : 'External Firebase Web Config Missing'}
              </div>
              <p className="leading-relaxed">
                Set <code className="font-mono-code">NEXT_PUBLIC_FIREBASE_API_KEY</code>,{' '}
                <code className="font-mono-code">NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN</code> in{' '}
                <code className="font-mono-code">admin-web/.env.local</code>.
              </p>
            </div>
          )}

          {/* Error Message Alert */}
          {errorMessage && (
            <div
              role="alert"
              className="rounded-xl border border-rose-300 dark:border-rose-900 bg-rose-50 dark:bg-rose-950/40 p-3.5 text-xs text-rose-800 dark:text-rose-200 flex items-start gap-2.5"
            >
              <ShieldAlert className="h-4 w-4 text-rose-600 dark:text-rose-400 shrink-0 mt-0.5" />
              <div className="flex-1 font-medium leading-relaxed">{errorMessage}</div>
            </div>
          )}

          {/* Main Form or MFA Challenge */}
          {!mfaResolver ? (
            <div className="space-y-4">
              {/* Fast 1-Click Passkey & Google SSO Buttons */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                <button
                  type="button"
                  onClick={handlePasskeySignIn}
                  disabled={loading}
                  className="sakuga-spring-tap flex items-center justify-center gap-2 rounded-xl border p-3 text-xs font-semibold transition hover:border-[#3898EC] disabled:opacity-50"
                  style={{
                    borderColor: 'var(--border-subtle)',
                    color: 'var(--text-primary)',
                    backgroundColor: 'var(--bg-surface-subtle)',
                  }}
                >
                  <Fingerprint className="h-4 w-4 text-[#003399] dark:text-[#15E7CA]" />
                  <span>{isBengali ? 'পাসকি / বায়োমেট্রিক' : 'Passkey / Biometric'}</span>
                </button>

                <button
                  type="button"
                  onClick={handleGoogleSignIn}
                  disabled={loading || !firebaseConfigured}
                  className="sakuga-spring-tap flex items-center justify-center gap-2 rounded-xl border p-3 text-xs font-semibold transition hover:border-[#3898EC] disabled:opacity-50"
                  style={{
                    borderColor: 'var(--border-subtle)',
                    color: 'var(--text-primary)',
                    backgroundColor: 'var(--bg-surface-subtle)',
                  }}
                >
                  <Image
                    src="/images/google_logo.png"
                    alt=""
                    width={15}
                    height={15}
                    className="object-contain"
                  />
                  <span>{isBengali ? 'গুগল ওয়ার্কস্পেস' : 'Google Workspace'}</span>
                </button>
              </div>

              {/* Divider */}
              <div className="relative flex items-center justify-center py-1">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t" style={{ borderColor: 'var(--border-subtle)' }} />
                </div>
                <span
                  className="relative px-3 text-[11px] font-mono-code uppercase tracking-wider text-slate-400"
                  style={{ backgroundColor: 'var(--bg-surface)' }}
                >
                  {isBengali ? 'অথবা কর্পোরেট ইমেইল' : 'or corporate credentials'}
                </span>
              </div>

              {/* Email & Password Form */}
              <form onSubmit={handlePrimarySubmit} className="space-y-4">
                <div className="space-y-1.5">
                  <label
                    htmlFor="admin-identifier"
                    className="block text-xs font-semibold uppercase tracking-wider"
                    style={{ color: 'var(--text-secondary)' }}
                  >
                    {isSuperAdminView
                      ? (isBengali ? 'সুপার এডমিন ইউজারনেম বা ইমেইল' : 'Super Admin Username or Email')
                      : (isBengali ? 'আমন্ত্রিত এডমিন ইমেইল' : 'Invited Admin Email')}
                  </label>
                  <input
                    id="admin-identifier"
                    type={isSuperAdminView ? 'text' : 'email'}
                    required
                    autoComplete="username"
                    value={identifier}
                    onChange={(e) => setIdentifier(e.target.value)}
                    placeholder={
                      isSuperAdminView
                        ? 'tariq_superadmin or admin@skavia.com'
                        : 'admin@skavia.com'
                    }
                    className="w-full rounded-xl border px-4 py-2.5 text-sm outline-none transition focus:ring-2 focus:ring-[#003399]/40"
                    style={{
                      backgroundColor: 'var(--bg-canvas)',
                      borderColor: 'var(--border-subtle)',
                      color: 'var(--text-primary)',
                    }}
                  />
                </div>

                <div className="space-y-1.5">
                  <div className="flex items-center justify-between">
                    <label
                      htmlFor="admin-password"
                      className="block text-xs font-semibold uppercase tracking-wider"
                      style={{ color: 'var(--text-secondary)' }}
                    >
                      {isBengali ? 'পাসওয়ার্ড' : 'Password'}
                    </label>
                    <button
                      type="button"
                      onClick={() => setRecoveryMode((prev) => !prev)}
                      className="text-[11px] font-medium text-blue-600 dark:text-blue-400 hover:underline inline-flex items-center gap-1"
                    >
                      <KeyRound className="h-3 w-3" />
                      {recoveryMode
                        ? (isBengali ? 'পাসওয়ার্ডে ফিরুন' : 'Hide Recovery')
                        : (isBengali ? 'জরুরি রিকভারি কোড?' : 'Emergency Recovery Code?')}
                    </button>
                  </div>

                  <div className="relative">
                    <input
                      id="admin-password"
                      type={showPassword ? 'text' : 'password'}
                      required
                      autoComplete="current-password"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder={
                        isBengali
                          ? 'এডমিনিস্ট্রেটর পাসওয়ার্ড লিখুন'
                          : 'Enter administrator password'
                      }
                      className="w-full rounded-xl border px-4 py-2.5 text-sm outline-none transition focus:ring-2 focus:ring-[#003399]/40 pr-10"
                      style={{
                        backgroundColor: 'var(--bg-canvas)',
                        borderColor: 'var(--border-subtle)',
                        color: 'var(--text-primary)',
                      }}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword((prev) => !prev)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200"
                      aria-label={showPassword ? 'Hide password' : 'Show password'}
                    >
                      {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                  </div>
                </div>

                {recoveryMode && (
                  <div className="space-y-1.5 pt-1">
                    <label
                      htmlFor="recovery-code"
                      className="block text-xs font-semibold uppercase tracking-wider text-amber-600 dark:text-amber-400"
                    >
                      {isBengali ? 'এককালীন জরুরি রিকভারি কোড' : 'Single-Use Recovery Code'}
                    </label>
                    <input
                      id="recovery-code"
                      type="text"
                      required
                      value={recoveryCode}
                      onChange={(e) => setRecoveryCode(e.target.value)}
                      placeholder="SKV-XXXX-XXXX"
                      className="w-full rounded-xl border px-4 py-2.5 text-sm font-mono-code uppercase outline-none transition focus:ring-2 focus:ring-amber-500/40"
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
                  className="sakuga-spring-tap w-full flex items-center justify-center gap-2 rounded-xl py-3 px-4 text-sm font-bold text-white shadow-lg transition-all disabled:opacity-50"
                  style={{
                    backgroundColor: isSuperAdminView ? '#0F172A' : '#003399',
                  }}
                >
                  <Lock className="h-4 w-4" />
                  <span>
                    {loading
                      ? (isBengali ? 'পরিচয়পত্র যাচাই করা হচ্ছে...' : 'Verifying Credentials...')
                      : isSuperAdminView
                        ? (isBengali ? 'সুপার এডমিন লগইন' : 'Sign In to Super Admin')
                        : (isBengali ? 'এডমিন পোর্টাল লগইন' : 'Sign In to Admin Portal')}
                  </span>
                </button>
              </form>
            </div>
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

          {/* Security & RBAC Guarantee Badges */}
          <div
            className="pt-4 border-t flex items-center justify-between text-[11px] font-mono-code"
            style={{ borderColor: 'var(--border-subtle)', color: 'var(--text-muted)' }}
          >
            <span className="flex items-center gap-1">
              <ShieldCheck className="h-3.5 w-3.5 text-teal-500" />
              <span>{isBengali ? 'কঠোর আরব্যাক ও অডিট' : 'Fail-Closed RBAC'}</span>
            </span>
            <span>{isBengali ? 'পাসকি (FIDO2) সমর্থিত' : 'FIDO2 Passkey Enforced'}</span>
          </div>

          {/* Role Redirection Notice */}
          <div
            className="rounded-2xl border p-4 text-xs space-y-1.5"
            style={{
              borderColor: 'var(--border-subtle)',
              backgroundColor: 'var(--bg-canvas)',
            }}
          >
            <p className="font-semibold flex items-center gap-1.5" style={{ color: 'var(--text-primary)' }}>
              <UserCheck className="h-3.5 w-3.5 text-blue-500" />
              <span>{isBengali ? 'অন্যান্য প্ল্যাটফর্ম ভূমিকা?' : 'Other Platform Roles?'}</span>
            </p>
            <p className="text-[11px] leading-relaxed" style={{ color: 'var(--text-secondary)' }}>
              {isBengali
                ? 'দক্ষ কর্মী (Worker) ও ব্যক্তিগত গ্রাহকগণ অফিসিয়াল মোবাইল অ্যাপের মাধ্যমে যুক্ত থাকুন। এখানে শুধুমাত্র প্রশাসনিক কর্মকর্তারা প্রবেশ করতে পারেন।'
                : 'Technicians and customers interact via the official Android Mobile App. This gateway is strictly reserved for authorized management staff.'}
            </p>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="relative z-10 w-full max-w-5xl mx-auto py-3 text-center text-xs text-slate-500">
        <p>© {new Date().getFullYear()} SKAVIA Technologies Ltd. &middot; Accountable Workforce Platform</p>
      </footer>
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
