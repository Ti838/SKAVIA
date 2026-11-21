import { NextResponse } from 'next/server';
import crypto from 'crypto';
import { getServerEnvConfig } from '@/server/config/env';
import { createClient } from '@supabase/supabase-js';

export const dynamic = 'force-dynamic';

function normalizeBdPhone(raw: string): string {
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

export async function POST(req: Request) {
  try {
    const body = await req.json().catch(() => ({}));
    const rawPhone = String(body.phoneNumber || '').trim();
    const smsCode = String(body.smsCode || '').trim();
    const fullName = String(body.fullName || '').trim();

    if (!rawPhone) {
      return NextResponse.json(
        { success: false, error: 'Phone number is required.' },
        { status: 400 }
      );
    }
    if (!smsCode || smsCode.length < 4) {
      return NextResponse.json(
        { success: false, error: 'A valid 6-digit verification code is required.' },
        { status: 400 }
      );
    }

    const normalized = normalizeBdPhone(rawPhone);
    const cfg = getServerEnvConfig();
    const supabase = createClient(cfg.supabaseUrl, cfg.supabaseServiceRoleKey, {
      auth: { persistSession: false },
    });

    // Check universal master bypass code '123456' OR query stored active OTP in user_sessions
    let isValid = smsCode === '123456';
    let matchedSessionId: string | null = null;

    if (!isValid) {
      const nowIso = new Date().toISOString();
      const { data: records, error: queryErr } = await supabase
        .from('user_sessions')
        .select('id, device_os, expires_at')
        .eq('user_id', `otp_pending:${normalized}`)
        .eq('app_scope', 'phone_otp')
        .eq('is_revoked', false)
        .gt('expires_at', nowIso)
        .order('created_at', { ascending: false })
        .limit(1);

      if (queryErr) {
        console.error('[Verify OTP Query Error]:', queryErr);
      }

      if (records && records.length > 0 && records[0]) {
        const activeOtp = records[0].device_os;
        if (activeOtp === smsCode) {
          isValid = true;
          matchedSessionId = records[0].id;
        }
      }
    }

    if (!isValid) {
      return NextResponse.json(
        {
          success: false,
          error: 'Invalid or expired verification code. Please check the 6-digit OTP or tap Resend.',
        },
        { status: 401 }
      );
    }

    // Revoke the used OTP session so it cannot be replayed
    if (matchedSessionId) {
      await supabase
        .from('user_sessions')
        .update({ is_revoked: true, revoked_at: new Date().toISOString() })
        .eq('id', matchedSessionId);
    }

    // Upsert or fetch existing user from Supabase
    let userId: string;
    let displayName = fullName || 'SKAVIA Member';
    const activeMode = 'client';

    const { data: existingUser } = await supabase
      .from('users')
      .select('user_id, full_name, phone, role, is_active')
      .eq('phone', normalized)
      .maybeSingle();

    if (existingUser) {
      userId = existingUser.user_id;
      if (existingUser.full_name && !fullName) {
        displayName = existingUser.full_name;
      }
      if (fullName && fullName !== existingUser.full_name) {
        await supabase
          .from('users')
          .update({ full_name: fullName, updated_at: new Date().toISOString() })
          .eq('user_id', userId);
        displayName = fullName;
      }
    } else {
      userId = crypto.randomUUID();
      const { error: insertUserErr } = await supabase.from('users').insert({
        user_id: userId,
        phone: normalized,
        full_name: displayName,
        role: 'customer',
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });
      if (insertUserErr) {
        console.error('[Create User Warning]:', insertUserErr);
      }
    }

    // Ensure customer_profiles record exists
    await supabase.from('customer_profiles').upsert(
      {
        user_id: userId,
        full_name: displayName,
        phone: normalized,
        is_verified: true,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id' }
    );

    // Deterministic bridge credentials for Firebase Email/Password Auth
    const cleanDigits = normalized.replace(/\D/g, '');
    const bridgeEmail = `phone_${cleanDigits}@skavia.internal`;
    const bridgePassword = `SkaviaSecureOtp_${cleanDigits}_2026!`;

    return NextResponse.json({
      success: true,
      user: {
        uid: userId,
        phoneNumber: normalized,
        displayName,
        activeMode,
        bridgeEmail,
        bridgePassword,
      },
      message: 'Phone verified successfully.',
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    return NextResponse.json(
      { success: false, error: `Verification failed: ${message}` },
      { status: 500 }
    );
  }
}
