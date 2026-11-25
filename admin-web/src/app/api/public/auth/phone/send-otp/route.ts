import { NextResponse } from 'next/server';
import { getServerEnvConfig } from '@/server/config/env';
import { createClient } from '@supabase/supabase-js';
import {
  dispatchOtpSms,
  isValidBdPhone,
  isValidEmail,
  issueOtpChallenge,
  normalizeBdPhone,
  normalizeEmail,
} from '@/server/services/sms-otp';
import { sendUserOtpEmail } from '@/server/services/email';

export const dynamic = 'force-dynamic';

export async function POST(req: Request) {
  try {
    const body = await req.json().catch(() => ({}));
    const rawPhone = String(body.phoneNumber || '').trim();
    const rawEmail = String(body.email || '').trim();

    if (!rawPhone) {
      return NextResponse.json(
        { success: false, error: 'Phone number is required.' },
        { status: 400 }
      );
    }

    const normalized = normalizeBdPhone(rawPhone);
    if (!isValidBdPhone(normalized)) {
      return NextResponse.json(
        {
          success: false,
          error:
            'Invalid Bangladesh mobile number. Please enter an 11-digit number starting with 01 (e.g. 01704872142).',
        },
        { status: 400 }
      );
    }

    if (rawEmail && !isValidEmail(rawEmail)) {
      return NextResponse.json(
        { success: false, error: 'Please enter a valid email address.' },
        { status: 400 }
      );
    }

    const cfg = getServerEnvConfig();
    const supabase = createClient(cfg.supabaseUrl, cfg.supabaseServiceRoleKey, {
      auth: { persistSession: false },
    });

    const issued = await issueOtpChallenge({
      supabase,
      scope: 'phone_otp',
      otpKey: `otp_pending:${normalized}`,
      secret: cfg.adminSessionSecret,
    });

    if (!issued.ok) {
      return NextResponse.json(
        { success: false, error: issued.error },
        { status: issued.status }
      );
    }

    // 1. Dispatch real SMS if SMS_PROVIDER is configured
    const smsResult = await dispatchOtpSms({
      phoneNumber: normalized,
      otp: issued.otp,
    });

    if (smsResult.channel === 'sms' && !smsResult.sent) {
      await supabase
        .from('user_sessions')
        .update({ is_revoked: true, revoked_at: new Date().toISOString() })
        .eq('device_id', issued.verificationId);

      return NextResponse.json(
        {
          success: false,
          error: `SMS delivery failed (${smsResult.provider}): ${smsResult.error || 'Gateway error'}`,
        },
        { status: 502 }
      );
    }

    // 2. Dispatch real Email via Resend/SMTP (explicit email OR registered user email)
    let emailDelivered = false;
    let resolvedEmail: string | null = rawEmail ? normalizeEmail(rawEmail) : null;
    let resolvedName: string | undefined;
    let emailError: string | undefined;

    try {
      const { data: userRecord } = await supabase
        .from('users')
        .select('email, full_name')
        .eq('phone', normalized)
        .maybeSingle();

      if (userRecord?.full_name) resolvedName = userRecord.full_name;
      if (!resolvedEmail && userRecord?.email) {
        resolvedEmail = normalizeEmail(userRecord.email);
      }

      if (resolvedEmail) {
        const emailRes = await sendUserOtpEmail({
          to: resolvedEmail,
          fullName: resolvedName,
          otp: issued.otp,
          targetPhone: normalized,
        });
        emailDelivered = emailRes.status === 'Sent';
        if (!emailDelivered) {
          emailError = emailRes.error;
        }
      }
    } catch {
      // Non-blocking fallback handled below
    }

    const deliveryChannel =
      smsResult.channel === 'sms'
        ? 'sms'
        : emailDelivered
          ? 'email'
          : 'in_app_demo';

    const exposeDemoOtp = deliveryChannel === 'in_app_demo';

    return NextResponse.json({
      success: true,
      verificationId: issued.verificationId,
      phoneNumber: normalized,
      email: emailDelivered ? resolvedEmail : null,
      deliveryChannel,
      ...(emailError ? { emailDeliveryNote: emailError } : {}),
      ...(exposeDemoOtp ? { otp: issued.otp } : {}),
      expiresAt: issued.expiresAt,
      message:
        deliveryChannel === 'sms'
          ? `A 6-digit verification SMS has been sent to ${normalized}.`
          : deliveryChannel === 'email'
            ? `A 6-digit verification code has been sent to ${resolvedEmail}.`
            : `Verification code generated for ${normalized}.`,
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    return NextResponse.json(
      { success: false, error: `Failed to dispatch OTP: ${message}` },
      { status: 500 }
    );
  }
}
