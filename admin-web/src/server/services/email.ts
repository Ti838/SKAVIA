import nodemailer from 'nodemailer';
import { getServerEnvConfig } from '../config/env';

export interface EmailSendResult {
  status: 'Sent' | 'DeliveryFailed' | 'NotConfigured';
  provider: 'smtp' | 'resend' | 'none';
  messageId?: string;
  error?: string;
}

function escapeHtml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

export async function sendTransactionalEmail(params: {
  to: string;
  subject: string;
  html: string;
  text: string;
}): Promise<EmailSendResult> {
  const cfg = getServerEnvConfig();

  if (cfg.smtp) {
    try {
      const transporter = nodemailer.createTransport({
        host: cfg.smtp.host,
        port: cfg.smtp.port,
        secure: cfg.smtp.secure,
        auth: {
          user: cfg.smtp.user,
          pass: cfg.smtp.pass,
        },
      });
      const info = await transporter.sendMail({
        from: cfg.smtp.from,
        to: params.to,
        subject: params.subject,
        html: params.html,
        text: params.text,
      });
      return {
        status: 'Sent',
        provider: 'smtp',
        messageId: info.messageId,
      };
    } catch (err) {
      return {
        status: 'DeliveryFailed',
        provider: 'smtp',
        error: err instanceof Error ? err.message : 'SMTP delivery error',
      };
    }
  }

  if (cfg.resendApiKey) {
    try {
      const preferredFrom =
        process.env.RESEND_FROM?.trim() ||
        process.env.SMTP_FROM?.trim() ||
        'SKAVIA Security <security@skavia.com>';

      const dispatchResend = async (fromAddress: string) =>
        fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${cfg.resendApiKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: fromAddress,
            to: [params.to],
            subject: params.subject,
            html: params.html,
            text: params.text,
          }),
        });

      let res = await dispatchResend(preferredFrom);
      let textBody = res.ok ? '' : await res.text();

      // Automatic fallback to Resend's built-in onboarding sender if custom domain is not yet DNS-verified
      if (
        res.status === 403 &&
        textBody.toLowerCase().includes('domain is not verified') &&
        !preferredFrom.includes('onboarding@resend.dev')
      ) {
        res = await dispatchResend('SKAVIA Security <onboarding@resend.dev>');
        textBody = res.ok ? '' : await res.text();
      }

      if (!res.ok) {
        return {
          status: 'DeliveryFailed',
          provider: 'resend',
          error: `Resend HTTP ${res.status}: ${textBody.slice(0, 200)}`,
        };
      }
      const data = (await res.json()) as { id?: string };
      return {
        status: 'Sent',
        provider: 'resend',
        messageId: data.id,
      };
    } catch (err) {
      return {
        status: 'DeliveryFailed',
        provider: 'resend',
        error: err instanceof Error ? err.message : 'Resend API request failed',
      };
    }
  }

  return {
    status: 'NotConfigured',
    provider: 'none',
    error: 'No SMTP_* or RESEND_API_KEY configured on server.',
  };
}

export async function sendAdminInvitationEmail(params: {
  to: string;
  fullName: string;
  roleName: string;
  branchNames: string[];
  activationUrl: string;
  expiresAt: string;
  invitedByName: string;
}): Promise<EmailSendResult> {
  const scopeText =
    params.branchNames.length > 0
      ? params.branchNames.join(', ')
      : 'Global Operational Scope';
  const subject = `Official SKAVIA Internal Admin Invitation (${params.roleName})`;
  const html = `
    <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden;">
      <div style="background: #003399; color: #ffffff; padding: 24px 28px;">
        <h1 style="margin: 0; font-size: 20px;">SKAVIA Operations & Governance</h1>
        <p style="margin: 6px 0 0; font-size: 13px; color: #cbd5e1;">Official Internal Administrator Onboarding</p>
      </div>
      <div style="padding: 28px; color: #0f172a; line-height: 1.6;">
        <p>Hello <strong>${escapeHtml(params.fullName)}</strong>,</p>
        <p>The primary SKAVIA Super Admin (<strong>${escapeHtml(params.invitedByName)}</strong>) has invited you to activate an internal administrative account.</p>
        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px 16px; margin: 18px 0; font-size: 13px;">
          <div><strong>Assigned Role:</strong> ${escapeHtml(params.roleName)}</div>
          <div><strong>Operational Branch Scope:</strong> ${escapeHtml(scopeText)}</div>
          <div><strong>Expires At:</strong> ${escapeHtml(new Date(params.expiresAt).toUTCString())}</div>
        </div>
        <p>Complete your secure activation using your official invite link below. This link is single-use and cannot be transferred:</p>
        <p style="margin: 24px 0;">
          <a href="${escapeHtml(params.activationUrl)}" style="display: inline-block; background: #003399; color: #ffffff; text-decoration: none; font-weight: 600; padding: 12px 20px; border-radius: 8px;">Activate Admin Account</a>
        </p>
        <p style="font-size: 12px; color: #64748b;">Security notice: SKAVIA will never ask you for your password or OTP. Your account may require explicit Super Admin approval before portal sign-in is enabled.</p>
      </div>
    </div>
  `;
  const text = [
    `Hello ${params.fullName},`,
    '',
    `You have been invited by SKAVIA Super Admin (${params.invitedByName}) as ${params.roleName}.`,
    `Branch Scope: ${scopeText}`,
    `Expires At: ${new Date(params.expiresAt).toUTCString()}`,
    '',
    `Activate your account using this single-use link:`,
    params.activationUrl,
    '',
    'This invitation is confidential and tied to your verified email address.',
  ].join('\n');

  return sendTransactionalEmail({
    to: params.to,
    subject,
    html,
    text,
  });
}

export async function sendNewDeviceSecurityAlert(params: {
  to: string;
  fullName: string;
  roleName: string;
  surface: string;
  ipAddress: string;
  userAgent: string;
}): Promise<EmailSendResult> {
  const subject = 'SKAVIA Security Alert: New Device Admin Sign-In Detected';
  const html = `
    <div style="font-family: sans-serif; max-width: 560px; margin: 0 auto; border: 1px solid #fecaca; border-radius: 10px; padding: 24px;">
      <h2 style="margin-top: 0; color: #b91c1c;">New Device Sign-In Alert</h2>
      <p>Hello ${escapeHtml(params.fullName)},</p>
      <p>A new session was created for your <strong>${escapeHtml(params.roleName)}</strong> account on <strong>${escapeHtml(params.surface)}</strong>.</p>
      <ul style="font-size: 13px; color: #334155;">
        <li><strong>IP Address:</strong> ${escapeHtml(params.ipAddress)}</li>
        <li><strong>Device / Browser:</strong> ${escapeHtml(params.userAgent)}</li>
        <li><strong>Time:</strong> ${escapeHtml(new Date().toUTCString())}</li>
      </ul>
      <p style="font-size: 12px; color: #64748b;">If this was not you, revoke all active sessions immediately from Security Settings or contact the primary Super Admin.</p>
    </div>
  `;
  const text = `New Device Sign-In Alert for ${params.fullName} (${params.roleName}) on ${params.surface}. IP: ${params.ipAddress}, Device: ${params.userAgent}.`;

  return sendTransactionalEmail({
    to: params.to,
    subject,
    html,
    text,
  });
}

export async function sendUserOtpEmail(params: {
  to: string;
  fullName?: string;
  otp: string;
  targetPhone?: string;
}): Promise<EmailSendResult> {
  const recipientName = params.fullName?.trim() || 'SKAVIA Member';
  const subject = `Your SKAVIA Verification Code: ${params.otp}`;
  const phoneLine = params.targetPhone
    ? `<p style="margin: 0 0 12px; font-size: 13px; color: #475569;">Requested for phone number: <strong>${escapeHtml(params.targetPhone)}</strong></p>`
    : '';
  const html = `
    <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 560px; margin: 0 auto; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden;">
      <div style="background: #003399; color: #ffffff; padding: 20px 24px;">
        <h1 style="margin: 0; font-size: 18px;">SKAVIA Verification</h1>
        <p style="margin: 4px 0 0; font-size: 12px; color: #cbd5e1;">One-Time Passcode (OTP)</p>
      </div>
      <div style="padding: 24px; color: #0f172a; line-height: 1.6;">
        <p style="margin-top: 0;">Hello <strong>${escapeHtml(recipientName)}</strong>,</p>
        ${phoneLine}
        <p>Use the 6-digit verification code below to complete your sign-in:</p>
        <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 10px; padding: 16px; margin: 18px 0; text-align: center;">
          <span style="font-size: 30px; font-weight: 800; letter-spacing: 6px; color: #003399;">${escapeHtml(params.otp)}</span>
        </div>
        <p style="font-size: 13px; color: #475569;">This code expires in <strong>5 minutes</strong>. Never share this code with anyone.</p>
      </div>
    </div>
  `;
  const text = [
    `Hello ${recipientName},`,
    '',
    params.targetPhone ? `Phone: ${params.targetPhone}` : '',
    `Your 6-digit SKAVIA verification code is: ${params.otp}`,
    '',
    'This code expires in 5 minutes. Never share it with anyone.',
    '— SKAVIA Security Team',
  ]
    .filter(Boolean)
    .join('\n');

  return sendTransactionalEmail({
    to: params.to,
    subject,
    html,
    text,
  });
}

