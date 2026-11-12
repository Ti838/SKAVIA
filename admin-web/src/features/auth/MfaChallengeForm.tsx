'use client';

import type React from 'react';
import { ShieldCheck } from 'lucide-react';

export function MfaChallengeForm({
  hintLabel,
  totpCode,
  loading,
  onChangeCode,
  onCancel,
  onSubmit,
}: {
  hintLabel: string;
  totpCode: string;
  loading: boolean;
  onChangeCode: (code: string) => void;
  onCancel: () => void;
  onSubmit: (e: React.FormEvent) => void;
}) {
  return (
    <form onSubmit={onSubmit} className="space-y-4">
      <div className="rounded-lg bg-blue-50 dark:bg-blue-950/40 border border-blue-200 dark:border-blue-800 p-3 text-xs text-blue-900 dark:text-blue-200">
        <div className="flex items-center gap-1.5 font-semibold">
          <ShieldCheck className="h-4 w-4 text-blue-700 dark:text-blue-300" />
          Second Factor Required ({hintLabel})
        </div>
        <p className="mt-1">
          Enter the 6-digit verification code from your enrolled authenticator app.
        </p>
      </div>

      <div>
        <label
          htmlFor="totp-code"
          className="block text-xs font-semibold uppercase tracking-wider mb-1.5"
          style={{ color: 'var(--text-secondary)' }}
        >
          6-Digit TOTP Code
        </label>
        <input
          id="totp-code"
          type="text"
          inputMode="numeric"
          pattern="[0-9]{6}"
          maxLength={6}
          required
          autoFocus
          value={totpCode}
          onChange={(e) => onChangeCode(e.target.value)}
          placeholder="123456"
          className="w-full rounded-lg border px-3.5 py-2.5 text-center text-lg font-mono-code tracking-widest outline-none focus:ring-2 focus:ring-blue-500"
          style={{
            backgroundColor: 'var(--bg-canvas)',
            borderColor: 'var(--border-subtle)',
            color: 'var(--text-primary)',
          }}
        />
      </div>

      <div className="flex gap-2">
        <button
          type="button"
          onClick={onCancel}
          className="flex-1 rounded-lg border px-4 py-2.5 text-sm font-medium"
          style={{ borderColor: 'var(--border-subtle)' }}
        >
          Back
        </button>
        <button
          type="submit"
          disabled={loading}
          className="flex-1 rounded-lg px-4 py-2.5 text-sm font-semibold text-white disabled:opacity-50"
          style={{ backgroundColor: '#003399' }}
        >
          {loading ? 'Verifying MFA...' : 'Verify & Enter'}
        </button>
      </div>
    </form>
  );
}
