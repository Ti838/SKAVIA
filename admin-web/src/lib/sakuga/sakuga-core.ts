/**
 * SKAVIA Sakuga VFX Web Core Engine
 * Adapted directly from Sakuga VFX (https://github.com/finktheartist/sakuga-vfx)
 *
 * MIT License
 * Copyright (c) 2026 Justin Finkelman
 *
 * Brand-tuned for SKAVIA (Royal Blue / Sky Blue / Violet / Aqua / Emerald)
 * with reduced-motion enforcement, zero idle CPU usage, and SSR safety.
 */

export type SakugaIntensity = 'subtle' | 'medium' | 'strong';

interface SakugaPalette {
  fill: string;
  shade: string;
  line: string;
  accent: string;
  success: string;
}

interface EffectParticle {
  t: number;
  life: number;
  dead?: boolean;
  draw: (
    ctx: CanvasRenderingContext2D,
    k: number,
    t: number,
    dt: number,
  ) => void;
}

const TAU = Math.PI * 2;
const clamp = (v: number, a = 0, b = 1) => Math.min(b, Math.max(a, v));
const rnd = (a = 1, b?: number) =>
  b === undefined ? Math.random() * a : a + Math.random() * (b - a);
const outCubic = (t: number) => 1 - (1 - t) ** 3;
const inCubic = (t: number) => t * t * t;

/** Sub-stepped damped harmonic spring matching Sakuga VFX core.js */
export class SakugaSpring {
  x: number;
  v = 0;
  to: number;
  k: number;
  d: number;

  constructor(x = 0, k = 380, d = 22) {
    this.x = x;
    this.to = x;
    this.k = k;
    this.d = d;
  }

  step(dt: number): number {
    if (!(dt > 0)) return this.x;
    const steps = Math.max(1, Math.ceil(dt / 0.008));
    const h = dt / steps;
    for (let i = 0; i < steps; i++) {
      this.v += (-this.k * (this.x - this.to) - this.d * this.v) * h;
      this.x += this.v * h;
    }
    return this.x;
  }

  isSettled(eps = 0.001): boolean {
    return Math.abs(this.x - this.to) < eps && Math.abs(this.v) < 0.01;
  }
}

let canvasEl: HTMLCanvasElement | null = null;
let ctx2d: CanvasRenderingContext2D | null = null;
let dpr = 1;
let liveParticles: EffectParticle[] = [];
let dirty = false;
let running = false;
let lastFrameMs = 0;
const frameListeners = new Set<(dt: number) => void>();

export function isReducedMotion(): boolean {
  if (typeof window === 'undefined' || !window.matchMedia) return false;
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

function getPalette(): SakugaPalette {
  const isDark =
    typeof document !== 'undefined' &&
    (document.documentElement.classList.contains('dark') ||
      document.documentElement.getAttribute('data-theme') === 'dark');

  if (isDark) {
    return {
      fill: '#EFF6FF',
      shade: '#60A5FA',
      line: '#3898EC',
      accent: '#15E7CA',
      success: '#22C55E',
    };
  }
  return {
    fill: '#FFFFFF',
    shade: '#BFDBFE',
    line: '#003399',
    accent: '#3898EC',
    success: '#16A34A',
  };
}

function resizeCanvas() {
  if (!canvasEl || typeof window === 'undefined') return;
  dpr = Math.min(2.5, window.devicePixelRatio || 1);
  canvasEl.width = Math.round(window.innerWidth * dpr);
  canvasEl.height = Math.round(window.innerHeight * dpr);
}

function ensureCanvas() {
  if (canvasEl || typeof document === 'undefined' || !document.body) return;
  canvasEl = document.createElement('canvas');
  canvasEl.className = 'sakuga-fx';
  canvasEl.setAttribute('aria-hidden', 'true');
  Object.assign(canvasEl.style, {
    position: 'fixed',
    inset: '0',
    width: '100vw',
    height: '100vh',
    pointerEvents: 'none',
    zIndex: '2147483000',
  });
  document.body.appendChild(canvasEl);
  ctx2d = canvasEl.getContext('2d');
  resizeCanvas();
  window.addEventListener('resize', resizeCanvas, { passive: true });
}

function loop(ms: number) {
  if (!running) return;
  const dt = clamp((ms - lastFrameMs) / 1000, 0, 0.034);
  lastFrameMs = ms;

  for (const fn of frameListeners) fn(dt);

  if (canvasEl && ctx2d && (liveParticles.length > 0 || dirty)) {
    const g = ctx2d;
    g.setTransform(dpr, 0, 0, dpr, 0, 0);
    g.clearRect(0, 0, canvasEl.width / dpr, canvasEl.height / dpr);
    g.translate(-window.scrollX, -window.scrollY);
    g.lineJoin = 'round';
    g.lineCap = 'round';

    liveParticles = liveParticles.filter((p) => !p.dead && (p.t += dt) < p.life);
    for (const p of liveParticles) {
      g.save();
      p.draw(g, p.t / p.life, p.t, dt);
      g.restore();
    }
    dirty = liveParticles.length > 0;
  }

  if (frameListeners.size === 0 && liveParticles.length === 0 && !dirty) {
    running = false;
    return;
  }
  requestAnimationFrame(loop);
}

function startLoop() {
  if (running || typeof window === 'undefined') return;
  running = true;
  lastFrameMs = performance.now();
  requestAnimationFrame(loop);
}

function addParticle(
  life: number,
  draw: EffectParticle['draw'],
): EffectParticle | null {
  if (typeof window === 'undefined' || isReducedMotion()) return null;
  ensureCanvas();
  const p: EffectParticle = { t: 0, life, draw };
  liveParticles.push(p);
  startLoop();
  return p;
}

export function elementCenter(el: HTMLElement, fx = 0.5, fy = 0.5) {
  const r = el.getBoundingClientRect();
  return {
    x: r.left + window.scrollX + r.width * fx,
    y: r.top + window.scrollY + r.height * fy,
    w: r.width,
    h: r.height,
  };
}

/** SUBTLE/MEDIUM: Fanning kinetic accent wedges (adapted from Sakuga core `ticks`) */
export function sakugaTicks(
  x: number,
  y: number,
  opts: {
    n?: number;
    r?: number;
    len?: number;
    dir?: number;
    fan?: number;
    life?: number;
    color?: string;
  } = {},
) {
  const {
    n = 3,
    r = 12,
    len = 10,
    dir = -Math.PI / 2,
    fan = 0.52,
    life = 0.34,
    color,
  } = opts;
  const P = getPalette();
  const col = color ?? P.accent;

  addParticle(life, (g, k) => {
    const a = outCubic(clamp(k / 0.5));
    const b = inCubic(clamp((k - 0.4) / 0.6));
    g.fillStyle = col;
    g.globalAlpha = clamp(1 - b * 0.85);
    g.beginPath();
    for (let i = 0; i < n; i++) {
      const an = dir + (i - (n - 1) / 2) * fan;
      const r0 = r + len * b * 1.25;
      const r1 = r + len * a * 1.25;
      if (r1 - r0 < 0.7) continue;
      const hw = 0.065 + 1.8 / (r1 + 8);
      g.moveTo(x + Math.cos(an) * r0, y + Math.sin(an) * r0);
      g.lineTo(x + Math.cos(an - hw) * r1, y + Math.sin(an - hw) * r1);
      g.lineTo(x + Math.cos(an + hw) * r1, y + Math.sin(an + hw) * r1);
      g.closePath();
    }
    g.fill();
  });
}

/** SUBTLE/MEDIUM: Crisp expanding settle ring */
export function sakugaRing(
  x: number,
  y: number,
  opts: { r?: number; life?: number; w?: number; color?: string } = {},
) {
  const { r = 24, life = 0.36, w = 2.6, color } = opts;
  const P = getPalette();
  const col = color ?? P.line;

  addParticle(life, (g, k) => {
    const s = outCubic(k);
    const lw = w * (1 - k);
    if (lw < 0.25) return;
    g.beginPath();
    g.arc(x, y, r * (0.35 + s * 0.85), 0, TAU);
    g.strokeStyle = col;
    g.globalAlpha = clamp((1 - k) * 0.85);
    g.lineWidth = lw + 1.2;
    g.stroke();
  });
}

/** MEDIUM: 4-pointed sparkle glint (ratings, verified badges, completed steps) */
export function sakugaKira(
  x: number,
  y: number,
  opts: { r?: number; life?: number; color?: string } = {},
) {
  const { r = 10, life = 0.44, color } = opts;
  const P = getPalette();
  const col = color ?? P.accent;

  addParticle(life, (g, k, t) => {
    const s = r * Math.sin(k * Math.PI) ** 0.6;
    if (s < 0.6) return;
    const q = s * 0.18;
    g.translate(x, y);
    g.rotate(Math.sin(t * 6) * 0.16);
    const p = new Path2D();
    p.moveTo(0, -s);
    p.quadraticCurveTo(q, -q, s * 0.72, 0);
    p.quadraticCurveTo(q, q, 0, s);
    p.quadraticCurveTo(-q, q, -s * 0.72, 0);
    p.quadraticCurveTo(-q, -q, 0, -s);
    p.closePath();
    g.fillStyle = P.fill;
    g.fill(p);
    g.strokeStyle = col;
    g.lineWidth = 1.6;
    g.stroke(p);
  });
}

/** STRONG BUT SHORT: Verified action completion burst + crisp shards (no anime lettering) */
export function sakugaCelebrate(
  x: number,
  y: number,
  opts: { r?: number; color?: string; life?: number } = {},
) {
  const { r = 46, color, life = 0.5 } = opts;
  const P = getPalette();
  const accent = color ?? P.success;

  const spikes = Array.from({ length: 22 }, (_, i) =>
    i % 2 ? rnd(0.38, 0.5) : rnd(0.8, 1.08),
  );
  const rot = rnd(TAU);

  addParticle(life * 0.72, (g, k) => {
    const R = r * outCubic(clamp(k / 0.34));
    const fade = 1 - inCubic(clamp((k - 0.38) / 0.62));
    const hollow = 1 + inCubic(clamp((k - 0.35) / 0.65)) * 0.85;
    const p = new Path2D();
    spikes.forEach((m, i) => {
      const a = rot + (i / spikes.length) * TAU;
      const rr = R * (i % 2 ? m * hollow : m);
      if (i === 0) p.moveTo(x + Math.cos(a) * rr, y + Math.sin(a) * rr);
      else p.lineTo(x + Math.cos(a) * rr, y + Math.sin(a) * rr);
    });
    p.closePath();
    g.globalAlpha = fade * 0.45;
    g.fillStyle = P.shade;
    g.fill(p);
    g.globalAlpha = fade * 0.85;
    g.strokeStyle = accent;
    g.lineWidth = 1.4;
    g.stroke(p);
  });

  sakugaRing(x, y, { r: r * 1.15, life, w: 3, color: accent });

  for (let i = 0; i < 7; i++) {
    const a = (i / 7) * TAU + rnd(-0.3, 0.3);
    const v = rnd(85, 165);
    const s = rnd(3.2, 5.8);
    const spin = rnd(-7, 7);
    addParticle(life * rnd(0.75, 1), (g, k, t) => {
      const sc = s * (1 - inCubic(clamp((k - 0.55) / 0.45)));
      if (sc < 0.7) return;
      const px = x + Math.cos(a) * v * t;
      const py = y + Math.sin(a) * v * t + 210 * t * t;
      g.translate(px, py);
      g.rotate(spin * t + a);
      const p = new Path2D();
      p.moveTo(-sc * 1.3, 0);
      p.lineTo(0, -sc * 0.65);
      p.lineTo(sc * 1.3, 0);
      p.lineTo(0, sc * 0.65);
      p.closePath();
      g.fillStyle = P.fill;
      g.fill(p);
      g.strokeStyle = accent;
      g.lineWidth = 1.1;
      g.stroke(p);
    });
  }
}

/**
 * Attaches volume-preserving Sakuga spring squash-and-stretch to a DOM element.
 * Returns a cleanup disposer. Respects `prefers-reduced-motion` and idles at 0% CPU.
 */
export function attachSakugaSquash(
  el: HTMLElement,
  opts: { low?: number; wide?: number; k?: number; d?: number } = {},
) {
  const { low = 0.91, wide = 0.22, k = 520, d = 22 } = opts;
  const s = new SakugaSpring(1, k, d);
  let active = false;

  const stepFn = (dt: number) => {
    const y = s.step(dt);
    if (s.isSettled(0.0015) && s.to === 1) {
      el.style.transform = '';
      frameListeners.delete(stepFn);
      active = false;
      return;
    }
    const sx = 1 + (1 - y) * wide;
    el.style.transform = `scale(${sx.toFixed(4)}, ${y.toFixed(4)})`;
  };

  const wake = () => {
    if (isReducedMotion()) return;
    if (!active) {
      active = true;
      frameListeners.add(stepFn);
      startLoop();
    }
  };

  const onDown = () => {
    if ((el as HTMLButtonElement).disabled || isReducedMotion()) return;
    s.to = low;
    wake();
  };

  const onUp = () => {
    if (isReducedMotion()) return;
    s.to = 1;
    s.v += 2.2;
    wake();
  };

  const onLeave = () => {
    if (s.to !== 1) {
      s.to = 1;
      wake();
    }
  };

  el.addEventListener('pointerdown', onDown, { passive: true });
  el.addEventListener('pointerup', onUp, { passive: true });
  el.addEventListener('pointercancel', onLeave, { passive: true });
  el.addEventListener('pointerleave', onLeave, { passive: true });

  return () => {
    frameListeners.delete(stepFn);
    el.style.transform = '';
    el.removeEventListener('pointerdown', onDown);
    el.removeEventListener('pointerup', onUp);
    el.removeEventListener('pointercancel', onLeave);
    el.removeEventListener('pointerleave', onLeave);
  };
}
