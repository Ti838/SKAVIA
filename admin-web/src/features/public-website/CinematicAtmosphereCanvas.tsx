'use client';

import { useEffect, useRef } from 'react';

interface Particle {
  x: number;
  y: number;
  radius: number;
  vx: number;
  vy: number;
  alpha: number;
  maxAlpha: number;
  pulseSpeed: number;
  color: string;
}

export function CinematicAtmosphereCanvas({ dark }: { dark: boolean }) {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    // Respect user's motion preferences
    const prefersReducedMotion = window.matchMedia?.('(prefers-reduced-motion: reduce)')?.matches;
    if (prefersReducedMotion) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animationFrameId: number;
    let isVisible = true;

    const resize = () => {
      if (!canvas) return;
      canvas.width = canvas.parentElement?.clientWidth || window.innerWidth;
      canvas.height = canvas.parentElement?.clientHeight || window.innerHeight;
    };

    resize();
    window.addEventListener('resize', resize, { passive: true });

    // IntersectionObserver to pause loop when not on screen
    const observer = new IntersectionObserver(
      (entries) => {
        const [entry] = entries;
        isVisible = Boolean(entry?.isIntersecting);
      },
      { threshold: 0.1 }
    );
    observer.observe(canvas);

    // Particle Palette
    const palette = dark
      ? ['#003399', '#3898EC', '#15E7CA', '#60A5FA']
      : ['#003399', '#3898EC', '#0D9488', '#93C5FD'];

    const particleCount = Math.min(32, Math.floor((canvas.width * canvas.height) / 28000));
    const particles: Particle[] = Array.from({ length: particleCount }, () => ({
      x: Math.random() * canvas.width,
      y: Math.random() * canvas.height,
      radius: Math.random() * 2.2 + 0.8,
      vx: (Math.random() - 0.5) * 0.35,
      vy: (Math.random() - 0.5) * 0.35 - 0.1, // subtle upward drift
      alpha: Math.random() * 0.4 + 0.1,
      maxAlpha: dark ? Math.random() * 0.35 + 0.15 : Math.random() * 0.18 + 0.08,
      pulseSpeed: Math.random() * 0.015 + 0.005,
      color: palette[Math.floor(Math.random() * palette.length)] ?? '#3898EC',
    }));

    let pulse = 0;

    const render = () => {
      if (!isVisible) {
        animationFrameId = requestAnimationFrame(render);
        return;
      }

      ctx.clearRect(0, 0, canvas.width, canvas.height);
      pulse += 0.01;

      // Soft ambient light orb
      const gradient = ctx.createRadialGradient(
        canvas.width * 0.5,
        canvas.height * 0.35,
        20,
        canvas.width * 0.5,
        canvas.height * 0.35,
        canvas.width * 0.6
      );
      if (dark) {
        gradient.addColorStop(0, 'rgba(0, 51, 153, 0.14)');
        gradient.addColorStop(0.5, 'rgba(21, 231, 202, 0.04)');
        gradient.addColorStop(1, 'transparent');
      } else {
        gradient.addColorStop(0, 'rgba(0, 51, 153, 0.04)');
        gradient.addColorStop(0.5, 'rgba(56, 152, 236, 0.02)');
        gradient.addColorStop(1, 'transparent');
      }
      ctx.fillStyle = gradient;
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      // Render floating cinematic dust particles
      for (const p of particles) {
        p.x += p.vx;
        p.y += p.vy;

        // Wrap around bounds
        if (p.x < 0) p.x = canvas.width;
        if (p.x > canvas.width) p.x = 0;
        if (p.y < 0) p.y = canvas.height;
        if (p.y > canvas.height) p.y = 0;

        const currentAlpha = p.maxAlpha * (0.6 + 0.4 * Math.sin(pulse * p.pulseSpeed * 100));

        ctx.save();
        ctx.globalAlpha = currentAlpha;
        ctx.fillStyle = p.color;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
      }

      animationFrameId = requestAnimationFrame(render);
    };

    render();

    return () => {
      cancelAnimationFrame(animationFrameId);
      observer.disconnect();
      window.removeEventListener('resize', resize);
    };
  }, [dark]);

  return (
    <canvas
      ref={canvasRef}
      className="absolute inset-0 w-full h-full pointer-events-none z-0"
      aria-hidden="true"
    />
  );
}
