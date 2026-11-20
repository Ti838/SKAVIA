import { describe, expect, it } from 'vitest';
import { formatBdtLocale, toBengaliDigits } from '@/lib/formatters';
import { translations, type TranslationDictionary } from '@/lib/l10n/translations';

describe('SKAVIA Phase 7 & 8 — 7-Role Portals & Bilingual Formatters', () => {
  it('converts Latin numerals to Bengali digits flawlessly', () => {
    expect(toBengaliDigits(0)).toBe('০');
    expect(toBengaliDigits(1234567890)).toBe('১২৩৪৫৬৭৮৯০');
    expect(toBengaliDigits('OTP: 8421')).toBe('OTP: ৮৪২১');
    expect(toBengaliDigits('')).toBe('');
    expect(toBengaliDigits(null)).toBe('');
  });

  it('formats BDT currency accurately in English and Bengali', () => {
    const amount = 2500.5;
    const enFormatted = formatBdtLocale(amount, 'en');
    const bnFormatted = formatBdtLocale(amount, 'bn');

    expect(enFormatted).toContain('2,500.50');
    expect(bnFormatted).toContain('৳');
    expect(bnFormatted).toContain('২,৫০০.৫০');
  });

  it('maintains 100% key parity between English and Bangla dictionaries', () => {
    const enKeys = Object.keys(translations.en).sort();
    const bnKeys = Object.keys(translations.bn).sort();

    expect(enKeys).toEqual(bnKeys);
    expect(enKeys.length).toBeGreaterThanOrEqual(45);

    // Verify all keys have non-empty values
    for (const key of enKeys) {
      const enVal = translations.en[key as keyof TranslationDictionary];
      const bnVal = translations.bn[key as keyof TranslationDictionary];
      expect(enVal.trim().length).toBeGreaterThan(0);
      expect(bnVal.trim().length).toBeGreaterThan(0);
    }
  });

  it('provides dedicated translations for all 7 platform roles and portals', () => {
    const { en, bn } = translations;

    // 7 Roles
    expect(en.roleIndividualCustomer).toBe('Individual Customer');
    expect(bn.roleIndividualCustomer).toBe('ব্যক্তিগত গ্রাহক');

    expect(en.roleBusinessClient).toBe('Business & Organization');
    expect(bn.roleBusinessClient).toBe('ব্যবসায়িক ও প্রাতিষ্ঠানিক ক্লায়েন্ট');

    expect(en.roleWorker).toBe('Skilled Specialist (Worker)');
    expect(bn.roleWorker).toBe('দক্ষ কর্মী (স্পেশালিস্ট)');

    expect(en.roleAdminPortal).toBe('Enterprise Admin Portal');
    expect(bn.roleAdminPortal).toBe('এডমিন গভর্ন্যান্স পোর্টাল');

    // 3 Dedicated Role Portals
    expect(en.navWorkerConsole).toBe('Worker Console');
    expect(bn.navWorkerConsole).toBe('ওয়ার্কার কনসোল');

    expect(en.navCustomerPortal).toBe('Customer Portal');
    expect(bn.navCustomerPortal).toBe('কাস্টমার পোর্টাল');

    expect(en.navBusinessPortal).toBe('Business & Projects');
    expect(bn.navBusinessPortal).toBe('বিজনেস ও প্রজেক্ট');
  });

  it('provides complete translations for the 4-digit arrival handshake OTP workflow', () => {
    const { en, bn } = translations;

    expect(en.handshakeOtp).toContain('4-Digit');
    expect(bn.handshakeOtp).toContain('৪-ডিজিটের');

    expect(en.shareOtpWithWorker.length).toBeGreaterThan(15);
    expect(bn.shareOtpWithWorker.length).toBeGreaterThan(15);

    expect(en.verifyOtpAction).toContain('OTP');
    expect(bn.verifyOtpAction).toContain('ওটিপি');
  });
});
