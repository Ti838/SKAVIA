'use client';

import { useId } from 'react';

interface HeroAtmosphereProps {
  dark: boolean;
  variant?: 'hero' | 'subpage' | 'enterprise' | 'technical';
  accentColor?: string;
  className?: string;
}

export function HeroAtmosphere({
  dark,
  variant = 'hero',
  accentColor,
  className = '',
}: HeroAtmosphereProps) {
  const patternId = useId();

  // Color profiles based on variant & theme
  const getGlowStyles = () => {
    if (variant === 'enterprise') {
      return {
        primary: dark
          ? 'radial-gradient(ellipse 85% 60% at 50% -10%, rgba(124, 58, 237, 0.28) 0%, rgba(0, 51, 153, 0.18) 40%, rgba(21, 231, 202, 0.05) 70%, transparent 100%)'
          : 'radial-gradient(ellipse 85% 60% at 50% -10%, rgba(124, 58, 237, 0.1) 0%, rgba(0, 51, 153, 0.06) 40%, transparent 100%)',
        accentLeft: dark
          ? 'radial-gradient(circle 500px at 15% 15%, rgba(124, 58, 237, 0.12), transparent 70%)'
          : 'radial-gradient(circle 500px at 15% 15%, rgba(124, 58, 237, 0.05), transparent 70%)',
        accentRight: dark
          ? 'radial-gradient(circle 500px at 85% 20%, rgba(56, 152, 236, 0.1), transparent 70%)'
          : 'radial-gradient(circle 500px at 85% 20%, rgba(56, 152, 236, 0.05), transparent 70%)',
        horizonBeam: dark ? 'from-transparent via-purple-400/50 to-transparent' : 'from-transparent via-purple-500/30 to-transparent',
      };
    }

    if (variant === 'technical') {
      return {
        primary: dark
          ? 'radial-gradient(ellipse 85% 60% at 50% -10%, rgba(0, 51, 153, 0.35) 0%, rgba(56, 152, 236, 0.2) 38%, rgba(21, 231, 202, 0.08) 65%, transparent 100%)'
          : 'radial-gradient(ellipse 85% 60% at 50% -10%, rgba(0, 51, 153, 0.1) 0%, rgba(56, 152, 236, 0.08) 40%, transparent 100%)',
        accentLeft: dark
          ? 'radial-gradient(circle 500px at 10% 20%, rgba(56, 152, 236, 0.12), transparent 70%)'
          : 'radial-gradient(circle 500px at 10% 20%, rgba(56, 152, 236, 0.05), transparent 70%)',
        accentRight: dark
          ? 'radial-gradient(circle 500px at 90% 15%, rgba(21, 231, 202, 0.1), transparent 70%)'
          : 'radial-gradient(circle 500px at 90% 15%, rgba(21, 231, 202, 0.04), transparent 70%)',
        horizonBeam: dark ? 'from-transparent via-cyan-400/50 to-transparent' : 'from-transparent via-blue-500/30 to-transparent',
      };
    }

    if (variant === 'subpage') {
      return {
        primary: dark
          ? 'radial-gradient(ellipse 90% 65% at 50% -15%, rgba(0, 51, 153, 0.28) 0%, rgba(21, 231, 202, 0.1) 45%, transparent 100%)'
          : 'radial-gradient(ellipse 90% 65% at 50% -15%, rgba(0, 51, 153, 0.08) 0%, rgba(21, 231, 202, 0.04) 45%, transparent 100%)',
        accentLeft: dark
          ? 'radial-gradient(circle 450px at 15% 10%, rgba(21, 231, 202, 0.08), transparent 70%)'
          : 'radial-gradient(circle 450px at 15% 10%, rgba(21, 231, 202, 0.03), transparent 70%)',
        accentRight: dark
          ? 'radial-gradient(circle 450px at 85% 15%, rgba(56, 152, 236, 0.08), transparent 70%)'
          : 'radial-gradient(circle 450px at 85% 15%, rgba(56, 152, 236, 0.03), transparent 70%)',
        horizonBeam: dark ? 'from-transparent via-[#15E7CA]/40 to-transparent' : 'from-transparent via-[#003399]/20 to-transparent',
      };
    }

    // Default: 'hero'
    return {
      primary: dark
        ? 'radial-gradient(ellipse 85% 65% at 50% -10%, rgba(0, 51, 153, 0.42) 0%, rgba(79, 70, 229, 0.22) 36%, rgba(21, 231, 202, 0.1) 62%, transparent 100%)'
        : 'radial-gradient(ellipse 85% 65% at 50% -10%, rgba(0, 51, 153, 0.12) 0%, rgba(56, 152, 236, 0.08) 38%, rgba(21, 231, 202, 0.04) 65%, transparent 100%)',
      accentLeft: dark
        ? 'radial-gradient(circle 550px at 12% 12%, rgba(21, 231, 202, 0.09), transparent 70%)'
        : 'radial-gradient(circle 550px at 12% 12%, rgba(14, 165, 233, 0.05), transparent 70%)',
      accentRight: dark
        ? 'radial-gradient(circle 550px at 88% 18%, rgba(99, 102, 241, 0.12), transparent 70%)'
        : 'radial-gradient(circle 550px at 88% 18%, rgba(99, 102, 241, 0.05), transparent 70%)',
      horizonBeam: dark ? 'from-transparent via-[#15E7CA]/50 to-transparent' : 'from-transparent via-[#003399]/30 to-transparent',
    };
  };

  const styles = getGlowStyles();

  return (
    <div
      className={`absolute inset-0 w-full h-full pointer-events-none overflow-hidden select-none z-0 ${className}`}
      aria-hidden="true"
    >
      {/* Layer 1: Top Horizon Lighting Beam */}
      <div
        className={`absolute top-0 left-0 right-0 h-[1px] w-full bg-gradient-to-r ${styles.horizonBeam}`}
      />

      {/* Layer 2: Main Top-Anchored Radial Spotlight (Smooth, seamless falloff) */}
      <div
        className="absolute inset-0 w-full h-full transition-opacity duration-700"
        style={{
          background: styles.primary,
        }}
      />

      {/* Layer 3: Left Ambient Color Swell */}
      <div
        className="absolute inset-0 w-full h-full transition-opacity duration-700"
        style={{
          background: styles.accentLeft,
        }}
      />

      {/* Layer 4: Right Ambient Color Swell */}
      <div
        className="absolute inset-0 w-full h-full transition-opacity duration-700"
        style={{
          background: styles.accentRight,
        }}
      />

      {/* Custom Accent Tint if provided */}
      {accentColor && (
        <div
          className="absolute inset-0 w-full h-full opacity-15"
          style={{
            background: `radial-gradient(circle 400px at 50% 10%, ${accentColor}, transparent 70%)`,
          }}
        />
      )}

      {/* Layer 5: Architectural Precision Dot Grid with Organic Radial Fade (Magic UI Style) */}
      <svg
        className="absolute inset-0 w-full h-full"
        style={{
          maskImage: 'radial-gradient(ellipse 70% 55% at 50% 25%, black 20%, transparent 80%)',
          WebkitMaskImage: 'radial-gradient(ellipse 70% 55% at 50% 25%, black 20%, transparent 80%)',
        }}
      >
        <defs>
          <pattern
            id={patternId}
            width="32"
            height="32"
            patternUnits="userSpaceOnUse"
            patternContentUnits="userSpaceOnUse"
          >
            <circle
              cx="1"
              cy="1"
              r="1"
              fill={dark ? 'rgba(255, 255, 255, 0.12)' : 'rgba(0, 51, 153, 0.1)'}
            />
          </pattern>
        </defs>
        <rect width="100%" height="100%" strokeWidth="0" fill={`url(#${patternId})`} />
      </svg>
    </div>
  );
}
