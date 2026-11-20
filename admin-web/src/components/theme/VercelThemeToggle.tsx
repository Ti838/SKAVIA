'use client';

import { Laptop, Moon, Sun } from 'lucide-react';

export type ThemeMode = 'system' | 'light' | 'dark';

interface VercelThemeToggleProps {
  themeMode: ThemeMode;
  onSelectTheme: (mode: ThemeMode) => void;
  compact?: boolean;
  className?: string;
}

/**
 * High-fidelity, Vercel-inspired segmented 3-state theme control.
 * Renders System, Light, and Dark options in a sleek sub-pixel segmented pill.
 */
export function VercelThemeToggle({
  themeMode,
  onSelectTheme,
  compact = false,
  className = '',
}: VercelThemeToggleProps) {
  const options: Array<{ mode: ThemeMode; label: string; icon: typeof Laptop }> = [
    { mode: 'system', label: 'System', icon: Laptop },
    { mode: 'light', label: 'Light', icon: Sun },
    { mode: 'dark', label: 'Dark', icon: Moon },
  ];

  return (
    <div
      role="radiogroup"
      aria-label="Select display theme"
      className={`inline-flex items-center p-0.5 rounded-full border border-neutral-200 dark:border-neutral-800 bg-neutral-100/80 dark:bg-neutral-900/80 backdrop-blur-md transition-colors ${className}`.trim()}
    >
      {options.map(({ mode, label, icon: Icon }) => {
        const isSelected = themeMode === mode;
        return (
          <button
            key={mode}
            type="button"
            role="radio"
            aria-checked={isSelected}
            onClick={() => onSelectTheme(mode)}
            title={`Select ${label} theme`}
            className={`relative flex items-center justify-center gap-1.5 px-2.5 py-1 text-xs font-medium rounded-full transition-all duration-150 select-none ${
              isSelected
                ? 'bg-white text-neutral-950 shadow-xs dark:bg-neutral-800 dark:text-neutral-100'
                : 'text-neutral-500 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-neutral-200'
            }`}
          >
            <Icon className="h-3.5 w-3.5 shrink-0" />
            {!compact && (
              <span className="text-[11px] font-mono tracking-tight hidden sm:inline">
                {label}
              </span>
            )}
          </button>
        );
      })}
    </div>
  );
}
