import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { PUBLIC_SERVICES } from '@/features/public-website/services-catalog-data';
import { ServiceDetailScreen } from '@/features/public-website/screens/ServiceDetailScreen';

interface Props {
  params: Promise<{ slug: string }>;
}

export async function generateStaticParams() {
  return PUBLIC_SERVICES.map((s) => ({
    slug: s.slug,
  }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const service = PUBLIC_SERVICES.find((s) => s.slug === slug);
  if (!service) return { title: 'Service Not Found | SKAVIA' };

  return {
    title: `${service.nameEn} — ${service.branchNameEn} | SKAVIA`,
    description: service.summaryEn,
  };
}

export default async function ServiceDetailPage({ params }: Props) {
  const { slug } = await params;
  const service = PUBLIC_SERVICES.find((s) => s.slug === slug);
  if (!service) {
    notFound();
  }

  return <ServiceDetailScreen service={service} />;
}
