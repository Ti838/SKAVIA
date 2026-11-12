import {
  generateAuthenticationOptions,
  generateRegistrationOptions,
  verifyAuthenticationResponse,
  verifyRegistrationResponse,
  type AuthenticationResponseJSON,
  type AuthenticatorTransport,
  type RegistrationResponseJSON,
} from '@simplewebauthn/server';
import { getServerEnvConfig } from '../config/env';

export interface StoredPasskeyRecord {
  credential_id: string;
  user_id: string;
  friendly_name: string;
  public_key: string;
  counter: number;
  transports: string[];
  device_type: string;
  backed_up: boolean;
  aaguid: string | null;
  last_used_at: string | null;
  revoked_at: string | null;
  created_at: string;
}

export function resolveWebAuthnRp(req: Request): { rpID: string; expectedOrigin: string } {
  const cfg = getServerEnvConfig();
  const hostHeader =
    req.headers.get('x-forwarded-host') ||
    req.headers.get('host') ||
    'localhost:3001';
  const protoHeader =
    req.headers.get('x-forwarded-proto') ||
    (hostHeader.startsWith('localhost') || hostHeader.startsWith('127.0.0.1')
      ? 'http'
      : 'https');
  const firstHost = (hostHeader.split(',')[0] ?? 'localhost:3001').trim();
  const derivedRpId = firstHost.replace(/:\d+$/, '');
  const derivedOrigin = `${protoHeader}://${firstHost}`;

  return {
    rpID: cfg.webauthnRpId || derivedRpId || 'localhost',
    expectedOrigin: cfg.webauthnOrigin || req.headers.get('origin') || derivedOrigin,
  };
}

export async function createPasskeyRegistrationOptions(params: {
  rpID: string;
  userId: string;
  email: string;
  fullName: string;
  existingCredentials: StoredPasskeyRecord[];
}) {
  return generateRegistrationOptions({
    rpName: 'SKAVIA Operations & Security',
    rpID: params.rpID,
    userName: params.email,
    userDisplayName: params.fullName,
    userID: new TextEncoder().encode(params.userId),
    attestationType: 'none',
    authenticatorSelection: {
      residentKey: 'preferred',
      userVerification: 'required',
    },
    excludeCredentials: params.existingCredentials
      .filter((c) => !c.revoked_at)
      .map((c) => ({
        id: c.credential_id,
        transports: c.transports as AuthenticatorTransport[],
      })),
  });
}

export async function verifyPasskeyRegistration(params: {
  response: RegistrationResponseJSON;
  expectedChallenge: string;
  expectedOrigin: string;
  expectedRPID: string;
}) {
  return verifyRegistrationResponse({
    response: params.response,
    expectedChallenge: params.expectedChallenge,
    expectedOrigin: params.expectedOrigin,
    expectedRPID: params.expectedRPID,
    requireUserVerification: true,
  });
}

export async function createPasskeyAuthenticationOptions(params: {
  rpID: string;
  existingCredentials?: StoredPasskeyRecord[];
}) {
  return generateAuthenticationOptions({
    rpID: params.rpID,
    userVerification: 'required',
    allowCredentials: params.existingCredentials
      ?.filter((c) => !c.revoked_at)
      .map((c) => ({
        id: c.credential_id,
        transports: c.transports as AuthenticatorTransport[],
      })),
  });
}

export async function verifyPasskeyAssertion(params: {
  response: AuthenticationResponseJSON;
  expectedChallenge: string;
  expectedOrigin: string;
  expectedRPID: string;
  credential: StoredPasskeyRecord;
}) {
  const publicKeyBytes = new Uint8Array(
    Buffer.from(params.credential.public_key, 'base64url')
  );
  return verifyAuthenticationResponse({
    response: params.response,
    expectedChallenge: params.expectedChallenge,
    expectedOrigin: params.expectedOrigin,
    expectedRPID: params.expectedRPID,
    requireUserVerification: true,
    credential: {
      id: params.credential.credential_id,
      publicKey: publicKeyBytes,
      counter: params.credential.counter,
      transports: params.credential.transports as AuthenticatorTransport[],
    },
  });
}
