'use client';

import { useEffect, useState } from 'react';
import { Check, ChevronDown, MapPin, X } from 'lucide-react';
import { useTranslation } from '@/lib/l10n/LanguageContext';

export interface ServiceZone {
  id: string;
  nameEn: string;
  nameBn: string;
  districtEn: string;
  districtBn: string;
}

export const SERVICE_ZONES: ServiceZone[] = [
  { id: 'dhanmondi', nameEn: 'Dhanmondi', nameBn: 'ধানমন্ডি', districtEn: 'Dhaka', districtBn: 'ঢাকা' },
  { id: 'gulshan', nameEn: 'Gulshan', nameBn: 'গুলশান', districtEn: 'Dhaka', districtBn: 'ঢাকা' },
  { id: 'banani', nameEn: 'Banani', nameBn: 'বনানী', districtEn: 'Dhaka', districtBn: 'ঢাকা' },
  { id: 'uttara', nameEn: 'Uttara', nameBn: 'উত্তরা', districtEn: 'Dhaka', districtBn: 'ঢাকা' },
  { id: 'mirpur', nameEn: 'Mirpur', nameBn: 'মিরপুর', districtEn: 'Dhaka', districtBn: 'ঢাকা' },
  { id: 'mohammadpur', nameEn: 'Mohammadpur', nameBn: 'মোহাম্মদপুর', districtEn: 'Dhaka', districtBn: 'ঢাকা' },
  { id: 'motijheel', nameEn: 'Motijheel', nameBn: 'মতিঝিল', districtEn: 'Dhaka', districtBn: 'ঢাকা' },
  { id: 'chattogram', nameEn: 'Agrabad', nameBn: 'আগ্রাবাদ', districtEn: 'Chattogram', districtBn: 'চট্টগ্রাম' },
  { id: 'sylhet', nameEn: 'Zindabazar', nameBn: 'জিন্দাবাজার', districtEn: 'Sylhet', districtBn: 'সিলেট' },
];

export function LocationPill({ compact = false }: { compact?: boolean }) {
  const { isBengali, t } = useTranslation();
  const [selectedZoneId, setSelectedZoneId] = useState<string>('dhanmondi');
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    try {
      const saved = localStorage.getItem('skavia-user-zone');
      if (saved && SERVICE_ZONES.some((z) => z.id === saved)) {
        setSelectedZoneId(saved);
      }
    } catch {}
  }, []);

  const fallbackZone: ServiceZone = SERVICE_ZONES[0] ?? {
    id: 'dhanmondi',
    nameEn: 'Dhanmondi',
    nameBn: 'ধানমন্ডি',
    districtEn: 'Dhaka',
    districtBn: 'ঢাকা',
  };
  const currentZone: ServiceZone =
    SERVICE_ZONES.find((z) => z.id === selectedZoneId) ?? fallbackZone;
  const displayLabel = isBengali
    ? `${currentZone.nameBn}, ${currentZone.districtBn}`
    : `${currentZone.nameEn}, ${currentZone.districtEn}`;

  const handleSelectZone = (id: string) => {
    setSelectedZoneId(id);
    setIsOpen(false);
    try {
      localStorage.setItem('skavia-user-zone', id);
    } catch {}
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setIsOpen(true)}
        aria-haspopup="dialog"
        aria-expanded={isOpen}
        title={t.changeLocation}
        className={`inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-medium transition ${
          compact ? 'max-w-[130px] truncate' : ''
        }`}
        style={{
          backgroundColor: 'var(--bg-surface-subtle)',
          borderColor: 'var(--border-subtle)',
          color: 'var(--text-secondary)',
        }}
      >
        <MapPin className="h-3.5 w-3.5 shrink-0 text-[#003399] dark:text-[#3898EC]" />
        <span className="truncate">{displayLabel}</span>
        <ChevronDown className="h-3 w-3 shrink-0 text-slate-400" />
      </button>

      {/* Location Picker Modal */}
      {isOpen && (
        <div
          role="dialog"
          aria-modal="true"
          aria-label={t.selectLocation}
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200"
          onClick={() => setIsOpen(false)}
        >
          <div
            className="w-full max-w-md rounded-2xl border p-5 shadow-2xl space-y-4"
            style={{
              backgroundColor: 'var(--bg-surface)',
              borderColor: 'var(--border-subtle)',
              color: 'var(--text-primary)',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between border-b pb-3" style={{ borderColor: 'var(--border-subtle)' }}>
              <div className="flex items-center gap-2">
                <MapPin className="h-4 w-4 text-[#003399] dark:text-[#3898EC]" />
                <h3 className="text-sm font-bold tracking-tight">{t.selectLocation}</h3>
              </div>
              <button
                type="button"
                onClick={() => setIsOpen(false)}
                className="rounded-lg p-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 max-h-[320px] overflow-y-auto pr-1">
              {SERVICE_ZONES.map((zone) => {
                const isSelected = zone.id === selectedZoneId;
                const label = isBengali
                  ? `${zone.nameBn}, ${zone.districtBn}`
                  : `${zone.nameEn}, ${zone.districtEn}`;

                return (
                  <button
                    key={zone.id}
                    type="button"
                    onClick={() => handleSelectZone(zone.id)}
                    className={`flex items-center justify-between rounded-xl border p-3 text-left text-xs transition ${
                      isSelected
                        ? 'border-[#003399] bg-[#003399]/10 text-[#003399] dark:border-[#3898EC] dark:text-[#3898EC] font-semibold'
                        : 'border-slate-200 dark:border-slate-800 hover:border-slate-300 dark:hover:border-slate-700'
                    }`}
                  >
                    <span>{label}</span>
                    {isSelected && <Check className="h-3.5 w-3.5" />}
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      )}
    </>
  );
}
