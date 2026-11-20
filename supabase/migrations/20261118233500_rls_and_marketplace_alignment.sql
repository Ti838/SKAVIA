-- ==============================================================================
-- SKAVIA PLATFORM — MASTER COMPREHENSIVE PRODUCTION ALIGNMENT MIGRATION
-- Migration: 20261118233500_rls_and_marketplace_alignment.sql
-- Description: Sets zero-fake-data defaults, recreates the public marketplace
--              view with all required columns, and establishes RLS policies.
-- Safe, idempotent, zero destructive drops (no table or data loss).
-- ==============================================================================

-- 1. REAL DATA INTEGRITY: Ensure columns exist & eliminate 5.0 fake rating default
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE public.worker_profiles ADD COLUMN IF NOT EXISTS total_reviews INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.worker_profiles ALTER COLUMN rating_average SET DEFAULT 0.00;
ALTER TABLE public.worker_profiles ALTER COLUMN total_reviews SET DEFAULT 0;
ALTER TABLE public.worker_profiles ALTER COLUMN completed_jobs SET DEFAULT 0;
ALTER TABLE public.worker_profiles ALTER COLUMN expected_rate SET DEFAULT 0.00;

UPDATE public.worker_profiles
SET rating_average = 0.00
WHERE COALESCE(total_reviews, 0) = 0 AND rating_average = 5.00;

-- 2. PUBLIC MARKETPLACE DISCOVERY VIEW (Clean, Non-PII Projection)
-- Drop view if exists and recreate with canonical column order to avoid PostgreSQL column type mismatch
DROP VIEW IF EXISTS public.marketplace_public_profiles CASCADE;

CREATE VIEW public.marketplace_public_profiles AS
SELECT
    wp.worker_profile_id,
    wp.user_id,
    u.full_name AS display_name,
    u.avatar_url,
    wp.title,
    wp.bio,
    wp.location,
    wp.expected_rate,
    wp.rating_average,
    wp.completed_jobs,
    wp.verification_status,
    wp.is_available,
    wp.category_id,
    COALESCE(wp.total_reviews, 0) AS total_reviews
FROM public.worker_profiles wp
JOIN public.users u ON u.user_id = wp.user_id
WHERE wp.is_available = TRUE
  AND u.status = 'Active';

GRANT SELECT ON public.marketplace_public_profiles TO anon, authenticated;

-- 3. REVIEWS RLS POLICIES
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Reviews Public Read" ON public.reviews;
CREATE POLICY "Reviews Public Read"
ON public.reviews
FOR SELECT
TO anon, authenticated
USING (true);

DROP POLICY IF EXISTS "Reviews Owner Insert" ON public.reviews;
CREATE POLICY "Reviews Owner Insert"
ON public.reviews
FOR INSERT
TO authenticated
WITH CHECK (client_id = auth.uid()::text);

-- 4. PAYOUT REQUESTS RLS POLICIES (Safe Guarded)
DO $$
BEGIN
    IF to_regclass('public.payout_requests') IS NOT NULL THEN
        ALTER TABLE public.payout_requests ENABLE ROW LEVEL SECURITY;

        DROP POLICY IF EXISTS "Payout Requests Owner Read" ON public.payout_requests;
        CREATE POLICY "Payout Requests Owner Read"
        ON public.payout_requests
        FOR SELECT
        TO authenticated
        USING (
            EXISTS (
                SELECT 1
                FROM public.worker_profiles wp
                WHERE wp.worker_profile_id = payout_requests.worker_profile_id
                  AND wp.user_id = auth.uid()::text
            )
            OR requested_by = auth.uid()::text
        );

        DROP POLICY IF EXISTS "Payout Requests Owner Insert" ON public.payout_requests;
        CREATE POLICY "Payout Requests Owner Insert"
        ON public.payout_requests
        FOR INSERT
        TO authenticated
        WITH CHECK (
            EXISTS (
                SELECT 1
                FROM public.worker_profiles wp
                WHERE wp.worker_profile_id = payout_requests.worker_profile_id
                  AND wp.user_id = auth.uid()::text
            )
            OR requested_by = auth.uid()::text
        );
    END IF;
END $$;

-- 5. MATCH RESULTS RLS POLICIES
ALTER TABLE public.match_results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Match Results Owner Read" ON public.match_results;
CREATE POLICY "Match Results Owner Read"
ON public.match_results
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.requirements r
        WHERE r.requirement_id = match_results.requirement_id
          AND r.submitted_by = auth.uid()::text
    )
);

DROP POLICY IF EXISTS "Match Results Owner Insert" ON public.match_results;
CREATE POLICY "Match Results Owner Insert"
ON public.match_results
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.requirements r
        WHERE r.requirement_id = match_results.requirement_id
          AND r.submitted_by = auth.uid()::text
    )
);

-- 6. TEAMS, TEAM MEMBERS & TASKS RLS POLICIES
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teams Project Owner Insert" ON public.teams;
CREATE POLICY "Teams Project Owner Insert"
ON public.teams
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.projects p
        WHERE p.project_id = teams.project_id
          AND p.client_id = auth.uid()::text
    )
);

DROP POLICY IF EXISTS "Tasks Project Owner Insert" ON public.tasks;
CREATE POLICY "Tasks Project Owner Insert"
ON public.tasks
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.projects p
        WHERE p.project_id = tasks.project_id
          AND p.client_id = auth.uid()::text
    )
);

DROP POLICY IF EXISTS "Tasks Authorized Update" ON public.tasks;
CREATE POLICY "Tasks Authorized Update"
ON public.tasks
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.projects p
        WHERE p.project_id = tasks.project_id
          AND p.client_id = auth.uid()::text
    )
    OR EXISTS (
        SELECT 1
        FROM public.team_members tm
        JOIN public.worker_profiles wp ON tm.worker_profile_id = wp.worker_profile_id
        WHERE tm.team_member_id = tasks.assigned_team_member_id
          AND wp.user_id = auth.uid()::text
    )
);

-- 7. MESSAGES UPDATE POLICY (Mark Read)
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Messages Participant Mark Read" ON public.messages;
CREATE POLICY "Messages Participant Mark Read"
ON public.messages
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.conversations c
        WHERE c.conversation_id = messages.conversation_id
          AND (c.participant_one = auth.uid()::text OR c.participant_two = auth.uid()::text)
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.conversations c
        WHERE c.conversation_id = messages.conversation_id
          AND (c.participant_one = auth.uid()::text OR c.participant_two = auth.uid()::text)
    )
);

-- 8. AUDIT LOGS INSERT POLICY
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Audit Logs Actor Insert" ON public.audit_logs;
CREATE POLICY "Audit Logs Actor Insert"
ON public.audit_logs
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid()::text);

-- 9. ENSURE APP-RELEASES BUCKET EXISTS IN STORAGE
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('app-releases', 'app-releases', true, 104857600, NULL)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Public Read App Releases" ON storage.objects;
CREATE POLICY "Public Read App Releases"
ON storage.objects
FOR SELECT
USING (bucket_id = 'app-releases');
