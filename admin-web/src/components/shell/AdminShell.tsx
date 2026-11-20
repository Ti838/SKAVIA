'use client';

import { useState, type ReactNode } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';
import {
  Activity,
  BadgeCheck,
  BarChart3,
  Briefcase,
  Building2,
  CalendarClock,
  CreditCard,
  Layers,
  LayoutDashboard,
  PackageCheck,
  Scale,
  Settings,
  Shield,
  Users,
  UserCheck,
  Wrench,
  X,
} from 'lucide-react';
import type { PermissionKey } from '@/lib/types';
import { useTranslation } from '@/lib/l10n/LanguageContext';
import type { TranslationDictionary } from '@/lib/l10n/translations';
import { useAdminSession } from './SessionProvider';
import { TopBar } from './TopBar';

interface NavItemDef {
  key: keyof TranslationDictionary;
  href: string;
  permission?: PermissionKey;
  primarySuperAdminOnly?: boolean;
  icon: ReactNode;
  section: 'Operations' | 'Platform' | 'Governance';
}

const NAV_ITEM_DEFS: NavItemDef[] = [
  {
    key: 'navDashboard',
    href: '/dashboard',
    permission: 'branch.analytics.view',
    icon: <LayoutDashboard className="h-4 w-4" />,
    section: 'Operations',
  },
  {
    key: 'navBookings',
    href: '/bookings',
    permission: 'booking.view',
    icon: <CalendarClock className="h-4 w-4" />,
    section: 'Operations',
  },
  {
    key: 'navVerifications',
    href: '/verifications',
    permission: 'worker.verify',
    icon: <BadgeCheck className="h-4 w-4" />,
    section: 'Operations',
  },
  {
    key: 'navTeams',
    href: '/teams',
    permission: 'project.team.manage',
    icon: <Briefcase className="h-4 w-4" />,
    section: 'Operations',
  },
  {
    key: 'navDisputes',
    href: '/disputes',
    permission: 'dispute.view',
    icon: <Scale className="h-4 w-4" />,
    section: 'Operations',
  },
  {
    key: 'navCustomers',
    href: '/customers',
    permission: 'customer.view',
    icon: <Users className="h-4 w-4" />,
    section: 'Platform',
  },
  {
    key: 'navWorkers',
    href: '/workers',
    permission: 'worker.view',
    icon: <UserCheck className="h-4 w-4" />,
    section: 'Platform',
  },
  {
    key: 'navBranches',
    href: '/branches',
    permission: 'branch.view',
    icon: <Building2 className="h-4 w-4" />,
    section: 'Platform',
  },
  {
    key: 'navServices',
    href: '/services',
    permission: 'service.view',
    icon: <Layers className="h-4 w-4" />,
    section: 'Platform',
  },
  {
    key: 'navFinance',
    href: '/finance',
    permission: 'payment.view',
    icon: <CreditCard className="h-4 w-4" />,
    section: 'Governance',
  },
  {
    key: 'navReports',
    href: '/reports',
    permission: 'report.view',
    icon: <BarChart3 className="h-4 w-4" />,
    section: 'Governance',
  },
  {
    key: 'navAdmins',
    href: '/admins',
    permission: 'admin.view',
    primarySuperAdminOnly: true,
    icon: <Wrench className="h-4 w-4" />,
    section: 'Governance',
  },
  {
    key: 'navSecurity',
    href: '/security',
    permission: 'security.audit.view',
    primarySuperAdminOnly: true,
    icon: <Shield className="h-4 w-4" />,
    section: 'Governance',
  },
  {
    key: 'navReleases',
    href: '/releases',
    permission: 'release.view',
    primarySuperAdminOnly: true,
    icon: <PackageCheck className="h-4 w-4" />,
    section: 'Governance',
  },
  {
    key: 'navSettings',
    href: '/settings',
    icon: <Settings className="h-4 w-4" />,
    section: 'Governance',
  },
];

export function AdminShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const { session } = useAdminSession();
  const { t } = useTranslation();
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  const visibleItems = NAV_ITEM_DEFS.filter((item) => {
    if (item.primarySuperAdminOnly && !session.isPrimarySuperAdmin) {
      return false;
    }
    return !item.permission || session.effectivePermissions.includes(item.permission);
  });

  const sections: Array<NavItemDef['section']> = ['Operations', 'Platform', 'Governance'];
  const sectionLabelKeys: Record<NavItemDef['section'], keyof TranslationDictionary> = {
    Operations: 'sectionOperations',
    Platform: 'sectionPlatform',
    Governance: 'sectionGovernance',
  };

  const renderSidebarContent = () => (
    <div className="flex flex-col h-full text-neutral-900 dark:text-neutral-100 bg-[#FAFAFA] dark:bg-black">
      <div className="h-16 px-5 flex items-center justify-between border-b border-neutral-200 dark:border-neutral-800">
        <Link href="/dashboard" className="flex items-center gap-2.5">
          <div className="h-9 w-9 rounded-lg bg-neutral-100 dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800 flex items-center justify-center p-1">
            <SkaviaBrandMark variant="emblem" size={24} />
          </div>
          <div>
            <p className="text-sm font-bold tracking-tight text-neutral-950 dark:text-white">SKAVIA</p>
            <p className="text-[10px] font-mono uppercase tracking-widest text-neutral-500 dark:text-neutral-400">
              {session.isPrimarySuperAdmin ? 'Super Admin Portal' : session.primaryRole}
            </p>
          </div>
        </Link>
        <button
          type="button"
          onClick={() => setMobileNavOpen(false)}
          aria-label="Close mobile menu"
          className="lg:hidden p-1 text-neutral-500 hover:text-neutral-950 dark:hover:text-white"
        >
          <X className="h-5 w-5" />
        </button>
      </div>

      <nav
        className="flex-1 overflow-y-auto px-3 py-4 space-y-5 [scrollbar-width:none] [-ms-overflow-style:none] [&::-webkit-scrollbar]:hidden"
        aria-label="Sidebar Navigation"
      >
        {sections.map((section) => {
          const items = visibleItems.filter((i) => i.section === section);
          if (items.length === 0) return null;
          return (
            <div key={section}>
              <p className="px-3 mb-1.5 text-[10px] font-mono uppercase tracking-wider text-neutral-400 dark:text-neutral-500 font-semibold">
                {t[sectionLabelKeys[section]]}
              </p>
              <ul className="space-y-0.5">
                {items.map((item) => {
                  const active = pathname === item.href || pathname.startsWith(`${item.href}/`);
                  return (
                    <li key={item.href}>
                      <Link
                        href={item.href}
                        onClick={() => setMobileNavOpen(false)}
                        className={`sakuga-spring-tap flex items-center gap-2.5 rounded-lg px-3 py-2 text-xs font-medium transition-all ${
                          active
                            ? 'bg-neutral-200/80 text-neutral-950 font-semibold dark:bg-white/10 dark:text-white shadow-xs'
                            : 'text-neutral-600 hover:text-neutral-950 hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-900/60'
                        }`}
                      >
                        <span className={`shrink-0 ${active ? 'text-neutral-950 dark:text-white' : 'text-neutral-500 dark:text-neutral-400'}`}>
                          {item.icon}
                        </span>
                        <span>{t[item.key]}</span>
                      </Link>
                    </li>
                  );
                })}
              </ul>
            </div>
          );
        })}
      </nav>

      <div className="p-3.5 border-t border-neutral-200 dark:border-neutral-800 bg-neutral-50 dark:bg-neutral-950">
        <div className="flex items-center gap-2.5">
          <div className="h-8 w-8 rounded-full bg-neutral-200 dark:bg-neutral-800 border border-neutral-300 dark:border-neutral-700 flex items-center justify-center text-xs font-bold text-neutral-800 dark:text-neutral-200 shrink-0">
            {session.fullName.slice(0, 2).toUpperCase()}
          </div>
          <div className="min-w-0">
            <p className="text-xs font-semibold text-neutral-900 dark:text-white truncate">
              {session.fullName}
            </p>
            <p className="text-[10px] font-mono text-neutral-500 dark:text-neutral-400 flex items-center gap-1 truncate">
              <Activity className="h-3 w-3 text-emerald-500 shrink-0" />
              {session.primaryRole}
            </p>
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen flex bg-neutral-50 dark:bg-black text-neutral-900 dark:text-neutral-100">
      {/* Desktop Fixed Sidebar */}
      <aside className="hidden lg:block w-64 shrink-0 border-r border-neutral-200 dark:border-neutral-800">
        <div className="sticky top-0 h-screen">{renderSidebarContent()}</div>
      </aside>

      {/* Mobile Drawer Sidebar */}
      {mobileNavOpen && (
        <div className="fixed inset-0 z-50 lg:hidden flex">
          <div className="w-64 h-full shadow-2xl border-r border-neutral-200 dark:border-neutral-800">{renderSidebarContent()}</div>
          <div className="flex-1 bg-black/50 backdrop-blur-xs" onClick={() => setMobileNavOpen(false)} />
        </div>
      )}

      {/* Main Content Workspace */}
      <div className="flex-1 min-w-0 flex flex-col bg-white dark:bg-black">
        <TopBar onOpenMobileNav={() => setMobileNavOpen(true)} />
        <main className="flex-1 p-4 lg:p-6 max-w-[1480px] w-full mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
}

