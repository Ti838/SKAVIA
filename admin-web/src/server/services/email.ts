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
      const res = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${cfg.resendApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: process.env.SMTP_FROM || 'SKAVIA Security <security@skavia.com>',
          to: [params.to],
          subject: params.subject,
          html: params.html,
          text: params.text,
        }),
      });
      if (!res.ok) {
        const textBody = await res.text();
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

