import { NextResponse } from 'next/server';
import { z } from 'zod';
import { resolveVerifiedAdminSession } from '@/server/auth/session';
import {
  createPasskeyAuthenticationOptions,
  resolveWebAuthnRp,
} from '@/server/auth/webauthn';
import { getAdminRepository } from '@/server/db/store-factory';
import { jsonErrorResponse } from '@/server/http/guard';

const AuthOptionsSchema = z.object({
  mode: z.enum(['login', 'step_up']).default('login'),
});

export async function POST(req: Request) {
  const correlationId = req.headers.get('x-correlation-id') || crypto.randomUUID();
  try {
    const repo = getAdminRepository();
    const body = AuthOptionsSchema.parse(await req.json().catch(() => ({})));
    const { rpID } = resolveWebAuthnRp(req);

    let userId: string | null = null;
    let existingCredentials;

    if (body.mode === 'step_up') {
      const session = await resolveVerifiedAdminSession(repo, req);
      userId = session.userId;
      existingCredentials = await repo.listPasskeysForUser(session.userId);
    }

    const options = await createPasskeyAuthenticationOptions({
      rpID,
      existingCredentials,
    });

    const challengeRec = await repo.createWebAuthnChallenge({
      userId,
      challenge: options.challenge,
      purpose: body.mode === 'step_up' ? 'step_up' : 'authenticate',
      expiresAt: new Date(Date.now() + 5 * 60 * 1000).toISOString(),
    });

    return NextResponse.json({
      challengeId: challengeRec.challenge_id,
      options,
    });
  } catch (error) {
    return jsonErrorResponse(error, correlationId);
  }
}

