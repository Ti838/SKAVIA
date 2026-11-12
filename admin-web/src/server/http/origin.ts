import { getServerEnvConfig } from '@/server/config/env';

/**
 * Resolves the external client-facing origin from Request/Next.js headers
 * behind Vercel / reverse proxies.
 */
export function resolveHeaderOrigin(
  hdrs: Pick<Headers, 'get'>,
  fallbackUrl?: string
): string {
  const forwardedHost = hdrs.get('x-forwarded-host')?.split(',')[0]?.trim();
  const host = forwardedHost || hdrs.get('host')?.split(',')[0]?.trim();
  if (host) {
    const isLocal = host.startsWith('localhost') || host.startsWith('127.0.0.1');
    const forwardedProto = hdrs.get('x-forwarded-proto')?.split(',')[0]?.trim();
    const proto = forwardedProto || (isLocal ? 'http' : 'https');
    return `${proto}://${host}`;
  }
  return fallbackUrl ? new URL(fallbackUrl).origin : 'http://localhost:3001';
}

/**
 * Resolves the external client-facing origin behind Vercel / reverse proxies.
 */
export function resolvePublicRequestOrigin(req: Request): string {
  return resolveHeaderOrigin(req.headers, req.url);
}

/**
 * Resolves the activation link origin for invited admins.
 * - Uses http://localhost... on local dev
 * - Uses dedicated NEXT_PUBLIC_ADMIN_HOST when running on separate skavia.com subdomains
 * - Uses the current request origin (e.g. https://<app>.vercel.app) on single-domain Vercel deployments
 */
export function resolveActivationOrigin(req: Request): string {
  const origin = resolvePublicRequestOrigin(req);
  const host = new URL(origin).host.toLowerCase();
  if (host.startsWith('localhost') || host.startsWith('127.0.0.1')) {
    return origin;
  }

  const cfg = getServerEnvConfig();
  const explicitAdminHost = process.env.NEXT_PUBLIC_ADMIN_HOST?.trim().toLowerCase();
  if (explicitAdminHost && (host.endsWith('.skavia.com') || host === 'skavia.com')) {
    return `https://${cfg.adminHost}`;
  }
  if (!explicitAdminHost && (host.startsWith('superadmin.') || host.startsWith('www.'))) {
    return `https://${cfg.adminHost}`;
  }

  return origin;
}

