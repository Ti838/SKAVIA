'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Building2, LogOut, Menu, Moon, Search, ShieldCheck, Sun } from 'lucide-react';
import { signOutFirebaseClient } from '@/lib/firebase-client';
import { useAdminSession } from './SessionProvider';
import { CommandPalette } from './CommandPalette';

export function TopBar({ onOpenMobileNav }: { onOpenMobileNav: () => void }) {
  const router = useRouter();
  const { session, availableBranches, selectedBranchId, setSelectedBranchId, openStepUp } =
    useAdminSession();
  const [paletteOpen, setPaletteOpen] = useState(false);
  const [dark, setDark] = useState(false);

  useEffect(() => {
    const saved = window.localStorage.getItem('skavia_admin_theme');
    if (saved === 'dark') {
      document.documentElement.setAttribute('data-theme', 'dark');
      document.documentElement.classList.add('dark');
      setDark(true);
    } else {
      document.documentElement.removeAttribute('data-theme');
      document.documentElement.classList.remove('dark');
    }
  }, []);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        setPaletteOpen((v) => !v);
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  function toggleTheme() {
    const next = !dark;
    setDark(next);
    if (next) {
      document.documentElement.setAttribute('data-theme', 'dark');
      document.documentElement.classList.add('dark');
      window.localStorage.setItem('skavia_admin_theme', 'dark');
    } else {
      document.documentElement.removeAttribute('data-theme');
      document.documentElement.classList.remove('dark');
      window.localStorage.setItem('skavia_admin_theme', 'light');
    }
  }

  async function handleLogout() {
    await fetch('/api/admin/auth/logout', { method: 'POST', credentials: 'include' }).catch(
      () => {}
    );
    await signOutFirebaseClient();
    router.replace('/login');
  }

  const stepUpActive =
    Boolean(session.stepUpExpiresAt) &&
    new Date(session.stepUpExpiresAt as string).getTime() > Date.now();

  return (
    <>
      <header
        className="sticky top-0 z-30 h-16 border-b px-4 lg:px-6 flex items-center justify-between gap-3"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div className="flex items-center gap-3 min-w-0">
          <button
            type="button"
            onClick={onOpenMobileNav}
            aria-label="Open navigation menu"
            className="lg:hidden rounded-lg p-2 border hover:bg-slate-100 dark:hover:bg-slate-800"
            style={{ borderColor: 'var(--border-subtle)' }}
          >
            <Menu className="h-4 w-4" />
          </button>

          <div className="flex items-center gap-2 min-w-0">
            <Building2 className="h-4 w-4 shrink-0 text-blue-700 dark:text-sky-400" />
            {session.branchScoped ? (
              <span
                data-testid="branch-scope-indicator"
                className="inline-flex items-center gap-1.5 rounded-full bg-amber-50 dark:bg-amber-950/50 border border-amber-200 dark:border-amber-800/70 px-3 py-1 text-xs font-semibold text-amber-900 dark:text-amber-200 truncate"
              >
                Branch Scope:{' '}
                {session.assignedBranches.map((b) => b.name).join(', ') || 'Unassigned'}
              </span>
            ) : (
              <div className="flex items-center gap-2">
                <label htmlFor="branch-scope-select" className="sr-only">
                  SKAVIA Branch Context
                </label>
                <select
                  id="branch-scope-select"
                  data-testid="branch-scope-select"
                  value={selectedBranchId}
                  onChange={(e) => setSelectedBranchId(e.target.value)}
                  className="rounded-lg border px-2.5 py-1.5 text-xs font-semibold outline-none focus:ring-2 focus:ring-blue-500"
                  style={{
                    backgroundColor: 'var(--bg-canvas)',
                    borderColor: 'var(--border-subtle)',
                    color: 'var(--text-primary)',
                  }}
                >
                  <option value="">All SKAVIA Branches (Global)</option>
                  {availableBranches.map((b) => (
                    <option key={b.branch_id} value={b.branch_id}>
                      {b.name} ({b.code})
                    </option>
                  ))}
                </select>
              </div>
            )}
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => setPaletteOpen(true)}
            className="hidden sm:inline-flex items-center gap-2 rounded-lg border px-3 py-1.5 text-xs transition hover:border-blue-400"
            style={{
              backgroundColor: 'var(--bg-canvas)',
              borderColor: 'var(--border-subtle)',
              color: 'var(--text-muted)',
            }}
          >
            <Search className="h-3.5 w-3.5" />
            <span>Search...</span>
            <kbd className="rounded bg-slate-200/80 dark:bg-slate-800 px-1.5 py-0.5 text-[10px] font-mono-code text-slate-700 dark:text-slate-300">
              Ctrl K
            </kbd>
          </button>

          <button
            type="button"
            onClick={openStepUp}
            title="Manage Step-Up MFA Authorization"
            className={`hidden md:inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-medium ${
              stepUpActive
                ? 'bg-emerald-50 dark:bg-emerald-950/50 border-emerald-200 dark:border-emerald-800/70 text-emerald-800 dark:text-emerald-200'
                : 'bg-slate-100 dark:bg-slate-800 border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-200'
            }`}
          >
            <ShieldCheck className="h-3.5 w-3.5" />
            {stepUpActive ? 'Step-Up Verified' : 'Verify Step-Up'}
          </button>

          <button
            type="button"
            onClick={toggleTheme}
            aria-label="Toggle color theme"
            className="rounded-lg p-2 border hover:bg-slate-100 dark:hover:bg-slate-800"
            style={{ borderColor: 'var(--border-subtle)' }}
          >
            {dark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
          </button>

          <button
            type="button"
            onClick={handleLogout}
            className="inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1.5 text-xs font-medium hover:bg-red-50 dark:hover:bg-red-950/40 hover:text-red-700 dark:hover:text-red-300 hover:border-red-200 dark:hover:border-red-800/70 transition"
            style={{ borderColor: 'var(--border-subtle)' }}
          >
            <LogOut className="h-3.5 w-3.5" />
            <span className="hidden sm:inline">Sign Out</span>
          </button>
        </div>
      </header>

      <CommandPalette open={paletteOpen} onClose={() => setPaletteOpen(false)} />
    </>
  );
}

