import type { AdminPasskeyRecord, WebAuthnChallengeRecord } from '../repository';
import type { StoreDbClient } from './base';

const CHALLENGE_SELECT_COLUMNS =
  'challenge_id, user_id, invitation_id, challenge, purpose, expires_at, consumed_at';
const PASSKEY_SELECT_COLUMNS =
  'credential_id, user_id, friendly_name, public_key, counter, transports, device_type, backed_up, aaguid, last_used_at, revoked_at, revoked_by, created_at';

export class SupabasePasskeysStore {
  constructor(private readonly db: StoreDbClient) {}

  async createWebAuthnChallenge(input: {
    userId: string | null;
    invitationId?: string | null;
    challenge: string;
    purpose: 'register' | 'authenticate' | 'step_up' | 'invite_activate';
    expiresAt: string;
  }): Promise<WebAuthnChallengeRecord> {
    const { data, error } = await this.db
      .from('webauthn_challenges')
      .insert({
        user_id: input.userId,
        invitation_id: input.invitationId ?? null,
        challenge: input.challenge,
        purpose: input.purpose,
        expires_at: input.expiresAt,
      })
      .select(CHALLENGE_SELECT_COLUMNS)
      .single();
    if (error || !data) {
      throw new Error(`Failed storing WebAuthn challenge: ${error?.message ?? 'unknown'}`);
    }
    return data as WebAuthnChallengeRecord;
  }

  async consumeWebAuthnChallenge(
    challengeId: string,
    purpose: 'register' | 'authenticate' | 'step_up' | 'invite_activate'
  ): Promise<WebAuthnChallengeRecord | null> {
    const now = new Date().toISOString();
    const { data, error } = await this.db
      .from('webauthn_challenges')
      .update({ consumed_at: now })
      .eq('challenge_id', challengeId)
      .eq('purpose', purpose)
      .is('consumed_at', null)
      .gt('expires_at', now)
      .select(CHALLENGE_SELECT_COLUMNS)
      .maybeSingle();

    if (error) throw new Error(`Failed consuming WebAuthn challenge: ${error.message}`);
    return (data as WebAuthnChallengeRecord | null) ?? null;
  }

  async savePasskeyCredential(input: {
    credentialId: string;
    userId: string;
    friendlyName: string;
    publicKey: string;
    counter: number;
    transports: string[];
    deviceType: string;
    backedUp: boolean;
    aaguid: string | null;
  }): Promise<AdminPasskeyRecord> {
    const { data, error } = await this.db
      .from('admin_passkeys')
      .upsert(
        {
          credential_id: input.credentialId,
          user_id: input.userId,
          friendly_name: input.friendlyName,
          public_key: input.publicKey,
          counter: input.counter,
          transports: input.transports,
          device_type: input.deviceType,
          backed_up: input.backedUp,
          aaguid: input.aaguid,
        },
        { onConflict: 'credential_id' }
      )
      .select(PASSKEY_SELECT_COLUMNS)
      .single();
    if (error || !data) throw new Error(`Failed saving passkey: ${error?.message ?? 'unknown'}`);
    return data as AdminPasskeyRecord;
  }

  async listPasskeysForUser(userId: string): Promise<AdminPasskeyRecord[]> {
    const { data, error } = await this.db
      .from('admin_passkeys')
      .select(PASSKEY_SELECT_COLUMNS)
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    if (error) throw new Error(`Failed listing passkeys: ${error.message}`);
    return (data ?? []) as AdminPasskeyRecord[];
  }

  async listAllPasskeys(): Promise<AdminPasskeyRecord[]> {
    const { data, error } = await this.db
      .from('admin_passkeys')
      .select(PASSKEY_SELECT_COLUMNS)
      .order('created_at', { ascending: false })
      .limit(200);
    if (error) throw new Error(`Failed listing all passkeys: ${error.message}`);
    return (data ?? []) as AdminPasskeyRecord[];
  }

  async getPasskeyById(credentialId: string): Promise<AdminPasskeyRecord | null> {
    const { data, error } = await this.db
      .from('admin_passkeys')
      .select(PASSKEY_SELECT_COLUMNS)
      .eq('credential_id', credentialId)
      .is('revoked_at', null)
      .maybeSingle();
    if (error) throw new Error(`Failed reading passkey: ${error.message}`);
    return (data as AdminPasskeyRecord | null) ?? null;
  }

  async touchPasskeyUsage(credentialId: string, newCounter: number): Promise<void> {
    await this.db
      .from('admin_passkeys')
      .update({
        counter: newCounter,
        last_used_at: new Date().toISOString(),
      })
      .eq('credential_id', credentialId);
  }

  async revokePasskey(credentialId: string, revokedBy: string): Promise<void> {
    await this.db
      .from('admin_passkeys')
      .update({
        revoked_at: new Date().toISOString(),
        revoked_by: revokedBy,
      })
      .eq('credential_id', credentialId);
  }

  async setRecoveryCodeHashes(userId: string, hashes: string[]): Promise<void> {
    await this.db.from('admin_profiles').upsert(
      {
        user_id: userId,
        recovery_codes_hashes: hashes,
        recovery_codes_generated_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id' }
    );
  }

  async getRecoveryCodeHashes(
    userId: string
  ): Promise<{ hashes: string[]; generatedAt: string | null }> {
    const { data } = await this.db
      .from('admin_profiles')
      .select('recovery_codes_hashes, recovery_codes_generated_at')
      .eq('user_id', userId)
      .maybeSingle();
    return {
      hashes: Array.isArray(data?.recovery_codes_hashes)
        ? (data.recovery_codes_hashes as string[])
        : [],
      generatedAt: (data?.recovery_codes_generated_at as string | null) ?? null,
    };
  }
}

