import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'SKAVIA | Accountable Skilled Workforce Platform & Admin Portal',
  description:
    'On-demand technical, residential, and corporate operations with Haversine dispatch, cryptographic 4-digit OTP, atomic 85/15 escrow, and zero-trust governance.',
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
      <body className="min-h-screen antialiased">{children}</body>
    </html>
  );
}
