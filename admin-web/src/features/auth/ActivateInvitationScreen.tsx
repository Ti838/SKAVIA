'use client';

import { Suspense, useEffect, useState } from 'react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import {
  BadgeCheck,
  CheckCircle2,
  KeyRound,
  ShieldAlert,
  ShieldCheck,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import {
  createInvitedAdminFirebaseAccount,
  isFirebaseWebConfigured,
  signInAdminWithEmail,
  signInAdminWithGoogle,
} from '@/lib/firebase-client';
import { AdminApiError, apiFetch } from '@/lib/api-client';

interface InvitationPreview {
  invitation_id: string;
  full_name: string;
  email: string;
  role_name: 'Company Admin' | 'Branch Manager';
  assigned_branch_names: string[];
  require_approval: boolean;
  expires_at: string;
  status: string;
}

function ActivateInvitationContent() {
  const searchParams = useSearchParams();
  const token = (searchParams.get('token') || '').trim();
  const firebaseConfigured = isFirebaseWebConfigured();

  const [preview, setPreview] = useState<InvitationPreview | null>(null);
  const [loadingPreview, setLoadingPreview] = useState(true);
  const [previewError, setPreviewError] = useState<string | null>(null);

  const [authMode, setAuthMode] = useState<'new_password' | 'existing_password' | 'google'>(
    'new_password'
  );
  const [fullName, setFullName] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [acceptedTerms, setAcceptedTerms] = useState(false);

  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [activationResult, setActivationResult] = useState<{
    status: string;
    message: string;
  } | null>(null);

  useEffect(() => {
    if (!token) {
      setPreviewError('No activation token found in this link.');
      setLoadingPreview(false);
      return;
    }

    fetch(`/api/public/invitations/verify?token=${encodeURIComponent(token)}`)
      .then(async (res) => {
        const payload = await res.json();
        if (!res.ok) {
          throw new Error(payload?.error?.message || `Invalid token (${res.status})`);
        }
        return payload.invitation as InvitationPreview;
      })
      .then((inv) => {
        setPreview(inv);
        setFullName(inv.full_name);
      })
      .catch((err) => {
        setPreviewError(err instanceof Error ? err.message : 'Unable to verify invitation link.');
      })
      .finally(() => setLoadingPreview(false));
  }, [token]);

  async function handleActivate(e: React.FormEvent) {
    e.preventDefault();
    if (!preview) return;
    setSubmitError(null);

    if (!acceptedTerms) {
      setSubmitError('You must accept the SKAVIA Administrative Security Policy.');
      return;
    }

    if (authMode === 'new_password') {
      if (password.length < 10) {
        setSubmitError('Password must be at least 10 characters long.');
        return;
      }
      if (password !== confirmPassword) {
        setSubmitError('Password confirmation does not match.');
        return;
      }
    }

    setSubmitting(true);
    try {
      let idToken = '';
      if (authMode === 'new_password') {
        idToken = await createInvitedAdminFirebaseAccount({
          email: preview.email,
          password,
          fullName: fullName.trim() || preview.full_name,
        });
      } else if (authMode === 'existing_password') {
        const loginRes = await signInAdminWithEmail(preview.email, password);
        if (!loginRes.idToken) {
          throw new Error('Could not verify your existing Firebase credential.');
        }
        idToken = loginRes.idToken;
      } else {
        const googleRes = await signInAdminWithGoogle(preview.email);
        if (!googleRes.idToken) {
          throw new Error('Google sign-in did not complete.');
        }
        idToken = googleRes.idToken;
      }

      const res = await apiFetch<{ status: string; message: string }>(
        '/api/public/invitations/activate',
        {
          method: 'POST',
          body: JSON.stringify({
            token,
            idToken,
            fullName: fullName.trim() || preview.full_name,
            acceptedTerms: true,
            deviceLabel: navigator.userAgent.slice(0, 100),
          }),
        }
      );

      setActivationResult({ status: res.status, message: res.message });
    } catch (err) {
      if (err instanceof AdminApiError) {
        setSubmitError(`${err.message} (${err.code})`);
      } else if (err instanceof Error) {
        setSubmitError(err.message);
      } else {
        setSubmitError('Invitation activation failed.');
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div
      className="min-h-screen flex items-center justify-center p-6"
      style={{
        background: 'linear-gradient(135deg, #003399 0%, #0B1938 55%, #0F172A 100%)',
      }}
    >
      <div
        className="w-full max-w-lg rounded-2xl border p-8 shadow-2xl space-y-6"
        style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
      >
        <div className="flex items-center gap-3">
          <div className="h-12 w-12 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 flex items-center justify-center p-1.5 shrink-0">
            <SkaviaBrandMark variant="emblem" size={38} priority />
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-tight">Internal Admin Activation</h1>
            <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
              Single-Use Invitation Verification &amp; Identity Binding
            </p>
          </div>
        </div>

        {loadingPreview ? (
          <p className="text-sm text-slate-600 dark:text-slate-300">Verifying cryptographic invitation token...</p>
        ) : previewError ? (
          <div
            role="alert"
            className="rounded-xl border border-red-300 dark:border-red-800 bg-red-50 dark:bg-red-950/40 p-4 text-sm text-red-900 dark:text-red-200 space-y-2"
          >
            <div className="flex items-center gap-2 font-semibold">
              <ShieldAlert className="h-4 w-4 text-red-700 dark:text-red-300" />
              Invitation Unavailable
            </div>
            <p>{previewError}</p>
          </div>
        ) : activationResult ? (
          <div className="rounded-xl border border-emerald-300 dark:border-emerald-800 bg-emerald-50 dark:bg-emerald-950/40 p-5 text-sm text-emerald-950 dark:text-emerald-200 space-y-3">
            <div className="flex items-center gap-2 font-bold text-base">
              <CheckCircle2 className="h-5 w-5 text-emerald-700 dark:text-emerald-300" />
              {activationResult.status === 'PendingApproval'
                ? 'Activation Submitted — Awaiting Super Admin Approval'
                : 'Internal Admin Account Activated'}
            </div>
            <p className="leading-relaxed">{activationResult.message}</p>
            <div className="pt-2">
              <Link
                href="/login"
                className="inline-flex items-center gap-2 rounded-lg px-4 py-2 text-xs font-semibold text-white"
                style={{ backgroundColor: '#003399' }}
              >
                <ShieldCheck className="h-4 w-4" />
                Go to Internal Admin Login
              </Link>
            </div>
          </div>
        ) : preview ? (
          <form onSubmit={handleActivate} className="space-y-4">
            <div className="rounded-xl border border-blue-200 dark:border-blue-800 bg-blue-50/70 dark:bg-blue-950/40 p-4 text-xs text-slate-800 dark:text-slate-200 space-y-1.5">
              <div className="flex items-center gap-1.5 font-semibold text-blue-900 dark:text-blue-200">
                <BadgeCheck className="h-4 w-4 text-blue-700 dark:text-blue-300" />
                Verified SKAVIA Invitation
              </div>
              <p>
                <strong>Invited Email:</strong> {preview.email}
              </p>
              <p>
                <strong>Assigned Role:</strong> {preview.role_name}
              </p>
              <p>
                <strong>Branch Scope:</strong>{' '}
                {preview.assigned_branch_names.length > 0
                  ? preview.assigned_branch_names.join(', ')
                  : 'All SKAVIA Branches'}
              </p>
              <p>
                <strong>Approval Policy:</strong>{' '}
                {preview.require_approval
                  ? 'Requires Primary Super Admin final approval after setup'
                  : 'Immediate portal activation'}
              </p>
            </div>

            {!firebaseConfigured && (
              <div className="rounded-xl border border-amber-300 dark:border-amber-800 bg-amber-50 dark:bg-amber-950/40 p-3 text-xs text-amber-900 dark:text-amber-200">
                Firebase Web SDK config is required in <code className="font-mono-code">.env.local</code>{' '}
                to create or link your Firebase credential.
              </div>
            )}

            {submitError && (
              <div role="alert" className="rounded-xl border border-red-300 dark:border-red-800 bg-red-50 dark:bg-red-950/40 p-3 text-xs text-red-900 dark:text-red-200">
                {submitError}
              </div>
            )}

            <div>
              <label className="block text-xs font-semibold uppercase mb-1">Full Name</label>
              <input
                type="text"
                required
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                className="w-full rounded-lg border px-3.5 py-2 text-sm"
                style={{ borderColor: 'var(--border-subtle)', backgroundColor: 'var(--bg-canvas)' }}
              />
            </div>

            <div className="flex gap-1.5 text-xs">
              {[
                { id: 'new_password', label: 'Create Password' },
                { id: 'existing_password', label: 'Existing Password' },
                { id: 'google', label: 'Google Email' },
              ].map((m) => (
                <button
                  key={m.id}
                  type="button"
                  onClick={() => setAuthMode(m.id as typeof authMode)}
                  className={`flex-1 rounded-lg border px-2 py-2 font-medium ${
                    authMode === m.id
                      ? 'bg-[#003399] text-white border-[#003399]'
                      : 'border-slate-300 dark:border-slate-700 text-slate-600 dark:text-slate-300'
                  }`}
                >
                  {m.label}
                </button>
              ))}
            </div>

            {authMode !== 'google' && (
              <>
                <div>
                  <label className="block text-xs font-semibold uppercase mb-1">
                    {authMode === 'new_password' ? 'Set Strong Password (min 10 chars)' : 'Current Password'}
                  </label>
                  <input
                    type="password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full rounded-lg border px-3.5 py-2 text-sm"
                    style={{ borderColor: 'var(--border-subtle)', backgroundColor: 'var(--bg-canvas)' }}
                  />
                </div>
                {authMode === 'new_password' && (
                  <div>
                    <label className="block text-xs font-semibold uppercase mb-1">
                      Confirm Password
                    </label>
                    <input
                      type="password"
                      required
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      className="w-full rounded-lg border px-3.5 py-2 text-sm"
                      style={{ borderColor: 'var(--border-subtle)', backgroundColor: 'var(--bg-canvas)' }}
                    />
                  </div>
                )}
              </>
            )}

            <label className="flex items-start gap-2.5 text-xs text-slate-600 dark:text-slate-300 cursor-pointer">
              <input
                type="checkbox"
                checked={acceptedTerms}
                onChange={(e) => setAcceptedTerms(e.target.checked)}
                className="mt-0.5"
              />
              <span>
                I acknowledge that SKAVIA administrative access is strictly audited, branch-scoped,
                and governed by MFA/Passkey security policy. After activation, I will enroll a
                device Passkey or authenticator factor in My Settings.
              </span>
            </label>

            <button
              type="submit"
              disabled={submitting || !firebaseConfigured}
              className="w-full flex items-center justify-center gap-2 rounded-lg px-4 py-2.5 text-sm font-semibold text-white disabled:opacity-50"
              style={{ backgroundColor: '#003399' }}
            >
              <KeyRound className="h-4 w-4" />
              {submitting ? 'Completing Activation...' : 'Complete Identity Activation'}
            </button>
          </form>
        ) : null}
      </div>
    </div>
  );
}

export function ActivateInvitationScreen() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen flex items-center justify-center bg-slate-950 text-slate-300 text-sm">
          Loading Invitation Onboarding...
        </div>
      }
    >
      <ActivateInvitationContent />
    </Suspense>
  );
}

