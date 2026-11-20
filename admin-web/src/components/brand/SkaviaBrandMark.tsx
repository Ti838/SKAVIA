import Image from 'next/image';

interface SkaviaBrandMarkProps {
  variant?: 'emblem' | 'full';
  size?: number;
  className?: string;
  priority?: boolean;
}

/**
 * Renders the official SKAVIA logo asset copied from assets/images/.
 * Preserves exact geometric aspect ratios (Emblem 480x633, Full 480x653)
 * to guarantee zero distortion, zero blur, and sub-pixel clarity across all devices.
 * Uses next/image so all routes pass @next/next/no-img-element strictly.
 */
export function SkaviaBrandMark({
  variant = 'emblem',
  size = 36,
  className = '',
  priority = false,
}: SkaviaBrandMarkProps) {
  if (variant === 'full') {
    // Exact ratio: 480 / 653 = 0.7350689
    const width = Math.max(1, Math.round(size * (480 / 653)));
    return (
      <Image
        src="/images/skavia_logo.png"
        alt="SKAVIA Official Logo"
        width={width}
        height={size}
        priority={priority}
        style={{ width: 'auto', height: size }}
        className={`object-contain select-none ${className}`.trim()}
      />
    );
  }

  // Exact ratio: 480 / 633 = 0.7582938
  const width = Math.max(1, Math.round(size * (480 / 633)));
  return (
    <Image
      src="/images/skavia_emblem.png"
      alt="SKAVIA Official Emblem"
      width={width}
      height={size}
      priority={priority}
      style={{ width: 'auto', height: size }}
      className={`object-contain select-none ${className}`.trim()}
    />
  );
}


