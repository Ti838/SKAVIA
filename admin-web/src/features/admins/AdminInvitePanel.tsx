'use client';

import type React from 'react';
import { useState } from 'react';
import { ShieldPlus } from 'lucide-react';
import {
  INVITABLE_ADMIN_ROLES,
  type InvitableAdminRole,
} from '@/lib/contracts';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import type { AdminInvitationDto, BranchSummary } from '@/lib/types';

export function AdminInvitePanel({
  branches,
  onCreated,
  onError,
}: {
  branches: BranchSummary[];
  onCreated: (outcome: { message: string; manualUrl?: string }) => Promise<void> | void;
  onError: (message: string) => void;
}) {
  const [invFullName, setInvFullName] = useState('');
  const [invEmail, setInvEmail] = useState('');
  const [invRole, setInvRole] = useState<InvitableAdminRole>('Branch Manager');
  const [invBranchIds, setInvBranchIds] = useState<string[]>([]);
  const [invHours, setInvHours] = useState(24);
  const [invRequireApproval, setInvRequireApproval] = useState(true);
  const [invNote, setInvNote] = useState('');
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    try {
      const res = await apiFetch<{
        invitation: AdminInvitationDto;
        emailDelivery: { status: string; provider: string; error: string | null };
        manualActivationUrl?: string;
      }>('/api/admin/invitations', {
        method: 'POST',
        body: JSON.stringify({
          fullName: invFullName.trim(),
          email: invEmail.trim().toLowerCase(),
          roleName: invRole,
          branchIds: invBranchIds,
          expiresInHours: invHours,
          requireApproval: invRequireApproval,
          note: invNote.trim() || undefined,
        }),
      });

      setInvFullName('');
      setInvEmail('');
      setInvBranchIds([]);
      setInvNote('');

      await onCreated({
        message:
          res.emailDelivery.status === 'Sent'
            ? `Invitation created and dispatched via ${res.emailDelivery.provider}.`
            : `Invitation recorded (Email transport status: ${res.emailDelivery.status}). Use the one-time activation link below for secure manual handoff:`,
        manualUrl: res.manualActivationUrl,
      });
    } catch (err) {
      onError(err instanceof AdminApiError ? err.message : 'Failed issuing admin invitation.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="rounded-xl border p-5 space-y-4"
      style={{ backgroundColor: 'var(--bg-surface)', borderColor: 'var(--border-subtle)' }}
    >
      <div className="flex items-center justify-between">
        <h2 className="text-base font-semibold flex items-center gap-2">
          <ShieldPlus className="h-4 w-4 text-blue-700" />
          Issue Official Admin Invitation
        </h2>
        <span className="text-[11px]" style={{ color: 'var(--text-muted)' }}>
          Single-use SHA-256 hashed token &middot; Step-Up MFA required
        </span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
        <input
          type="text"
          required
          value={invFullName}
          onChange={(e) => setInvFullName(e.target.value)}
          placeholder="Full Name"
          className="rounded-lg border px-3 py-2 text-sm"
          style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
        />
        <input
          type="email"
          required
          value={invEmail}
          onChange={(e) => setInvEmail(e.target.value)}
          placeholder="invitee@skavia.com"
          className="rounded-lg border px-3 py-2 text-sm"
          style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
        />
        <select
          value={invRole}
          onChange={(e) => setInvRole(e.target.value as InvitableAdminRole)}
          className="rounded-lg border px-3 py-2 text-sm"
          style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
        >
          {INVITABLE_ADMIN_ROLES.map((r) => (
            <option key={r} value={r}>
              {r}
            </option>
          ))}
        </select>
      </div>

      {invRole === 'Branch Manager' && (
        <div>
          <p className="text-xs font-semibold mb-1.5">
            Assign Branch Scope (Required for Branch Managers):
          </p>
          <div className="flex flex-wrap gap-2">
            {branches.map((b) => {
              const checked = invBranchIds.includes(b.branch_id);
              return (
                <label
                  key={b.branch_id}
                  className={`inline-flex items-center gap-1.5 rounded-lg border px-3 py-1.5 text-xs cursor-pointer ${
                    checked
                      ? 'border-blue-600 bg-blue-50 dark:bg-blue-950/60 text-blue-900 dark:text-blue-100'
                      : ''
                  }`}
                  style={!checked ? { borderColor: 'var(--border-subtle)' } : undefined}
                >
                  <input
                    type="checkbox"
                    checked={checked}
                    onChange={(e) =>
                      setInvBranchIds((prev) =>
                        e.target.checked
                          ? [...prev, b.branch_id]
                          : prev.filter((id) => id !== b.branch_id)
                      )
                    }
                  />
                  {b.name} ({b.code})
                </label>
              );
            })}
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-3 items-center">
        <div>
          <label className="block text-[11px] font-semibold uppercase mb-1">
            Token Expiry (Hours)
          </label>
          <input
            type="number"
            min={1}
            max={168}
            value={invHours}
            onChange={(e) => setInvHours(Number(e.target.value) || 24)}
            className="w-full rounded-lg border px-3 py-2 text-sm"
            style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
          />
        </div>

        <div className="md:col-span-2">
          <label className="block text-[11px] font-semibold uppercase mb-1">
            Internal Note (Optional)
          </label>
          <input
            type="text"
            value={invNote}
            onChange={(e) => setInvNote(e.target.value)}
            placeholder="Reason for role delegation or territory note"
            className="w-full rounded-lg border px-3 py-2 text-sm"
            style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
          />
        </div>
      </div>

      <div className="flex flex-wrap items-center justify-between gap-3">
        <label className="flex items-center gap-2 text-xs cursor-pointer">
          <input
            type="checkbox"
            checked={invRequireApproval}
            onChange={(e) => setInvRequireApproval(e.target.checked)}
          />
          <span>Require final Super Admin approval before invited admin can sign in</span>
        </label>

        <button
          type="submit"
          disabled={submitting}
          className="rounded-lg px-4 py-2 text-xs font-semibold text-white"
          style={{ backgroundColor: '#003399' }}
        >
          {submitting ? 'Issuing Invitation...' : 'Create & Send Official Invitation'}
        </button>
      </div>
    </form>
  );
}

