import { NextResponse } from 'next/server';
import { resolvePublicRequestOrigin } from '@/server/http/origin';
import { getPublicDistributionSnapshot } from '@/server/releases/distribution-snapshot';

export const dynamic = 'force-dynamic';

export async function GET(req: Request) {
  const origin = resolvePublicRequestOrigin(req);
  const snapshot = await getPublicDistributionSnapshot(origin);
  return NextResponse.json(snapshot, {
    headers: { 'Cache-Control': 'no-store' },
  });
}
