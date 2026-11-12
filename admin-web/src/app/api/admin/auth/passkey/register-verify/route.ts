import { NextResponse } from 'next/server';
import type { RegistrationResponseJSON } from '@simplewebauthn/server';
import { z } from 'zod';
import { recordAdminAudit } from '@/server/audit/logger';
import { AuthorizationError } from '@/server/auth/rbac';
import {
  resolveWebAuthnRp,
  verifyPasskeyRegistration,
} from '@/server/auth/webauthn';
import { withAdminRoute } from '@/server/http/guard';

const RegisterVerifySchema = z.object({
  challengeId: z.string().uuid(),
  friendlyName: z.string().trim().min(2).max(120).default('Biometric Passkey'),
  response: z.custom<RegistrationResponseJSON>(
    (v) => Boolean(v && typeof v === 'object' && 'id' in v && 'response' in v),
    'Valid WebAuthn registration payload required.'
  ),
});

export async function POST(req: Request) {
  return withAdminRoute(req, {}, async ({ session, repo, correlationId, ipAddress }) => {
    const input = RegisterVerifySchema.parse(await req.json());
    const challengeRec = await repo.consumeWebAuthnChallenge(input.challengeId, 'register');
    if (!challengeRec || challengeRec.user_id !== session.userId) {
      throw new AuthorizationError(
        'CHALLENGE_INVALID',
        'Passkey registration challenge expired or invalid.',
        400
      );
    }

    const { rpID, expectedOrigin } = resolveWebAuthnRp(req);
    const verification = await verifyPasskeyRegistration({
      response: input.response,
      expectedChallenge: challengeRec.challenge,
      expectedOrigin,
      expectedRPID: rpID,
    });

    if (!verification.verified || !verification.registrationInfo) {
      throw new AuthorizationError(
        'PASSKEY_VERIFICATION_FAILED',
        'Passkey cryptographic attestation failed.',
        400
      );
    }

    const info = verification.registrationInfo;
    const saved = await repo.savePasskeyCredential({
      credentialId: info.credential.id,
      userId: session.userId,
      friendlyName: input.friendlyName,
      publicKey: Buffer.from(info.credential.publicKey).toString('base64url'),
      counter: info.credential.counter,
      transports: (info.credential.transports ?? []).map(String),
      deviceType: info.credentialDeviceType,
      backedUp: info.credentialBackedUp,
      aaguid: info.aaguid || null,
    });

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: 'admin.passkey.enrolled',
      entityType: 'admin_passkey',
      entityId: saved.credential_id,
      details: {
        friendly_name: saved.friendly_name,
        device_type: saved.device_type,
        backed_up: saved.backed_up,
      },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({ credential: saved }, { status: 201 });
  });
}

