import { createRemoteJWKSet, jwtVerify } from 'jose';
import { getServerEnvConfig } from '../config/env';

const FIREBASE_JWKS = createRemoteJWKSet(
  new URL(
    'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com'
  )
);

export interface VerifiedFirebaseToken {
  uid: string;
  email: string | null;
  mfaVerified: boolean;
  mfaMethod: string | null;
}

export async function verifyFirebaseIdToken(
  idToken: string
): Promise<VerifiedFirebaseToken> {
  const config = getServerEnvConfig();

  // In automated test environments only, verify HS256 harness tokens signed with adminSessionSecret
  if (config.isTestHarness && idToken.startsWith('test-harness.')) {
    const raw = idToken.slice('test-harness.'.length);
    const secret = new TextEncoder().encode(config.adminSessionSecret);
    const { payload } = await jwtVerify(raw, secret, {
      issuer: 'skavia-test-harness',
      audience: config.firebaseProjectId,
    });
    const uid = typeof payload.sub === 'string' ? payload.sub : '';
    if (!uid) throw new Error('Invalid test token subject');
    const secondFactor =
      typeof payload.mfa_method === 'string' ? payload.mfa_method : null;
    return {
      uid,
      email: typeof payload.email === 'string' ? payload.email : null,
      mfaVerified: Boolean(secondFactor),
      mfaMethod: secondFactor,
    };
  }

  const { payload } = await jwtVerify(idToken, FIREBASE_JWKS, {
    issuer: `https://securetoken.google.com/${config.firebaseProjectId}`,
    audience: config.firebaseProjectId,
  });

  const uid = typeof payload.sub === 'string' ? payload.sub : '';
  if (!uid) {
    throw new Error('Firebase token missing subject (uid).');
  }

  const fbClaim =
    payload.firebase && typeof payload.firebase === 'object'
      ? (payload.firebase as Record<string, unknown>)
      : undefined;
  const secondFactor =
    fbClaim && typeof fbClaim.sign_in_second_factor === 'string'
      ? fbClaim.sign_in_second_factor
      : null;

  return {
    uid,
    email: typeof payload.email === 'string' ? payload.email : null,
    mfaVerified: Boolean(secondFactor),
    mfaMethod: secondFactor,
  };
}

