'use client';

/**
 * SKAVIA Sakuga Link
 * Volume-preserving squash & stretch spring physics + optional kinetic feedback for Next.js Link.
 * Adapted from Sakuga VFX (MIT License, Copyright (c) 2026 Justin Finkelman).
 */

import {
  forwardRef,
  useEffect,
  useRef,
  type AnchorHTMLAttributes,
  type MouseEvent,
} from 'react';
import Link, { type LinkProps } from 'next/link';
import {
  attachSakugaSquash,
  elementCenter,
  sakugaCelebrate,
  sakugaTicks,
  type SakugaIntensity,
} from '@/lib/sakuga/sakuga-core';

export interface SakugaLinkProps
  extends Omit<AnchorHTMLAttributes<HTMLAnchorElement>, keyof LinkProps>,
    LinkProps {
  intensity?: SakugaIntensity;
  emitVfx?: boolean;
  celebrateOnClick?: boolean;
}

export const SakugaLink = forwardRef<HTMLAnchorElement, SakugaLinkProps>(
  function SakugaLink(
    {
      intensity,
      emitVfx = true,
      celebrateOnClick = false,
      className = '',
      onClick,
      children,
      href,
      ...rest
    },
    forwardedRef,
  ) {
    const innerRef = useRef<HTMLAnchorElement | null>(null);
    const resolvedIntensity: SakugaIntensity = intensity ?? (celebrateOnClick ? 'strong' : 'subtle');

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

    const handleClick = (e: MouseEvent<HTMLAnchorElement>) => {
      if (emitVfx && innerRef.current) {
        const c = elementCenter(innerRef.current);
        if (celebrateOnClick || resolvedIntensity === 'strong') {
          sakugaCelebrate(c.x, c.y, { r: 44 });
        } else if (resolvedIntensity === 'medium') {
          sakugaTicks(c.x, c.y - c.h / 2 - 2, {
            n: 4,
            r: 8,
            len: 10,
            fan: 0.62,
            color: '#3898EC',
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

    return (
      <Link
        ref={(node) => {
          innerRef.current = node;
          if (typeof forwardedRef === 'function') {
            forwardedRef(node);
          } else if (forwardedRef) {
            forwardedRef.current = node;
          }
        }}
        href={href}
        onClick={handleClick}
        className={`sakuga-spring-tap ${className}`}
        {...rest}
      >
        {children}
      </Link>
    );
  },
);
