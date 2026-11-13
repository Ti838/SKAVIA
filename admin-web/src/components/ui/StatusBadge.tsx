'use client';

const VARIANT_CLASSES: Record<string, string> = {
  success:
    'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-200 border-emerald-200 dark:border-emerald-800/70',
  warning:
    'bg-amber-50 dark:bg-amber-950/60 text-amber-800 dark:text-amber-200 border-amber-200 dark:border-amber-800/70',
  danger:
    'bg-red-50 dark:bg-red-950/60 text-red-800 dark:text-red-200 border-red-200 dark:border-red-800/70',
  info:
    'bg-sky-50 dark:bg-sky-950/60 text-sky-800 dark:text-sky-200 border-sky-200 dark:border-sky-800/70',
  neutral:
    'bg-slate-100 dark:bg-slate-800/80 text-slate-700 dark:text-slate-200 border-slate-200 dark:border-slate-700',
};

function resolveVariant(status: string): keyof typeof VARIANT_CLASSES {
  const s = status.toLowerCase();
  if (
    ['active', 'verified', 'approved', 'completed', 'resolved', 'succeeded', 'closed', 'sent', 'delivered', 'published'].includes(s)
  ) {
    return 'success';
  }
  if (
    ['pending', 'pendingapproval', 'setupinprogress', 'investigating', 'in progress', 'requested', 'scheduled', 'contained', 'low', 'medium', 'draft'].includes(s)
  ) {
    return 'warning';
  }
  if (
    ['suspended', 'rejected', 'canceled', 'cancelled', 'deactivated', 'failed', 'deliveryfailed', 'expired', 'critical', 'high', 'deny', 'revoked', 'dismissed'].includes(s)
  ) {
    return 'danger';
  }
  if (['allow', 'open', 'matched', 'confirmed', 'accepted', 'invited', 'opened', 'validated'].includes(s)) {
    return 'info';
  }
  return 'neutral';
}

export function StatusBadge({
  status,
  variant,
}: {
  status: string;
  variant?: keyof typeof VARIANT_CLASSES;
}) {
  const resolved = variant ?? resolveVariant(status);
  return (
    <span
      className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${VARIANT_CLASSES[resolved]}`}
    >
      {status}
    </span>
  );
}

