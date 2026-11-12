import { NextResponse } from 'next/server';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(req, {}, async ({ session, repo }) => {
    const credentials = await repo.listPasskeysForUser(session.userId);
    return NextResponse.json({
      credentials: credentials.map((c) => ({
        credential_id: c.credential_id,
        user_id: c.user_id,
        friendly_name: c.friendly_name,
        device_type: c.device_type,
        backed_up: c.backed_up,
        transports: c.transports,
        last_used_at: c.last_used_at,
        revoked_at: c.revoked_at,
        created_at: c.created_at,
      })),
    });
  });
}

