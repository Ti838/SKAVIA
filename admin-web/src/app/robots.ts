import type { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_PUBLIC_HOST
    ? `https://${process.env.NEXT_PUBLIC_PUBLIC_HOST}`
    : 'https://www.skavia.com';

  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: [
        '/api/admin/',
        '/dashboard/',
        '/admins/',
        '/finance/',
        '/security/',
        '/settings/',
        '/bookings/',
        '/verifications/',
        '/teams/',
        '/disputes/',
        '/reports/',
        '/releases/',
      ],
    },
    sitemap: `${baseUrl}/sitemap.xml`,
  };
}
