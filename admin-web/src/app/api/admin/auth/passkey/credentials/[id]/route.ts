import { NextResponse } from 'next/server';
import { recordAdminAudit } from '@/server/audit/logger';
import { AuthorizationError } from '@/server/auth/rbac';
import { withAdminRoute } from '@/server/http/guard';

export async function DELETE(
  req: Request,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params;
  const decodedId = decodeURIComponent(id);

  return withAdminRoute(req, { requireStepUp: true }, async ({ session, repo, correlationId, ipAddress }) => {
    const cred = await repo.getPasskeyById(decodedId);
    if (!cred) {
      throw new AuthorizationError('NOT_FOUND', 'Passkey credential not found.', 404);
    }

    const isOwner = cred.user_id === session.userId;
    if (!isOwner && !session.isPrimarySuperAdmin) {
      throw new AuthorizationError(
        'FORBIDDEN',
        'You can only revoke passkeys registered to your own account.',
        403
      );
    }

    await repo.revokePasskey(cred.credential_id, session.userId);

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: 'admin.passkey.revoked',
      entityType: 'admin_passkey',
      entityId: cred.credential_id,
      details: { target_user_id: cred.user_id, friendly_name: cred.friendly_name },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({ revoked: true, credentialId: cred.credential_id });
  });
}

