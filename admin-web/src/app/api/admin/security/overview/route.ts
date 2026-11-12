import { NextResponse } from 'next/server';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'security.audit.view', requirePrimarySuperAdmin: true, requireStepUp: false },
    async ({ repo }) => {
      const [loginEvents, passkeys, invitations] = await Promise.all([
        repo.listLoginEvents(100),
        repo.listAllPasskeys(),
        repo.listAdminInvitations(),
      ]);

      return NextResponse.json({
        loginEvents,
        passkeys: passkeys.map((p) => ({
          credential_id: p.credential_id,
          user_id: p.user_id,
          friendly_name: p.friendly_name,
          device_type: p.device_type,
          backed_up: p.backed_up,
          transports: p.transports,
          last_used_at: p.last_used_at,
          revoked_at: p.revoked_at,
          created_at: p.created_at,
        })),
        invitationsSummary: {
          total: invitations.length,
          pendingApproval: invitations.filter((i) => i.status === 'PendingApproval').length,
          active: invitations.filter((i) => i.status === 'Active').length,
          awaitingAcceptance: invitations.filter((i) =>
            ['Invited', 'Delivered', 'Opened', 'SetupInProgress'].includes(i.status)
          ).length,
        },
      });
    }
  );
}

