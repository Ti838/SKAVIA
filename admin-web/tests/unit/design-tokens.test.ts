import { describe, expect, it } from 'vitest';
import { SKAVIA_BREAKPOINTS, SKAVIA_COLORS, SKAVIA_TYPOGRAPHY } from '@/lib/design-tokens';

function hexToRgb(hex: string): [number, number, number] {
  const clean = hex.replace('#', '');
  const bigint = parseInt(clean, 16);
  return [(bigint >> 16) & 255, (bigint >> 8) & 255, bigint & 255];
}

function relativeLuminance(rgb: [number, number, number]): number {
  const [r = 0, g = 0, b = 0] = rgb.map((val) => {
    const s = val / 255;
    return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function contrastRatio(hex1: string, hex2: string): number {
  const l1 = relativeLuminance(hexToRgb(hex1));
  const l2 = relativeLuminance(hexToRgb(hex2));
  const brightest = Math.max(l1, l2);
  const darkest = Math.min(l1, l2);
  return (brightest + 0.05) / (darkest + 0.05);
}

describe('SKAVIA Phase 4 — Design Tokens & Accessibility Contrast', () => {
  it('primary text meets WCAG AAA (>= 7:1) in both light and dark modes', () => {
    const lightRatio = contrastRatio(SKAVIA_COLORS.textPrimaryLight, SKAVIA_COLORS.surfaceLight);
    const darkRatio = contrastRatio(SKAVIA_COLORS.textPrimaryDark, SKAVIA_COLORS.surfaceDark);

    expect(lightRatio).toBeGreaterThanOrEqual(7.0);
    expect(darkRatio).toBeGreaterThanOrEqual(7.0);
  });

  it('secondary text meets WCAG AAA (>= 7:1) in light mode and dark mode', () => {
    const lightRatio = contrastRatio(SKAVIA_COLORS.textSecondaryLight, SKAVIA_COLORS.surfaceLight);
    const darkRatio = contrastRatio(SKAVIA_COLORS.textSecondaryDark, SKAVIA_COLORS.surfaceDark);

    expect(lightRatio).toBeGreaterThanOrEqual(7.0);
    expect(darkRatio).toBeGreaterThanOrEqual(7.0);
  });

  it('muted text meets WCAG AA (>= 4.5:1) for body legibility', () => {
    const lightRatio = contrastRatio(SKAVIA_COLORS.textMutedLight, SKAVIA_COLORS.surfaceLight);
    const darkRatio = contrastRatio(SKAVIA_COLORS.textMutedDark, SKAVIA_COLORS.surfaceDark);

    expect(lightRatio).toBeGreaterThanOrEqual(4.5);
    expect(darkRatio).toBeGreaterThanOrEqual(4.5);
  });

  it('royal cobalt brand anchor meets WCAG AAA against white surface', () => {
    const brandRatio = contrastRatio(SKAVIA_COLORS.brandRoyal, '#FFFFFF');
    expect(brandRatio).toBeGreaterThanOrEqual(7.0);
  });

  it('all seven roles have defined light/dark color tokens and localized labels', () => {
    const roles = [
      SKAVIA_COLORS.roleSuperAdmin,
      SKAVIA_COLORS.roleCompanyAdmin,
      SKAVIA_COLORS.roleBranchManager,
      SKAVIA_COLORS.roleWorker,
      SKAVIA_COLORS.roleIndividualCustomer,
      SKAVIA_COLORS.roleBusinessClient,
      SKAVIA_COLORS.roleOrganization,
    ];

    expect(roles).toHaveLength(7);
    for (const role of roles) {
      expect(role.light).toMatch(/^#[0-9A-Fa-f]{6}$/);
      expect(role.dark).toMatch(/^#[0-9A-Fa-f]{6}$/);
      expect(role.label.length).toBeGreaterThan(0);
      expect(role.labelBn.length).toBeGreaterThan(0);
    }
  });

  it('enforces zero letter-spacing for Bengali typography', () => {
    expect(SKAVIA_TYPOGRAPHY.rules.bengaliLetterSpacing).toBe('0px');
    expect(SKAVIA_TYPOGRAPHY.rules.bengaliLineHeight).toBeGreaterThanOrEqual(1.45);
  });

  it('declares responsive breakpoints covering 320px to 1536px+', () => {
    expect(SKAVIA_BREAKPOINTS.xs).toBe(320);
    expect(SKAVIA_BREAKPOINTS.sm).toBe(480);
    expect(SKAVIA_BREAKPOINTS.md).toBe(768);
    expect(SKAVIA_BREAKPOINTS.lg).toBe(1024);
    expect(SKAVIA_BREAKPOINTS.xl).toBe(1280);
  });
});
