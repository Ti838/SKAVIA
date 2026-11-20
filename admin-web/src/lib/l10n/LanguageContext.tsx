'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { translations, type LanguageCode, type TranslationDictionary } from './translations';

interface LanguageContextValue {
  language: LanguageCode;
  setLanguage: (lang: LanguageCode) => void;
  toggleLanguage: () => void;
  t: TranslationDictionary;
  isBengali: boolean;
}

const LanguageContext = createContext<LanguageContextValue | null>(null);

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguageState] = useState<LanguageCode>('en');

  useEffect(() => {
    try {
      const saved = localStorage.getItem('skavia-lang') as LanguageCode | null;
      if (saved === 'en' || saved === 'bn') {
        setLanguageState(saved);
        document.documentElement.lang = saved;
        document.documentElement.setAttribute('data-lang', saved);
      }
    } catch {}
  }, []);

  const setLanguage = (lang: LanguageCode) => {
    setLanguageState(lang);
    try {
      localStorage.setItem('skavia-lang', lang);
      document.documentElement.lang = lang;
      document.documentElement.setAttribute('data-lang', lang);
      document.cookie = `skavia-lang=${lang}; path=/; max-age=31536000; SameSite=Lax`;
    } catch {}
  };

  const toggleLanguage = () => {
    setLanguage(language === 'en' ? 'bn' : 'en');
  };

  const value: LanguageContextValue = {
    language,
    setLanguage,
    toggleLanguage,
    t: translations[language],
    isBengali: language === 'bn',
  };

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useTranslation(): LanguageContextValue {
  const ctx = useContext(LanguageContext);
  if (!ctx) {
    // Zero-crash fallback when rendered outside provider in tests
    return {
      language: 'en',
      setLanguage: () => {},
      toggleLanguage: () => {},
      t: translations.en,
      isBengali: false,
    };
  }
  return ctx;
}
