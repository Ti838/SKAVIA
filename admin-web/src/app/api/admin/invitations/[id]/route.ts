import { NextResponse } from 'next/server';
import { z } from 'zod';
import { recordAdminAudit } from '@/server/audit/logger';
import {
  generateSecureToken,
  hashToken,
} from '@/server/auth/crypto-tokens';
import { AuthorizationError } from '@/server/auth/rbac';
import { withAdminRoute } from '@/server/http/guard';
import { resolveActivationOrigin } from '@/server/http/origin';
import { sendAdminInvitationEmail } from '@/server/services/email';

const InvitationMutationSchema = z.object({
  action: z.enum(['resend', 'revoke', 'approve']),
  expiresInHours: z.number().int().min(1).max(168).default(24),
});

export async function POST(
  req: Request,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params;
  return withAdminRoute(
    req,
    { permission: 'admin.invite', requireStepUp: true, requirePrimarySuperAdmin: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const inv = await repo.getInvitationById(id);
      if (!inv) {
        throw new AuthorizationError('NOT_FOUND', 'Invitation record not found.', 404);
      }

      const input = InvitationMutationSchema.parse(await req.json());

      if (input.action === 'revoke') {
        if (inv.status === 'Active') {
          throw new AuthorizationError(
            'ALREADY_ACTIVE',
            'Invitation is already activated; suspend or edit the admin account directly.',
            400
          );
        }
        const revoked = await repo.updateInvitationState(inv.invitation_id, {
          status: 'Revoked',
          revoked_at: new Date().toISOString(),
        });
        await recordAdminAudit(repo, {
          userId: session.userId,
          action: 'admin.invitation.revoked',
          entityType: 'admin_invitation',
          entityId: inv.invitation_id,
          details: { invited_email: inv.email },
          ipAddress,
          correlationId,
        });
        return NextResponse.json({
          invitation: { ...revoked, token_hash: undefined },
        });
      }

      if (input.action === 'approve') {
        if (inv.status !== 'PendingApproval' || !inv.activated_user_id) {
          throw new AuthorizationError(
            'INVALID_APPROVAL_STATE',
            'Only invitations in PendingApproval status with an onboarded Firebase account can be approved.',
            400
          );
        }
        await repo.updateAdminPermissions(
          inv.activated_user_id,
          { reactivate: true },
          session.userId
        );
        const now = new Date().toISOString();
        const approved = await repo.updateInvitationState(inv.invitation_id, {
          status: 'Active',
          approved_by: session.userId,
          approved_at: now,
          activated_at: inv.activated_at ?? now,
        });
        await recordAdminAudit(repo, {
          userId: session.userId,
          action: 'admin.invitation.approved',
          entityType: 'admin_invitation',
          entityId: inv.invitation_id,
          details: {
            invited_email: inv.email,
            activated_user_id: inv.activated_user_id,
          },
          ipAddress,
          correlationId,
        });
        return NextResponse.json({
          invitation: { ...approved, token_hash: undefined },
        });
      }

      // action === 'resend': invalidate old token via fresh hash + extend expiry
      if (inv.status === 'Active' || inv.status === 'Revoked') {
        throw new AuthorizationError(
          'INVALID_RESEND_STATE',
          `Cannot resend an invitation in ${inv.status} state.`,
          400
        );
      }

      const rawToken = generateSecureToken();
      const tokenHash = hashToken(rawToken);
      const expiresAt = new Date(
        Date.now() + input.expiresInHours * 60 * 60 * 1000
      ).toISOString();
      const activationUrl = `${resolveActivationOrigin(req)}/activate?token=${encodeURIComponent(
        rawToken
      )}`;

      const emailResult = await sendAdminInvitationEmail({
        to: inv.email,
        fullName: inv.full_name,
        roleName: inv.role_name,
        branchNames: inv.assigned_branch_names,
        activationUrl,
        expiresAt,
        invitedByName: session.fullName,
      });

      const resent = await repo.updateInvitationState(inv.invitation_id, {
        token_hash: tokenHash,
        expires_at: expiresAt,
        status: emailResult.status === 'Sent' ? 'Delivered' : 'Invited',
        delivery_status: emailResult.status,
        delivery_error: emailResult.error ?? null,
        sent_at: emailResult.status === 'Sent' ? new Date().toISOString() : inv.sent_at,
      });

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'admin.invitation.resent',
        entityType: 'admin_invitation',
        entityId: inv.invitation_id,
        details: {
          invited_email: inv.email,
          delivery_status: emailResult.status,
          expires_at: expiresAt,
        },
        ipAddress,
        correlationId,
      });

      return NextResponse.json({
        invitation: { ...resent, token_hash: undefined },
        emailDelivery: {
          status: emailResult.status,
          provider: emailResult.provider,
          error: emailResult.error ?? null,
        },
        manualActivationUrl:
          emailResult.status !== 'Sent' ? activationUrl : undefined,
      });
    }
  );
}

