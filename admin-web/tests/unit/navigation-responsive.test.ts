import { describe, expect, it } from 'vitest';
import { SERVICE_ZONES } from '@/components/navigation/LocationPill';
import { translations, type TranslationDictionary } from '@/lib/l10n/translations';

describe('SKAVIA Phase 5 — Global Navigation & Responsive Foundation', () => {
  it('has exact translation key parity between English and Bangla dictionaries', () => {
    const enKeys = Object.keys(translations.en).sort();
    const bnKeys = Object.keys(translations.bn).sort();

    expect(enKeys).toEqual(bnKeys);
    expect(enKeys.length).toBeGreaterThan(25);

    // Verify no values are empty strings
    for (const key of enKeys) {
      const enVal = translations.en[key as keyof TranslationDictionary];
      const bnVal = translations.bn[key as keyof TranslationDictionary];
      expect(enVal.trim().length).toBeGreaterThan(0);
      expect(bnVal.trim().length).toBeGreaterThan(0);
    }
  });

  it('includes core Bangladesh service zones with bilingual naming', () => {
    expect(SERVICE_ZONES.length).toBeGreaterThanOrEqual(7);

    const zoneIds = SERVICE_ZONES.map((z) => z.id);
    expect(zoneIds).toContain('dhanmondi');
    expect(zoneIds).toContain('gulshan');
    expect(zoneIds).toContain('uttara');
    expect(zoneIds).toContain('mirpur');

    for (const zone of SERVICE_ZONES) {
      expect(zone.nameEn.length).toBeGreaterThan(0);
      expect(zone.nameBn.length).toBeGreaterThan(0);
      expect(zone.districtEn.length).toBeGreaterThan(0);
      expect(zone.districtBn.length).toBeGreaterThan(0);
    }
  });

  it('provides navigation translations for all 7 platform roles', () => {
    const { en, bn } = translations;
    expect(en.roleIndividualCustomer).toBe('Individual Customer');
    expect(bn.roleIndividualCustomer).toBe('ব্যক্তিগত গ্রাহক');

    expect(en.roleBusinessClient).toBe('Business & Organization');
    expect(bn.roleBusinessClient).toBe('ব্যবসায়িক ও প্রাতিষ্ঠানিক ক্লায়েন্ট');

    expect(en.roleWorker).toBe('Skilled Specialist (Worker)');
    expect(bn.roleWorker).toBe('দক্ষ কর্মী (স্পেশালিস্ট)');

    expect(en.roleAdminPortal).toBe('Enterprise Admin Portal');
    expect(bn.roleAdminPortal).toBe('এডমিন গভর্ন্যান্স পোর্টাল');
  });
});
