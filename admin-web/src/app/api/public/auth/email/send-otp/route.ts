import { NextResponse } from 'next/server';
import { getServerEnvConfig } from '@/server/config/env';
import { createClient } from '@supabase/supabase-js';
import {
  isValidEmail,
  issueOtpChallenge,
  normalizeEmail,
} from '@/server/services/sms-otp';
import { sendUserOtpEmail } from '@/server/services/email';

export const dynamic = 'force-dynamic';

export async function POST(req: Request) {
  try {
    const body = await req.json().catch(() => ({}));
    const rawEmail = String(body.email || '').trim();

    if (!rawEmail || !isValidEmail(rawEmail)) {
      return NextResponse.json(
        { success: false, error: 'Please enter a valid email address.' },
        { status: 400 }
      );
    }

    const normalizedEmail = normalizeEmail(rawEmail);
    const cfg = getServerEnvConfig();
    const supabase = createClient(cfg.supabaseUrl, cfg.supabaseServiceRoleKey, {
      auth: { persistSession: false },
    });

    const issued = await issueOtpChallenge({
      supabase,
      scope: 'email_otp',
      otpKey: `otp_pending:email:${normalizedEmail}`,
      secret: cfg.adminSessionSecret,
    });

    if (!issued.ok) {
      return NextResponse.json(
        { success: false, error: issued.error },
        { status: issued.status }
      );
    }

    const { data: userRecord } = await supabase
      .from('users')
      .select('full_name')
      .eq('email', normalizedEmail)
      .maybeSingle();

    const emailResult = await sendUserOtpEmail({
      to: normalizedEmail,
      fullName: userRecord?.full_name || undefined,
      otp: issued.otp,
    });

    const emailDelivered = emailResult.status === 'Sent';
    const allowDemoFallback =
      process.env.NODE_ENV !== 'production' ||
      process.env.OTP_ALLOW_DEMO_FALLBACK === 'true';

    if (!emailDelivered && !allowDemoFallback) {
      await supabase
        .from('user_sessions')
        .update({ is_revoked: true, revoked_at: new Date().toISOString() })
        .eq('device_id', issued.verificationId);

      return NextResponse.json(
        {
          success: false,
          error:
            emailResult.error ||
            'Email delivery failed. Configure SMTP or verify a Resend domain.',
        },
        { status: 502 }
      );
    }

    const deliveryChannel = emailDelivered ? 'email' : 'in_app_demo';

    return NextResponse.json({
      success: true,
      verificationId: issued.verificationId,
      email: normalizedEmail,
      deliveryChannel,
      ...(emailDelivered ? {} : { otp: issued.otp }),
      ...(emailResult.error ? { emailDeliveryNote: emailResult.error } : {}),
      expiresAt: issued.expiresAt,
      message: emailDelivered
        ? `A 6-digit verification code has been sent to ${normalizedEmail}.`
        : `Verification code generated for ${normalizedEmail}.`,
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    return NextResponse.json(
      { success: false, error: `Failed to dispatch email OTP: ${message}` },
      { status: 500 }
    );
  }
}
