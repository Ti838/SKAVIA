'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  ChevronDown,
  Menu,
  Shield,
  Smartphone,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { VercelThemeToggle, type ThemeMode } from '@/components/theme/VercelThemeToggle';
import { MobileNavDrawer } from './MobileNavDrawer';

interface PublicHeaderProps {
  themeMode: 'system' | 'light' | 'dark';
  onCycleTheme: () => void;
  setThemeMode?: (mode: 'system' | 'light' | 'dark') => void;
  onDownloadClick?: () => void;
}

export function PublicHeader({
  themeMode,
  onCycleTheme,
  setThemeMode,
  onDownloadClick,
}: PublicHeaderProps) {
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [servicesMenuOpen, setServicesMenuOpen] = useState(false);

  const branches = [
    { code: 'HOME', name: 'SKAVIA Home', desc: 'Plumbing, leak detection, sanitary & cleaning', href: '/branches/home' },
    { code: 'TECH', name: 'SKAVIA Technical', desc: 'HVAC cooling, gas charging & electrical', href: '/branches/technical' },
    { code: 'AGRI', name: 'SKAVIA Agriculture', desc: 'Drip irrigation & pump automation', href: '/services-catalog' },
    { code: 'LOGI', name: 'SKAVIA Logistics', desc: 'Trade equipment transport & dispatch', href: '/services-catalog' },
    { code: 'DIGI', name: 'SKAVIA Digital', desc: 'Cat6 cabling, PoE CCTV & POS networking', href: '/services-catalog' },
    { code: 'BIZ', name: 'SKAVIA Business', desc: 'Turnkey commercial fit-outs & SLAs', href: '/business' },
    { code: 'CONS', name: 'SKAVIA Construction', desc: 'Civil renovation & gypsum partitions', href: '/services-catalog' },
    { code: 'EVNT', name: 'SKAVIA Events', desc: 'Staging & high-voltage power distribution', href: '/services-catalog' },
  ];

  const navLinks = [
    { label: 'About', href: '/about' },
    { label: 'Services', href: '/services-catalog', hasDropdown: true },
    { label: 'How It Works', href: '/how-it-works' },
    { label: 'Trust & Safety', href: '/experience' },
    { label: 'For Specialists', href: '/specialists' },
    { label: 'Enterprise', href: '/business' },
    { label: 'FAQ', href: '/faq' },
    { label: 'Contact', href: '/contact' },
  ];

  const handleSelectTheme = (mode: ThemeMode) => {
    if (setThemeMode) {
      setThemeMode(mode);
    } else {
      onCycleTheme();
    }
  };

  return (
    <>
      <header className="sticky top-0 z-40 border-b backdrop-blur-xl bg-white/80 dark:bg-black/80 border-neutral-200/80 dark:border-white/10 transition-colors duration-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between gap-3 sm:gap-4">
          {/* Brand Logo & Wordmark */}
          <div className="flex items-center gap-3 sm:gap-4 min-w-0">
            <Link
              href="/"
              className="group flex items-center gap-2.5 shrink-0 transition-opacity hover:opacity-90"
              aria-label="SKAVIA Home"
            >
              <SkaviaBrandMark variant="emblem" size={30} priority />
              <div className="flex flex-col">
                <span className="font-heading font-extrabold text-base tracking-tight leading-none text-neutral-950 dark:text-white">
                  SKAVIA
                </span>
                <span className="text-[10px] font-mono tracking-wider text-neutral-500 dark:text-neutral-400 hidden sm:inline uppercase">
                  Workforce &amp; Services
                </span>
              </div>
            </Link>
          </div>

          {/* Desktop Navigation Links (>= 1024px) */}
          <nav
            aria-label="Public Site Navigation"
            className="hidden lg:flex items-center gap-1 text-xs font-medium"
          >
            {navLinks.map((link) => {
              const isActive =
                pathname === link.href ||
                (link.href !== '/' && pathname.startsWith(`${link.href}/`));

              if (link.hasDropdown) {
                return (
                  <div
                    key={link.href}
                    className="relative"
                    onMouseEnter={() => setServicesMenuOpen(true)}
                    onMouseLeave={() => setServicesMenuOpen(false)}
                  >
                    <Link
                      href={link.href}
                      className={`inline-flex items-center gap-1 px-3 py-1.5 rounded-full transition-all ${
                        isActive
                          ? 'bg-neutral-100 text-neutral-950 dark:bg-white/10 dark:text-white font-semibold'
                          : 'text-neutral-600 hover:text-neutral-950 dark:text-neutral-400 dark:hover:text-white hover:bg-neutral-100/80 dark:hover:bg-neutral-800/60'
                      }`}
                    >
                      <span>{link.label}</span>
                      <ChevronDown className="h-3 w-3 opacity-60 transition-transform group-hover:rotate-180" />
                    </Link>

                    {/* Services Dropdown Flyout */}
                    {servicesMenuOpen && (
                      <div className="absolute left-1/2 -translate-x-1/2 top-full pt-2 w-80 sm:w-96 z-50 animate-in fade-in slide-in-from-top-1 duration-150">
                        <div className="rounded-2xl border border-neutral-200 dark:border-neutral-800 bg-white/95 dark:bg-neutral-950/95 backdrop-blur-2xl p-3 shadow-2xl space-y-1">
                          <div className="px-2 py-1.5 border-b border-neutral-100 dark:border-neutral-800/80 flex items-center justify-between">
                            <span className="text-[11px] font-mono uppercase tracking-wider text-neutral-400 font-semibold">
                              8 Specialization Branches
                            </span>
                            <Link
                              href="/services-catalog"
                              className="text-[11px] font-semibold text-[#003399] dark:text-[#3898EC] hover:underline"
                            >
                              View Catalog →
                            </Link>
                          </div>
                          <div className="grid grid-cols-1 gap-1 max-h-80 overflow-y-auto py-1">
                            {branches.map((b) => (
                              <Link
                                key={b.code}
                                href={b.href}
                                className="group/item flex items-start gap-2.5 p-2 rounded-xl hover:bg-neutral-100 dark:hover:bg-neutral-900 transition-colors"
                              >
                                <span className="font-mono text-[10px] font-bold px-1.5 py-0.5 rounded-md bg-neutral-100 dark:bg-neutral-800 text-neutral-700 dark:text-neutral-300 shrink-0 mt-0.5">
                                  {b.code}
                                </span>
                                <div className="flex flex-col min-w-0">
                                  <span className="text-xs font-semibold text-neutral-900 dark:text-neutral-100 group-hover/item:text-[#003399] dark:group-hover/item:text-[#3898EC] transition-colors truncate">
                                    {b.name}
                                  </span>
                                  <span className="text-[11px] text-neutral-500 dark:text-neutral-400 line-clamp-1">
                                    {b.desc}
                                  </span>
                                </div>
                              </Link>
                            ))}
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                );
              }

              return (
                <Link
                  key={link.href}
                  href={link.href}
                  className={`px-3 py-1.5 rounded-full transition-all ${
                    isActive
                      ? 'bg-neutral-100 text-neutral-950 dark:bg-white/10 dark:text-white font-semibold'
                      : 'text-neutral-600 hover:text-neutral-950 dark:text-neutral-400 dark:hover:text-white hover:bg-neutral-100/80 dark:hover:bg-neutral-800/60'
                  }`}
                >
                  {link.label}
                </Link>
              );
            })}
          </nav>

          {/* Right Action Controls */}
          <div className="flex items-center gap-2 sm:gap-3 shrink-0">
            {/* Segmented Vercel Theme Switcher */}
            <VercelThemeToggle
              themeMode={themeMode}
              onSelectTheme={handleSelectTheme}
            />

            {/* Admin Portal Sign In Link */}
            <Link
              href="/login"
              className="hidden md:inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium text-neutral-600 hover:text-neutral-950 dark:text-neutral-400 dark:hover:text-white hover:bg-neutral-100 dark:hover:bg-neutral-800 transition"
              title="SKAVIA Enterprise Admin Portal"
            >
              <Shield className="h-3.5 w-3.5 opacity-70" />
              <span>Admin</span>
            </Link>

            {/* High-Contrast Primary CTA (Vercel Style) */}
            <Link
              href="/download"
              onClick={onDownloadClick}
              className="inline-flex items-center gap-1.5 rounded-full px-4 py-2 text-xs font-semibold bg-neutral-950 text-white hover:bg-neutral-800 dark:bg-white dark:text-neutral-950 dark:hover:bg-neutral-200 transition-all hover:scale-[1.02] active:scale-[0.98] shadow-xs"
            >
              <Smartphone className="h-3.5 w-3.5" />
              <span className="hidden sm:inline">Get Mobile App</span>
              <span className="sm:hidden">Get App</span>
            </Link>

            {/* Mobile Hamburger Button (< 1024px) */}
            <button
              type="button"
              onClick={() => setMobileMenuOpen(true)}
              aria-label="Open navigation menu"
              aria-expanded={mobileMenuOpen}
              className="lg:hidden inline-flex items-center justify-center h-8 w-8 rounded-full border border-neutral-200 dark:border-neutral-800 text-neutral-700 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800 transition"
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
        themeMode={themeMode}
        onCycleTheme={onCycleTheme}
      />
    </>
  );
}
