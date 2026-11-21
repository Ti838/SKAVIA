'use client';

/**
 * SKAVIA Pro Button
 * Clean, tactile Apple/Vercel standard micro-interactions.
 * Snappy uniform scale(0.98) active depression, zero rubber warping, crystal-clear typography.
 */

import {
  forwardRef,
  type ButtonHTMLAttributes,
  type MouseEvent,
} from 'react';
import { Check } from 'lucide-react';
import {
  elementCenter,
  sakugaCelebrate,
} from '@/lib/sakuga/sakuga-core';

export interface SakugaButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  emitVfx?: boolean;
  done?: boolean;
  intensity?: 'subtle' | 'medium' | 'high';
}

export const SakugaButton = forwardRef<HTMLButtonElement, SakugaButtonProps>(
  function SakugaButton(
    {
      variant = 'primary',
      emitVfx = false,
      done = false,
      intensity,
      className = '',
      onClick,
      disabled,
      children,
      type = 'button',
      ...rest
    },
    ref,
  ) {
    void intensity;
    const handleClick = (e: MouseEvent<HTMLButtonElement>) => {
      if (!disabled && emitVfx && e.currentTarget) {
        const c = elementCenter(e.currentTarget);
        sakugaCelebrate(c.x, c.y, { r: 38 });
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
        ref={ref}
        type={type}
        disabled={disabled}
        onClick={handleClick}
        className={`inline-flex items-center justify-center font-medium rounded-xl transition-all duration-150 active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed ${variantStyles} ${className}`}
        {...rest}
      >
        {done ? (
          <span className="inline-flex items-center gap-1.5 animate-in fade-in zoom-in-95 duration-150">
            <Check className="h-4 w-4" />
            <span>{children}</span>
          </span>
        ) : (
          children
        )}
      </button>
    );
  },
);
