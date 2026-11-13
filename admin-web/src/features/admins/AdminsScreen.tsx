'use client';

import dynamic from 'next/dynamic';
import { useCallback, useEffect, useState } from 'react';
import {
  CheckCircle2,
  Copy,
  Fingerprint,
  MailPlus,
  RefreshCw,
  XCircle,
} from 'lucide-react';
import type { AdminRoleName, PermissionKey } from '@/lib/contracts';
import { AdminApiError, apiFetch } from '@/lib/api-client';
import { formatDateTime } from '@/lib/formatters';
import type {
  AdminAccountDto,
  AdminInvitationDto,
  BranchSummary,
} from '@/lib/types';
import { useAdminSession } from '@/components/shell/SessionProvider';
import { DataTable, type TableColumn } from '@/components/ui/DataTable';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ErrorPanel, LoadingPanel } from '@/components/ui/StatePanels';
import { AdminDetailDrawer } from './AdminDetailDrawer';

const AdminInvitePanel = dynamic(
  () => import('./AdminInvitePanel').then((m) => m.AdminInvitePanel),
  { ssr: false }
);

export default function AdminsPage() {
  const { session } = useAdminSession();
  const [tab, setTab] = useState<'directory' | 'invitations'>('directory');

  const [admins, setAdmins] = useState<AdminAccountDto[]>([]);
  const [invitations, setInvitations] = useState<AdminInvitationDto[]>([]);
  const [branches, setBranches] = useState<BranchSummary[]>([]);
  const [selected, setSelected] = useState<AdminAccountDto | null>(null);

  const [showInviteForm, setShowInviteForm] = useState(false);

  const [inviteOutcomeBanner, setInviteOutcomeBanner] = useState<{
    message: string;
    manualUrl?: string;
  } | null>(null);

  // Edit drawer state
  const [editRole, setEditRole] = useState<AdminRoleName>('Branch Manager');
  const [ovPermission, setOvPermission] = useState<PermissionKey>('branch.view');
  const [ovEffect, setOvEffect] = useState<'ALLOW' | 'DENY'>('DENY');
  const [ovReason, setOvReason] = useState('');

  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [aRes, bRes, iRes] = await Promise.all([
        apiFetch<{ admins: AdminAccountDto[] }>('/api/admin/admins'),
        apiFetch<{ branches: BranchSummary[] }>('/api/admin/branches'),
        apiFetch<{ invitations: AdminInvitationDto[] }>('/api/admin/invitations'),
      ]);
      setAdmins(aRes.admins);
      setBranches(bRes.branches);
      setInvitations(iRes.invitations);
    } catch (err) {
      setError(
        err instanceof AdminApiError
          ? err.message
          : 'Failed loading Super Admin governance console.'
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  async function handleInvitationCreated(outcome: {
    message: string;
    manualUrl?: string;
  }) {
    setError(null);
    setShowInviteForm(false);
    setTab('invitations');
    setInviteOutcomeBanner(outcome);
    await loadData();
  }

  async function handleInvitationAction(
    invitationId: string,
    action: 'resend' | 'revoke' | 'approve'
  ) {
    setSubmitting(true);
    setError(null);
    setInviteOutcomeBanner(null);
    try {
      const res = await apiFetch<{
        invitation: AdminInvitationDto;
        emailDelivery?: { status: string; provider: string };
        manualActivationUrl?: string;
      }>(`/api/admin/invitations/${invitationId}`, {
        method: 'POST',
        body: JSON.stringify({ action }),
      });

      if (action === 'resend') {
        setInviteOutcomeBanner({
          message:
            res.emailDelivery?.status === 'Sent'
              ? 'Fresh single-use invitation link dispatched via email.'
              : `Token rotated cleanly (Email status: ${res.emailDelivery?.status || 'NotConfigured'}). Share the new one-time link:`,
          manualUrl: res.manualActivationUrl,
        });
      }
      await loadData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : `Invitation ${action} failed.`);
    } finally {
      setSubmitting(false);
    }
  }

  async function handleSaveOverride(e: React.FormEvent) {
    e.preventDefault();
    if (!selected) return;
    setSubmitting(true);
    setError(null);
    try {
      const res = await apiFetch<{ admin: AdminAccountDto }>(
        `/api/admin/admins/${selected.user_id}`,
        {
          method: 'PATCH',
          body: JSON.stringify({
            roleName: editRole,
            override: {
              permissionKey: ovPermission,
              effect: ovEffect,
              reason: ovReason.trim(),
            },
          }),
        }
      );
      setSelected(res.admin);
      setOvReason('');
      await loadData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Permission update failed.');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleToggleSuspend(admin: AdminAccountDto) {
    setSubmitting(true);
    setError(null);
    try {
      const suspending = admin.account_status !== 'suspended';
      const res = await apiFetch<{ admin: AdminAccountDto }>(
        `/api/admin/admins/${admin.user_id}`,
        {
          method: 'PATCH',
          body: JSON.stringify(
            suspending
              ? { suspendReason: 'Administrative access suspended by Primary Super Admin' }
              : { reactivate: true }
          ),
        }
      );
      setSelected(res.admin);
      await loadData();
    } catch (err) {
      setError(err instanceof AdminApiError ? err.message : 'Status update failed.');
    } finally {
      setSubmitting(false);
    }
  }

  const adminColumns: TableColumn<AdminAccountDto>[] = [
    {
      key: 'name',
      header: 'Administrator',
      render: (r) => (
        <div>
          <div className="flex items-center gap-1.5">
            <p className="font-medium">{r.full_name}</p>
            {r.isPrimarySuperAdmin && (
              <span className="rounded bg-indigo-100 dark:bg-indigo-950/70 px-1.5 py-0.5 text-[10px] font-bold text-indigo-800 dark:text-indigo-200">
                PRIMARY ROOT
              </span>
            )}
          </div>
          <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
            {r.email} &middot; v{r.permissionVersion}
          </p>
        </div>
      ),
    },
    {
      key: 'roles',
      header: 'Role',
      render: (r) => (
        <div className="flex flex-wrap gap-1">
          {r.roles.map((role) => (
            <StatusBadge key={role} status={role} variant="info" />
          ))}
        </div>
      ),
    },
    {
      key: 'branches',
      header: 'Branch Scope',
      render: (r) =>
        r.assignedBranches.length > 0 && r.roles.includes('Branch Manager')
          ? r.assignedBranches.map((b) => b.code).join(', ')
          : r.roles.includes('Branch Manager')
            ? 'Unassigned'
            : 'All SKAVIA Branches',
    },
    {
      key: 'passkey',
      header: 'Passkey / MFA',
      render: (r) => (
        <span className="inline-flex items-center gap-1 text-xs">
          <Fingerprint className={`h-3.5 w-3.5 ${r.passkeyEnrolled ? 'text-emerald-600' : 'text-slate-400'}`} />
          {r.passkeyEnrolled ? 'Enrolled' : r.mfaEnforced ? 'MFA Enforced' : 'Standard'}
        </span>
      ),
    },
    {
      key: 'lastLogin',
      header: 'Last Login',
      render: (r) => (
        <div className="text-xs">
          <p>{formatDateTime(r.lastLoginAt)}</p>
          {r.lastLoginIp && <p style={{ color: 'var(--text-muted)' }}>{r.lastLoginIp}</p>}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (r) => <StatusBadge status={r.account_status || r.status} />,
    },
  ];

  const inviteColumns: TableColumn<AdminInvitationDto>[] = [
    {
      key: 'recipient',
      header: 'Invited Admin',
      render: (r) => (
        <div>
          <p className="font-medium">{r.full_name}</p>
          <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
            {r.email}
          </p>
        </div>
      ),
    },
    {
      key: 'role',
      header: 'Role & Scope',
      render: (r) => (
        <div className="space-y-1">
          <StatusBadge status={r.role_name} variant="info" />
          <p className="text-[11px]" style={{ color: 'var(--text-muted)' }}>
            {r.assigned_branch_names.length > 0
              ? r.assigned_branch_names.join(', ')
              : 'All Branches'}
          </p>
        </div>
      ),
    },
    {
      key: 'delivery',
      header: 'Email Delivery',
      render: (r) => (
        <div>
          <StatusBadge status={r.delivery_status} />
          {r.delivery_error && (
            <p className="text-[10px] mt-0.5 max-w-[180px] truncate" title={r.delivery_error}>
              {r.delivery_error}
            </p>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Lifecycle State',
      render: (r) => <StatusBadge status={r.status} />,
    },
    {
      key: 'expires',
      header: 'Expires',
      render: (r) => <span className="text-xs">{formatDateTime(r.expires_at)}</span>,
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (r) => (
        <div className="flex justify-end gap-1.5">
          {r.status === 'PendingApproval' && (
            <button
              type="button"
              disabled={submitting}
              onClick={() => void handleInvitationAction(r.invitation_id, 'approve')}
              className="inline-flex items-center gap-1 rounded-md bg-emerald-600 px-2.5 py-1 text-[11px] font-semibold text-white"
            >
              <CheckCircle2 className="h-3 w-3" />
              Approve
            </button>
          )}
          {r.status !== 'Active' && r.status !== 'Revoked' && (
            <button
              type="button"
              disabled={submitting}
              onClick={() => void handleInvitationAction(r.invitation_id, 'resend')}
              className="inline-flex items-center gap-1 rounded-md border px-2 py-1 text-[11px] font-medium"
              style={{ borderColor: 'var(--border-subtle)' }}
            >
              <RefreshCw className="h-3 w-3" />
              Resend
            </button>
          )}
          {r.status !== 'Active' && r.status !== 'Revoked' && (
            <button
              type="button"
              disabled={submitting}
              onClick={() => void handleInvitationAction(r.invitation_id, 'revoke')}
              className="inline-flex items-center gap-1 rounded-md bg-red-600 px-2 py-1 text-[11px] font-semibold text-white"
            >
              <XCircle className="h-3 w-3" />
              Revoke
            </button>
          )}
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Super Admin Governance &amp; Invitations</h1>
          <p className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>
            Single primary Super Admin governance for internal Company Admins, Branch Managers, and single-use invitations.
          </p>
        </div>

        <button
          type="button"
          onClick={() => setShowInviteForm((v) => !v)}
          className="inline-flex items-center gap-1.5 rounded-lg px-4 py-2 text-xs font-semibold text-white"
          style={{ backgroundColor: '#003399' }}
        >
          <MailPlus className="h-4 w-4" />
          Invite Internal Admin
        </button>
      </div>

      {inviteOutcomeBanner && (
        <div className="rounded-xl border border-blue-300 dark:border-blue-800/70 bg-blue-50 dark:bg-blue-950/40 p-4 text-xs text-blue-950 dark:text-blue-100 space-y-2">
          <p className="font-semibold">{inviteOutcomeBanner.message}</p>
          {inviteOutcomeBanner.manualUrl && (
            <div className="flex flex-wrap items-center gap-2 rounded-lg bg-white dark:bg-slate-900 border border-blue-200 dark:border-blue-800/70 p-2.5 font-mono-code text-[11px] break-all">
              <span className="flex-1">{inviteOutcomeBanner.manualUrl}</span>
              <button
                type="button"
                onClick={() => void navigator.clipboard.writeText(inviteOutcomeBanner.manualUrl!)}
                className="inline-flex items-center gap-1 rounded bg-blue-700 px-2.5 py-1 text-white font-sans font-semibold shrink-0"
              >
                <Copy className="h-3 w-3" />
                Copy Link
              </button>
            </div>
          )}
        </div>
      )}

      {showInviteForm && (
        <AdminInvitePanel
          branches={branches}
          onCreated={handleInvitationCreated}
          onError={(msg) => setError(msg)}
        />
      )}

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => setTab('directory')}
          className={`rounded-lg border px-3.5 py-2 text-xs font-semibold ${
            tab === 'directory' ? 'bg-blue-700 text-white border-blue-700' : ''
          }`}
          style={tab !== 'directory' ? { borderColor: 'var(--border-subtle)' } : undefined}
        >
          Admin Directory ({admins.length})
        </button>
        <button
          type="button"
          onClick={() => setTab('invitations')}
          className={`rounded-lg border px-3.5 py-2 text-xs font-semibold ${
            tab === 'invitations' ? 'bg-blue-700 text-white border-blue-700' : ''
          }`}
          style={tab !== 'invitations' ? { borderColor: 'var(--border-subtle)' } : undefined}
        >
          Invitations &amp; Approvals ({invitations.length})
        </button>
      </div>

      {error && <ErrorPanel message={error} onRetry={() => void loadData()} />}

      {loading ? (
        <LoadingPanel />
      ) : tab === 'directory' ? (
        <DataTable
          columns={adminColumns}
          rows={admins}
          rowKey={(r) => r.user_id}
          onRowClick={(r) => {
            setSelected(r);
            setEditRole(r.roles[0] || 'Branch Manager');
          }}
        />
      ) : (
        <DataTable
          columns={inviteColumns}
          rows={invitations}
          rowKey={(r) => r.invitation_id}
          emptyTitle="No invitations issued yet"
          emptyDescription="Use Invite Internal Admin to onboard a verified Company Admin or Branch Manager."
        />
      )}

      <AdminDetailDrawer
        selected={selected}
        currentUserId={session.userId}
        submitting={submitting}
        editRole={editRole}
        ovPermission={ovPermission}
        ovEffect={ovEffect}
        ovReason={ovReason}
        onClose={() => setSelected(null)}
        onToggleSuspend={(admin) => void handleToggleSuspend(admin)}
        onChangeRole={setEditRole}
        onChangeOvPermission={setOvPermission}
        onChangeOvEffect={setOvEffect}
        onChangeOvReason={setOvReason}
        onSubmitOverride={(e) => void handleSaveOverride(e)}
      />
    </div>
  );
}
