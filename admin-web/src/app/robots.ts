import type { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/api/', '/dashboard/', '/admins/', '/finance/', '/security/', '/settings/'],
    },
    sitemap: 'https://skavia-bd.vercel.app/sitemap.xml',
  };
}
