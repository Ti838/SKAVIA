import Link from 'next/link';
import { ShieldAlert } from 'lucide-react';
import { SkaviaBrandMark } from '@/components/brand/SkaviaBrandMark';

export function AccessDeniedScreen() {
  return (
    <div className="min-h-screen flex items-center justify-center p-6 bg-slate-950 text-slate-100">
      <div className="max-w-md w-full rounded-2xl border border-red-500/30 bg-slate-900 p-8 text-center space-y-4">
        <div className="flex justify-center">
          <div className="h-14 w-14 rounded-2xl border border-red-500/30 bg-red-500/10 flex items-center justify-center">
            <ShieldAlert className="h-7 w-7 text-red-400" />
          </div>
        </div>
        <div className="flex items-center justify-center gap-2">
          <SkaviaBrandMark variant="emblem" size={24} />
          <span className="font-bold tracking-tight">SKAVIA Security Boundary</span>
        </div>
        <h1 className="text-lg font-bold text-white">Portal Surface or Role Access Denied</h1>
        <p className="text-xs text-slate-300 leading-relaxed">
          You attempted to access an administrative route outside your assigned portal surface or
          role authorization boundary. Primary Super Admin tools are inaccessible from internal
          admin portals or public websites.
        </p>
        <div className="pt-2 flex justify-center gap-3">
          <Link
            href="/dashboard"
            className="rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white hover:bg-blue-700"
          >
            Return to Dashboard
          </Link>
        </div>
      </div>
    </div>
  );
}

