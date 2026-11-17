'use client';

/**
 * SKAVIA Sakuga Button
 * Volume-preserving squash & stretch spring physics + optional kinetic feedback.
 * Adapted from Sakuga VFX (MIT License, Copyright (c) 2026 Justin Finkelman).
 */

import {
  forwardRef,
  useEffect,
  useRef,
  type ButtonHTMLAttributes,
  type MouseEvent,
} from 'react';
import { Check } from 'lucide-react';
import {
  attachSakugaSquash,
  elementCenter,
  sakugaCelebrate,
  sakugaTicks,
  type SakugaIntensity,
} from '@/lib/sakuga/sakuga-core';

export interface SakugaButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  intensity?: SakugaIntensity;
  emitVfx?: boolean;
  done?: boolean;
}

export const SakugaButton = forwardRef<HTMLButtonElement, SakugaButtonProps>(
  function SakugaButton(
    {
      variant = 'primary',
      intensity,
      emitVfx = true,
      done = false,
      className = '',
      onClick,
      disabled,
      children,
      type = 'button',
      ...rest
    },
    forwardedRef,
  ) {
    const innerRef = useRef<HTMLButtonElement | null>(null);
    const resolvedIntensity: SakugaIntensity =
      intensity ??
      (variant === 'primary' || variant === 'danger' ? 'medium' : 'subtle');

    useEffect(() => {
      const el = innerRef.current;
      if (!el) return;
      const low =
        resolvedIntensity === 'subtle'
          ? 0.96
          : resolvedIntensity === 'strong'
            ? 0.87
            : 0.91;
      const wide =
        resolvedIntensity === 'subtle'
          ? 0.14
          : resolvedIntensity === 'strong'
            ? 0.28
            : 0.22;
      return attachSakugaSquash(el, { low, wide });
    }, [resolvedIntensity]);

    const handleClick = (e: MouseEvent<HTMLButtonElement>) => {
      if (!disabled && emitVfx && innerRef.current) {
        const c = elementCenter(innerRef.current);
        if (resolvedIntensity === 'strong') {
          sakugaCelebrate(c.x, c.y, { r: 44 });
        } else if (resolvedIntensity === 'medium') {
          sakugaTicks(c.x, c.y - c.h / 2 - 2, {
            n: 4,
            r: 8,
            len: 10,
            fan: 0.62,
            color: variant === 'danger' ? '#DC2626' : '#3898EC',
          });
        } else {
          sakugaTicks(c.x + c.w / 2 - 4, c.y - c.h / 2 + 2, {
            n: 3,
            r: 4,
            len: 8,
            dir: -0.85,
            fan: 0.4,
          });
        }
      }
      onClick?.(e);
    };

    const variantStyles =
      variant === 'primary'
        ? 'bg-[#003399] hover:bg-[#00297A] text-white border border-transparent shadow-sm'
        : variant === 'danger'
          ? 'bg-red-600 hover:bg-red-700 text-white border border-transparent shadow-sm'
          : variant === 'secondary'
            ? 'bg-white dark:bg-slate-900 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-900 dark:text-slate-100 border border-slate-200 dark:border-slate-700'
            : 'bg-transparent hover:bg-slate-100 dark:hover:bg-slate-800/70 text-slate-700 dark:text-slate-200 border border-transparent';

    return (
      <button
        ref={(node) => {
          innerRef.current = node;
          if (typeof forwardedRef === 'function') forwardedRef(node);
          else if (forwardedRef) forwardedRef.current = node;
        }}
        type={type}
        disabled={disabled}
        onClick={handleClick}
        className={`inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-semibold transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#3898EC] disabled:opacity-50 disabled:cursor-not-allowed select-none will-change-transform ${variantStyles} ${className}`}
        {...rest}
      >
        {children}
        {done && (
          <Check
            className="h-4 w-4 text-emerald-300 shrink-0 sakuga-pop-in"
            aria-hidden="true"
          />
        )}
      </button>
    );
  },
);
