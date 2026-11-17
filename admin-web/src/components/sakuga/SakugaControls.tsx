'use client';

/**
 * SKAVIA Sakuga Interactive Controls (Toggle, Checkbox, Radio, Input, Tabs, Progress, Rating, Slider, Tooltip)
 * Motion physics adapted from Sakuga VFX (MIT License, Copyright (c) 2026 Justin Finkelman).
 */

import {
  useEffect,
  useRef,
  useState,
  type InputHTMLAttributes,
  type ReactNode,
} from 'react';
import { Check, Star } from 'lucide-react';
import {
  elementCenter,
  sakugaCelebrate,
  sakugaKira,
  sakugaRing,
  sakugaTicks,
} from '@/lib/sakuga/sakuga-core';

export function SakugaToggle({
  checked,
  onChange,
  label,
  disabled = false,
}: {
  checked: boolean;
  onChange: (next: boolean) => void;
  label?: string;
  disabled?: boolean;
}) {
  const btnRef = useRef<HTMLButtonElement | null>(null);

  const handleToggle = () => {
    if (disabled) return;
    const next = !checked;
    if (btnRef.current) {
      const c = elementCenter(btnRef.current, next ? 0.78 : 0.22, 0.5);
      sakugaRing(c.x, c.y, {
        r: 16,
        w: 2.2,
        color: next ? '#003399' : '#94A3B8',
      });
    }
    onChange(next);
  };

  return (
    <button
      ref={btnRef}
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      onClick={handleToggle}
      className={`relative inline-flex h-7 w-12 shrink-0 items-center rounded-full p-1 transition-colors duration-200 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#3898EC] disabled:opacity-50 ${
        checked ? 'bg-[#003399]' : 'bg-slate-300 dark:bg-slate-700'
      }`}
    >
      <span
        className={`inline-block h-5 w-5 rounded-full bg-white shadow-sm transition-transform duration-200 ease-[cubic-bezier(0.34,1.56,0.64,1)] ${
          checked ? 'translate-x-5' : 'translate-x-0'
        }`}
      />
    </button>
  );
}

export function SakugaCheckbox({
  checked,
  onChange,
  label,
  disabled = false,
}: {
  checked: boolean;
  onChange: (next: boolean) => void;
  label?: string;
  disabled?: boolean;
}) {
  const boxRef = useRef<HTMLButtonElement | null>(null);

  const handleToggle = () => {
    if (disabled) return;
    const next = !checked;
    if (next && boxRef.current) {
      const c = elementCenter(boxRef.current);
      sakugaTicks(c.x, c.y, { n: 3, r: 10, len: 7, dir: -0.8, color: '#3898EC' });
    }
    onChange(next);
  };

  return (
    <label className="inline-flex items-center gap-2 cursor-pointer select-none">
      <button
        ref={boxRef}
        type="button"
        role="checkbox"
        aria-checked={checked}
        aria-label={label}
        disabled={disabled}
        onClick={handleToggle}
        className={`flex h-5 w-5 items-center justify-center rounded-md border-2 transition-all duration-150 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#3898EC] disabled:opacity-50 ${
          checked
            ? 'bg-[#003399] border-[#003399] text-white scale-100'
            : 'bg-transparent border-slate-300 dark:border-slate-600 hover:border-[#3898EC]'
        }`}
      >
        {checked && <Check className="h-3.5 w-3.5 stroke-[3] sakuga-pop-in" />}
      </button>
      {label && (
        <span className="text-sm text-slate-700 dark:text-slate-200">{label}</span>
      )}
    </label>
  );
}

export function SakugaRadio({
  checked,
  onChange,
  label,
  disabled = false,
}: {
  checked: boolean;
  onChange: () => void;
  label?: string;
  disabled?: boolean;
}) {
  const btnRef = useRef<HTMLButtonElement | null>(null);

  const handleSelect = () => {
    if (disabled || checked) return;
    if (btnRef.current) {
      const c = elementCenter(btnRef.current);
      sakugaTicks(c.x, c.y, { n: 4, r: 10, len: 6, fan: 1.4, color: '#3898EC' });
    }
    onChange();
  };

  return (
    <label className="inline-flex items-center gap-2 cursor-pointer select-none">
      <button
        ref={btnRef}
        type="button"
        role="radio"
        aria-checked={checked}
        aria-label={label}
        disabled={disabled}
        onClick={handleSelect}
        className={`flex h-5 w-5 items-center justify-center rounded-full border-2 transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#3898EC] disabled:opacity-50 ${
          checked
            ? 'border-[#003399]'
            : 'border-slate-300 dark:border-slate-600 hover:border-[#3898EC]'
        }`}
      >
        <span
          className={`h-2.5 w-2.5 rounded-full bg-[#003399] transition-transform duration-200 ease-[cubic-bezier(0.34,1.56,0.64,1)] ${
            checked ? 'scale-100' : 'scale-0'
          }`}
        />
      </button>
      {label && (
        <span className="text-sm text-slate-700 dark:text-slate-200">{label}</span>
      )}
    </label>
  );
}

export function SakugaInput({
  className = '',
  ...props
}: InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      {...props}
      className={`rounded-lg border px-3 py-2 text-sm outline-none transition-all duration-150 focus:ring-2 focus:ring-[#3898EC]/40 focus:border-[#3898EC] focus:scale-[1.005] ${className}`}
    />
  );
}

export function SakugaTabs<T extends string>({
  tabs,
  active,
  onChange,
  className = '',
}: {
  tabs: { id: T; label: string }[];
  active: T;
  onChange: (id: T) => void;
  className?: string;
}) {
  return (
    <div
      role="tablist"
      className={`inline-flex items-center gap-1 rounded-xl bg-slate-100 dark:bg-slate-800/80 p-1 ${className}`}
    >
      {tabs.map((tab) => {
        const isActive = tab.id === active;
        return (
          <button
            key={tab.id}
            type="button"
            role="tab"
            aria-selected={isActive}
            onClick={(e) => {
              if (!isActive) {
                const c = elementCenter(e.currentTarget, 0.5, 1);
                sakugaTicks(c.x, c.y, { n: 3, r: 4, len: 6, dir: -Math.PI / 2 });
                onChange(tab.id);
              }
            }}
            className={`rounded-lg px-3.5 py-1.5 text-xs font-semibold transition-all duration-200 ease-[cubic-bezier(0.34,1.56,0.64,1)] ${
              isActive
                ? 'bg-white dark:bg-slate-900 text-[#003399] dark:text-sky-300 shadow-sm scale-[1.02]'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
            }`}
          >
            {tab.label}
          </button>
        );
      })}
    </div>
  );
}

export function SakugaProgress({
  value,
  label,
}: {
  value: number;
  label?: string;
}) {
  const clamped = Math.max(0, Math.min(100, value));
  const barRef = useRef<HTMLDivElement | null>(null);
  const celebratedRef = useRef(clamped >= 100);

  useEffect(() => {
    if (clamped < 100) {
      celebratedRef.current = false;
    } else if (!celebratedRef.current) {
      celebratedRef.current = true;
      if (barRef.current) {
        const c = elementCenter(barRef.current, 1, 0.5);
        sakugaKira(c.x, c.y, { r: 11, color: '#16A34A' });
      }
    }
  }, [clamped]);

  return (
    <div className="w-full">
      {label && (
        <div className="mb-1.5 flex items-center justify-between text-xs font-semibold">
          <span className="text-slate-700 dark:text-slate-200">{label}</span>
          <span className="tabular-nums text-[#003399] dark:text-sky-400">
            {Math.round(clamped)}%
          </span>
        </div>
      )}
      <div
        ref={barRef}
        role="progressbar"
        aria-valuenow={Math.round(clamped)}
        aria-valuemin={0}
        aria-valuemax={100}
        className="h-2 w-full overflow-hidden rounded-full bg-slate-200 dark:bg-slate-800"
      >
        <div
          className={`h-full rounded-full transition-all duration-300 ease-out ${
            clamped >= 100 ? 'bg-emerald-600' : 'bg-[#003399] dark:bg-[#3898EC]'
          }`}
          style={{ width: `${clamped}%` }}
        />
      </div>
    </div>
  );
}

export function SakugaRating({
  value,
  max = 5,
  onChange,
}: {
  value: number;
  max?: number;
  onChange?: (rating: number) => void;
}) {
  return (
    <div className="inline-flex items-center gap-1" role="radiogroup" aria-label="Rating">
      {Array.from({ length: max }, (_, idx) => {
        const starVal = idx + 1;
        const filled = starVal <= value;
        return (
          <button
            key={starVal}
            type="button"
            disabled={!onChange}
            aria-label={`Rate ${starVal} of ${max}`}
            onClick={(e) => {
              if (!onChange) return;
              const c = elementCenter(e.currentTarget);
              if (starVal === max) {
                sakugaCelebrate(c.x, c.y, { r: 30, color: '#F59E0B' });
              } else {
                sakugaKira(c.x, c.y, { r: 10, color: '#F59E0B' });
              }
              onChange(starVal);
            }}
            className="p-0.5 transition-transform duration-150 hover:scale-110 active:scale-90 disabled:cursor-default"
          >
            <Star
              className={`h-5 w-5 transition-colors ${
                filled
                  ? 'fill-amber-400 text-amber-400'
                  : 'text-slate-300 dark:text-slate-600'
              }`}
            />
          </button>
        );
      })}
    </div>
  );
}

export function SakugaSlider({
  value,
  min = 0,
  max = 100,
  step = 1,
  label,
  onChange,
}: {
  value: number;
  min?: number;
  max?: number;
  step?: number;
  label?: string;
  onChange: (val: number) => void;
}) {
  return (
    <div className="w-full">
      {label && (
        <div className="mb-1 flex justify-between text-xs font-medium text-slate-600 dark:text-slate-300">
          <span>{label}</span>
          <span className="tabular-nums font-semibold">{value}</span>
        </div>
      )}
      <input
        type="range"
        min={min}
        max={max}
        step={step}
        value={value}
        aria-label={label ?? 'Slider'}
        onChange={(e) => onChange(Number(e.target.value))}
        className="w-full accent-[#003399] dark:accent-[#3898EC] cursor-pointer"
      />
    </div>
  );
}

export function SakugaTooltip({
  content,
  children,
}: {
  content: string;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(false);

  return (
    <span
      className="relative inline-flex"
      onMouseEnter={() => setOpen(true)}
      onMouseLeave={() => setOpen(false)}
      onFocus={() => setOpen(true)}
      onBlur={() => setOpen(false)}
    >
      {children}
      {open && (
        <span
          role="tooltip"
          className="sakuga-pop-in pointer-events-none absolute bottom-full left-1/2 z-50 mb-2 -translate-x-1/2 whitespace-nowrap rounded-lg bg-slate-900 dark:bg-slate-100 px-2.5 py-1 text-xs font-semibold text-white dark:text-slate-900 shadow-lg"
        >
          {content}
        </span>
      )}
    </span>
  );
}
