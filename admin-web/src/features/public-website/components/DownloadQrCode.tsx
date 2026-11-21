'use client';

import { useEffect, useState } from 'react';
import QRCode from 'qrcode';
import { Copy, Check, QrCode as QrIcon } from 'lucide-react';
import { useSakugaToast } from '@/components/sakuga';

interface DownloadQrCodeProps {
  url: string;
  className?: string;
  compact?: boolean;
  variant?: 'card' | 'horizontal' | 'compact';
}

export function DownloadQrCode({
  url,
  className = '',
  compact = false,
  variant,
}: DownloadQrCodeProps) {
  const [svgHtml, setSvgHtml] = useState<string>('');
  const [copied, setCopied] = useState(false);
  const { showToast } = useSakugaToast();

  const resolvedVariant = variant ?? (compact ? 'compact' : 'card');

  useEffect(() => {
    let isMounted = true;
    QRCode.toString(
      url,
      {
        type: 'svg',
        margin: 1,
        color: {
          dark: '#003399',
          light: '#FFFFFF',
        },
      },
      (err, svg) => {
        if (!err && svg && isMounted) {
          setSvgHtml(svg);
        }
      }
    );
    return () => {
      isMounted = false;
    };
  }, [url]);

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      showToast('Download link copied to clipboard', 'success');
      setTimeout(() => setCopied(false), 2500);
    } catch {
      showToast('Unable to copy link', 'info');
    }
  };

  if (resolvedVariant === 'compact') {
    return (
      <div
        className={`p-4 sm:p-5 rounded-2xl border border-neutral-200 dark:border-neutral-800 bg-white dark:bg-neutral-900/90 shadow-md flex items-center justify-between gap-4 flex-wrap sm:flex-nowrap ${className}`}
      >
        <div className="flex items-center gap-3.5 min-w-0">
          <div className="p-1.5 rounded-xl bg-white border border-neutral-200/80 shadow-xs shrink-0">
            {svgHtml ? (
              <div
                className="w-14 h-14 sm:w-16 sm:h-16 [&>svg]:w-full [&>svg]:h-full"
                dangerouslySetInnerHTML={{ __html: svgHtml }}
              />
            ) : (
              <div className="w-14 h-14 sm:w-16 sm:h-16 bg-neutral-100 rounded-lg animate-pulse" />
            )}
          </div>
          <div className="space-y-0.5 min-w-0">
            <span className="text-xs font-mono font-bold uppercase tracking-wider text-neutral-900 dark:text-white flex items-center gap-1.5 truncate">
              <QrIcon className="h-3.5 w-3.5 text-[#003399] dark:text-[#3898EC] shrink-0" />
              <span>Instant Scan to Phone</span>
            </span>
            <p className="text-[11px] text-neutral-500 dark:text-neutral-400 line-clamp-1">
              Point your camera or Google Lens to install directly on Android.
            </p>
          </div>
        </div>
        <button
          type="button"
          onClick={handleCopyLink}
          className="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 text-xs font-medium text-neutral-700 dark:text-neutral-200 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition shrink-0 whitespace-nowrap active:scale-[0.98]"
        >
          {copied ? (
            <>
              <Check className="h-3.5 w-3.5 text-emerald-500" />
              <span className="text-emerald-600 dark:text-emerald-400">Link Copied!</span>
            </>
          ) : (
            <>
              <Copy className="h-3.5 w-3.5" />
              <span>Copy Link</span>
            </>
          )}
        </button>
      </div>
    );
  }

  if (resolvedVariant === 'horizontal') {
    return (
      <div
        className={`w-full p-4 sm:p-5 rounded-3xl border border-neutral-200 dark:border-neutral-800 bg-white dark:bg-neutral-900/90 shadow-xl flex flex-col sm:flex-row items-center gap-4 sm:gap-5 ${className}`}
      >
        {/* QR Code Container */}
        <div className="relative p-2 rounded-2xl bg-white border border-neutral-200/90 shadow-sm shrink-0">
          {svgHtml ? (
            <div
              className="w-24 h-24 sm:w-28 sm:h-28 [&>svg]:w-full [&>svg]:h-full"
              dangerouslySetInnerHTML={{ __html: svgHtml }}
            />
          ) : (
            <div className="w-24 h-24 sm:w-28 sm:h-28 flex items-center justify-center bg-neutral-100 rounded-xl animate-pulse">
              <span className="text-[10px] text-neutral-400 font-mono">Generating QR...</span>
            </div>
          )}
        </div>

        {/* Action & Info Details */}
        <div className="flex-1 min-w-0 text-center sm:text-left space-y-2">
          <div className="flex items-center justify-center sm:justify-start gap-1.5">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
            <span className="text-[10.5px] font-mono uppercase tracking-wider text-emerald-600 dark:text-emerald-400 font-bold">
              Instant Wireless Sideload
            </span>
          </div>

          <div className="space-y-0.5">
            <h3 className="text-sm font-extrabold text-neutral-950 dark:text-white tracking-tight flex items-center justify-center sm:justify-start gap-1.5">
              <QrIcon className="h-4 w-4 text-[#003399] dark:text-[#3898EC] shrink-0" />
              <span>Scan to Download APK</span>
            </h3>
            <p className="text-xs text-neutral-500 dark:text-neutral-400 leading-relaxed">
              Point your smartphone camera or Google Lens to start direct APK download.
            </p>
          </div>

          <div className="pt-0.5 flex items-center justify-center sm:justify-start">
            <button
              type="button"
              onClick={handleCopyLink}
              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 text-xs font-medium text-neutral-700 dark:text-neutral-200 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition active:scale-[0.98]"
            >
              {copied ? (
                <>
                  <Check className="h-3.5 w-3.5 text-emerald-500" />
                  <span className="text-emerald-600 dark:text-emerald-400">Link Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="h-3.5 w-3.5" />
                  <span>Copy Direct URL</span>
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={`flex flex-col items-center rounded-3xl border border-neutral-200 dark:border-neutral-800 bg-white dark:bg-neutral-900/90 p-6 shadow-xl text-center space-y-4 ${className}`}>
      <div className="flex items-center gap-2 text-xs font-mono uppercase tracking-wider text-neutral-500 dark:text-neutral-400 font-semibold">
        <QrIcon className="h-4 w-4 text-[#003399] dark:text-[#3898EC]" />
        <span>Scan to Download on Phone</span>
      </div>

      {/* QR Code Container */}
      <div className="relative p-3 rounded-2xl bg-white border border-neutral-200/80 shadow-md">
        {svgHtml ? (
          <div
            className="w-40 h-40 sm:w-44 sm:h-44 [&>svg]:w-full [&>svg]:h-full"
            dangerouslySetInnerHTML={{ __html: svgHtml }}
          />
        ) : (
          <div className="w-40 h-40 sm:w-44 sm:h-44 flex items-center justify-center bg-neutral-100 rounded-xl animate-pulse">
            <span className="text-xs text-neutral-400 font-mono">Generating QR...</span>
          </div>
        )}
      </div>

      <p className="text-xs text-neutral-500 dark:text-neutral-400 max-w-[200px] leading-relaxed">
        Point your mobile camera or Google Lens to install directly.
      </p>

      <button
        type="button"
        onClick={handleCopyLink}
        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full border border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800 text-xs font-medium text-neutral-700 dark:text-neutral-200 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition"
      >
        {copied ? (
          <>
            <Check className="h-3.5 w-3.5 text-emerald-500" />
            <span className="text-emerald-600 dark:text-emerald-400">Link Copied!</span>
          </>
        ) : (
          <>
            <Copy className="h-3.5 w-3.5" />
            <span>Copy Direct URL</span>
          </>
        )}
      </button>
    </div>
  );
}
