import { NextResponse } from 'next/server';
import {
  createPasskeyRegistrationOptions,
  resolveWebAuthnRp,
} from '@/server/auth/webauthn';
import { withAdminRoute } from '@/server/http/guard';

export async function POST(req: Request) {
  return withAdminRoute(req, {}, async ({ session, repo }) => {
    const { rpID } = resolveWebAuthnRp(req);
    const existing = await repo.listPasskeysForUser(session.userId);
    const options = await createPasskeyRegistrationOptions({
      rpID,
      userId: session.userId,
      email: session.email || session.userId,
      fullName: session.fullName,
      existingCredentials: existing,
    });

    const challengeRec = await repo.createWebAuthnChallenge({
      userId: session.userId,
      challenge: options.challenge,
      purpose: 'register',
      expiresAt: new Date(Date.now() + 5 * 60 * 1000).toISOString(),
    });

    return NextResponse.json({
      challengeId: challengeRec.challenge_id,
      options,
    });
  });
}

