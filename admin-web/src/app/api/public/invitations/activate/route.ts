import { NextResponse } from 'next/server';
import { InvitationActivateSchema } from '@/lib/contracts';
import { extractClientIp, recordAdminAudit } from '@/server/audit/logger';
import { hashToken } from '@/server/auth/crypto-tokens';
import { verifyFirebaseIdToken } from '@/server/auth/firebase-jwt';
import { AuthorizationError } from '@/server/auth/rbac';
import { getAdminRepository } from '@/server/db/store-factory';
import { jsonErrorResponse } from '@/server/http/guard';

export async function POST(req: Request) {
  const correlationId = req.headers.get('x-correlation-id') || crypto.randomUUID();
  const ipAddress = extractClientIp(req);
  const userAgent = req.headers.get('user-agent');

  try {
    const repo = getAdminRepository();
    const input = InvitationActivateSchema.parse(await req.json());
    const tokenHash = hashToken(input.token);

    const inv = await repo.getInvitationByTokenHash(tokenHash);
    if (!inv) {
      throw new AuthorizationError(
        'INVITATION_NOT_FOUND',
        'Invitation link is invalid or superseded.',
        404
      );
    }

    if (inv.status === 'Revoked') {
      throw new AuthorizationError('INVITATION_REVOKED', 'This invitation was revoked.', 410);
    }
    if (inv.status === 'Expired') {
      throw new AuthorizationError('INVITATION_EXPIRED', 'This invitation has expired.', 410);
    }
    if (inv.status === 'Active' || inv.status === 'PendingApproval') {
      throw new AuthorizationError(
        'INVITATION_ALREADY_USED',
        'Single-use invitation token has already been consumed.',
        409
      );
    }

    let verified: Awaited<ReturnType<typeof verifyFirebaseIdToken>>;
    try {
      verified = await verifyFirebaseIdToken(input.idToken);
    } catch {
      throw new AuthorizationError(
        'INVALID_TOKEN',
        'Authenticated Firebase credential is required to complete activation.',
        401
      );
    }

    if (!verified.email || verified.email.toLowerCase() !== inv.email.toLowerCase()) {
      throw new AuthorizationError(
        'EMAIL_MISMATCH',
        'Authenticated account email must match the invited administrator email.',
        403
      );
    }

    await repo.updateInvitationState(inv.invitation_id, {
      status: 'SetupInProgress',
      setup_started_at: inv.setup_started_at ?? new Date().toISOString(),
    });

    const targetStatus = inv.require_approval ? 'PendingApproval' : 'Active';

    await repo.activateInvitedAdmin({
      invitationId: inv.invitation_id,
      userId: verified.uid,
      email: inv.email,
      fullName: input.fullName || inv.full_name,
      status: targetStatus,
    });

    await repo.recordLoginEvent({
      userId: verified.uid,
      email: inv.email,
      surface: 'admin',
      outcome: 'Invite_Activated',
      mfaMethod: verified.mfaMethod || 'password',
      ipAddress,
      userAgent,
      failureReason:
        targetStatus === 'PendingApproval'
          ? 'Onboarding submitted; awaiting Super Admin approval'
          : 'Invitation activated immediately',
    });

    await recordAdminAudit(repo, {
      userId: verified.uid,
      action: 'admin.invitation.activated',
      entityType: 'admin_invitation',
      entityId: inv.invitation_id,
      details: {
        role: inv.role_name,
        target_status: targetStatus,
        branch_ids: inv.assigned_branch_ids,
        accepted_terms: true,
      },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({
      activated: true,
      status: targetStatus,
      userId: verified.uid,
      roleName: inv.role_name,
      message:
        targetStatus === 'PendingApproval'
          ? 'Identity setup complete. Your account is now awaiting final Super Admin approval.'
          : 'Account activated successfully. You can now sign in to the Internal Admin Portal.',
    });
  } catch (error) {
    return jsonErrorResponse(error, correlationId);
  }
}

