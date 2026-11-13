export function formatBdt(amount: number | string | null | undefined): string {
  const num = typeof amount === 'string' ? parseFloat(amount) : (amount ?? 0);
  const safe = Number.isFinite(num) ? num : 0;
  return new Intl.NumberFormat('en-BD', {
    style: 'currency',
    currency: 'BDT',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(safe);
}

export function formatDateTime(iso: string | null | undefined): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  return new Intl.DateTimeFormat('en-GB', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(d);
}

export function maskIdentifier(value: string | null | undefined, visibleTail = 4): string {
  if (!value) return '—';
  const trimmed = value.trim();
  if (trimmed.length <= visibleTail) return trimmed;
  return `${'•'.repeat(Math.max(4, trimmed.length - visibleTail))}${trimmed.slice(-visibleTail)}`;
}

export function formatBytes(
  bytes: number | null | undefined,
  decimals = 2
): string {
  if (!bytes || !Number.isFinite(bytes) || bytes <= 0) return '—';
  const units = ['B', 'KB', 'MB', 'GB'];
  let idx = 0;
  let value = bytes;
  while (value >= 1024 && idx < units.length - 1) {
    value /= 1024;
    idx += 1;
  }
  return `${idx === 0 ? value.toFixed(0) : value.toFixed(decimals)} ${units[idx] ?? 'B'}`;
}

export function shortFingerprint(hex: string | null | undefined, head = 12, tail = 8): string {
  if (!hex) return '—';
  const clean = hex.trim().toLowerCase();
  if (clean.length <= head + tail + 3) return clean;
  return `${clean.slice(0, head)}…${clean.slice(-tail)}`;
}

