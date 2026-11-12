import type { SupabaseClient } from '@supabase/supabase-js';
import type { AdminSessionRecord } from '../repository';

export interface SessionRowShape {
  session_id: string;
  user_id: string;
  app_scope: string | null;
  ip_address: string | null;
  device_info: string | null;
  permission_version_snapshot: number | null;
  step_up_expires_at: string | null;
  revoked_at: string | null;
  revoked_by: string | null;
  created_at: string;
  expires_at: string;
}

export const SESSION_SELECT_COLUMNS =
  'session_id, user_id, app_scope, ip_address, device_info, permission_version_snapshot, step_up_expires_at, revoked_at, revoked_by, created_at, expires_at';

export function mapSessionRow(data: SessionRowShape): AdminSessionRecord {
  return {
    session_id: data.session_id,
    user_id: data.user_id,
    app_scope: data.app_scope ?? 'admin_web',
    ip_address: data.ip_address ?? null,
    device_label: data.device_info ?? null,
    permission_version_snapshot: data.permission_version_snapshot ?? 1,
    step_up_expires_at: data.step_up_expires_at ?? null,
    revoked_at: data.revoked_at ?? null,
    revoked_by: data.revoked_by ?? null,
    created_at: data.created_at,
    expires_at: data.expires_at,
  };
}

export function firstJoined<T>(value: T | T[] | null | undefined): T | undefined {
  return Array.isArray(value) ? value[0] : value ?? undefined;
}

export type StoreDbClient = SupabaseClient;

