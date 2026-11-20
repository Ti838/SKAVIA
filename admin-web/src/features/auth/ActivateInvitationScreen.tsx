'use client';

import { Suspense, useEffect, useState } from 'react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import {
  ArrowLeft,
  BadgeCheck,
  CheckCircle2,
  KeyRound,
  ShieldAlert,
  ShieldCheck,
} from 'lucide-react';
import { LanguageSwitcher } from '@/components/navigation/LanguageSwitcher';
import { useTranslation } from '@/lib/l10n/LanguageContext';
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
  const { isBengali } = useTranslation();

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
      setPreviewError(
        isBengali
          ? 'এই লিংকে কোনো অ্যাক্টিভেশন টোকেন পাওয়া যায়নি।'
          : 'No activation token found in this link.'
      );
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
        setPreviewError(
          err instanceof Error
            ? err.message
            : isBengali
              ? 'আমন্ত্রণ লিংকটি যাচাই করা যায়নি।'
              : 'Unable to verify invitation link.'
        );
      })
      .finally(() => setLoadingPreview(false));
  }, [token, isBengali]);

  async function handleActivate(e: React.FormEvent) {
    e.preventDefault();
    if (!preview) return;
    setSubmitError(null);

    if (!acceptedTerms) {
      setSubmitError(
        isBengali
          ? 'আপনাকে অবশ্যই স্ক্যাভিয়া প্রশাসনিক সুরক্ষা নীতি মেনে নিতে হবে।'
          : 'You must accept the SKAVIA Administrative Security Policy.'
      );
      return;
    }

    if (authMode === 'new_password') {
      if (password.length < 10) {
        setSubmitError(
          isBengali
            ? 'পাসওয়ার্ড অবশ্যই কমপক্ষে ১০ অক্ষরের হতে হবে।'
            : 'Password must be at least 10 characters long.'
        );
        return;
      }
      if (password !== confirmPassword) {
        setSubmitError(
          isBengali
            ? 'পাসওয়ার্ড নিশ্চিতকরণ মিলছে না।'
            : 'Password confirmation does not match.'
        );
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
          throw new Error(
            isBengali
              ? 'বিদ্যমান পাসওয়ার্ড যাচাই করা যায়নি।'
              : 'Could not verify your existing Firebase credential.'
          );
        }
        idToken = loginRes.idToken;
      } else {
        const loginRes = await signInAdminWithGoogle(preview.email);
        if (!loginRes.idToken) {
          throw new Error(
            isBengali
              ? 'গুগল সাইন ইন থেকে ক্রেডেনশিয়াল পাওয়া যায়নি।'
              : 'Google sign-in did not return a credential.'
          );
        }
        idToken = loginRes.idToken;
      }

      const res = await apiFetch<{ status: string; message: string }>(
        '/api/public/invitations/activate',
        {
          method: 'POST',
          body: JSON.stringify({
            token,
            idToken,
            fullName: fullName.trim() || preview.full_name,
          }),
        }
      );

      setActivationResult(res);
    } catch (err: unknown) {
      if (err instanceof AdminApiError) {
        setSubmitError(`${err.message} (${err.code})`);
      } else if (err instanceof Error) {
        setSubmitError(err.message);
      } else {
        setSubmitError(
          isBengali ? 'অ্যাক্টিভেশন সম্পন্ন করা যায়নি।' : 'Failed to complete activation.'
        );
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="min-h-screen relative flex flex-col justify-between p-4 sm:p-6 bg-[#05080F] text-slate-100 skavia-subtle-mesh-dark">
      {/* Seamless Ambient Atmosphere */}
      <div 
        className="absolute inset-0 pointer-events-none select-none overflow-hidden" 
        style={{
          background: 'radial-gradient(ellipse 85% 55% at 50% 0%, rgba(0, 51, 153, 0.22) 0%, rgba(21, 231, 202, 0.08) 45%, transparent 100%)'
        }}
        aria-hidden="true"
      />

      {/* Top Bar */}
      <header className="relative z-10 w-full max-w-4xl mx-auto flex items-center justify-between py-2 sm:py-4">
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-xs font-semibold px-3 py-1.5 rounded-full border border-slate-700 bg-slate-900/80 text-slate-300 hover:text-white transition"
        >
          <ArrowLeft className="h-3.5 w-3.5 text-blue-500" />
          <span>{isBengali ? 'হোমপেজে ফিরুন' : 'Back to Website'}</span>
        </Link>
        <LanguageSwitcher />
      </header>

      {/* Card */}
      <main className="relative z-10 w-full max-w-lg mx-auto my-auto py-6 sm:py-8">
        <div
          className="rounded-3xl border p-6 sm:p-8 shadow-2xl backdrop-blur-xl space-y-6"
          style={{
            backgroundColor: 'var(--bg-surface)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <div className="text-center space-y-2">
            <div className="inline-flex items-center gap-2 rounded-full border px-3 py-1 text-[11px] font-mono-code font-semibold border-cyan-400/30 bg-cyan-500/10 text-cyan-400">
              <span className="h-1.5 w-1.5 rounded-full bg-cyan-400 animate-pulse" />
              <span>{isBengali ? 'এডমিন আমন্ত্রণ গ্রহণ' : 'Administrative Onboarding'}</span>
            </div>

            <h1 className="font-heading text-2xl sm:text-3xl font-extrabold tracking-tight text-white">
              {isBengali ? 'স্ক্যাভিয়া এডমিন এক্টিভেশন' : 'Activate SKAVIA Invitation'}
            </h1>
            <p className="text-xs text-slate-400 max-w-sm mx-auto leading-relaxed">
              {isBengali
                ? 'অনুমোদিত অভ্যন্তরীণ এডমিন বা ব্রাঞ্চ ম্যানেজার হিসেবে আপনার পরিচয় নিশ্চিত করুন।'
                : 'Securely verify your credential, enroll in RBAC, and initialize administrative access.'}
            </p>
          </div>

          {loadingPreview ? (
            <div className="py-12 text-center text-xs text-slate-400">
              {isBengali ? 'আমন্ত্রণ যাচাই করা হচ্ছে...' : 'Verifying invitation token...'}
            </div>
          ) : previewError ? (
            <div className="rounded-2xl border border-rose-500/30 bg-rose-500/10 p-5 text-xs text-rose-300 space-y-2">
              <div className="flex items-center gap-2 font-semibold">
                <ShieldAlert className="h-4 w-4 text-rose-400" />
                <span>{isBengali ? 'আমন্ত্রণ লিংকটি অনুপলব্ধ' : 'Invitation Unavailable'}</span>
              </div>
              <p>{previewError}</p>
            </div>
          ) : activationResult ? (
            <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 p-6 text-sm text-emerald-200 space-y-4">
              <div className="flex items-center gap-2 font-bold text-base text-emerald-300">
                <CheckCircle2 className="h-5 w-5 text-emerald-400" />
                <span>
                  {activationResult.status === 'PendingApproval'
                    ? (isBengali ? 'আবেদন জমা হয়েছে — সুপার এডমিন অনুমোদনের অপেক্ষায়' : 'Activation Submitted — Awaiting Super Admin Approval')
                    : (isBengali ? 'এডমিন একাউন্ট সফলভাবে সক্রিয় হয়েছে' : 'Internal Admin Account Activated')}
                </span>
              </div>
              <p className="text-xs leading-relaxed text-emerald-100">{activationResult.message}</p>
              <div className="pt-2">
                <Link
                  href="/login"
                  className="sakuga-spring-tap inline-flex items-center gap-2 rounded-xl px-5 py-2.5 text-xs font-semibold text-white bg-[#003399] hover:bg-[#00287a] shadow-md transition"
                >
                  <ShieldCheck className="h-4 w-4" />
                  <span>{isBengali ? 'এডমিন লগইন প্যানেলে যান' : 'Go to Admin Login'}</span>
                </Link>
              </div>
            </div>
          ) : preview ? (
            <form onSubmit={handleActivate} className="space-y-4">
              <div className="rounded-2xl border border-blue-500/30 bg-blue-500/10 p-4 text-xs space-y-1.5 text-slate-200">
                <div className="flex items-center gap-1.5 font-semibold text-blue-300">
                  <BadgeCheck className="h-4 w-4 text-blue-400" />
                  <span>{isBengali ? 'যাচাইকৃত স্ক্যাভিয়া আমন্ত্রণ' : 'Verified SKAVIA Invitation'}</span>
                </div>
                <p>
                  <strong>{isBengali ? 'আমন্ত্রিত ইমেইল:' : 'Invited Email:'}</strong> {preview.email}
                </p>
                <p>
                  <strong>{isBengali ? 'প্রদত্ত ভূমিকা:' : 'Assigned Role:'}</strong> {preview.role_name}
                </p>
                <p>
                  <strong>{isBengali ? 'শাখা পরিধি:' : 'Branch Scope:'}</strong>{' '}
                  {preview.assigned_branch_names.length > 0
                    ? preview.assigned_branch_names.join(', ')
                    : isBengali ? 'সকল স্ক্যাভিয়া শাখা' : 'All SKAVIA Branches'}
                </p>
                <p>
                  <strong>{isBengali ? 'অনুমোদন নীতি:' : 'Approval Policy:'}</strong>{' '}
                  {preview.require_approval
                    ? isBengali ? 'সেটআপের পর সুপার এডমিনের চূড়ান্ত অনুমোদন প্রয়োজন' : 'Requires Super Admin final approval'
                    : isBengali ? 'তাৎক্ষণিক এক্টিভেশন' : 'Immediate activation'}
                </p>
              </div>

              {!firebaseConfigured && (
                <div className="rounded-xl border border-amber-500/30 bg-amber-500/10 p-3 text-xs text-amber-200">
                  Firebase Web SDK config is required in <code className="font-mono-code">.env.local</code>.
                </div>
              )}

              {submitError && (
                <div role="alert" className="rounded-xl border border-rose-500/30 bg-rose-500/10 p-3 text-xs text-rose-200">
                  {submitError}
                </div>
              )}

              <div className="space-y-1">
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400">
                  {isBengali ? 'পূর্ণ নাম' : 'Full Name'}
                </label>
                <input
                  type="text"
                  required
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="w-full rounded-xl border border-slate-700 bg-slate-900/90 px-4 py-2.5 text-sm text-white outline-none focus:ring-2 focus:ring-blue-500/30"
                />
              </div>

              <div className="flex gap-1.5 text-xs">
                {[
                  { id: 'new_password', label: isBengali ? 'নতুন পাসওয়ার্ড' : 'Create Password' },
                  { id: 'existing_password', label: isBengali ? 'বিদ্যমান পাসওয়ার্ড' : 'Existing Password' },
                  { id: 'google', label: isBengali ? 'গুগল একাউন্ট' : 'Google Account' },
                ].map((m) => (
                  <button
                    key={m.id}
                    type="button"
                    onClick={() => setAuthMode(m.id as typeof authMode)}
                    className={`flex-1 rounded-xl border px-2 py-2 text-xs font-semibold transition ${
                      authMode === m.id
                        ? 'bg-[#003399] text-white border-[#003399] shadow-sm'
                        : 'border-slate-700 text-slate-400 hover:text-white'
                    }`}
                  >
                    {m.label}
                  </button>
                ))}
              </div>

              {authMode !== 'google' && (
                <div className="space-y-3">
                  <div className="space-y-1">
                    <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400">
                      {authMode === 'new_password'
                        ? isBengali ? 'শক্তিশালী পাসওয়ার্ড দিন (কমপক্ষে ১০ অক্ষর)' : 'Set Strong Password (min 10 chars)'
                        : isBengali ? 'বর্তমান পাসওয়ার্ড' : 'Current Password'}
                    </label>
                    <input
                      type="password"
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      className="w-full rounded-xl border border-slate-700 bg-slate-900/90 px-4 py-2.5 text-sm text-white outline-none focus:ring-2 focus:ring-blue-500/30"
                    />
                  </div>

                  {authMode === 'new_password' && (
                    <div className="space-y-1">
                      <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400">
                        {isBengali ? 'পাসওয়ার্ড পুনরায় লিখুন' : 'Confirm Password'}
                      </label>
                      <input
                        type="password"
                        required
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                        className="w-full rounded-xl border border-slate-700 bg-slate-900/90 px-4 py-2.5 text-sm text-white outline-none focus:ring-2 focus:ring-blue-500/30"
                      />
                    </div>
                  )}
                </div>
              )}

              <label className="flex items-start gap-2.5 text-xs text-slate-300 cursor-pointer pt-1">
                <input
                  type="checkbox"
                  checked={acceptedTerms}
                  onChange={(e) => setAcceptedTerms(e.target.checked)}
                  className="mt-0.5 rounded border-slate-700 text-blue-600 focus:ring-0"
                />
                <span className="leading-relaxed">
                  {isBengali
                    ? 'আমি স্বীকার করছি যে স্ক্যাভিয়ার প্রশাসনিক কার্যক্রম সম্পূর্ণভাবে অডিট লগ, শাখাভিত্তিক সীমাবদ্ধতা এবং পাসকি/এমএফএ নীতি দ্বারা নিয়ন্ত্রিত।'
                    : 'I acknowledge that SKAVIA administrative access is strictly audited, branch-scoped, and governed by MFA/Passkey security policy.'}
                </span>
              </label>

              <button
                type="submit"
                disabled={submitting || !firebaseConfigured}
                className="sakuga-spring-tap w-full flex items-center justify-center gap-2 rounded-xl py-3 px-4 text-sm font-bold text-white shadow-lg bg-[#003399] hover:bg-[#00287a] transition-all disabled:opacity-50"
              >
                <KeyRound className="h-4 w-4" />
                <span>
                  {submitting
                    ? (isBengali ? 'অ্যাক্টিভেশন সম্পন্ন হচ্ছে...' : 'Completing Activation...')
                    : (isBengali ? 'পরিচয় এক্টিভেশন সম্পন্ন করুন' : 'Complete Identity Activation')}
                </span>
              </button>
            </form>
          ) : null}
        </div>
      </main>

      <footer className="relative z-10 w-full max-w-4xl mx-auto py-3 text-center text-xs text-slate-500">
        <p>© {new Date().getFullYear()} SKAVIA Technologies Ltd. &middot; Accountable Workforce Platform</p>
      </footer>
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
