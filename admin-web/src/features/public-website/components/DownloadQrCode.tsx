'use client';

import { useEffect, useState } from 'react';
import QRCode from 'qrcode';
import { Copy, Check, QrCode as QrIcon } from 'lucide-react';
import { useSakugaToast } from '@/components/sakuga';

interface DownloadQrCodeProps {
  url: string;
  className?: string;
}

export function DownloadQrCode({ url, className = '' }: DownloadQrCodeProps) {
  const [svgHtml, setSvgHtml] = useState<string>('');
  const [copied, setCopied] = useState(false);
  const { showToast } = useSakugaToast();

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
