import { NextResponse } from 'next/server';
import { TeamAssemblyCreateSchema } from '@/lib/contracts';
import { AuthorizationError, assertAuthorized, resolveAuthorizedBranchFilter } from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

export async function GET(req: Request) {
  return withAdminRoute(req, { permission: 'project.team.manage' }, async ({ session, repo }) => {
    const url = new URL(req.url);
    const branchFilter = resolveAuthorizedBranchFilter(
      session,
      url.searchParams.get('branchId')
    );
    const projects = await repo.listProjects(branchFilter);
    return NextResponse.json({ projects });
  });
}

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'project.team.manage' },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = TeamAssemblyCreateSchema.parse(await req.json());
      const projects = await repo.listProjects(null);
      const targetProject = projects.find((p) => p.project_id === input.projectId);

      if (!targetProject) {
        throw new AuthorizationError('NOT_FOUND', 'Turnkey project not found.', 404);
      }

      assertAuthorized(session, {
        permission: 'project.team.manage',
        targetBranchId: targetProject.branch_id,
      });

      const updatedProject = await repo.assembleProjectTeam({
        projectId: input.projectId,
        teamName: input.teamName,
        members: input.members,
        initialTasks: input.initialTasks,
      });

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'project.team.assembled',
        entityType: 'project',
        entityId: input.projectId,
        details: {
          team_name: input.teamName,
          member_count: input.members.length,
          tasks_created: input.initialTasks.length,
        },
        ipAddress,
        correlationId,
      });

      return NextResponse.json({ project: updatedProject }, { status: 201 });
    }
  );
}

