'use client';

import { type ReactNode } from 'react';
import { PublicHeader } from '@/components/navigation/PublicHeader';
import { PublicFooter } from '@/components/navigation/PublicFooter';
import { usePublicTheme } from './PublicThemeProvider';
import type { PublicThemeTokens } from '../public-site-data';

interface PublicPageShellProps {
  children: (tokens: PublicThemeTokens) => ReactNode;
}

export function PublicPageShell({ children }: PublicPageShellProps) {
  const { themeMode, isDark, cycleTheme, setThemeMode, tokens } = usePublicTheme();

  return (
    <div
      suppressHydrationWarning
      className={`min-h-screen transition-colors duration-200 overflow-x-clip ${
        isDark ? 'bg-black text-neutral-100' : 'bg-white text-neutral-900'
      }`}
    >
      <PublicHeader
        themeMode={themeMode}
        onCycleTheme={cycleTheme}
        setThemeMode={setThemeMode}
      />
      <main className="w-full">{children(tokens)}</main>
      <PublicFooter />
    </div>
  );
}
