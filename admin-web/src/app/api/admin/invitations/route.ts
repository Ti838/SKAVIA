import { NextResponse } from 'next/server';
import { AdminInviteCreateSchema } from '@/lib/contracts';
import { recordAdminAudit } from '@/server/audit/logger';
import {
  generateSecureToken,
  hashToken,
} from '@/server/auth/crypto-tokens';
import { withAdminRoute } from '@/server/http/guard';
import { resolveActivationOrigin } from '@/server/http/origin';
import { sendAdminInvitationEmail } from '@/server/services/email';

export async function GET(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'admin.view', requirePrimarySuperAdmin: true },
    async ({ repo }) => {
      const invitations = await repo.listAdminInvitations();
      return NextResponse.json({
        invitations: invitations.map((inv) => ({
          ...inv,
          token_hash: undefined,
        })),
      });
    }
  );
}

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'admin.invite', requireStepUp: true, requirePrimarySuperAdmin: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = AdminInviteCreateSchema.parse(await req.json());
      const rawToken = generateSecureToken();
      const tokenHash = hashToken(rawToken);
      const expiresAt = new Date(
        Date.now() + input.expiresInHours * 60 * 60 * 1000
      ).toISOString();

      const created = await repo.createAdminInvitation({
        fullName: input.fullName,
        email: input.email,
        roleName: input.roleName,
        branchIds: input.branchIds,
        permissionProfile: input.permissionProfile,
        note: input.note,
        tokenHash,
        requireApproval: input.requireApproval,
        expiresAt,
        invitedBy: session.userId,
      });

      const activationUrl = `${resolveActivationOrigin(req)}/activate?token=${encodeURIComponent(
        rawToken
      )}`;

      const emailResult = await sendAdminInvitationEmail({
        to: created.email,
        fullName: created.full_name,
        roleName: created.role_name,
        branchNames: created.assigned_branch_names,
        activationUrl,
        expiresAt: created.expires_at,
        invitedByName: session.fullName,
      });

      const updated = await repo.updateInvitationState(created.invitation_id, {
        status: emailResult.status === 'Sent' ? 'Delivered' : 'Invited',
        delivery_status: emailResult.status,
        delivery_error: emailResult.error ?? null,
        sent_at: emailResult.status === 'Sent' ? new Date().toISOString() : null,
      });

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'admin.invitation.created',
        entityType: 'admin_invitation',
        entityId: created.invitation_id,
        details: {
          invited_email: created.email,
          role: created.role_name,
          branch_ids: created.assigned_branch_ids,
          delivery_status: emailResult.status,
          require_approval: created.require_approval,
          expires_at: created.expires_at,
        },
        ipAddress,
        correlationId,
      });

      return NextResponse.json(
        {
          invitation: { ...updated, token_hash: undefined },
          emailDelivery: {
            status: emailResult.status,
            provider: emailResult.provider,
            error: emailResult.error ?? null,
          },
          // Only returned once in HTTP response when automated email transport is not configured
          manualActivationUrl:
            emailResult.status !== 'Sent' ? activationUrl : undefined,
        },
        { status: 201 }
      );
    }
  );
}

