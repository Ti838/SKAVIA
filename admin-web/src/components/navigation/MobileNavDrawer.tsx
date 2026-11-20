'use client';

import { useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Briefcase,
  Building2,
  CalendarClock,
  HelpCircle,
  Home,
  Laptop,
  Layers,
  Mail,
  Moon,
  ShieldCheck,
  Smartphone,
  Sun,
  Wrench,
  X,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';

interface MobileNavDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  onDownloadClick?: () => void;
  themeMode?: 'system' | 'light' | 'dark';
  onCycleTheme?: () => void;
}

export function MobileNavDrawer({
  isOpen,
  onClose,
  onDownloadClick,
  themeMode = 'system',
  onCycleTheme,
}: MobileNavDrawerProps) {
  const pathname = usePathname();

  // Escape key listener & body scroll lock
  useEffect(() => {
    if (!isOpen) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };

    document.body.style.overflow = 'hidden';
    window.addEventListener('keydown', handleKeyDown);

    return () => {
      document.body.style.overflow = '';
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const navLinks = [
    { label: 'Home', href: '/', icon: Home },
    { label: 'About SKAVIA', href: '/about', icon: Briefcase },
    { label: 'Services Directory', href: '/services-catalog', icon: Layers },
    { label: 'How It Works', href: '/how-it-works', icon: CalendarClock },
    { label: 'Trust & Safety', href: '/experience', icon: ShieldCheck },
    { label: 'For Specialists', href: '/specialists', icon: Wrench },
    { label: 'Enterprise Solutions', href: '/business', icon: Building2 },
    { label: 'FAQ', href: '/faq', icon: HelpCircle },
    { label: 'Contact & Support', href: '/contact', icon: Mail },
  ];

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label="Navigation Menu"
      className="fixed inset-0 z-50 flex lg:hidden bg-black/60 backdrop-blur-xs animate-in fade-in duration-200"
    >
      {/* Backdrop tap to dismiss */}
      <div className="fixed inset-0" onClick={onClose} aria-hidden="true" />

      {/* Slide-over Drawer */}
      <div
        className="relative ml-auto w-full max-w-xs sm:max-w-sm h-full flex flex-col shadow-2xl overflow-y-auto animate-in slide-in-from-right duration-250 bg-white dark:bg-[#0B1120] text-slate-900 dark:text-slate-100 border-l border-slate-200 dark:border-slate-800"
      >
        {/* Drawer Header */}
        <div className="sticky top-0 z-10 flex items-center justify-between px-4 py-3.5 border-b border-slate-200 dark:border-slate-800 bg-white/95 dark:bg-[#0B1120]/95 backdrop-blur-md">
          <div className="flex items-center gap-2.5">
            <SkaviaBrandMark variant="emblem" size={26} />
            <div className="flex flex-col">
              <span className="font-heading font-extrabold text-sm tracking-tight leading-none text-slate-900 dark:text-white">
                SKAVIA
              </span>
              <span className="text-[9px] font-mono-code text-slate-500 tracking-wider uppercase">
                Workforce &amp; Services
              </span>
            </div>
          </div>

          <div className="flex items-center gap-2">
            {onCycleTheme && (
              <button
                type="button"
                onClick={onCycleTheme}
                aria-label={`Toggle theme (currently ${themeMode})`}
                className="rounded-lg p-1.5 border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition"
                title={`Theme: ${themeMode}`}
              >
                {themeMode === 'system' ? (
                  <Laptop className="h-4 w-4 text-[#3898EC]" />
                ) : themeMode === 'light' ? (
                  <Sun className="h-4 w-4 text-amber-500" />
                ) : (
                  <Moon className="h-4 w-4 text-indigo-400" />
                )}
              </button>
            )}

            <button
              type="button"
              onClick={onClose}
              aria-label="Close menu"
              className="rounded-lg p-1.5 border border-slate-200 dark:border-slate-800 hover:bg-slate-100 dark:hover:bg-slate-800 transition text-slate-700 dark:text-slate-300"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        </div>

        {/* Navigation Content */}
        <div className="flex-1 px-3 py-4 space-y-1">
          <p className="text-[10px] font-mono-code uppercase tracking-wider text-slate-400 px-3 mb-2 font-bold">
            Navigation Menu
          </p>

          {navLinks.map((link) => {
            const Icon = link.icon;
            const isActive =
              pathname === link.href ||
              (link.href !== '/' && pathname.startsWith(`${link.href}/`));
            return (
              <Link
                key={link.href}
                href={link.href}
                onClick={onClose}
                className={`flex items-center gap-3 rounded-xl px-3 py-2.5 text-xs font-semibold transition-all ${
                  isActive
                    ? 'bg-[#003399]/10 text-[#003399] dark:bg-cyan-500/15 dark:text-cyan-300 font-bold'
                    : 'text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800/80 hover:text-slate-950 dark:hover:text-white'
                }`}
              >
                <Icon className="h-4 w-4 shrink-0 text-[#003399] dark:text-[#3898EC]" />
                <span>{link.label}</span>
              </Link>
            );
          })}
        </div>

        {/* Drawer Footer CTA */}
        <div className="sticky bottom-0 p-4 border-t border-slate-200 dark:border-slate-800 bg-white/95 dark:bg-[#0B1120]/95 backdrop-blur-md space-y-2">
          <Link
            href="/download"
            onClick={() => {
              onClose();
              if (onDownloadClick) onDownloadClick();
            }}
            className="w-full flex items-center justify-center gap-2 rounded-full bg-neutral-950 text-white hover:bg-neutral-800 dark:bg-white dark:text-neutral-950 dark:hover:bg-neutral-200 px-4 py-2.5 text-xs font-semibold shadow-md transition-all"
          >
            <Smartphone className="h-4 w-4" />
            <span>Download Mobile App</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
