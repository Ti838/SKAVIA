import { createHash, randomBytes, timingSafeEqual } from 'node:crypto';
import { getServerEnvConfig } from '../config/env';

/**
 * Generates a high-entropy URL-safe single-use token (256 bits).
 */
export function generateSecureToken(): string {
  return randomBytes(32).toString('base64url');
}

/**
 * Computes deterministic SHA-256 hex digest for storing tokens at rest.
 * Only hashes are stored in PostgreSQL; plaintext tokens are never persisted.
 */
export function hashToken(rawToken: string): string {
  return createHash('sha256').update(rawToken, 'utf8').digest('hex');
}

export function constantTimeHashEqual(aHex: string, bHex: string): boolean {
  const a = Buffer.from(aHex, 'hex');
  const b = Buffer.from(bHex, 'hex');
  if (a.length === 0 || a.length !== b.length) return false;
  return timingSafeEqual(a, b);
}

/**
 * Generates human-readable one-time emergency recovery codes (`SKV-XXXX-XXXX`)
 * alongside salted/peppered SHA-256 digests for database storage.
 */
export function generateRecoveryCodes(count = 8): {
  plaintextCodes: string[];
  hashes: string[];
} {
  const { adminSessionSecret } = getServerEnvConfig();
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  const plaintextCodes: string[] = [];
  const hashes: string[] = [];

  for (let i = 0; i < count; i += 1) {
    const bytes = randomBytes(8);
    let block1 = '';
    let block2 = '';
    for (let j = 0; j < 4; j += 1) {
      const b1 = bytes[j] ?? 0;
      const b2 = bytes[j + 4] ?? 0;
      block1 += alphabet[b1 % alphabet.length] ?? 'A';
      block2 += alphabet[b2 % alphabet.length] ?? '2';
    }
    const code = `SKV-${block1}-${block2}`;
    plaintextCodes.push(code);
    hashes.push(hashRecoveryCode(code, adminSessionSecret));
  }

  return { plaintextCodes, hashes };
}

export function hashRecoveryCode(rawCode: string, secretPepper?: string): string {
  const pepper = secretPepper ?? getServerEnvConfig().adminSessionSecret;
  const normalized = rawCode.trim().toUpperCase().replace(/\s+/g, '');
  return createHash('sha256')
    .update(`${pepper}:${normalized}`, 'utf8')
    .digest('hex');
}

export function consumeRecoveryCodeHash(
  rawCode: string,
  storedHashes: string[]
): { matched: boolean; remainingHashes: string[] } {
  const candidate = hashRecoveryCode(rawCode);
  let matchedIndex = -1;
  for (let i = 0; i < storedHashes.length; i += 1) {
    const targetHash = storedHashes[i];
    if (targetHash && constantTimeHashEqual(candidate, targetHash)) {
      matchedIndex = i;
      break;
    }
  }
  if (matchedIndex === -1) {
    return { matched: false, remainingHashes: storedHashes };
  }
  return {
    matched: true,
    remainingHashes: storedHashes.filter((_, idx) => idx !== matchedIndex),
  };
}
