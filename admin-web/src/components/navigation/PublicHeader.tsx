'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  Laptop,
  Menu,
  Moon,
  Smartphone,
  Sun,
  User,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import { LanguageSwitcher } from './LanguageSwitcher';
import { LocationPill } from './LocationPill';
import { MobileNavDrawer } from './MobileNavDrawer';

interface PublicHeaderProps {
  themeMode: 'system' | 'light' | 'dark';
  onCycleTheme: () => void;
  onDownloadClick?: () => void;
}

export function PublicHeader({
  themeMode,
  onCycleTheme,
  onDownloadClick,
}: PublicHeaderProps) {
  const { t } = useTranslation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <>
      <header
        className="sticky top-0 z-40 border-b backdrop-blur-xl transition-all"
        style={{
          backgroundColor: 'rgba(var(--bg-surface-rgb, 255, 255, 255), 0.82)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between gap-3 sm:gap-4">
          {/* Left Brand & Location */}
          <div className="flex items-center gap-3 sm:gap-4 min-w-0">
            <Link href="/" className="group flex items-center gap-2.5 shrink-0 transition-transform hover:scale-[1.02]">
              <SkaviaBrandMark variant="emblem" size={32} priority />
              <div className="flex flex-col">
                <span
                  className="font-heading font-extrabold text-base tracking-tight leading-none"
                  style={{ color: 'var(--text-primary)' }}
                >
                  {t.brandName}
                </span>
                <span className="text-[10px] font-mono-code text-slate-500 dark:text-slate-400 tracking-wider hidden sm:inline uppercase">
                  Workforce &amp; Services
                </span>
              </div>
            </Link>

            {/* Location Context Pill */}
            <LocationPill compact />
          </div>

          {/* Center Navigation Links (Desktop >= 1024px) */}
          <nav
            aria-label="Public Site Navigation"
            className="hidden lg:flex items-center gap-1 xl:gap-2 text-xs font-semibold"
          >
            <a
              href="#about"
              className="px-3 py-1.5 rounded-full transition-all text-slate-600 dark:text-slate-300 hover:text-slate-950 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-slate-800/60"
            >
              {t.navAbout}
            </a>
            <a
              href="#branches"
              className="px-3 py-1.5 rounded-full transition-all text-slate-600 dark:text-slate-300 hover:text-slate-950 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-slate-800/60"
            >
              {t.navBranches}
            </a>
            <a
              href="#how-it-works"
              className="px-3 py-1.5 rounded-full transition-all text-slate-600 dark:text-slate-300 hover:text-slate-950 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-slate-800/60"
            >
              {t.navHowItWorks}
            </a>
            <a
              href="#solutions"
              className="px-3 py-1.5 rounded-full transition-all text-slate-600 dark:text-slate-300 hover:text-slate-950 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-slate-800/60"
            >
              {t.navSolutions}
            </a>
            <a
              href="#workers"
              className="px-3 py-1.5 rounded-full transition-all text-slate-600 dark:text-slate-300 hover:text-slate-950 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-slate-800/60"
            >
              {t.navBecomeWorker}
            </a>
            <a
              href="#faq"
              className="px-3 py-1.5 rounded-full transition-all text-slate-600 dark:text-slate-300 hover:text-slate-950 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-slate-800/60"
            >
              {t.navFaq}
            </a>
          </nav>

          {/* Right Action Controls */}
          <div className="flex items-center gap-2 sm:gap-3 shrink-0">
            {/* Language Switcher */}
            <LanguageSwitcher />

            {/* Theme Toggle Button */}
            <button
              type="button"
              onClick={onCycleTheme}
              aria-label={`Toggle color theme (currently ${themeMode})`}
              title={`Color theme: ${themeMode}`}
              className="inline-flex items-center justify-center h-8 w-8 sm:h-9 sm:w-auto sm:px-2.5 rounded-full border text-xs font-medium transition hover:border-slate-400 dark:hover:border-slate-600"
              style={{
                backgroundColor: 'var(--bg-surface-subtle)',
                borderColor: 'var(--border-subtle)',
                color: 'var(--text-secondary)',
              }}
            >
              {themeMode === 'system' ? (
                <>
                  <Laptop className="h-3.5 w-3.5 text-[#3898EC]" />
                  <span className="text-[11px] font-mono-code uppercase tracking-wider hidden sm:inline ml-1.5">
                    {t.themeAuto}
                  </span>
                </>
              ) : themeMode === 'light' ? (
                <>
                  <Sun className="h-3.5 w-3.5 text-amber-500" />
                  <span className="text-[11px] font-mono-code uppercase tracking-wider hidden sm:inline ml-1.5">
                    {t.themeLight}
                  </span>
                </>
              ) : (
                <>
                  <Moon className="h-3.5 w-3.5 text-indigo-400" />
                  <span className="text-[11px] font-mono-code uppercase tracking-wider hidden sm:inline ml-1.5">
                    {t.themeDark}
                  </span>
                </>
              )}
            </button>

            {/* Portal / Sign In link (Desktop) */}
            <Link
              href="/login"
              className="hidden sm:inline-flex items-center gap-1.5 rounded-full border px-3.5 py-1.5 text-xs font-semibold transition hover:bg-slate-100 dark:hover:bg-slate-800"
              style={{
                borderColor: 'var(--border-subtle)',
                color: 'var(--text-primary)',
              }}
            >
              <User className="h-3.5 w-3.5 text-slate-500 dark:text-slate-400" />
              <span>{t.navPortalSignIn}</span>
            </Link>

            {/* Get App CTA (Desktop) */}
            <a
              href="#download"
              onClick={onDownloadClick}
              className="hidden md:inline-flex items-center gap-1.5 rounded-full px-4 py-2 text-xs font-semibold text-white shadow-md shadow-blue-900/20 bg-gradient-to-r from-[#003399] to-[#1D4ED8] hover:from-[#002266] hover:to-[#1e40af] transition-all hover:scale-[1.02]"
            >
              <Smartphone className="h-3.5 w-3.5" />
              <span>{t.navGetApp}</span>
            </a>

            {/* Mobile Hamburger Button (< 1024px) */}
            <button
              type="button"
              onClick={() => setMobileMenuOpen(true)}
              aria-label="Open navigation menu"
              aria-expanded={mobileMenuOpen}
              className="lg:hidden inline-flex items-center justify-center h-8 w-8 rounded-lg border hover:bg-slate-100 dark:hover:bg-slate-800 transition"
              style={{ borderColor: 'var(--border-subtle)', color: 'var(--text-primary)' }}
            >
              <Menu className="h-4 w-4" />
            </button>
          </div>
        </div>
      </header>

      {/* Accessible Slide-Over Mobile Drawer */}
      <MobileNavDrawer
        isOpen={mobileMenuOpen}
        onClose={() => setMobileMenuOpen(false)}
        onDownloadClick={onDownloadClick}
      />
    </>
  );
}
