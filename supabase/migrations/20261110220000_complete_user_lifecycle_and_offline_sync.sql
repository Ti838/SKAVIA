-- ==============================================================================
-- SKAVIA PLATFORM — MASTER USER LIFECYCLE, OFFLINE SYNC & ELIGIBILITY MIGRATION
-- Migration: 20261110220000_complete_user_lifecycle_and_offline_sync.sql
-- Compliance: OWASP Top 10 API Security, RLS Tenant Isolation, ACID Transactions
-- ==============================================================================

-- 1. EXTEND USERS TABLE (Safe, non-destructive column additions)
DO $$
BEGIN
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS date_of_birth DATE;
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS birthday_notifications_enabled BOOLEAN DEFAULT true;
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS gender TEXT DEFAULT 'unspecified';
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS emergency_contact_name TEXT;
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS emergency_contact_phone TEXT;
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS preferred_language TEXT DEFAULT 'en';
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS timezone TEXT DEFAULT 'Asia/Dhaka';
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS account_status TEXT DEFAULT 'active';
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS verification_status TEXT DEFAULT 'unverified';
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS privacy_settings JSONB DEFAULT '{"profile_visibility": "public", "share_phone_with_assigned_specialist": true, "data_sharing_consent": true}'::jsonb;
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{"push_enabled": true, "sms_enabled": true, "email_enabled": true, "urgent_alerts": true, "birthday_reminders": true, "promotional": false}'::jsonb;
    ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_completion_percentage INTEGER DEFAULT 30;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Some columns already exist in public.users: %', SQLERRM;
END $$;


-- 2. CREATE SAVED ADDRESSES TABLE (Multi-location delivery & booking eligibility)
CREATE TABLE IF NOT EXISTS public.user_addresses (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL,
    label TEXT NOT NULL DEFAULT 'Home',
    recipient_name TEXT,
    recipient_phone TEXT,
    address_line TEXT NOT NULL,
    zone TEXT NOT NULL DEFAULT 'Dhaka North',
    city TEXT NOT NULL DEFAULT 'Dhaka',
    postal_code TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_addresses_user ON public.user_addresses(user_id);
ALTER TABLE public.user_addresses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "User Addresses Owner Access" ON public.user_addresses;
CREATE POLICY "User Addresses Owner Access"
ON public.user_addresses
FOR ALL
TO authenticated
USING (user_id = auth.uid()::text)
WITH CHECK (user_id = auth.uid()::text);

GRANT ALL ON TABLE public.user_addresses TO authenticated, service_role;


-- 3. CREATE USER SESSIONS & ACTIVE DEVICES TABLE
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL,
    device_id TEXT NOT NULL,
    device_name TEXT,
    device_os TEXT,
    app_version TEXT,
    ip_address TEXT,
    last_active_at TIMESTAMPTZ DEFAULT now(),
    is_revoked BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON public.user_sessions(user_id);
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "User Sessions Owner Access" ON public.user_sessions;
CREATE POLICY "User Sessions Owner Access"
ON public.user_sessions
FOR ALL
TO authenticated
USING (user_id = auth.uid()::text)
WITH CHECK (user_id = auth.uid()::text);

GRANT ALL ON TABLE public.user_sessions TO authenticated, service_role;


-- 4. CREATE OFFLINE SYNC QUEUE & IDEMPOTENCY LEDGER
CREATE TABLE IF NOT EXISTS public.offline_sync_queue (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL,
    idempotency_key TEXT NOT NULL UNIQUE,
    operation_type TEXT NOT NULL,
    payload JSONB NOT NULL,
    status TEXT DEFAULT 'pending',
    retry_count INTEGER DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    processed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_offline_sync_user ON public.offline_sync_queue(user_id, status);
ALTER TABLE public.offline_sync_queue ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Offline Sync Queue Owner Access" ON public.offline_sync_queue;
CREATE POLICY "Offline Sync Queue Owner Access"
ON public.offline_sync_queue
FOR ALL
TO authenticated
USING (user_id = auth.uid()::text)
WITH CHECK (user_id = auth.uid()::text);

GRANT ALL ON TABLE public.offline_sync_queue TO authenticated, service_role;


-- 5. CREATE NOTIFICATIONS TABLE WITH DEDUPLICATION & CATEGORIES
CREATE TABLE IF NOT EXISTS public.user_notifications (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL,
    dedup_key TEXT UNIQUE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    action_route TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_notifications_user ON public.user_notifications(user_id, is_read);
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "User Notifications Owner Access" ON public.user_notifications;
CREATE POLICY "User Notifications Owner Access"
ON public.user_notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid()::text)
WITH CHECK (user_id = auth.uid()::text);

GRANT ALL ON TABLE public.user_notifications TO authenticated, service_role;


-- 6. STORED PROCEDURE: CALCULATE PROFILE COMPLETION INTELLIGENCE
CREATE OR REPLACE FUNCTION public.calculate_profile_completion(p_user_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_address_count INTEGER := 0;
    v_total_points INTEGER := 0;
    v_missing_fields TEXT[] := ARRAY[]::TEXT[];
    v_full_name TEXT := NULL;
    v_email TEXT := NULL;
    v_phone TEXT := NULL;
    v_avatar_url TEXT := NULL;
    v_dob DATE := NULL;
    v_emergency_phone TEXT := NULL;
BEGIN
    -- Query user details safely across user_id or id columns
    BEGIN
        SELECT full_name, email, phone, avatar_url, date_of_birth, emergency_contact_phone
        INTO v_full_name, v_email, v_phone, v_avatar_url, v_dob, v_emergency_phone
        FROM public.users
        WHERE user_id = p_user_id;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            SELECT full_name, email, phone, avatar_url, date_of_birth, emergency_contact_phone
            INTO v_full_name, v_email, v_phone, v_avatar_url, v_dob, v_emergency_phone
            FROM public.users
            WHERE id::text = p_user_id;
        EXCEPTION WHEN OTHERS THEN
            v_full_name := NULL;
        END;
    END;

    -- Basic Profile Scoring (50 points)
    IF v_full_name IS NOT NULL AND length(trim(v_full_name)) > 2 THEN
        v_total_points := v_total_points + 15;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Full Name');
    END IF;

    IF v_email IS NOT NULL AND length(trim(v_email)) > 4 THEN
        v_total_points := v_total_points + 15;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Email Address');
    END IF;

    IF v_phone IS NOT NULL AND length(trim(v_phone)) > 6 THEN
        v_total_points := v_total_points + 10;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Phone Number');
    END IF;

    IF v_avatar_url IS NOT NULL THEN
        v_total_points := v_total_points + 10;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Profile Photo');
    END IF;

    -- Check Address (20 points)
    SELECT count(*) INTO v_address_count FROM public.user_addresses WHERE user_id = p_user_id;
    IF v_address_count > 0 THEN
        v_total_points := v_total_points + 20;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Saved Delivery Address');
    END IF;

    -- DOB (15 points)
    IF v_dob IS NOT NULL THEN
        v_total_points := v_total_points + 15;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Date of Birth');
    END IF;

    -- Emergency Contact (15 points)
    IF v_emergency_phone IS NOT NULL AND length(trim(v_emergency_phone)) > 6 THEN
        v_total_points := v_total_points + 15;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Emergency Contact');
    END IF;

    -- Cap at 100
    IF v_total_points > 100 THEN
        v_total_points := 100;
    END IF;

    -- Update score in users table safely
    BEGIN
        UPDATE public.users SET profile_completion_percentage = v_total_points WHERE user_id = p_user_id;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            UPDATE public.users SET profile_completion_percentage = v_total_points WHERE id::text = p_user_id;
        EXCEPTION WHEN OTHERS THEN
            NULL;
        END;
    END;

    RETURN jsonb_build_object(
        'user_id', p_user_id,
        'completion_percentage', v_total_points,
        'missing_fields', to_jsonb(v_missing_fields),
        'is_profile_complete', (v_total_points >= 80)
    );
END;
$$;


-- 7. STORED PROCEDURE: PROGRESSIVE FEATURE ELIGIBILITY GATE
CREATE OR REPLACE FUNCTION public.check_feature_eligibility(
    p_user_id TEXT,
    p_feature_name TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_address_count INTEGER := 0;
    v_is_eligible BOOLEAN := false;
    v_reasons TEXT[] := ARRAY[]::TEXT[];
    v_account_status TEXT := 'active';
    v_phone TEXT := NULL;
BEGIN
    -- Query user status safely
    BEGIN
        SELECT account_status, phone INTO v_account_status, v_phone FROM public.users WHERE user_id = p_user_id;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            SELECT account_status, phone INTO v_account_status, v_phone FROM public.users WHERE id::text = p_user_id;
        EXCEPTION WHEN OTHERS THEN
            v_account_status := 'active';
        END;
    END;

    IF v_account_status = 'suspended' OR v_account_status = 'deactivated' THEN
        RETURN jsonb_build_object('eligible', false, 'reason', 'Account is suspended or deactivated');
    END IF;

    IF p_feature_name = 'book_service' THEN
        SELECT count(*) INTO v_address_count FROM public.user_addresses WHERE user_id = p_user_id;
        IF v_address_count = 0 THEN
            v_reasons := array_append(v_reasons, 'A saved service address is required before booking.');
        END IF;

        IF v_phone IS NULL OR length(trim(v_phone)) < 6 THEN
            v_reasons := array_append(v_reasons, 'A contact phone number is required for booking dispatch.');
        END IF;

        IF array_length(v_reasons, 1) IS NULL THEN
            v_is_eligible := true;
        END IF;
    ELSE
        v_is_eligible := true;
    END IF;

    RETURN jsonb_build_object(
        'eligible', v_is_eligible,
        'feature', p_feature_name,
        'reasons', to_jsonb(v_reasons)
    );
END;
$$;
