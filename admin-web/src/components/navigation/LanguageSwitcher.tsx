'use client';

import { useTranslation } from '@/lib/l10n/LanguageContext';

export function LanguageSwitcher({ className = '' }: { className?: string }) {
  const { language, setLanguage } = useTranslation();

  return (
    <div
      role="group"
      aria-label="Language selection"
      className={`inline-flex items-center rounded-full border p-0.5 text-xs font-medium transition-colors ${className}`}
      style={{
        backgroundColor: 'var(--bg-surface-subtle)',
        borderColor: 'var(--border-subtle)',
      }}
    >
      <button
        type="button"
        onClick={() => setLanguage('bn')}
        aria-pressed={language === 'bn'}
        className={`rounded-full px-2.5 py-1 transition-all ${
          language === 'bn'
            ? 'bg-[#003399] text-white shadow-xs font-semibold'
            : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
        }`}
      >
        বাং
      </button>
      <button
        type="button"
        onClick={() => setLanguage('en')}
        aria-pressed={language === 'en'}
        className={`rounded-full px-2.5 py-1 transition-all ${
          language === 'en'
            ? 'bg-[#003399] text-white shadow-xs font-semibold'
            : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
        }`}
      >
        EN
      </button>
    </div>
  );
}
