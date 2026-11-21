'use client';

import Image from 'next/image';
import Link from 'next/link';
import { BadgeCheck, KeyRound, ShieldCheck, Smartphone } from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';

export function PublicFooter() {
  const branches = [
    { code: 'HOME', name: 'SKAVIA Home', desc: 'Plumbing & sanitary', href: '/branches/home' },
    { code: 'TECH', name: 'SKAVIA Technical', desc: 'HVAC & electrical', href: '/branches/technical' },
    { code: 'AGRI', name: 'SKAVIA Agriculture', desc: 'Irrigation & automation', href: '/services-catalog' },
    { code: 'LOGI', name: 'SKAVIA Logistics', desc: 'Transport & tool supply', href: '/services-catalog' },
    { code: 'DIGI', name: 'SKAVIA Digital', desc: 'IP CCTV & POS networking', href: '/services-catalog' },
    { code: 'BIZ', name: 'SKAVIA Business', desc: 'Turnkey commercial fit-outs', href: '/business' },
    { code: 'CONS', name: 'SKAVIA Construction', desc: 'Civil renovation & partitions', href: '/services-catalog' },
    { code: 'EVNT', name: 'SKAVIA Events', desc: 'Staging & power grids', href: '/services-catalog' },
  ];

  return (
    <footer className="border-t border-neutral-200 dark:border-neutral-800 bg-white dark:bg-black text-neutral-600 dark:text-neutral-400 py-16 px-4 sm:px-6 lg:px-8 transition-colors">
      <div className="max-w-7xl mx-auto space-y-12">
        {/* Main 5-Column Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8">
          {/* Brand Column */}
          <div className="lg:col-span-2 space-y-4">
            <Link href="/" className="inline-flex items-center gap-2.5">
              <SkaviaBrandMark variant="emblem" size={30} />
              <div className="flex flex-col">
                <span className="font-heading font-extrabold text-base tracking-tight text-neutral-900 dark:text-white">
                  SKAVIA
                </span>
                <span className="text-[10px] font-mono tracking-wider text-neutral-500 uppercase">
                  Workforce &amp; Services
                </span>
              </div>
            </Link>

            <p className="text-xs leading-relaxed max-w-sm text-neutral-600 dark:text-neutral-400">
              Accountable on-demand trade maintenance and commercial workforce platform. 
              Operates across 8 internal specialization branches with biometric NID verification, 
              4-digit arrival OTP handshakes, and atomic escrow protection.
            </p>

            <div className="pt-2 flex flex-wrap gap-2 text-[11px] font-mono text-neutral-500">
              <span className="inline-flex items-center gap-1 rounded-md border border-neutral-200 dark:border-neutral-800 px-2 py-0.5 bg-neutral-50 dark:bg-neutral-900">
                <ShieldCheck className="h-3 w-3 text-teal-600 dark:text-teal-400" /> NID Verified
              </span>
              <span className="inline-flex items-center gap-1 rounded-md border border-neutral-200 dark:border-neutral-800 px-2 py-0.5 bg-neutral-50 dark:bg-neutral-900">
                <KeyRound className="h-3 w-3 text-blue-600 dark:text-blue-400" /> 4-Digit Arrival OTP
              </span>
              <span className="inline-flex items-center gap-1 rounded-md border border-neutral-200 dark:border-neutral-800 px-2 py-0.5 bg-neutral-50 dark:bg-neutral-900">
                <BadgeCheck className="h-3 w-3 text-amber-600 dark:text-amber-400" /> Escrow Protected
              </span>
            </div>

            {/* Parent Organization Endorsement: BITA STUDIO */}
            <div className="pt-2">
              <a
                href="https://bita-studio.vercel.app/"
                target="_blank"
                rel="noopener noreferrer"
                className="group inline-flex items-center gap-3 rounded-2xl border border-neutral-200 dark:border-neutral-800 p-2.5 bg-neutral-50 dark:bg-neutral-900/60 hover:border-blue-500/50 hover:bg-neutral-100 dark:hover:bg-neutral-800/80 transition-all shadow-xs"
              >
                <Image
                  src="/images/bita-studio-logo.png"
                  alt="BITA STUDIO"
                  width={36}
                  height={36}
                  className="h-8 w-auto object-contain transition-transform group-hover:scale-105"
                />
                <div className="flex flex-col">
                  <span className="text-[10px] font-mono tracking-wider uppercase text-neutral-500 dark:text-neutral-400 group-hover:text-blue-500 transition-colors font-medium">
                    A Product of BITA STUDIO
                  </span>
                  <span className="text-xs font-bold text-neutral-900 dark:text-white">
                    Building Ideas. Engineering the Future.
                  </span>
                </div>
              </a>
            </div>
          </div>

          {/* 8 Specialization Branches */}
          <div className="space-y-3">
            <p className="text-xs font-mono uppercase tracking-wider font-semibold text-neutral-900 dark:text-neutral-100">
              Specialized Branches
            </p>
            <ul className="space-y-2 text-xs">
              {branches.map((b) => (
                <li key={b.code}>
                  <Link
                    href={b.href}
                    className="hover:text-neutral-950 dark:hover:text-white transition-colors"
                  >
                    {b.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Solutions & Discovery */}
          <div className="space-y-3">
            <p className="text-xs font-mono uppercase tracking-wider font-semibold text-neutral-900 dark:text-neutral-100">
              Platform &amp; Services
            </p>
            <ul className="space-y-2 text-xs">
              <li>
                <Link href="/services-catalog" className="hover:text-neutral-950 dark:hover:text-white transition-colors">
                  Trade Services Catalog
                </Link>
              </li>
              <li>
                <Link href="/how-it-works" className="hover:text-neutral-950 dark:hover:text-white transition-colors">
                  How It Works (4 Steps)
                </Link>
              </li>
              <li>
                <Link href="/experience" className="hover:text-neutral-950 dark:hover:text-white transition-colors">
                  Customer Trust &amp; Safety
                </Link>
              </li>
              <li>
                <Link href="/business" className="hover:text-neutral-950 dark:hover:text-white transition-colors">
                  Enterprise Turnkey SLAs
                </Link>
              </li>
              <li>
                <Link href="/specialists" className="hover:text-neutral-950 dark:hover:text-white transition-colors">
                  Specialist 90% Earnings Charter
                </Link>
              </li>
              <li>
                <Link href="/download" className="inline-flex items-center gap-1 font-semibold text-[#003399] dark:text-[#3898EC] hover:underline">
                  <Smartphone className="h-3 w-3" />
                  <span>Download Mobile APK</span>
                </Link>
              </li>
            </ul>
          </div>

          {/* Governance & Support */}
          <div className="space-y-3">
            <p className="text-xs font-mono uppercase tracking-wider font-semibold text-neutral-900 dark:text-neutral-100">
              Governance &amp; Support
            </p>
            <ul className="space-y-2 text-xs">
              <li>
                <Link href="/about" className="hover:text-neutral-950 dark:hover:text-white transition-colors">
                  About SKAVIA
                </Link>
              </li>
              <li>
                <Link href="/contact" className="hover:text-neutral-950 dark:hover:text-white transition-colors">
                  Operations Command Desk
                </Link>
              </li>
              <li>
                <Link href="/faq" className="hover:text-neutral-950 dark:hover:text-white transition-colors">
                  Knowledge Base &amp; FAQ
                </Link>
              </li>
              <li>
                <Link href="/privacy" className="hover:text-neutral-950 dark:hover:text-white transition-colors">
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link href="/terms" className="hover:text-neutral-950 dark:hover:text-white transition-colors">
                  Terms of Service
                </Link>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Bar: Copyright and BITA STUDIO Engineering Backing */}
        <div className="pt-8 border-t border-neutral-200 dark:border-neutral-800 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-neutral-500">
          <div className="flex flex-wrap items-center gap-4">
            <p>© {new Date().getFullYear()} SKAVIA Technologies. Headquartered in Dhaka, Bangladesh.</p>
          </div>
          <a
            href="https://bita-studio.vercel.app/"
            target="_blank"
            rel="noopener noreferrer"
            className="group inline-flex items-center gap-2 hover:opacity-100 transition"
          >
            <span className="text-[11px] text-neutral-500 group-hover:text-blue-500 transition-colors">
              Engineered by
            </span>
            <span className="text-xs font-extrabold text-neutral-800 dark:text-neutral-200 group-hover:text-blue-500 transition-colors">
              BITA STUDIO
            </span>
          </a>
        </div>
      </div>
    </footer>
  );
}
