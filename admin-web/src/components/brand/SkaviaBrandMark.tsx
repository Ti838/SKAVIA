import Image from 'next/image';

interface SkaviaBrandMarkProps {
  variant?: 'emblem' | 'full';
  size?: number;
  className?: string;
  priority?: boolean;
}

/**
 * Renders the official SKAVIA logo asset copied from assets/images/.
 * Uses next/image so all routes pass @next/next/no-img-element strictly.
 */
export function SkaviaBrandMark({
  variant = 'emblem',
  size = 36,
  className = '',
  priority = false,
}: SkaviaBrandMarkProps) {
  if (variant === 'full') {
    const width = Math.round(size * 0.72);
    return (
      <Image
        src="/images/skavia_logo.png"
        alt="SKAVIA Official Logo"
        width={width}
        height={size}
        priority={priority}
        className={`object-contain select-none ${className}`.trim()}
      />
    );
  }

  return (
    <Image
      src="/images/skavia_emblem.png"
      alt="SKAVIA Official Emblem"
      width={size}
      height={size}
      priority={priority}
      className={`object-contain select-none ${className}`.trim()}
    />
  );
}

