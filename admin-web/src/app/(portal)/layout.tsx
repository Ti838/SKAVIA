import type { ReactNode } from 'react';
import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { AuthorizationError } from '@/server/auth/rbac';
import {
  ADMIN_SESSION_COOKIE,
  resolveVerifiedAdminSession,
} from '@/server/auth/session';
import { ServerConfigError } from '@/server/config/env';
import { getAdminRepository } from '@/server/db/store-factory';
import { SessionProvider } from '@/components/shell/SessionProvider';
import { AdminShell } from '@/components/shell/AdminShell';

export const dynamic = 'force-dynamic';

export default async function PortalLayout({
  children,
}: {
  children: ReactNode;
}) {
  const cookieStore = await cookies();
  if (!cookieStore.get(ADMIN_SESSION_COOKIE)?.value) {
    redirect('/login');
  }

  try {
    const repo = getAdminRepository();
    const session = await resolveVerifiedAdminSession(repo);

    return (
      <SessionProvider initialSession={session}>
        <AdminShell>{children}</AdminShell>
      </SessionProvider>
    );
  } catch (error) {
    if (error instanceof AuthorizationError) {
      redirect('/login');
    }

    if (error instanceof ServerConfigError) {
      return (
        <div className="min-h-screen flex items-center justify-center p-6 bg-slate-950 text-slate-100">
          <div className="max-w-lg rounded-2xl border border-amber-500/40 bg-slate-900 p-6 space-y-3">
            <h1 className="text-lg font-bold text-amber-300">
              Admin Portal Server Configuration Incomplete ({error.code})
            </h1>
            <p className="text-sm text-slate-300 leading-relaxed">{error.message}</p>
            <p className="text-xs text-slate-400">
              This portal refuses to run with mock data. Configure the required server
              environment variables in <code className="font-mono-code">admin-web/.env.local</code>{' '}
              and restart the server.
            </p>
          </div>
        </div>
      );
    }

    redirect('/login');
  }
}

