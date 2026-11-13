import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'SKAVIA | Accountable Skilled Workforce Platform & Admin Portal',
  description:
    'On-demand technical, residential, and corporate operations with Haversine dispatch, cryptographic 4-digit OTP, atomic 85/15 escrow, and zero-trust governance.',
  icons: {
    icon: '/favicon.png',
    shortcut: '/favicon.png',
    apple: '/images/skavia_emblem.png',
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
