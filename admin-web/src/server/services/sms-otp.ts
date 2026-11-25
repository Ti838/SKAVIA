import crypto from 'crypto';
import type { SupabaseClient } from '@supabase/supabase-js';

export type OtpDeliveryChannel = 'sms' | 'email' | 'in_app_demo';
export type OtpScope = 'phone_otp' | 'email_otp';

export interface SmsDispatchResult {
  channel: OtpDeliveryChannel;
  provider: 'bulksmsbd' | 'sslwireless' | 'greenweb' | 'webhook' | 'none';
  sent: boolean;
  error?: string;
}

const BD_PHONE_REGEX = /^\+8801[3-9]\d{8}$/;
const EMAIL_REGEX = /^[\w\-.+]+@([\w-]+\.)+[\w-]{2,}$/i;
const RESEND_COOLDOWN_MS = 30 * 1000;
const MAX_REQUESTS_15_MIN = 5;
const MAX_IP_REQUESTS_15_MIN = 15;
const MAX_VERIFY_ATTEMPTS = 5;

/**
 * Normalizes Bangladesh phone inputs (01..., 8801..., 008801..., +8801...)
 * into canonical E.164 format (+8801XXXXXXXXX).
 */
export function normalizeBdPhone(raw: string): string {
  let cleaned = raw.replace(/[^\d+]/g, '');
  if (cleaned.startsWith('00880')) {
    cleaned = '+' + cleaned.substring(2);
  } else if (cleaned.startsWith('880')) {
    cleaned = '+' + cleaned;
  } else if (cleaned.startsWith('01')) {
    cleaned = '+880' + cleaned.substring(1);
  } else if (!cleaned.startsWith('+')) {
    cleaned = '+' + cleaned;
  }
  return cleaned;
}

export function isValidBdPhone(normalized: string): boolean {
  return BD_PHONE_REGEX.test(normalized);
}

export function normalizeEmail(raw: string): string {
  return raw.trim().toLowerCase();
}

export function isValidEmail(email: string): boolean {
  return EMAIL_REGEX.test(email.trim());
}

/**
 * Computes a keyed SHA-256 digest for storing OTP challenges safely at rest.
 */
export function hashOtp(
  otp: string,
  verificationId: string,
  secret: string
): string {
  const digest = crypto
    .createHmac('sha256', secret)
    .update(`${verificationId}:${otp}`)
    .digest('hex');
  return `sha256:${digest}`;
}

export function verifyOtpHash(params: {
  otp: string;
  verificationId: string;
  storedValue: string;
  secret: string;
}): boolean {
  const expected = hashOtp(params.otp, params.verificationId, params.secret);
  const a = Buffer.from(expected, 'utf8');
  const b = Buffer.from(params.storedValue, 'utf8');
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(a, b);
}

/**
 * Derives server-only bridge credentials for Firebase Email/Password Spark auth
 * using HMAC-SHA256(ADMIN_SESSION_SECRET, identity) so clients cannot forge logins
 * without passing server-side OTP verification.
 */
export function derivePhoneBridgeCredentials(
  normalizedIdentity: string,
  secret: string
): { bridgeEmail: string; bridgePassword: string } {
  const isEmail = normalizedIdentity.includes('@');
  const bridgeEmail = isEmail
    ? `otp_${crypto.createHash('sha256').update(normalizedIdentity).digest('hex').slice(0, 16)}@skavia.internal`
    : `phone_${normalizedIdentity.replace(/\D/g, '')}@skavia.internal`;
  const hmac = crypto
    .createHmac('sha256', secret)
    .update(`skavia-phone-bridge:${normalizedIdentity}`)
    .digest('base64url');
  const bridgePassword = `${hmac.slice(0, 28)}_Sk1!`;
  return { bridgeEmail, bridgePassword };
}

function parseAttempts(deviceInfo: string | null | undefined): number {
  const match = String(deviceInfo || '').match(/attempts:(\d+)/);
  return match ? Number(match[1]) : 0;
}

/**
 * Shared challenge issuer enforcing cooldowns, rate limits, and keyed HMAC hashing.
 */
export async function issueOtpChallenge(params: {
  supabase: SupabaseClient;
  scope: OtpScope;
  otpKey: string;
  ipAddress?: string;
  secret: string;
}): Promise<
  | { ok: true; otp: string; verificationId: string; expiresAt: string }
  | { ok: false; status: number; error: string }
> {
  const { supabase, scope, otpKey, ipAddress, secret } = params;
  const fifteenMinAgo = new Date(Date.now() - 15 * 60 * 1000).toISOString();

  // 1. IP-level rate limiting to prevent SMS/email bombing
  if (ipAddress && ipAddress !== 'unknown' && ipAddress !== '127.0.0.1') {
    const { count: ipCount } = await supabase
      .from('user_sessions')
      .select('id', { count: 'exact', head: true })
      .eq('ip_address', ipAddress)
      .gte('created_at', fifteenMinAgo);

    if ((ipCount || 0) >= MAX_IP_REQUESTS_15_MIN) {
      return {
        ok: false,
        status: 429,
        error: 'Too many requests from this network. Please wait 15 minutes and try again.',
      };
    }
  }

  // 2. Target identity rate limiting
  const { data: recentRequests } = await supabase
    .from('user_sessions')
    .select('created_at')
    .eq('user_id', otpKey)
    .eq('app_scope', scope)
    .gte('created_at', fifteenMinAgo)
    .order('created_at', { ascending: false });

  const latestRequest = recentRequests?.[0];
  if (latestRequest) {
    const elapsed = Date.now() - new Date(latestRequest.created_at).getTime();
    if (elapsed < RESEND_COOLDOWN_MS) {
      const waitSec = Math.ceil((RESEND_COOLDOWN_MS - elapsed) / 1000);
      return {
        ok: false,
        status: 429,
        error: `Please wait ${waitSec} seconds before requesting another OTP.`,
      };
    }
    if ((recentRequests?.length || 0) >= MAX_REQUESTS_15_MIN) {
      return {
        ok: false,
        status: 429,
        error: 'Too many OTP requests. Please wait 15 minutes and try again.',
      };
    }
  }

  const otp = crypto.randomInt(100000, 1000000).toString();
  const verificationId = `vid_${crypto.randomUUID().replace(/-/g, '')}`;
  const expiresAt = new Date(Date.now() + 5 * 60 * 1000).toISOString();
  const otpDigest = hashOtp(otp, verificationId, secret);

  await supabase
    .from('user_sessions')
    .update({ is_revoked: true, revoked_at: new Date().toISOString() })
    .eq('user_id', otpKey)
    .eq('app_scope', scope)
    .eq('is_revoked', false);

  const { error: insertErr } = await supabase.from('user_sessions').insert({
    user_id: otpKey,
    device_id: verificationId,
    device_name: scope,
    device_os: otpDigest,
    device_info: 'attempts:0',
    app_scope: scope,
    ip_address: ipAddress || null,
    expires_at: expiresAt,
    is_revoked: false,
  });

  if (insertErr) {
    console.error('[Issue OTP Store Error]:', insertErr);
    return {
      ok: false,
      status: 500,
      error: 'Could not initialize OTP session. Please try again.',
    };
  }

  return { ok: true, otp, verificationId, expiresAt };
}

/**
 * Shared OTP verifier enforcing expiry, attempt limits, and single-use revocation.
 */
export async function verifyOtpChallenge(params: {
  supabase: SupabaseClient;
  scope: OtpScope;
  otpKey: string;
  smsCode: string;
  verificationId?: string;
  secret: string;
}): Promise<{ ok: true } | { ok: false; status: number; error: string }> {
  const { supabase, scope, otpKey, smsCode, verificationId, secret } = params;

  const allowDevBypass =
    process.env.NODE_ENV !== 'production' &&
    process.env.ALLOW_TEST_OTP_BYPASS === 'true';

  if (allowDevBypass && smsCode === '123456') {
    return { ok: true };
  }

  const nowIso = new Date().toISOString();
  let query = supabase
    .from('user_sessions')
    .select('id, device_id, device_os, device_info, expires_at')
    .eq('user_id', otpKey)
    .eq('app_scope', scope)
    .eq('is_revoked', false)
    .gt('expires_at', nowIso)
    .order('created_at', { ascending: false })
    .limit(1);

  if (verificationId) {
    query = query.eq('device_id', verificationId);
  }

  const { data: records, error: queryErr } = await query;
  if (queryErr) {
    console.error('[Verify OTP Query Error]:', queryErr);
    return {
      ok: false,
      status: 500,
      error: 'Unable to verify OTP right now. Please try again.',
    };
  }

  const activeRecord = records?.[0];
  if (!activeRecord) {
    return {
      ok: false,
      status: 401,
      error: 'Verification code expired or not found. Please tap Resend.',
    };
  }

  const attempts = parseAttempts(activeRecord.device_info);
  if (attempts >= MAX_VERIFY_ATTEMPTS) {
    await supabase
      .from('user_sessions')
      .update({ is_revoked: true, revoked_at: new Date().toISOString() })
      .eq('id', activeRecord.id);
    return {
      ok: false,
      status: 429,
      error: 'Too many invalid attempts. Please request a new OTP.',
    };
  }

  const stored = String(activeRecord.device_os || '');
  const vid = String(activeRecord.device_id || '');
  const isHashed = stored.startsWith('sha256:');
  const matches = isHashed
    ? verifyOtpHash({
        otp: smsCode,
        verificationId: vid,
        storedValue: stored,
        secret,
      })
    : (process.env.NODE_ENV !== 'production' && stored === smsCode);

  if (!matches) {
    const nextAttempts = attempts + 1;
    const shouldLock = nextAttempts >= MAX_VERIFY_ATTEMPTS;
    await supabase
      .from('user_sessions')
      .update({
        device_info: `attempts:${nextAttempts}`,
        ...(shouldLock
          ? { is_revoked: true, revoked_at: new Date().toISOString() }
          : {}),
      })
      .eq('id', activeRecord.id);

    return {
      ok: false,
      status: shouldLock ? 429 : 401,
      error: shouldLock
        ? 'Too many invalid attempts. Please request a new OTP.'
        : 'Invalid verification code. Please check the 6-digit OTP or tap Resend.',
    };
  }

  // Single-use immediate revocation
  await supabase
    .from('user_sessions')
    .update({ is_revoked: true, revoked_at: new Date().toISOString() })
    .eq('id', activeRecord.id);

  return { ok: true };
}

/**
 * Dispatches an OTP via the configured Bangladesh SMS provider.
 * Falls back to 'in_app_demo' only when no SMS provider is configured.
 */
export async function dispatchOtpSms(params: {
  phoneNumber: string;
  otp: string;
}): Promise<SmsDispatchResult> {
  const provider = (process.env.SMS_PROVIDER || '').trim().toLowerCase();
  const message = `Your SKAVIA verification code is ${params.otp}. Valid for 5 minutes. Do not share this code.`;
  const localDigits = params.phoneNumber.replace(/^\+/, ''); // 8801XXXXXXXXX

  if (provider === 'bulksmsbd') {
    const apiKey = process.env.BULKSMSBD_API_KEY?.trim() || '';
    const senderId = process.env.BULKSMSBD_SENDER_ID?.trim() || '';
    if (!apiKey || !senderId) {
      return {
        channel: 'sms',
        provider: 'bulksmsbd',
        sent: false,
        error: 'BULKSMSBD_API_KEY or BULKSMSBD_SENDER_ID is missing.',
      };
    }

    try {
      const form = new URLSearchParams({
        api_key: apiKey,
        type: 'text',
        number: localDigits,
        senderid: senderId,
        message,
      });
      const res = await fetch('https://bulksmsbd.net/api/smsapi', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: form.toString(),
      });
      const body = await res.json().catch(() => ({}));
      const ok = res.ok && Number(body.response_code) === 202;
      return {
        channel: 'sms',
        provider: 'bulksmsbd',
        sent: ok,
        error: ok ? undefined : body.error_message || `BulkSMSBD HTTP ${res.status}`,
      };
    } catch (err) {
      return {
        channel: 'sms',
        provider: 'bulksmsbd',
        sent: false,
        error: err instanceof Error ? err.message : 'BulkSMSBD network error',
      };
    }
  }

  if (provider === 'sslwireless') {
    const apiToken = process.env.SSL_SMS_API_TOKEN?.trim() || '';
    const sid = process.env.SSL_SMS_SID?.trim() || '';
    if (!apiToken || !sid) {
      return {
        channel: 'sms',
        provider: 'sslwireless',
        sent: false,
        error: 'SSL_SMS_API_TOKEN or SSL_SMS_SID is missing.',
      };
    }

    try {
      const res = await fetch('https://smsplus.sslwireless.com/api/v3/send-sms', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          api_token: apiToken,
          sid,
          msisdn: localDigits,
          sms: message,
          csms_id: `skv_${Date.now()}`,
        }),
      });
      const body = await res.json().catch(() => ({}));
      const ok = res.ok && String(body.status || '').toUpperCase() === 'SUCCESS';
      return {
        channel: 'sms',
        provider: 'sslwireless',
        sent: ok,
        error: ok ? undefined : body.error_message || `SSL Wireless HTTP ${res.status}`,
      };
    } catch (err) {
      return {
        channel: 'sms',
        provider: 'sslwireless',
        sent: false,
        error: err instanceof Error ? err.message : 'SSL Wireless network error',
      };
    }
  }

  if (provider === 'greenweb') {
    const token = process.env.GREENWEB_TOKEN?.trim() || '';
    if (!token) {
      return {
        channel: 'sms',
        provider: 'greenweb',
        sent: false,
        error: 'GREENWEB_TOKEN is missing.',
      };
    }

    try {
      const form = new URLSearchParams({
        token,
        to: params.phoneNumber,
        message,
      });
      const res = await fetch('https://api.greenweb.com.bd/api.php?json', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: form.toString(),
      });
      const text = await res.text();
      const ok = res.ok && text.toLowerCase().includes('sent');
      return {
        channel: 'sms',
        provider: 'greenweb',
        sent: ok,
        error: ok ? undefined : text.slice(0, 160),
      };
    } catch (err) {
      return {
        channel: 'sms',
        provider: 'greenweb',
        sent: false,
        error: err instanceof Error ? err.message : 'GreenWeb network error',
      };
    }
  }

  if (provider === 'webhook') {
    const webhookUrl = process.env.SMS_WEBHOOK_URL?.trim() || '';
    const webhookSecret = process.env.SMS_WEBHOOK_SECRET?.trim() || '';
    if (!webhookUrl) {
      return {
        channel: 'sms',
        provider: 'webhook',
        sent: false,
        error: 'SMS_WEBHOOK_URL is missing.',
      };
    }

    try {
      const res = await fetch(webhookUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(webhookSecret ? { 'x-skavia-sms-secret': webhookSecret } : {}),
        },
        body: JSON.stringify({
          phoneNumber: params.phoneNumber,
          otp: params.otp,
          message,
          brand: 'SKAVIA',
        }),
      });
      return {
        channel: 'sms',
        provider: 'webhook',
        sent: res.ok,
        error: res.ok ? undefined : `Webhook HTTP ${res.status}`,
      };
    } catch (err) {
      return {
        channel: 'sms',
        provider: 'webhook',
        sent: false,
        error: err instanceof Error ? err.message : 'SMS webhook network error',
      };
    }
  }

  return {
    channel: 'in_app_demo',
    provider: 'none',
    sent: false,
  };
}
