const BENGALI_DIGITS = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

export function toBengaliDigits(input: number | string | null | undefined): string {
  if (input === null || input === undefined) return '';
  return String(input).replace(/[0-9]/g, (digit) => BENGALI_DIGITS[parseInt(digit, 10)] ?? digit);
}

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

export function formatBdtLocale(
  amount: number | string | null | undefined,
  lang: 'en' | 'bn' = 'en'
): string {
  const num = typeof amount === 'string' ? parseFloat(amount) : (amount ?? 0);
  const safe = Number.isFinite(num) ? num : 0;

  if (lang === 'bn') {
    const formatted = new Intl.NumberFormat('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(safe);
    return `৳ ${toBengaliDigits(formatted)}`;
  }

  return formatBdt(safe);
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

export function formatDateTimeLocale(
  iso: string | null | undefined,
  lang: 'en' | 'bn' = 'en'
): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';

  if (lang === 'bn') {
    const enFormatted = new Intl.DateTimeFormat('en-GB', {
      dateStyle: 'medium',
      timeStyle: 'short',
    }).format(d);
    return toBengaliDigits(enFormatted);
  }

  return formatDateTime(iso);
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
