'use client';

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from 'react';
import { getPublicThemeTokens, type PublicThemeTokens } from '../public-site-data';

export type ThemePreference = 'system' | 'light' | 'dark';

interface PublicThemeContextValue {
  themeMode: ThemePreference;
  isDark: boolean;
  cycleTheme: () => void;
  setThemeMode: (mode: ThemePreference) => void;
  tokens: PublicThemeTokens;
}

const PublicThemeContext = createContext<PublicThemeContextValue | null>(null);

export function PublicThemeProvider({ children }: { children: ReactNode }) {
  const [themeMode, setThemeModeState] = useState<ThemePreference>('system');
  const [systemDark, setSystemDark] = useState<boolean>(true);

  // 1. Initial client-side sync from localStorage & system media query
  useEffect(() => {
    try {
      const saved = localStorage.getItem('skavia-theme');
      if (saved === 'light' || saved === 'dark' || saved === 'system') {
        setThemeModeState(saved);
      }
      if (typeof window !== 'undefined' && window.matchMedia) {
        setSystemDark(window.matchMedia('(prefers-color-scheme: dark)').matches);
      }
    } catch {}

    const mediaQuery =
      typeof window !== 'undefined' && window.matchMedia
        ? window.matchMedia('(prefers-color-scheme: dark)')
        : null;

    const handleChange = (e: MediaQueryListEvent) => {
      setSystemDark(e.matches);
    };

    mediaQuery?.addEventListener('change', handleChange);
    return () => mediaQuery?.removeEventListener('change', handleChange);
  }, []);

  const isDark = themeMode === 'system' ? systemDark : themeMode === 'dark';

  // 2. Synchronize DOM classes and attributes whenever isDark changes
  useEffect(() => {
    if (typeof document === 'undefined') return;
    try {
      if (isDark) {
        document.documentElement.classList.add('dark');
        document.documentElement.setAttribute('data-theme', 'dark');
      } else {
        document.documentElement.classList.remove('dark');
        document.documentElement.setAttribute('data-theme', 'light');
      }
    } catch {}
  }, [isDark]);

  const setThemeMode = useCallback((mode: ThemePreference) => {
    setThemeModeState(mode);
    try {
      localStorage.setItem('skavia-theme', mode);
      localStorage.setItem('skavia_admin_theme', mode);
    } catch {}
  }, []);

  const cycleTheme = useCallback(() => {
    setThemeModeState((prev) => {
      let next: ThemePreference;
      if (prev === 'system') next = 'light';
      else if (prev === 'light') next = 'dark';
      else next = 'system';

      try {
        localStorage.setItem('skavia-theme', next);
        localStorage.setItem('skavia_admin_theme', next);
      } catch {}
      return next;
    });
  }, []);

  const tokens = getPublicThemeTokens(isDark);

  return (
    <PublicThemeContext.Provider
      value={{
        themeMode,
        isDark,
        cycleTheme,
        setThemeMode,
        tokens,
      }}
    >
      {children}
    </PublicThemeContext.Provider>
  );
}

export function usePublicTheme(): PublicThemeContextValue {
  const context = useContext(PublicThemeContext);
  if (!context) {
    // Graceful fallback if used outside provider
    return {
      themeMode: 'system',
      isDark: true,
      cycleTheme: () => {},
      setThemeMode: () => {},
      tokens: getPublicThemeTokens(true),
    };
  }
  return context;
}
