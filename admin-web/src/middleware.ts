import { NextResponse, type NextRequest } from 'next/server';

const ADMIN_ROUTES_PREFIXES = [
  '/login',
  '/dashboard',
  '/admins',
  '/bookings',
  '/branches',
  '/customers',
  '/disputes',
  '/finance',
  '/releases',
  '/reports',
  '/security',
  '/services',
  '/settings',
  '/teams',
  '/verifications',
  '/workers',
  '/activate',
  '/access-denied',
];

function extractHost(req: NextRequest): string {
  const raw = req.headers.get('x-forwarded-host') || req.headers.get('host') || '';
  return (raw.split(',')[0] ?? '').trim().toLowerCase().replace(/:\d+$/, '');
}

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/images') ||
    pathname === '/favicon.png' ||
    pathname === '/icon.png'
  ) {
    return NextResponse.next();
  }

  const host = extractHost(req);
  const publicHost = (process.env.NEXT_PUBLIC_PUBLIC_HOST || 'www.skavia.com').toLowerCase();
  const superadminHost = (process.env.NEXT_PUBLIC_SUPERADMIN_HOST || 'superadmin.skavia.com').toLowerCase();
  const adminHost = (process.env.NEXT_PUBLIC_ADMIN_HOST || 'admin.skavia.com').toLowerCase();

  const isPublicHost =
    host === publicHost || host === 'skavia.com' || host.startsWith('www.');
  const isSuperAdminHost =
    host === superadminHost || host.startsWith('superadmin.');
  const isAdminHost =
    host === adminHost || host.startsWith('admin.');

  // Strict Public Website Domain: forbid all internal admin routes & APIs
  if (isPublicHost) {
    if (pathname.startsWith('/api/admin')) {
      return NextResponse.json(
        {
          error: {
            code: 'SURFACE_FORBIDDEN',
            message: 'Administrative APIs are disabled on the public website domain.',
          },
        },
        { status: 403 }
      );
    }

    if (ADMIN_ROUTES_PREFIXES.some((prefix) => pathname === prefix || pathname.startsWith(`${prefix}/`))) {
      return new NextResponse('Not Found', { status: 404 });
    }

    return NextResponse.next();
  }

  // Dedicated Super Admin Hostname
  if (isSuperAdminHost) {
    if (pathname === '/') {
      const hasCookie = Boolean(req.cookies.get('skavia_admin_session')?.value);
      const target = hasCookie ? '/dashboard' : '/login';
      return NextResponse.redirect(new URL(target, req.url));
    }
    const res = NextResponse.next();
    res.headers.set('x-skavia-surface', 'superadmin');
    return res;
  }

  // Dedicated Internal Admin Hostname (Company Admin / Branch Manager + Activation)
  if (isAdminHost) {
    if (pathname === '/') {
      const hasCookie = Boolean(req.cookies.get('skavia_admin_session')?.value);
      const target = hasCookie ? '/dashboard' : '/login';
      return NextResponse.redirect(new URL(target, req.url));
    }
    if (
      pathname.startsWith('/admins') ||
      pathname.startsWith('/security') ||
      pathname.startsWith('/releases')
    ) {
      return NextResponse.redirect(new URL('/access-denied?reason=superadmin-only', req.url));
    }
    const res = NextResponse.next();
    res.headers.set('x-skavia-surface', 'admin');
    return res;
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
