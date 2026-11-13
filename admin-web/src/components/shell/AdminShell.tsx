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
import { useAdminSession } from './SessionProvider';
import { TopBar } from './TopBar';

interface NavItem {
  label: string;
  href: string;
  permission?: PermissionKey;
  primarySuperAdminOnly?: boolean;
  icon: ReactNode;
  section: 'Operations' | 'Platform' | 'Governance';
}

const NAV_ITEMS: NavItem[] = [
  {
    label: 'Overview',
    href: '/dashboard',
    permission: 'branch.analytics.view',
    icon: <LayoutDashboard className="h-4 w-4" />,
    section: 'Operations',
  },
  {
    label: 'Bookings',
    href: '/bookings',
    permission: 'booking.view',
    icon: <CalendarClock className="h-4 w-4" />,
    section: 'Operations',
  },
  {
    label: 'Verification Queue',
    href: '/verifications',
    permission: 'worker.verify',
    icon: <BadgeCheck className="h-4 w-4" />,
    section: 'Operations',
  },
  {
    label: 'Turnkey Teams',
    href: '/teams',
    permission: 'project.team.manage',
    icon: <Briefcase className="h-4 w-4" />,
    section: 'Operations',
  },
  {
    label: 'Disputes',
    href: '/disputes',
    permission: 'dispute.view',
    icon: <Scale className="h-4 w-4" />,
    section: 'Operations',
  },
  {
    label: 'Customers',
    href: '/customers',
    permission: 'customer.view',
    icon: <Users className="h-4 w-4" />,
    section: 'Platform',
  },
  {
    label: 'Workers',
    href: '/workers',
    permission: 'worker.view',
    icon: <UserCheck className="h-4 w-4" />,
    section: 'Platform',
  },
  {
    label: 'Branches',
    href: '/branches',
    permission: 'branch.view',
    icon: <Building2 className="h-4 w-4" />,
    section: 'Platform',
  },
  {
    label: 'Services & Skills',
    href: '/services',
    permission: 'service.view',
    icon: <Layers className="h-4 w-4" />,
    section: 'Platform',
  },
  {
    label: 'Finance & Approvals',
    href: '/finance',
    permission: 'payment.view',
    icon: <CreditCard className="h-4 w-4" />,
    section: 'Governance',
  },
  {
    label: 'Reports & Export',
    href: '/reports',
    permission: 'report.view',
    icon: <BarChart3 className="h-4 w-4" />,
    section: 'Governance',
  },
  {
    label: 'Admins & Invitations',
    href: '/admins',
    permission: 'admin.view',
    primarySuperAdminOnly: true,
    icon: <Wrench className="h-4 w-4" />,
    section: 'Governance',
  },
  {
    label: 'Security Center',
    href: '/security',
    permission: 'security.audit.view',
    primarySuperAdminOnly: true,
    icon: <Shield className="h-4 w-4" />,
    section: 'Governance',
  },
  {
    label: 'App Releases',
    href: '/releases',
    permission: 'release.view',
    primarySuperAdminOnly: true,
    icon: <PackageCheck className="h-4 w-4" />,
    section: 'Governance',
  },
  {
    label: 'Passkeys & Profile',
    href: '/settings',
    icon: <Settings className="h-4 w-4" />,
    section: 'Governance',
  },
];

export function AdminShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const { session } = useAdminSession();
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  const visibleItems = NAV_ITEMS.filter((item) => {
    if (item.primarySuperAdminOnly && !session.isPrimarySuperAdmin) {
      return false;
    }
    return !item.permission || session.effectivePermissions.includes(item.permission);
  });

  const sections: Array<NavItem['section']> = ['Operations', 'Platform', 'Governance'];

  const renderSidebarContent = () => (
    <div className="flex flex-col h-full text-slate-100" style={{ backgroundColor: 'var(--bg-sidebar)' }}>
      <div className="h-16 px-5 flex items-center justify-between border-b border-white/10">
        <Link href="/dashboard" className="flex items-center gap-2.5">
          <div className="h-9 w-9 rounded-lg bg-white/10 border border-white/15 flex items-center justify-center p-1">
            <SkaviaBrandMark variant="emblem" size={28} />
          </div>
          <div>
            <p className="text-sm font-bold tracking-wide text-white">SKAVIA</p>
            <p className="text-[10px] uppercase tracking-widest text-teal-300">
              {session.isPrimarySuperAdmin ? 'Super Admin Portal' : 'Internal Admin'}
            </p>
          </div>
        </Link>
        <button
          type="button"
          onClick={() => setMobileNavOpen(false)}
          aria-label="Close mobile menu"
          className="lg:hidden p-1 text-slate-300"
        >
          <X className="h-5 w-5" />
        </button>
      </div>

      <nav className="flex-1 overflow-y-auto px-3 py-4 space-y-5" aria-label="Sidebar Navigation">
        {sections.map((section) => {
          const items = visibleItems.filter((i) => i.section === section);
          if (items.length === 0) return null;
          return (
            <div key={section}>
              <p className="px-3 mb-1.5 text-[10px] font-semibold uppercase tracking-widest text-slate-400">
                {section}
              </p>
              <ul className="space-y-0.5">
                {items.map((item) => {
                  const active = pathname === item.href || pathname.startsWith(`${item.href}/`);
                  return (
                    <li key={item.href}>
                      <Link
                        href={item.href}
                        onClick={() => setMobileNavOpen(false)}
                        className={`flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm font-medium transition ${
                          active
                            ? 'bg-blue-600 text-white shadow-sm'
                            : 'text-slate-300 hover:bg-white/10 hover:text-white'
                        }`}
                      >
                        {item.icon}
                        <span>{item.label}</span>
                      </Link>
                    </li>
                  );
                })}
              </ul>
            </div>
          );
        })}
      </nav>

      <div className="p-4 border-t border-white/10 bg-black/20">
        <div className="flex items-center gap-2.5">
          <div className="h-8 w-8 rounded-full bg-blue-500/20 border border-blue-400/40 flex items-center justify-center text-xs font-bold text-teal-300 shrink-0">
            {session.fullName.slice(0, 2).toUpperCase()}
          </div>
          <div className="min-w-0">
            <p className="text-xs font-semibold text-white truncate">
              {session.fullName}
            </p>
            <p className="text-[11px] text-slate-300 flex items-center gap-1 truncate">
              <Activity className="h-3 w-3 text-teal-400 shrink-0" />
              {session.primaryRole}
            </p>
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen flex">
      {/* Desktop Fixed Sidebar */}
      <aside className="hidden lg:block w-64 shrink-0 border-r border-slate-800/40">
        <div className="sticky top-0 h-screen">{renderSidebarContent()}</div>
      </aside>

      {/* Mobile Drawer Sidebar */}
      {mobileNavOpen && (
        <div className="fixed inset-0 z-50 lg:hidden flex">
          <div className="w-64 h-full">{renderSidebarContent()}</div>
          <div className="flex-1 bg-slate-950/60" onClick={() => setMobileNavOpen(false)} />
        </div>
      )}

      {/* Main Content Workspace */}
      <div className="flex-1 min-w-0 flex flex-col">
        <TopBar onOpenMobileNav={() => setMobileNavOpen(true)} />
        <main className="flex-1 p-4 lg:p-6 max-w-[1480px] w-full mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
}

