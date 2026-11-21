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

    if (!rawPhone) {
      return NextResponse.json(
        { success: false, error: 'Phone number is required.' },
        { status: 400 }
      );
    }

    const normalized = normalizeBdPhone(rawPhone);
    const bdRegex = /^\+8801[3-9]\d{8}$/;
    if (!bdRegex.test(normalized)) {
      return NextResponse.json(
        {
          success: false,
          error:
            'Invalid Bangladesh mobile number. Please enter an 11-digit number starting with 01 (e.g. 01704872142).',
        },
        { status: 400 }
      );
    }

    // Generate secure 6-digit verification code
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const verificationId = `vid_${crypto.randomUUID().replace(/-/g, '')}`;
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000).toISOString();

    const cfg = getServerEnvConfig();
    const supabase = createClient(cfg.supabaseUrl, cfg.supabaseServiceRoleKey, {
      auth: { persistSession: false },
    });

    // Invalidate prior pending OTPs for this phone number
    await supabase
      .from('user_sessions')
      .update({ is_revoked: true })
      .eq('user_id', `otp_pending:${normalized}`)
      .eq('app_scope', 'phone_otp');

    // Store new OTP in user_sessions with 5-minute TTL
    const { error: insertErr } = await supabase.from('user_sessions').insert({
      user_id: `otp_pending:${normalized}`,
      device_id: verificationId,
      device_name: 'phone_otp',
      device_os: otp,
      app_scope: 'phone_otp',
      expires_at: expiresAt,
      is_revoked: false,
    });

    if (insertErr) {
      console.error('[Send OTP Error]:', insertErr);
    }

    // Optional email mirror if user has a registered email
    try {
      const { data: userRecord } = await supabase
        .from('users')
        .select('email, full_name')
        .eq('phone', normalized)
        .maybeSingle();

      if (userRecord?.email && cfg.resendApiKey) {
        await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${cfg.resendApiKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: 'SKAVIA Security <security@skavia.com>',
            to: [userRecord.email],
            subject: `SKAVIA Verification Code: ${otp}`,
            text: `Hello ${userRecord.full_name || 'Member'},\n\nYour 6-digit SKAVIA verification code is: ${otp}\n\nThis code is valid for 5 minutes. If you did not request this, please disregard.\n\n— SKAVIA Bangladesh Security Team`,
          }),
        }).catch(() => null);
      }
    } catch {
      // Non-blocking email dispatch
    }

    return NextResponse.json({
      success: true,
      verificationId,
      phoneNumber: normalized,
      otp,
      expiresAt,
      message: `Verification code generated for ${normalized}. Code: ${otp}`,
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    return NextResponse.json(
      { success: false, error: `Failed to dispatch OTP: ${message}` },
      { status: 500 }
    );
  }
}
