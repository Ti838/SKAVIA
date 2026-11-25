import { NextResponse } from 'next/server';
import { getServerEnvConfig } from '@/server/config/env';
import { createClient } from '@supabase/supabase-js';
import {
  derivePhoneBridgeCredentials,
  isValidBdPhone,
  normalizeBdPhone,
  verifyOtpChallenge,
} from '@/server/services/sms-otp';

export const dynamic = 'force-dynamic';

export async function POST(req: Request) {
  try {
    const body = await req.json().catch(() => ({}));
    const rawPhone = String(body.phoneNumber || '').trim();
    const smsCode = String(body.smsCode || '').trim();
    const verificationId = String(body.verificationId || '').trim();
    const fullName = String(body.fullName || '').trim();

    if (!rawPhone) {
      return NextResponse.json(
        { success: false, error: 'Phone number is required.' },
        { status: 400 }
      );
    }

    if (!/^\d{6}$/.test(smsCode)) {
      return NextResponse.json(
        { success: false, error: 'A valid 6-digit verification code is required.' },
        { status: 400 }
      );
    }

    const normalized = normalizeBdPhone(rawPhone);
    if (!isValidBdPhone(normalized)) {
      return NextResponse.json(
        { success: false, error: 'Invalid Bangladesh mobile number.' },
        { status: 400 }
      );
    }

    const cfg = getServerEnvConfig();
    const supabase = createClient(cfg.supabaseUrl, cfg.supabaseServiceRoleKey, {
      auth: { persistSession: false },
    });

    const verified = await verifyOtpChallenge({
      supabase,
      scope: 'phone_otp',
      otpKey: `otp_pending:${normalized}`,
      smsCode,
      verificationId: verificationId || undefined,
      secret: cfg.adminSessionSecret,
    });

    if (!verified.ok) {
      return NextResponse.json(
        { success: false, error: verified.error },
        { status: verified.status }
      );
    }

    const { data: existingUser } = await supabase
      .from('users')
      .select('user_id, full_name, email, phone, active_mode')
      .eq('phone', normalized)
      .maybeSingle();

    const displayName =
      fullName || existingUser?.full_name || 'SKAVIA Member';
    const activeMode = existingUser?.active_mode || 'client';

    if (existingUser && fullName && fullName !== existingUser.full_name) {
      await supabase
        .from('users')
        .update({ full_name: fullName, updated_at: new Date().toISOString() })
        .eq('user_id', existingUser.user_id);
    }

    const { bridgeEmail, bridgePassword } = derivePhoneBridgeCredentials(
      normalized,
      cfg.adminSessionSecret
    );

    return NextResponse.json({
      success: true,
      user: {
        uid: existingUser?.user_id || null,
        phoneNumber: normalized,
        displayName,
        activeMode,
        existingEmail: existingUser?.email || null,
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
