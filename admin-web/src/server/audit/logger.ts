import type { AuditWriteInput, AdminRepository } from '../db/repository';

export async function recordAdminAudit(
  repo: AdminRepository,
  input: AuditWriteInput & { correlationId: string }
): Promise<void> {
  const sanitizedDetails = {
    ...(input.details ?? {}),
    correlation_id: input.correlationId,
  };

  await repo.writeAuditLog({
    userId: input.userId,
    action: input.action,
    entityType: input.entityType,
    entityId: input.entityId ?? null,
    details: sanitizedDetails,
    ipAddress: input.ipAddress ?? null,
  });
}

export function extractClientIp(req: Request): string {
  const fwd = req.headers.get('x-forwarded-for');
  if (fwd) {
    const first = fwd.split(',')[0]?.trim();
    if (first) return first;
  }
  return req.headers.get('x-real-ip') || 'unknown';
}

