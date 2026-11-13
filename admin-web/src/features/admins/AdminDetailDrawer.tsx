'use client';

import type React from 'react';
import { ShieldAlert } from 'lucide-react';
import {
  INVITABLE_ADMIN_ROLES,
  PERMISSION_KEYS,
  type AdminRoleName,
  type PermissionKey,
} from '@/lib/contracts';
import type { AdminAccountDto } from '@/lib/types';
import { SideDrawer } from '@/components/ui/SideDrawer';
import { StatusBadge } from '@/components/ui/StatusBadge';

export function AdminDetailDrawer({
  selected,
  currentUserId,
  submitting,
  editRole,
  ovPermission,
  ovEffect,
  ovReason,
  onClose,
  onToggleSuspend,
  onChangeRole,
  onChangeOvPermission,
  onChangeOvEffect,
  onChangeOvReason,
  onSubmitOverride,
}: {
  selected: AdminAccountDto | null;
  currentUserId: string;
  submitting: boolean;
  editRole: AdminRoleName;
  ovPermission: PermissionKey;
  ovEffect: 'ALLOW' | 'DENY';
  ovReason: string;
  onClose: () => void;
  onToggleSuspend: (admin: AdminAccountDto) => void;
  onChangeRole: (role: AdminRoleName) => void;
  onChangeOvPermission: (permission: PermissionKey) => void;
  onChangeOvEffect: (effect: 'ALLOW' | 'DENY') => void;
  onChangeOvReason: (reason: string) => void;
  onSubmitOverride: (e: React.FormEvent) => void;
}) {
  return (
    <SideDrawer
      open={Boolean(selected)}
      title={selected?.full_name || ''}
      subtitle={selected ? `${selected.email} · UID: ${selected.user_id}` : undefined}
      onClose={onClose}
    >
      {selected && (
        <div className="space-y-5">
          {selected.isPrimarySuperAdmin ? (
            <div className="rounded-xl border border-indigo-300 dark:border-indigo-800/70 bg-indigo-50 dark:bg-indigo-950/50 p-4 text-xs text-indigo-950 dark:text-indigo-100 flex items-start gap-2.5">
              <ShieldAlert className="h-4 w-4 text-indigo-700 dark:text-indigo-300 shrink-0 mt-0.5" />
              <div>
                <p className="font-bold">Primary Super Admin Account Protected</p>
                <p className="mt-1 leading-relaxed">
                  The single primary Super Admin account cannot be demoted, suspended, or modified
                  through role delegation forms. Manage your Passkeys and Recovery Codes in Passkeys &amp; Profile.
                </p>
              </div>
            </div>
          ) : (
            <>
              <div className="flex items-center justify-between">
                <StatusBadge status={selected.account_status || selected.status} />
                {selected.user_id !== currentUserId && (
                  <button
                    type="button"
                    disabled={submitting}
                    onClick={() => onToggleSuspend(selected)}
                    className={`rounded-lg px-3 py-1.5 text-xs font-semibold text-white ${
                      selected.account_status === 'suspended' ? 'bg-emerald-600' : 'bg-red-600'
                    }`}
                  >
                    {selected.account_status === 'suspended'
                      ? 'Reactivate Admin'
                      : 'Suspend & Kill Sessions'}
                  </button>
                )}
              </div>

              <div>
                <h3 className="text-xs uppercase font-semibold mb-2" style={{ color: 'var(--text-muted)' }}>
                  Active Permission Overrides
                </h3>
                {selected.overrides.length === 0 ? (
                  <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                    No custom ABAC permission overrides applied.
                  </p>
                ) : (
                  <div className="space-y-1.5">
                    {selected.overrides.map((ov) => (
                      <div
                        key={ov.permission_key}
                        className="flex items-center justify-between rounded-lg border px-3 py-2 text-xs"
                        style={{ borderColor: 'var(--border-subtle)' }}
                      >
                        <span className="font-mono-code">{ov.permission_key}</span>
                        <StatusBadge
                          status={ov.effect}
                          variant={ov.effect === 'DENY' ? 'danger' : 'success'}
                        />
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <form
                onSubmit={onSubmitOverride}
                className="space-y-3 border-t pt-4"
                style={{ borderColor: 'var(--border-subtle)' }}
              >
                <h3 className="text-sm font-semibold">Apply Role Change or Permission Override</h3>

                <div>
                  <label className="block text-xs font-semibold uppercase mb-1">Role Tier</label>
                  <select
                    value={editRole}
                    onChange={(e) => onChangeRole(e.target.value as AdminRoleName)}
                    className="w-full rounded-lg border px-3 py-2 text-sm"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  >
                    {INVITABLE_ADMIN_ROLES.map((r) => (
                      <option key={r} value={r}>
                        {r}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="grid grid-cols-2 gap-2">
                  <select
                    value={ovPermission}
                    onChange={(e) => onChangeOvPermission(e.target.value as PermissionKey)}
                    className="rounded-lg border px-2.5 py-2 text-xs font-mono-code"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  >
                    {PERMISSION_KEYS.map((p) => (
                      <option key={p} value={p}>
                        {p}
                      </option>
                    ))}
                  </select>
                  <select
                    value={ovEffect}
                    onChange={(e) => onChangeOvEffect(e.target.value as 'ALLOW' | 'DENY')}
                    className="rounded-lg border px-2.5 py-2 text-xs font-semibold"
                    style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                  >
                    <option value="DENY">DENY Override</option>
                    <option value="ALLOW">ALLOW Override</option>
                  </select>
                </div>

                <input
                  type="text"
                  required
                  minLength={5}
                  value={ovReason}
                  onChange={(e) => onChangeOvReason(e.target.value)}
                  placeholder="Audit justification reason..."
                  className="w-full rounded-lg border px-3 py-2 text-sm"
                  style={{ backgroundColor: 'var(--bg-canvas)', borderColor: 'var(--border-subtle)' }}
                />

                <button
                  type="submit"
                  disabled={submitting}
                  className="w-full rounded-lg px-4 py-2 text-xs font-semibold text-white"
                  style={{ backgroundColor: '#003399' }}
                >
                  Save RBAC Update (Requires Step-Up)
                </button>
              </form>
            </>
          )}
        </div>
      )}
    </SideDrawer>
  );
}

