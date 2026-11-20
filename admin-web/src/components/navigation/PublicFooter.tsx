'use client';

import Link from 'next/link';
import { BadgeCheck, KeyRound, ShieldCheck, Smartphone } from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import { useTranslation } from '@/lib/l10n/LanguageContext';

export function PublicFooter() {
  const { t, isBengali } = useTranslation();

  const branches = [
    { code: 'HOME', nameEn: 'SKAVIA Home', nameBn: 'স্ক্যাভিয়া হোম', href: '#branches' },
    { code: 'AGRI', nameEn: 'SKAVIA Agriculture', nameBn: 'স্ক্যাভিয়া এগ্রিকালচার', href: '#branches' },
    { code: 'TECH', nameEn: 'SKAVIA Technical', nameBn: 'স্ক্যাভিয়া টেকনিক্যাল', href: '#branches' },
    { code: 'LOGI', nameEn: 'SKAVIA Logistics', nameBn: 'স্ক্যাভিয়া লজিস্টিকস', href: '#branches' },
    { code: 'DIGI', nameEn: 'SKAVIA Digital', nameBn: 'স্ক্যাভিয়া ডিজিটাল', href: '#branches' },
    { code: 'BIZ', nameEn: 'SKAVIA Business', nameBn: 'স্ক্যাভিয়া বিজনেস', href: '#branches' },
    { code: 'CONS', nameEn: 'SKAVIA Construction', nameBn: 'স্ক্যাভিয়া কনস্ট্রাকশন', href: '#branches' },
    { code: 'EVNT', nameEn: 'SKAVIA Events', nameBn: 'স্ক্যাভিয়া ইভেন্টস', href: '#branches' },
  ];

  return (
    <footer
      className="border-t py-14 px-4 sm:px-6 lg:px-8 transition-colors"
      style={{
        backgroundColor: 'var(--bg-surface)',
        borderColor: 'var(--border-subtle)',
        color: 'var(--text-secondary)',
      }}
    >
      <div className="max-w-7xl mx-auto space-y-12">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8">
          {/* Brand Column */}
          <div className="lg:col-span-2 space-y-3.5">
            <div className="flex items-center gap-2.5">
              <SkaviaBrandMark variant="emblem" size={32} />
              <span className="font-heading font-extrabold text-base tracking-tight" style={{ color: 'var(--text-primary)' }}>
                {t.brandName}
              </span>
            </div>
            <p className="text-xs leading-relaxed max-w-sm" style={{ color: 'var(--text-secondary)' }}>
              {t.footerDesc}
            </p>
            <div className="pt-2 flex flex-wrap gap-2 text-[11px] font-mono-code text-slate-500">
              <span className="inline-flex items-center gap-1 rounded-md border px-2 py-0.5" style={{ borderColor: 'var(--border-subtle)' }}>
                <ShieldCheck className="h-3 w-3 text-teal-600" /> NID Verified
              </span>
              <span className="inline-flex items-center gap-1 rounded-md border px-2 py-0.5" style={{ borderColor: 'var(--border-subtle)' }}>
                <KeyRound className="h-3 w-3 text-blue-600" /> 4-Digit Handshake OTP
              </span>
              <span className="inline-flex items-center gap-1 rounded-md border px-2 py-0.5" style={{ borderColor: 'var(--border-subtle)' }}>
                <BadgeCheck className="h-3 w-3 text-amber-600" /> Escrow Protected
              </span>
            </div>
          </div>

          {/* 8 Specialization Branches */}
          <div className="space-y-3">
            <p className="text-xs font-mono-code uppercase tracking-wider font-semibold" style={{ color: 'var(--text-primary)' }}>
              {t.footerBranchesTitle}
            </p>
            <ul className="space-y-1.5 text-xs">
              {branches.map((b) => (
                <li key={b.code}>
                  <a href={b.href} className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
                    {isBengali ? b.nameBn : b.nameEn}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Solutions & Roles */}
          <div className="space-y-3">
            <p className="text-xs font-mono-code uppercase tracking-wider font-semibold" style={{ color: 'var(--text-primary)' }}>
              {t.footerSolutionsTitle}
            </p>
            <ul className="space-y-1.5 text-xs">
              <li>
                <Link href="/customer-portal" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
                  {t.roleIndividualCustomer}
                </Link>
              </li>
              <li>
                <Link href="/business-portal" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
                  {t.roleBusinessClient}
                </Link>
              </li>
              <li>
                <a href="#workers" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
                  {t.roleWorker}
                </a>
              </li>
              <li>
                <a href="#download" className="inline-flex items-center gap-1 text-[#003399] dark:text-[#3898EC] font-semibold hover:underline">
                  <Smartphone className="h-3 w-3" />
                  <span>{t.downloadApkTitle}</span>
                </a>
              </li>
            </ul>
          </div>

          {/* Governance & Legal */}
          <div className="space-y-3">
            <p className="text-xs font-mono-code uppercase tracking-wider font-semibold" style={{ color: 'var(--text-primary)' }}>
              {t.footerLegalTitle}
            </p>
            <ul className="space-y-1.5 text-xs">
              <li>
                <Link href="/privacy" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
                  {t.footerPrivacy}
                </Link>
              </li>
              <li>
                <Link href="/terms" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
                  {t.footerTerms}
                </Link>
              </li>
              <li>
                <a href="#faq" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
                  {t.navFaq}
                </a>
              </li>
              <li>
                <a href="#contact" className="hover:text-[#003399] dark:hover:text-[#3898EC] transition">
                  {t.navContact}
                </a>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Rights Bar */}
        <div
          className="pt-6 border-t flex flex-col sm:flex-row items-center justify-between gap-3 text-xs"
          style={{ borderColor: 'var(--border-subtle)', color: 'var(--text-muted)' }}
        >
          <p>© {new Date().getFullYear()} {t.footerRights}</p>
          <p className="font-mono-code text-[11px]">SKAVIA v1.0.0 &middot; Made in Bangladesh</p>
        </div>
      </div>
    </footer>
  );
}
