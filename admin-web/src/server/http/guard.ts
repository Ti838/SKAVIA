import { NextResponse } from 'next/server';
import { ZodError } from 'zod';
import type { AdminSessionContext, PermissionKey } from '@/lib/contracts';
import { getAdminRepository } from '../db/store-factory';
import type { AdminRepository } from '../db/repository';
import { ServerConfigError } from '../config/env';
import {
  AuthorizationError,
  assertAuthorized,
  assertPrimarySuperAdminOnly,
} from '../auth/rbac';
import { resolveVerifiedAdminSession } from '../auth/session';
import { extractClientIp } from '../audit/logger';
import { ApkInspectionError } from '../releases/apk-inspector';
import { ReleaseValidationError } from '../releases/release-validator';

export interface AdminRequestContext {
  session: AdminSessionContext;
  repo: AdminRepository;
  correlationId: string;
  ipAddress: string;
}

export interface GuardOptions {
  permission?: PermissionKey;
  requireStepUp?: boolean;
  requirePrimarySuperAdmin?: boolean;
  targetBranchId?: string | null;
}

export function jsonErrorResponse(error: unknown, correlationId: string) {
  if (error instanceof AuthorizationError) {
    return NextResponse.json(
      {
        error: {
          code: error.code,
          message: error.message,
          correlationId,
        },
      },
      { status: error.statusCode }
    );
  }

  if (error instanceof ServerConfigError) {
    return NextResponse.json(
      {
        error: {
          code: error.code,
          message: error.message,
          correlationId,
        },
      },
      { status: 503 }
    );
  }

  if (error instanceof ApkInspectionError || error instanceof ReleaseValidationError) {
    return NextResponse.json(
      {
        error: {
          code: error.code,
          message: error.message,
          correlationId,
        },
      },
      { status: error.statusCode }
    );
  }

  if (error instanceof ZodError) {
    return NextResponse.json(
      {
        error: {
          code: 'VALIDATION_ERROR',
          message: error.issues.map((i) => `${i.path.join('.')}: ${i.message}`).join('; '),
          correlationId,
        },
      },
      { status: 400 }
    );
  }

  const message =
    error instanceof Error ? error.message : 'Unexpected server error.';
  return NextResponse.json(
    {
      error: {
        code: 'INTERNAL_ERROR',
        message,
        correlationId,
      },
    },
    { status: 500 }
  );
}

export async function withAdminRoute(
  req: Request,
  options: GuardOptions,
  handler: (ctx: AdminRequestContext) => Promise<NextResponse>
): Promise<NextResponse> {
  const correlationId =
    req.headers.get('x-correlation-id') || crypto.randomUUID();
  const ipAddress = extractClientIp(req);

  try {
    const repo = getAdminRepository();
    const session = await resolveVerifiedAdminSession(repo, req);

    if (options.requirePrimarySuperAdmin) {
      assertPrimarySuperAdminOnly(session);
    }

    if (options.permission) {
      assertAuthorized(session, {
        permission: options.permission,
        requireStepUp: options.requireStepUp,
        targetBranchId: options.targetBranchId,
      });
    }

    const res = await handler({
      session,
      repo,
      correlationId,
      ipAddress,
    });
    res.headers.set('X-Correlation-Id', correlationId);
    res.headers.set('Cache-Control', 'no-store');
    return res;
  } catch (error) {
    if (error instanceof AuthorizationError && error.statusCode === 403) {
      // Best-effort security telemetry when authenticated actor attempts forbidden access
      try {
        const repo = getAdminRepository();
        const session = await resolveVerifiedAdminSession(repo, req).catch(
          () => null
        );
        if (session) {
          await repo.writeAuditLog({
            userId: session.userId,
            action: 'security.access.denied',
            entityType: 'api_route',
            entityId: new URL(req.url).pathname,
            details: {
              correlation_id: correlationId,
              required_permission: options.permission ?? null,
              reason: error.code,
            },
            ipAddress,
          });
        }
      } catch {
        // Do not obscure original 403
      }
    }

    const res = jsonErrorResponse(error, correlationId);
    res.headers.set('X-Correlation-Id', correlationId);
    res.headers.set('Cache-Control', 'no-store');
    return res;
  }
}

