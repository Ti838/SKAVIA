-- ==============================================================================
-- SKAVIA PLATFORM — SECURITY MIGRATION: AUTHENTICATION, ROLES & TENANT ISOLATION
-- Migration: 20261019183000_harden_auth_roles_and_tenancy.sql
-- Compliance: OWASP Top 10 API Security, Role Escalation Prevention, Tenant Isolation
-- ==============================================================================

-- 1. HARDEN USER_ROLES PRIVILEGE BOUNDARIES
-- Prevent users from inserting, updating, or deleting roles (Anti-Privilege Escalation)
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "User Roles Read" ON public.user_roles;
CREATE POLICY "User Roles Read"
ON public.user_roles
FOR SELECT
TO authenticated
USING (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "User Roles Modify" ON public.user_roles;
CREATE POLICY "User Roles Modify"
ON public.user_roles
FOR ALL
TO authenticated
USING (false);

-- Strip modify grants from public and anon roles
REVOKE INSERT, UPDATE, DELETE ON TABLE public.user_roles FROM anon, authenticated, public;
GRANT SELECT ON TABLE public.user_roles TO authenticated;


-- 2. HARDEN TEAMS TENANT ISOLATION
-- Only project owners and assigned workers may view project teams
DROP POLICY IF EXISTS "Teams Read" ON public.teams;
CREATE POLICY "Teams Read"
ON public.teams
FOR SELECT
TO authenticated
USING (
    EXISTS (SELECT 1 FROM public.projects p WHERE p.project_id = teams.project_id AND p.client_id = auth.uid()::text)
    OR EXISTS (SELECT 1 FROM public.team_members tm JOIN public.worker_profiles wp ON tm.worker_profile_id = wp.worker_profile_id WHERE tm.team_id = teams.team_id AND wp.user_id = auth.uid()::text)
);


-- 3. HARDEN TEAM MEMBERS TENANT ISOLATION
-- Only project owners and member workers themselves may view team assignments
DROP POLICY IF EXISTS "Team Members Read" ON public.team_members;
CREATE POLICY "Team Members Read"
ON public.team_members
FOR SELECT
TO authenticated
USING (
    EXISTS (SELECT 1 FROM public.teams t JOIN public.projects p ON t.project_id = p.project_id WHERE t.team_id = team_members.team_id AND p.client_id = auth.uid()::text)
    OR EXISTS (SELECT 1 FROM public.worker_profiles wp WHERE wp.worker_profile_id = team_members.worker_profile_id AND wp.user_id = auth.uid()::text)
);


-- 4. HARDEN TASKS CROSS-TENANT ISOLATION
-- Prevent competitors or unrelated users from enumerating enterprise tasks
DROP POLICY IF EXISTS "Tasks Read" ON public.tasks;
CREATE POLICY "Tasks Read"
ON public.tasks
FOR SELECT
TO authenticated
USING (
    EXISTS (SELECT 1 FROM public.projects p WHERE p.project_id = tasks.project_id AND p.client_id = auth.uid()::text)
    OR EXISTS (SELECT 1 FROM public.team_members tm JOIN public.worker_profiles wp ON tm.worker_profile_id = wp.worker_profile_id WHERE tm.team_member_id = tasks.assigned_team_member_id AND wp.user_id = auth.uid()::text)
    OR EXISTS (SELECT 1 FROM public.teams t JOIN public.team_members tm ON t.team_id = tm.team_id JOIN public.worker_profiles wp ON tm.worker_profile_id = wp.worker_profile_id WHERE t.project_id = tasks.project_id AND wp.user_id = auth.uid()::text)
);
