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
        className="sticky top-0 z-40 border-b backdrop-blur-xl transition-colors"
        style={{
          backgroundColor: 'rgba(var(--bg-surface-rgb, 255, 255, 255), 0.88)',
          borderColor: 'var(--border-subtle)',
        }}
      >
        <div className="max-w-[1280px] mx-auto px-3 sm:px-6 h-16 flex items-center justify-between gap-2 sm:gap-4">
          {/* Left Brand & Location */}
          <div className="flex items-center gap-2 sm:gap-3.5 min-w-0">
            <Link href="/" className="flex items-center gap-2 shrink-0">
              <SkaviaBrandMark variant="emblem" size={30} priority />
              <span
                className="font-heading font-extrabold text-base tracking-tight hidden sm:inline"
                style={{ color: 'var(--text-primary)' }}
              >
                {t.brandName}
              </span>
            </Link>

            {/* Location Context Pill */}
            <LocationPill compact />
          </div>

          {/* Center Navigation Links (Desktop >= 1024px) */}
          <nav
            aria-label="Public Site Navigation"
            className="hidden lg:flex items-center gap-6 text-xs font-semibold"
            style={{ color: 'var(--text-secondary)' }}
          >
            <a href="#about" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
              {t.navAbout}
            </a>
            <a href="#how-it-works" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
              {t.navHowItWorks}
            </a>
            <a href="#branches" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
              {t.navBranches}
            </a>
            <a href="#solutions" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
              {t.navSolutions}
            </a>
            <a href="#workers" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
              {t.navBecomeWorker}
            </a>
            <a href="#faq" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
              {t.navFaq}
            </a>
          </nav>

          {/* Right Action Controls */}
          <div className="flex items-center gap-1.5 sm:gap-2.5 shrink-0">
            {/* Language Switcher */}
            <LanguageSwitcher />

            {/* Theme Toggle Button */}
            <button
              type="button"
              onClick={onCycleTheme}
              aria-label={`Toggle color theme (currently ${themeMode})`}
              title={`Color theme: ${themeMode}`}
              className="inline-flex items-center justify-center h-8 w-8 sm:h-9 sm:w-auto sm:px-2.5 rounded-full border text-xs font-medium transition"
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
              className="hidden sm:inline-flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-xs font-semibold transition"
              style={{
                borderColor: 'var(--border-subtle)',
                color: 'var(--text-primary)',
              }}
            >
              <User className="h-3.5 w-3.5 text-slate-500" />
              <span>{t.navPortalSignIn}</span>
            </Link>

            {/* Get App CTA (Desktop) */}
            <a
              href="#download"
              onClick={onDownloadClick}
              className="hidden md:inline-flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-xs font-semibold text-white shadow-xs bg-[#003399] hover:bg-[#00287a] transition"
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
