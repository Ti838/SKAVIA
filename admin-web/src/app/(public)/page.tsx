import { headers } from 'next/headers';
import { PublicWebsiteScreen } from '@/features/public-website/PublicWebsiteScreen';
import { resolveHeaderOrigin } from '@/server/http/origin';
import { getPublicDistributionSnapshot } from '@/server/releases/distribution-snapshot';

export const dynamic = 'force-dynamic';

export default async function PublicHomePage() {
  const reqHeaders = await headers();
  const origin = resolveHeaderOrigin(reqHeaders);
  const initialDistribution = await getPublicDistributionSnapshot(origin);
  return <PublicWebsiteScreen initialDistribution={initialDistribution} />;
}
