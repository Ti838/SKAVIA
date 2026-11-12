export class ServerConfigError extends Error {
  public readonly statusCode = 503;
  public readonly code = 'SERVER_NOT_CONFIGURED';

  constructor(message: string) {
    super(message);
    this.name = 'ServerConfigError';
  }
}

export interface SmtpConfig {
  host: string;
  port: number;
  secure: boolean;
  user: string;
  pass: string;
  from: string;
}

export interface ServerEnvConfig {
  supabaseUrl: string;
  supabaseServiceRoleKey: string;
  adminSessionSecret: string;
  firebaseProjectId: string;
  primarySuperAdminUid: string;
  allowedOrigin: string;
  publicHost: string;
  superadminHost: string;
  adminHost: string;
  webauthnRpId: string;
  webauthnOrigin: string;
  requireMfa: boolean;
  inviteTtlHours: number;
  resendApiKey: string;
  smtp: SmtpConfig | null;
  androidApkUrl: string;
  androidVersion: string;
  iosAppStoreUrl: string;
  isTestHarness: boolean;
}

export function getServerEnvConfig(): ServerEnvConfig {
  const isTestHarness =
    process.env.NODE_ENV === 'test' ||
    (process.env.NODE_ENV !== 'production' &&
      process.env.SKAVIA_TEST_MODE === 'harness');

  const supabaseUrl = process.env.SUPABASE_URL?.trim() || '';
  const supabaseServiceRoleKey =
    process.env.SUPABASE_SERVICE_ROLE_KEY?.trim() || '';
  const adminSessionSecret =
    process.env.ADMIN_SESSION_SECRET?.trim() ||
    (isTestHarness ? 'skavia_vitest_only_ephemeral_signing_secret_32_bytes_min' : '');
  const firebaseProjectId =
    process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID?.trim() || 'skavia-113a3';
  const primarySuperAdminUid =
    process.env.PRIMARY_SUPER_ADMIN_UID?.trim() || '';
  const allowedOrigin =
    process.env.ADMIN_ALLOWED_ORIGIN?.trim() || 'https://admin.skavia.com';
  const publicHost =
    process.env.NEXT_PUBLIC_PUBLIC_HOST?.trim() || 'www.skavia.com';
  const superadminHost =
    process.env.NEXT_PUBLIC_SUPERADMIN_HOST?.trim() || 'superadmin.skavia.com';
  const adminHost =
    process.env.NEXT_PUBLIC_ADMIN_HOST?.trim() || 'admin.skavia.com';
  const webauthnRpId =
    process.env.WEBAUTHN_RP_ID?.trim() || '';
  const webauthnOrigin =
    process.env.WEBAUTHN_ORIGIN?.trim() || '';
  const requireMfa = process.env.ADMIN_REQUIRE_MFA !== 'false';
  const inviteTtlHours = Math.min(
    168,
    Math.max(1, Number(process.env.ADMIN_INVITE_TTL_HOURS) || 24)
  );
  const resendApiKey = process.env.RESEND_API_KEY?.trim() || '';

  const smtpHost = process.env.SMTP_HOST?.trim() || '';
  const smtpUser = process.env.SMTP_USER?.trim() || '';
  const smtpPass = process.env.SMTP_PASS?.trim() || '';
  const smtpFrom = process.env.SMTP_FROM?.trim() || smtpUser || 'no-reply@skavia.com';
  const smtpPort = Number(process.env.SMTP_PORT) || 587;
  const smtp: SmtpConfig | null =
    smtpHost && smtpUser && smtpPass
      ? {
          host: smtpHost,
          port: smtpPort,
          secure: smtpPort === 465,
          user: smtpUser,
          pass: smtpPass,
          from: smtpFrom,
        }
      : null;

  const androidApkUrl = process.env.NEXT_PUBLIC_ANDROID_APK_URL?.trim() || '';
  const androidVersion = process.env.NEXT_PUBLIC_ANDROID_VERSION?.trim() || '';
  const iosAppStoreUrl = process.env.NEXT_PUBLIC_IOS_APP_STORE_URL?.trim() || '';

  if (!isTestHarness && (!supabaseUrl || !supabaseServiceRoleKey)) {
    throw new ServerConfigError(
      'Missing server credentials: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be configured in server environment.'
    );
  }

  if (!isTestHarness && adminSessionSecret.length < 32) {
    throw new ServerConfigError(
      'Missing or weak ADMIN_SESSION_SECRET (minimum 32 characters required in server environment).'
    );
  }

  return {
    supabaseUrl,
    supabaseServiceRoleKey,
    adminSessionSecret,
    firebaseProjectId,
    primarySuperAdminUid,
    allowedOrigin,
    publicHost,
    superadminHost,
    adminHost,
    webauthnRpId,
    webauthnOrigin,
    requireMfa,
    inviteTtlHours,
    resendApiKey,
    smtp,
    androidApkUrl,
    androidVersion,
    iosAppStoreUrl,
    isTestHarness,
  };
}
