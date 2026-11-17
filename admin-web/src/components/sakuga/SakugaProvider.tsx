'use client';

/**
 * SKAVIA Sakuga Toast Provider
 * Spring-eased toast notifications with subtle arrival kinetics & ARIA live region.
 * Motion principles adapted from Sakuga VFX (MIT License, Copyright (c) 2026 Justin Finkelman).
 */

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
  type ReactNode,
} from 'react';
import { AlertCircle, CheckCircle2, Info, X } from 'lucide-react';
import { isReducedMotion, sakugaTicks } from '@/lib/sakuga/sakuga-core';

export type SakugaToastTone = 'success' | 'error' | 'info';

interface ToastItem {
  id: number;
  message: string;
  tone: SakugaToastTone;
}

interface SakugaToastContextValue {
  showToast: (message: string, tone?: SakugaToastTone, durationMs?: number) => void;
}

const SakugaToastContext = createContext<SakugaToastContextValue>({
  showToast: () => {},
});

export function useSakugaToast() {
  return useContext(SakugaToastContext);
}

export function SakugaProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([]);
  const nextIdRef = useRef(1);
  const timersRef = useRef<Map<number, number>>(new Map());

  const dismiss = useCallback((id: number) => {
    const t = timersRef.current.get(id);
    if (t) {
      window.clearTimeout(t);
      timersRef.current.delete(id);
    }
    setToasts((prev) => prev.filter((item) => item.id !== id));
  }, []);

  const showToast = useCallback(
    (message: string, tone: SakugaToastTone = 'info', durationMs = 3400) => {
      const id = nextIdRef.current++;
      setToasts((prev) => [...prev.slice(-2), { id, message, tone }]);

      if (tone === 'success' && typeof window !== 'undefined' && !isReducedMotion()) {
        sakugaTicks(window.innerWidth - 160 + window.scrollX, window.innerHeight - 64 + window.scrollY, {
          n: 3,
          r: 14,
          len: 10,
          color: '#16A34A',
        });
      }

      if (typeof window !== 'undefined') {
        const timer = window.setTimeout(() => dismiss(id), durationMs);
        timersRef.current.set(id, timer);
      }
    },
    [dismiss],
  );

  useEffect(() => {
    const timers = timersRef.current;
    return () => {
      timers.forEach((timer) => window.clearTimeout(timer));
      timers.clear();
    };
  }, []);

  return (
    <SakugaToastContext.Provider value={{ showToast }}>
      {children}
      <div
        aria-live="polite"
        aria-atomic="true"
        className="fixed bottom-5 right-5 z-[100] flex flex-col gap-2.5 max-w-sm w-[calc(100vw-2.5rem)] pointer-events-none"
      >
        {toasts.map((toast) => {
          const toneClasses =
            toast.tone === 'success'
              ? 'bg-emerald-600 text-white border-emerald-500/40'
              : toast.tone === 'error'
                ? 'bg-red-600 text-white border-red-500/40'
                : 'bg-[#003399] text-white border-blue-400/40';
          const Icon =
            toast.tone === 'success'
              ? CheckCircle2
              : toast.tone === 'error'
                ? AlertCircle
                : Info;

          return (
            <div
              key={toast.id}
              role="status"
              className={`sakuga-toast-enter pointer-events-auto flex items-center gap-3 rounded-xl border px-4 py-3 text-sm font-medium shadow-xl ${toneClasses}`}
            >
              <Icon className="h-4 w-4 shrink-0" />
              <span className="flex-1 leading-snug">{toast.message}</span>
              <button
                type="button"
                aria-label="Dismiss notification"
                onClick={() => dismiss(toast.id)}
                className="opacity-80 hover:opacity-100 transition-opacity"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
          );
        })}
      </div>
    </SakugaToastContext.Provider>
  );
}
