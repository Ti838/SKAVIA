'use client';

import { useEffect } from 'react';
import Link from 'next/link';
import {
  Briefcase,
  Building2,
  CalendarClock,
  HelpCircle,
  Home,
  Layers,
  Mail,
  Smartphone,
  UserCheck,
  Users,
  Wrench,
  X,
} from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import { LanguageSwitcher } from './LanguageSwitcher';
import { LocationPill } from './LocationPill';

interface MobileNavDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  onDownloadClick?: () => void;
}

export function MobileNavDrawer({ isOpen, onClose, onDownloadClick }: MobileNavDrawerProps) {
  const { t } = useTranslation();

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

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={t.menuTitle}
      className="fixed inset-0 z-50 flex lg:hidden bg-black/60 backdrop-blur-xs animate-in fade-in duration-200"
    >
      {/* Backdrop tap to dismiss */}
      <div className="fixed inset-0" onClick={onClose} aria-hidden="true" />

      {/* Slide-over Drawer */}
      <div
        className="relative ml-auto w-full max-w-xs sm:max-w-sm h-full flex flex-col shadow-2xl overflow-y-auto animate-in slide-in-from-right duration-250"
        style={{
          backgroundColor: 'var(--bg-surface)',
          borderLeft: '1px solid var(--border-subtle)',
          color: 'var(--text-primary)',
        }}
      >
        {/* Drawer Header */}
        <div
          className="sticky top-0 z-10 flex items-center justify-between px-4 py-3.5 border-b"
          style={{
            backgroundColor: 'var(--bg-surface)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <div className="flex items-center gap-2.5">
            <SkaviaBrandMark variant="emblem" size={26} />
            <span className="font-heading font-bold text-sm tracking-tight">{t.brandName}</span>
          </div>

          <div className="flex items-center gap-2">
            <LanguageSwitcher />
            <button
              type="button"
              onClick={onClose}
              aria-label={t.menuClose}
              className="rounded-lg p-1.5 border hover:bg-slate-100 dark:hover:bg-slate-800 transition"
              style={{ borderColor: 'var(--border-subtle)' }}
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        </div>

        {/* Location Row */}
        <div
          className="px-4 py-2.5 border-b flex items-center justify-between"
          style={{
            backgroundColor: 'var(--bg-surface-subtle)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <span className="text-xs text-slate-500 font-medium">{t.activeLocation}:</span>
          <LocationPill compact />
        </div>

        {/* Navigation Content */}
        <div className="flex-1 px-4 py-4 space-y-6">
          {/* Section Links */}
          <div className="space-y-1">
            <p className="text-[11px] font-mono-code uppercase tracking-wider text-slate-400 px-2 mb-2">
              Navigation
            </p>

            <a
              href="#about"
              onClick={onClose}
              className="flex items-center gap-3 rounded-xl px-3 py-2.5 text-xs font-semibold hover:bg-slate-100 dark:hover:bg-slate-800 transition"
            >
              <Home className="h-4 w-4 text-[#003399] dark:text-[#3898EC]" />
              <span>{t.navAbout}</span>
            </a>

            <a
              href="#how-it-works"
              onClick={onClose}
              className="flex items-center gap-3 rounded-xl px-3 py-2.5 text-xs font-semibold hover:bg-slate-100 dark:hover:bg-slate-800 transition"
            >
              <CalendarClock className="h-4 w-4 text-[#003399] dark:text-[#3898EC]" />
              <span>{t.navHowItWorks}</span>
            </a>

            <a
              href="#branches"
              onClick={onClose}
              className="flex items-center gap-3 rounded-xl px-3 py-2.5 text-xs font-semibold hover:bg-slate-100 dark:hover:bg-slate-800 transition"
            >
              <Layers className="h-4 w-4 text-[#003399] dark:text-[#3898EC]" />
              <span>{t.navBranches}</span>
            </a>

            <a
              href="#solutions"
              onClick={onClose}
              className="flex items-center gap-3 rounded-xl px-3 py-2.5 text-xs font-semibold hover:bg-slate-100 dark:hover:bg-slate-800 transition"
            >
              <Briefcase className="h-4 w-4 text-[#003399] dark:text-[#3898EC]" />
              <span>{t.navSolutions}</span>
            </a>

            <a
              href="#workers"
              onClick={onClose}
              className="flex items-center gap-3 rounded-xl px-3 py-2.5 text-xs font-semibold hover:bg-slate-100 dark:hover:bg-slate-800 transition"
            >
              <Wrench className="h-4 w-4 text-[#003399] dark:text-[#3898EC]" />
              <span>{t.navBecomeWorker}</span>
            </a>

            <a
              href="#faq"
              onClick={onClose}
              className="flex items-center gap-3 rounded-xl px-3 py-2.5 text-xs font-semibold hover:bg-slate-100 dark:hover:bg-slate-800 transition"
            >
              <HelpCircle className="h-4 w-4 text-[#003399] dark:text-[#3898EC]" />
              <span>{t.navFaq}</span>
            </a>

            <a
              href="#contact"
              onClick={onClose}
              className="flex items-center gap-3 rounded-xl px-3 py-2.5 text-xs font-semibold hover:bg-slate-100 dark:hover:bg-slate-800 transition"
            >
              <Mail className="h-4 w-4 text-[#003399] dark:text-[#3898EC]" />
              <span>{t.navContact}</span>
            </a>
          </div>

          {/* Unified Role Portal Links */}
          <div className="space-y-1 pt-2 border-t" style={{ borderColor: 'var(--border-subtle)' }}>
            <p className="text-[11px] font-mono-code uppercase tracking-wider text-slate-400 px-2 mb-2">
              {t.roleSwitcherTitle}
            </p>

            <Link
              href="/customer-portal"
              onClick={onClose}
              className="flex items-center justify-between rounded-xl border p-2.5 text-xs transition hover:border-[#003399]"
              style={{ borderColor: 'var(--border-subtle)', backgroundColor: 'var(--bg-surface-subtle)' }}
            >
              <div className="flex items-center gap-2.5">
                <Users className="h-4 w-4 text-blue-600" />
                <span className="font-medium">{t.roleIndividualCustomer}</span>
              </div>
              <span className="text-[10px] uppercase font-mono-code text-slate-400">Portal</span>
            </Link>

            <Link
              href="/business-portal"
              onClick={onClose}
              className="flex items-center justify-between rounded-xl border p-2.5 text-xs transition hover:border-[#7C3AED]"
              style={{ borderColor: 'var(--border-subtle)', backgroundColor: 'var(--bg-surface-subtle)' }}
            >
              <div className="flex items-center gap-2.5">
                <Building2 className="h-4 w-4 text-purple-600" />
                <span className="font-medium">{t.roleBusinessClient}</span>
              </div>
              <span className="text-[10px] uppercase font-mono-code text-slate-400">Corporate</span>
            </Link>

            <a
              href="#workers"
              onClick={onClose}
              className="flex items-center justify-between rounded-xl border p-2.5 text-xs transition hover:border-[#0284C7]"
              style={{ borderColor: 'var(--border-subtle)', backgroundColor: 'var(--bg-surface-subtle)' }}
            >
              <div className="flex items-center gap-2.5">
                <UserCheck className="h-4 w-4 text-sky-600" />
                <span className="font-medium">{t.roleWorker}</span>
              </div>
              <span className="text-[10px] uppercase font-mono-code text-slate-400">Join</span>
            </a>
          </div>
        </div>

        {/* Drawer Footer CTA */}
        <div
          className="sticky bottom-0 p-4 border-t space-y-2"
          style={{
            backgroundColor: 'var(--bg-surface)',
            borderColor: 'var(--border-subtle)',
          }}
        >
          <a
            href="#download"
            onClick={() => {
              onClose();
              if (onDownloadClick) onDownloadClick();
            }}
            className="w-full flex items-center justify-center gap-2 rounded-xl bg-[#003399] px-4 py-2.5 text-xs font-semibold text-white shadow-sm hover:bg-[#00287a] transition"
          >
            <Smartphone className="h-4 w-4" />
            <span>{t.downloadApkTitle}</span>
          </a>
        </div>
      </div>
    </div>
  );
}
