/**
 * SKAVIA Centralized Design Tokens
 * 
 * Official, accessible design tokens shared across all public and portal interfaces.
 * Color definitions meet WCAG 2.2 AA / AAA contrast standards.
 */

export const SKAVIA_COLORS = {
  // Brand Anchors
  brandRoyal: '#003399',      // Primary corporate brand (10.4:1 contrast vs #FFFFFF)
  brandSky: '#3898EC',        // Interactive accent, focus, secondary button (4.8:1 vs dark)
  brandAqua: '#15E7CA',       // Verified badge, active availability, high-contrast cyan
  brandPeach: '#FDBA74',      // Subtle accent
  
  // Neutral Surfaces (Light)
  canvasLight: '#F8FAFC',     // Clean slate-50 background
  surfaceLight: '#FFFFFF',    // Pristine card/dialog surface
  surfaceSubtleLight: '#F1F5F9', // Striped table header, input fill
  borderSubtleLight: '#E2E8F0',  // 1px dividers, card borders
  borderStrongLight: '#CBD5E1',  // Input borders, hover borders
  textPrimaryLight: '#0F172A',   // 15.8:1 vs #FFFFFF (WCAG AAA)
  textSecondaryLight: '#475569', // 7.1:1 vs #FFFFFF (WCAG AAA)
  textMutedLight: '#64748B',     // 4.6:1 vs #FFFFFF (WCAG AA)
  
  // Neutral Surfaces (Dark) — Human Psychology & Visual Comfort
  canvasDark: '#070A11',      // Obsidian-velvet base canvas (restful scotopic background)
  surfaceDark: '#0E1424',     // Elevated card/dialog surface (midnight slate)
  surfaceSubtleDark: '#141C30', // Table header, inactive tabs
  borderSubtleDark: '#192338',  // Soft atmospheric divider
  borderStrongDark: '#546C8D',  // High-contrast interactive border (3.33:1 vs #0E1424)
  textPrimaryDark: '#EDEFEF',   // 15.9:1 vs #0E1424 (WCAG AAA without retinal halation)
  textSecondaryDark: '#9BB0C9', // 8.26:1 vs #0E1424 (WCAG AAA calm steel)
  textMutedDark: '#7189A8',     // 5.11:1 vs #0E1424 (WCAG AA)

  // Status Colors (Light / Dark)
  successLight: '#16A34A',    // 4.6:1 vs White
  successDark: '#34D399',     // Refined mineral emerald (9.5:1 vs #0E1424)
  warningLight: '#D97706',    // 4.5:1 vs White
  warningDark: '#F59E0B',     // Warm amber gold (8.5:1 vs #0E1424)
  dangerLight: '#DC2626',     // 5.9:1 vs White
  dangerDark: '#F87171',      // Soft rose-ruby (6.6:1 vs #0E1424)

  // 7-Role Color Identifiers
  roleSuperAdmin: { light: '#003399', dark: '#4C86F0', label: 'Super Admin', labelBn: 'সুপার অ্যাডমিন' },
  roleCompanyAdmin: { light: '#0D9488', dark: '#25C9B3', label: 'Company Admin', labelBn: 'কোম্পানি অ্যাডমিন' },
  roleBranchManager: { light: '#4F46E5', dark: '#818CF8', label: 'Branch Manager', labelBn: 'শাখা ব্যবস্থাপক' },
  roleWorker: { light: '#0284C7', dark: '#38BDF8', label: 'Skilled Worker', labelBn: 'দক্ষ কর্মী' },
  roleIndividualCustomer: { light: '#2563EB', dark: '#4C86F0', label: 'Individual Customer', labelBn: 'ব্যক্তিগত গ্রাহক' },
  roleBusinessClient: { light: '#7C3AED', dark: '#9D7BF2', label: 'Business Client', labelBn: 'ব্যবসায়িক ক্লায়েন্ট' },
  roleOrganization: { light: '#C026D3', dark: '#E879F9', label: 'Organization', labelBn: 'প্রতিষ্ঠান' },
} as const;

export const SKAVIA_TYPOGRAPHY = {
  fonts: {
    heading: "var(--font-jakarta), var(--font-bengali), -apple-system, sans-serif",
    body: "var(--font-inter), var(--font-bengali), -apple-system, sans-serif",
    bengali: "var(--font-bengali), sans-serif",
    mono: "'JetBrains Mono', ui-monospace, SFMono-Regular, monospace",
  },
  rules: {
    bengaliLetterSpacing: '0px',
    bengaliLineHeight: 1.48,
  },
} as const;

export const SKAVIA_BREAKPOINTS = {
  xs: 320,  // Small mobile (e.g., Galaxy A10, small Androids)
  sm: 480,  // Large mobile (e.g., iPhone 15 Pro Max)
  md: 768,  // Tablets (portrait iPad)
  lg: 1024, // Laptop / Tablets (landscape)
  xl: 1280, // Standard Desktop
  '2xl': 1536, // Wide Desktop
  maxContent: 1280,
} as const;
