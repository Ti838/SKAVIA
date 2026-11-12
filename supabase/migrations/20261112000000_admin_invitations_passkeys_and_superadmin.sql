-- ==============================================================================
-- SKAVIA ENTERPRISE SEPARATION — ADDITIVE MIGRATION
-- Supports: Primary Super Admin governance, Invitation-Only Admin Onboarding,
-- WebAuthn/FIDO2 Passkey Credentials, Challenges, Recovery Codes & Branches.
-- Strictly non-destructive: preserves all existing 50+ tables & Flutter data.
-- ==============================================================================

-- ==============================================================================
-- 1. PRIMARY SUPER ADMIN IDENTITY EXTENSIONS
-- ==============================================================================
ALTER TABLE public.admin_profiles
    ADD COLUMN IF NOT EXISTS is_primary_super_admin BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS login_username VARCHAR(80),
    ADD COLUMN IF NOT EXISTS recovery_codes_hashes JSONB NOT NULL DEFAULT '[]'::jsonb,
    ADD COLUMN IF NOT EXISTS recovery_codes_generated_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS registered_devices JSONB NOT NULL DEFAULT '[]'::jsonb;

CREATE UNIQUE INDEX IF NOT EXISTS idx_admin_profiles_primary_super_admin
    ON public.admin_profiles(is_primary_super_admin)
    WHERE is_primary_super_admin = TRUE;

CREATE UNIQUE INDEX IF NOT EXISTS idx_admin_profiles_login_username
    ON public.admin_profiles(lower(login_username))
    WHERE login_username IS NOT NULL;

-- ==============================================================================
-- 2. ADMIN INVITATIONS & LIFECYCLE STATE MACHINE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.admin_invitations (
    invitation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    role_name VARCHAR(40) NOT NULL CHECK (role_name IN ('Company Admin', 'Branch Manager')),
    assigned_branch_ids UUID[] NOT NULL DEFAULT '{}',
    permission_profile JSONB NOT NULL DEFAULT '[]'::jsonb,
    note TEXT,
    token_hash TEXT NOT NULL UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'Draft' CHECK (
        status IN (
            'Draft',
            'Invited',
            'Delivered',
            'Opened',
            'SetupInProgress',
            'PendingApproval',
            'Active',
            'Expired',
            'Revoked',
            'Suspended'
        )
    ),
    delivery_status VARCHAR(30) NOT NULL DEFAULT 'Pending' CHECK (
        delivery_status IN ('Pending', 'Sent', 'Delivered', 'DeliveryFailed', 'NotConfigured')
    ),
    delivery_error TEXT,
    require_approval BOOLEAN NOT NULL DEFAULT TRUE,
    invited_by TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE RESTRICT,
    approved_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    activated_user_id TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    sent_at TIMESTAMPTZ,
    opened_at TIMESTAMPTZ,
    setup_started_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    activated_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (
        role_name <> 'Branch Manager'
        OR COALESCE(array_length(assigned_branch_ids, 1), 0) >= 1
    )
);

CREATE INDEX IF NOT EXISTS idx_admin_invitations_email_status
    ON public.admin_invitations(lower(email), status);
CREATE INDEX IF NOT EXISTS idx_admin_invitations_created_at
    ON public.admin_invitations(created_at DESC);

-- ==============================================================================
-- 3. WEBAUTHN / FIDO2 PASSKEY CREDENTIALS & EPHEMERAL CHALLENGES
--    Stores public key & cryptographic metadata ONLY (zero biometric images).
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.admin_passkeys (
    credential_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    friendly_name VARCHAR(120) NOT NULL,
    public_key TEXT NOT NULL,
    counter BIGINT NOT NULL DEFAULT 0,
    transports TEXT[] NOT NULL DEFAULT '{}',
    device_type VARCHAR(30) NOT NULL DEFAULT 'singleDevice',
    backed_up BOOLEAN NOT NULL DEFAULT FALSE,
    aaguid VARCHAR(64),
    last_used_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    revoked_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_passkeys_user_active
    ON public.admin_passkeys(user_id, created_at DESC)
    WHERE revoked_at IS NULL;

CREATE TABLE IF NOT EXISTS public.webauthn_challenges (
    challenge_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT REFERENCES public.users(user_id) ON DELETE CASCADE,
    invitation_id UUID REFERENCES public.admin_invitations(invitation_id) ON DELETE CASCADE,
    challenge TEXT NOT NULL,
    purpose VARCHAR(30) NOT NULL CHECK (purpose IN ('register', 'authenticate', 'step_up', 'invite_activate')),
    expires_at TIMESTAMPTZ NOT NULL,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_webauthn_challenges_expires
    ON public.webauthn_challenges(expires_at);

-- ==============================================================================
-- 4. EXPAND LOGIN EVENTS TELEMETRY & SURFACE TRACKING
-- ==============================================================================
ALTER TABLE public.admin_login_events
    ADD COLUMN IF NOT EXISTS surface VARCHAR(30);

DO $$
DECLARE
    v_constraint TEXT;
BEGIN
    SELECT con.conname
    INTO v_constraint
    FROM pg_constraint con
    JOIN pg_class rel ON rel.oid = con.conrelid
    JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
    WHERE nsp.nspname = 'public'
      AND rel.relname = 'admin_login_events'
      AND con.contype = 'c'
      AND pg_get_constraintdef(con.oid) LIKE '%outcome%';

    IF v_constraint IS NOT NULL THEN
        EXECUTE format('ALTER TABLE public.admin_login_events DROP CONSTRAINT %I', v_constraint);
    END IF;
END $$;

ALTER TABLE public.admin_login_events
    ADD CONSTRAINT admin_login_events_outcome_check CHECK (
        outcome IN (
            'Success',
            'Blocked_NoAdminRole',
            'Blocked_NoMFA',
            'Blocked_Suspended',
            'Blocked_WrongSurface',
            'Blocked_PendingApproval',
            'Passkey_Success',
            'Passkey_Failed',
            'RecoveryCode_Used',
            'New_Device_Detected',
            'Invite_Activated',
            'Failed'
        )
    );

-- ==============================================================================
-- 5. STRICT RLS (SERVER SERVICE_ROLE ACCESS ONLY)
-- ==============================================================================
ALTER TABLE public.admin_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_passkeys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.webauthn_challenges ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- 6. PERMISSIONS & INTERNAL BRANCHES ALIGNMENT
-- ==============================================================================
INSERT INTO public.permissions (permission_key, domain, risk_tier, requires_step_up, requires_maker_checker, description)
VALUES
    ('admin.invite', 'IAM', 'Critical', TRUE, FALSE, 'Create, resend, revoke, and approve internal admin invitations')
ON CONFLICT (permission_key) DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_key, branch_scoped)
VALUES ('00000000-0000-4000-8000-000000000001'::uuid, 'admin.invite', FALSE)
ON CONFLICT DO NOTHING;

-- Additive internal operational specialization branches from SKAVIA domain & SRS
INSERT INTO public.branches (name, code, description, is_active) VALUES
    ('SKAVIA Technical', 'TECH', 'Electrical installations, HVAC servicing, CCTV security, and networking', TRUE),
    ('SKAVIA Home', 'HOME', 'Residential plumbing, painting, carpentry, and interior solutions', TRUE),
    ('SKAVIA Corporate', 'CORP', 'Commercial turnkey renovations and enterprise facility contracts', TRUE),
    ('SKAVIA Agriculture', 'AGRI', 'Agri-machinery servicing, irrigation systems, and farm operations', TRUE),
    ('SKAVIA Logistics', 'LOGI', 'Fleet dispatch support, supply coordination, and field logistics', TRUE),
    ('SKAVIA Digital', 'DIGI', 'IT infrastructure, hardware deployment, POS setup, and smart systems', TRUE),
    ('SKAVIA Business', 'BIZ', 'SME commercial fit-outs, workspace equipment, and recurring maintenance', TRUE),
    ('SKAVIA Construction', 'CONS', 'Civil repair, masonry, fabrication, and structural renovation', TRUE),
    ('SKAVIA Events', 'EVNT', 'Stage rigging, AV sound/lighting setups, and event infrastructure', TRUE)
ON CONFLICT (code) DO NOTHING;

