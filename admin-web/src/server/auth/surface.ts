import type { AdminRoleName, PortalSurface } from '@/lib/contracts';
import { getServerEnvConfig } from '../config/env';
import { AuthorizationError } from './rbac';

export type ResolvedSurface = PortalSurface | 'local';

function normalizeHost(rawHost: string | null | undefined): string {
  if (!rawHost) return '';
  return (rawHost.split(',')[0] ?? '').trim().toLowerCase().replace(/:\d+$/, '');
}

/**
 * Resolves which SKAVIA surface handles the incoming request based on hostname
 * (in production: www.skavia.com | superadmin.skavia.com | admin.skavia.com)
 * or explicit development surface headers/query parameters on localhost.
 */
export function resolvePortalSurfaceFromRequest(
  req: { headers: Pick<Headers, 'get'>; url?: string },
  explicitBodySurface?: PortalSurface | null
): ResolvedSurface {
  const cfg = getServerEnvConfig();
  const host = normalizeHost(
    req.headers.get('x-forwarded-host') || req.headers.get('host')
  );

  const superadminHost = normalizeHost(cfg.superadminHost);
  const adminHost = normalizeHost(cfg.adminHost);
  const publicHost = normalizeHost(cfg.publicHost);

  if (host === superadminHost || host.startsWith('superadmin.')) {
    return 'superadmin';
  }
  if (host === adminHost || host.startsWith('admin.')) {
    return 'admin';
  }
  if (host === publicHost || host === 'skavia.com' || host.startsWith('www.')) {
    return 'public';
  }

  const headerSurface = req.headers.get('x-skavia-surface')?.trim().toLowerCase();
  const candidate = (explicitBodySurface || headerSurface || '').toLowerCase();
  if (candidate === 'superadmin' || candidate === 'admin' || candidate === 'public') {
    return candidate;
  }

  if (req.url) {
    try {
      const parsed = new URL(req.url, 'http://localhost');
      const queryPortal = (
        parsed.searchParams.get('portal') || parsed.searchParams.get('surface')
      )?.toLowerCase();
      if (queryPortal === 'superadmin' || queryPortal === 'admin' || queryPortal === 'public') {
        return queryPortal;
      }
    } catch {
      // Ignore unparseable relative URLs
    }
  }

  // Bare localhost / 127.0.0.1 preview without explicit subdomain or query surface
  return 'local';
}

export function surfaceToStrictPortal(
  surface: ResolvedSurface,
  primaryRole: AdminRoleName
): PortalSurface {
  if (surface === 'superadmin') return 'superadmin';
  if (surface === 'admin') return 'admin';
  if (surface === 'public') return 'public';
  return primaryRole === 'Super Admin' ? 'superadmin' : 'admin';
}

/**
 * Enforces strict separation between:
 *  - Public website (`www.skavia.com`) -> no admin login allowed
 *  - Super Admin portal (`superadmin.skavia.com`) -> primary Super Admin only
 *  - Internal Admin portal (`admin.skavia.com`) -> Company Admin & Branch Manager only
 */
export function assertSurfaceRoleCompatibility(params: {
  surface: ResolvedSurface;
  primaryRole: AdminRoleName;
  roles: AdminRoleName[];
  isPrimarySuperAdmin: boolean;
}): void {
  const { surface, primaryRole, roles, isPrimarySuperAdmin } = params;

  if (surface === 'public') {
    throw new AuthorizationError(
      'WRONG_PORTAL_SURFACE',
      'Public website surface never permits administrative authentication.',
      403
    );
  }

  if (surface === 'superadmin') {
    const isSuper = roles.includes('Super Admin');
    if (!isSuper || !isPrimarySuperAdmin) {
      throw new AuthorizationError(
        'SUPERADMIN_SURFACE_REQUIRED',
        'Access denied: Super Admin portal is strictly restricted to the single primary Super Admin.',
        403
      );
    }
    return;
  }

  if (surface === 'admin') {
    if (primaryRole === 'Super Admin') {
      throw new AuthorizationError(
        'USE_SUPERADMIN_PORTAL',
        'Primary Super Admin must sign in through the dedicated Super Admin Portal.',
        403
      );
    }
    if (primaryRole !== 'Company Admin' && primaryRole !== 'Branch Manager') {
      throw new AuthorizationError(
        'ADMIN_SURFACE_REQUIRED',
        'Internal Admin Portal requires Company Admin or Branch Manager privileges.',
        403
      );
    }
  }
}
