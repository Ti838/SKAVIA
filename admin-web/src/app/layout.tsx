import type { Metadata } from 'next';
import { SakugaProvider } from '@/components/sakuga';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL('https://skavia-bd.vercel.app'),
  title: {
    default: 'SKAVIA BD | Official Skilled Workforce Platform & Services',
    template: '%s | SKAVIA BD',
  },
  description:
    'Official SKAVIA BD Platform — On-demand technical, residential, and corporate workforce operations in Bangladesh with Haversine dispatch, cryptographic 4-digit OTP, atomic 85/15 escrow, and zero-trust governance.',
  keywords: [
    'SKAVIA',
    'SKAVIA BD',
    'skavia-bd',
    'skavia-bd.vercel.app',
    'SKAVIA Bangladesh',
    'skavia app',
    'skilled workforce bangladesh',
    'on-demand services bd',
    'technician app dhaka',
    'home repair services bd',
    'verified skilled workers',
  ],
  authors: [{ name: 'SKAVIA Technologies' }],
  creator: 'SKAVIA',
  publisher: 'SKAVIA BD',
  alternates: {
    canonical: 'https://skavia-bd.vercel.app',
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  openGraph: {
    title: 'SKAVIA BD | Official Skilled Workforce Platform & Services',
    description:
      'Official SKAVIA BD Platform — On-demand technical, residential, and corporate workforce operations in Bangladesh. Download the official Android APK.',
    url: 'https://skavia-bd.vercel.app',
    siteName: 'SKAVIA BD',
    images: [
      {
        url: '/images/skavia_logo.png',
        width: 512,
        height: 512,
        alt: 'SKAVIA BD Official Logo',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary',
    title: 'SKAVIA BD | Official Skilled Workforce Platform',
    description:
      'Official SKAVIA BD Platform — On-demand technical, residential, and corporate operations in Bangladesh.',
    images: ['/images/skavia_logo.png'],
  },
  icons: {
    icon: [
      { url: '/favicon.ico', sizes: 'any' },
      { url: '/favicon.png', type: 'image/png' },
    ],
    shortcut: '/favicon.png',
    apple: '/apple-touch-icon.png',
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              (function() {
                try {
                  var saved = localStorage.getItem('skavia-theme');
                  var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
                  var isDark = saved === 'dark' || ((!saved || saved === 'system') && prefersDark);
                  if (isDark) {
                    document.documentElement.classList.add('dark');
                    document.documentElement.setAttribute('data-theme', 'dark');
                  } else {
                    document.documentElement.classList.remove('dark');
                    document.documentElement.setAttribute('data-theme', 'light');
                  }
                } catch (e) {}
              })();
            `,
          }}
        />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              '@context': 'https://schema.org',
              '@type': 'WebSite',
              name: 'SKAVIA BD',
              alternateName: ['SKAVIA', 'skavia-bd', 'SKAVIA Bangladesh', 'skavia-bd.vercel.app'],
              url: 'https://skavia-bd.vercel.app',
              description:
                'Official SKAVIA BD Platform — On-demand technical, residential, and corporate workforce operations in Bangladesh.',
              publisher: {
                '@type': 'Organization',
                name: 'SKAVIA BD',
                url: 'https://skavia-bd.vercel.app',
                logo: 'https://skavia-bd.vercel.app/images/skavia_logo.png',
              },
            }),
          }}
        />
      </head>
      <body className="min-h-screen antialiased">
        <SakugaProvider>{children}</SakugaProvider>
      </body>
    </html>
  );
}
