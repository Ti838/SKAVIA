'use client';

/**
 * SKAVIA Interactive Pro Link
 * Clean, tactile Apple/Vercel standard micro-interactions.
 * Zero rubber warping, uniform scale(0.98) active depression, 100% stable typography.
 */

import { forwardRef, type AnchorHTMLAttributes } from 'react';
import Link, { type LinkProps } from 'next/link';

export interface SakugaLinkProps
  extends Omit<AnchorHTMLAttributes<HTMLAnchorElement>, keyof LinkProps>,
    LinkProps {}

export const SakugaLink = forwardRef<HTMLAnchorElement, SakugaLinkProps>(
  function SakugaLink(
    {
      className = '',
      children,
      href,
      ...rest
    },
    ref,
  ) {
    return (
      <Link
        ref={ref}
        href={href}
        className={`inline-flex items-center transition-all duration-150 active:scale-[0.98] ${className}`}
        {...rest}
      >
        {children}
      </Link>
    );
  },
);
