import { describe, expect, it } from 'vitest';
import { isReducedMotion, SakugaSpring } from '@/lib/sakuga/sakuga-core';

describe('SKAVIA Sakuga Web Core Physics', () => {
  it('overshoots and settles cleanly on target with sub-stepped spring integration', () => {
    const spring = new SakugaSpring(0, 520, 20);
    spring.to = 1;

    let maxVal = 0;
    for (let i = 0; i < 120; i++) {
      const val = spring.step(1 / 60);
      if (val > maxVal) maxVal = val;
    }

    expect(maxVal).toBeGreaterThan(1.02);
    expect(Math.abs(spring.x - 1)).toBeLessThan(0.01);
    expect(spring.isSettled(0.01)).toBe(true);
  });

  it('remains stable under large frame delta spikes via 8ms sub-stepping', () => {
    const spring = new SakugaSpring(1, 520, 22);
    spring.to = 0.85;
    const next = spring.step(0.034);
    expect(Number.isFinite(next)).toBe(true);
    expect(next).toBeLessThan(1);
    expect(next).toBeGreaterThan(0.5);
  });

  it('safely evaluates reduced motion in SSR / Node environments', () => {
    expect(typeof isReducedMotion()).toBe('boolean');
  });
});
