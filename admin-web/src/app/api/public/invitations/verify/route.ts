import { NextResponse } from 'next/server';
import { hashToken } from '@/server/auth/crypto-tokens';
import { getAdminRepository } from '@/server/db/store-factory';
import { jsonErrorResponse } from '@/server/http/guard';

function maskEmail(email: string): string {
  const [local = '', domain = ''] = email.split('@');
  if (!domain) return '***';
  const visible = local.slice(0, Math.min(2, local.length));
  return `${visible}***@${domain}`;
}

export async function GET(req: Request) {
  const correlationId = req.headers.get('x-correlation-id') || crypto.randomUUID();
  try {
    const url = new URL(req.url);
    const rawToken = (url.searchParams.get('token') || '').trim();
    if (rawToken.length < 24) {
      return NextResponse.json(
        {
          error: {
            code: 'INVALID_TOKEN',
            message: 'Invitation token is missing or malformed.',
            correlationId,
          },
        },
        { status: 400 }
      );
    }

    const repo = getAdminRepository();
    const tokenHash = hashToken(rawToken);
    const inv = await repo.getInvitationByTokenHash(tokenHash);
    if (!inv) {
      return NextResponse.json(
        {
          error: {
            code: 'INVITATION_NOT_FOUND',
            message: 'Invitation link is invalid or superseded.',
            correlationId,
          },
        },
        { status: 404 }
      );
    }

    if (inv.status === 'Revoked') {
      return NextResponse.json(
        {
          error: {
            code: 'INVITATION_REVOKED',
            message: 'This invitation was revoked by the SKAVIA Super Admin.',
            correlationId,
          },
        },
        { status: 410 }
      );
    }

    if (inv.status === 'Expired') {
      return NextResponse.json(
        {
          error: {
            code: 'INVITATION_EXPIRED',
            message: 'This invitation has expired. Ask the Super Admin to issue a fresh invite.',
            correlationId,
          },
        },
        { status: 410 }
      );
    }

    if (inv.status === 'Active' || inv.status === 'PendingApproval') {
      return NextResponse.json(
        {
          error: {
            code: 'INVITATION_ALREADY_USED',
            message: `This invitation has already been completed (current status: ${inv.status}).`,
            correlationId,
          },
        },
        { status: 409 }
      );
    }

    if (inv.status === 'Invited' || inv.status === 'Delivered' || inv.status === 'Draft') {
      await repo.updateInvitationState(inv.invitation_id, {
        status: 'Opened',
        opened_at: inv.opened_at ?? new Date().toISOString(),
      });
    }

    return NextResponse.json({
      invitation: {
        invitation_id: inv.invitation_id,
        full_name: inv.full_name,
        email: inv.email,
        maskedEmail: maskEmail(inv.email),
        role_name: inv.role_name,
        assigned_branch_names: inv.assigned_branch_names,
        require_approval: inv.require_approval,
        expires_at: inv.expires_at,
        status: inv.status === 'Invited' || inv.status === 'Delivered' ? 'Opened' : inv.status,
      },
    });
  } catch (error) {
    return jsonErrorResponse(error, correlationId);
  }
}

