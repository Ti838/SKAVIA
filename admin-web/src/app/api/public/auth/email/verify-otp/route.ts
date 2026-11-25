import { NextResponse } from 'next/server';
import { getServerEnvConfig } from '@/server/config/env';
import { createClient } from '@supabase/supabase-js';
import {
  derivePhoneBridgeCredentials,
  isValidEmail,
  normalizeEmail,
  verifyOtpChallenge,
} from '@/server/services/sms-otp';

export const dynamic = 'force-dynamic';

export async function POST(req: Request) {
  try {
    const body = await req.json().catch(() => ({}));
    const rawEmail = String(body.email || '').trim();
    const smsCode = String(body.smsCode || body.otp || '').trim();
    const verificationId = String(body.verificationId || '').trim();
    const fullName = String(body.fullName || '').trim();

    if (!rawEmail || !isValidEmail(rawEmail)) {
      return NextResponse.json(
        { success: false, error: 'A valid email address is required.' },
        { status: 400 }
      );
    }

    if (!/^\d{6}$/.test(smsCode)) {
      return NextResponse.json(
        { success: false, error: 'A valid 6-digit verification code is required.' },
        { status: 400 }
      );
    }

    const normalizedEmail = normalizeEmail(rawEmail);
    const cfg = getServerEnvConfig();
    const supabase = createClient(cfg.supabaseUrl, cfg.supabaseServiceRoleKey, {
      auth: { persistSession: false },
    });

    const verified = await verifyOtpChallenge({
      supabase,
      scope: 'email_otp',
      otpKey: `otp_pending:email:${normalizedEmail}`,
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
      .eq('email', normalizedEmail)
      .maybeSingle();

    const displayName =
      fullName || existingUser?.full_name || 'SKAVIA Member';
    const activeMode = existingUser?.active_mode || 'client';

    if (existingUser) {
      await supabase
        .from('users')
        .update({
          verification_status: 'email_verified',
          ...(fullName && fullName !== existingUser.full_name
            ? { full_name: fullName }
            : {}),
          updated_at: new Date().toISOString(),
        })
        .eq('user_id', existingUser.user_id);
    }

    const { bridgeEmail, bridgePassword } = derivePhoneBridgeCredentials(
      normalizedEmail,
      cfg.adminSessionSecret
    );

    return NextResponse.json({
      success: true,
      user: {
        uid: existingUser?.user_id || null,
        email: normalizedEmail,
        phoneNumber: existingUser?.phone || null,
        displayName,
        activeMode,
        existingEmail: existingUser?.email || null,
        bridgeEmail,
        bridgePassword,
      },
      message: 'Email verified successfully.',
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    return NextResponse.json(
      { success: false, error: `Email verification failed: ${message}` },
      { status: 500 }
    );
  }
}
