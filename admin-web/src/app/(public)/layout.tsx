import type { ReactNode } from 'react';
import { PublicThemeProvider } from '@/features/public-website/components/PublicThemeProvider';

export default function PublicRootLayout({ children }: { children: ReactNode }) {
  return <PublicThemeProvider>{children}</PublicThemeProvider>;
}
