import { NextResponse } from 'next/server';
import { IncidentCreateSchema, IncidentUpdateSchema } from '@/lib/contracts';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'security.incident.manage', requireStepUp: false },
    async ({ repo }) => {
      const incidents = await repo.listIncidents();
      return NextResponse.json({ incidents });
    }
  );
}

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'security.incident.manage', requireStepUp: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = IncidentCreateSchema.parse(await req.json());
      const incident = await repo.createIncident(input);

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'security.incident.created',
        entityType: 'security_incident',
        entityId: incident.incident_id,
        details: { severity: input.severity, title: input.title },
        ipAddress,
        correlationId,
      });

      return NextResponse.json({ incident }, { status: 201 });
    }
  );
}

export async function PATCH(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'security.incident.manage', requireStepUp: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = IncidentUpdateSchema.parse(await req.json());
      const incident = await repo.updateIncident({
        incidentId: input.incidentId,
        status: input.status,
      });

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'security.incident.updated',
        entityType: 'security_incident',
        entityId: input.incidentId,
        details: { status: input.status, containment_note: input.containmentNote ?? null },
        ipAddress,
        correlationId,
      });

      return NextResponse.json({ incident });
    }
  );
}

