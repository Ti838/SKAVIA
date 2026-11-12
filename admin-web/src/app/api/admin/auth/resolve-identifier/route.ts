import { NextResponse } from 'next/server';
import { IdentifierLookupSchema } from '@/lib/contracts';
import { resolvePortalSurfaceFromRequest } from '@/server/auth/surface';
import { getAdminRepository } from '@/server/db/store-factory';
import { jsonErrorResponse } from '@/server/http/guard';

/**
 * Resolves the primary Super Admin login username to its Firebase auth email
 * ONLY on the Super Admin portal surface without leaking arbitrary accounts.
 */
export async function POST(req: Request) {
  const correlationId = req.headers.get('x-correlation-id') || crypto.randomUUID();
  try {
    const input = IdentifierLookupSchema.parse(await req.json());
    const identifier = input.identifier.trim();

    if (identifier.includes('@')) {
      return NextResponse.json({ email: identifier.toLowerCase(), isUsername: false });
    }

    const surface = resolvePortalSurfaceFromRequest(req, input.surface ?? null);
    if (surface !== 'superadmin' && surface !== 'local') {
      return NextResponse.json(
        {
          error: {
            code: 'USERNAME_NOT_SUPPORTED_ON_SURFACE',
            message: 'Username sign-in is reserved exclusively for the Super Admin portal.',
            correlationId,
          },
        },
        { status: 403 }
      );
    }

    const repo = getAdminRepository();
    const match = await repo.lookupPrimarySuperAdminByUsername(identifier);
    if (!match) {
      return NextResponse.json(
        {
          error: {
            code: 'INVALID_CREDENTIALS',
            message: 'Invalid Super Admin username or credentials.',
            correlationId,
          },
        },
        { status: 401 }
      );
    }

    return NextResponse.json({ email: match.email, isUsername: true });
  } catch (error) {
    return jsonErrorResponse(error, correlationId);
  }
}

