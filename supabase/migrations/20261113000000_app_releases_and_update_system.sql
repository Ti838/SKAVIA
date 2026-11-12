-- ==============================================================================
-- SKAVIA PRODUCTION APP RELEASE MANAGEMENT & APK DISTRIBUTION SCHEMA
-- Additive, non-destructive migration creating:
--   1. public.app_releases (immutable release history & lifecycle pointers)
--   2. public.app_release_events (real client update check & install telemetry)
--   3. storage.buckets 'app-releases' (private bucket; gated server download)
--   4. Super Admin RBAC permissions ('release.view', 'release.manage', 'release.publish')
-- ==============================================================================

-- 1. APP RELEASES REGISTRY
CREATE TABLE IF NOT EXISTS public.app_releases (
    release_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    platform VARCHAR(20) NOT NULL DEFAULT 'android' CHECK (platform IN ('android', 'ios')),
    channel VARCHAR(20) NOT NULL DEFAULT 'stable' CHECK (channel IN ('stable', 'beta', 'internal')),
    package_name VARCHAR(150) NOT NULL,
    version_name VARCHAR(60) NOT NULL,
    build_number INTEGER NOT NULL CHECK (build_number > 0),
    min_supported_build INTEGER NOT NULL CHECK (min_supported_build > 0 AND min_supported_build <= build_number),
    min_sdk_version INTEGER,
    target_sdk_version INTEGER,
    release_notes TEXT NOT NULL,
    is_mandatory BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (
        status IN ('draft', 'validated', 'published', 'suspended', 'archived')
    ),
    is_current BOOLEAN NOT NULL DEFAULT FALSE,
    storage_bucket VARCHAR(80) NOT NULL DEFAULT 'app-releases',
    storage_path TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_size_bytes BIGINT NOT NULL CHECK (file_size_bytes > 0),
    sha256_checksum VARCHAR(64) NOT NULL,
    signing_cert_sha256 VARCHAR(64),
    signing_schemes TEXT[] NOT NULL DEFAULT '{}',
    notify_users BOOLEAN NOT NULL DEFAULT TRUE,
    notifications_dispatched_at TIMESTAMPTZ,
    rolled_back_from_release_id UUID REFERENCES public.app_releases(release_id) ON DELETE SET NULL,
    suspension_reason TEXT,
    created_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    validated_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    published_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    validated_at TIMESTAMPTZ,
    published_at TIMESTAMPTZ,
    suspended_at TIMESTAMPTZ,
    archived_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_app_releases_platform_channel_build UNIQUE (platform, channel, build_number)
);

-- Enforce at most one active current release per (platform, channel)
CREATE UNIQUE INDEX IF NOT EXISTS idx_app_releases_current_channel
    ON public.app_releases(platform, channel)
    WHERE is_current = TRUE AND status = 'published';

CREATE INDEX IF NOT EXISTS idx_app_releases_lookup
    ON public.app_releases(platform, channel, status, build_number DESC);

CREATE INDEX IF NOT EXISTS idx_app_releases_sha256
    ON public.app_releases(sha256_checksum);

-- 2. REAL CLIENT RELEASE TELEMETRY (CHECK-INS, DOWNLOADS, CHECKSUM & INSTALL HANDOFF)
CREATE TABLE IF NOT EXISTS public.app_release_events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    release_id UUID REFERENCES public.app_releases(release_id) ON DELETE SET NULL,
    platform VARCHAR(20) NOT NULL DEFAULT 'android',
    channel VARCHAR(20) NOT NULL DEFAULT 'stable',
    installed_build INTEGER,
    installed_version VARCHAR(60),
    target_build INTEGER,
    event_type VARCHAR(40) NOT NULL CHECK (
        event_type IN (
            'update_check',
            'download_started',
            'download_completed',
            'checksum_verified',
            'checksum_failed',
            'installer_launched',
            'install_failed',
            'app_active'
        )
    ),
    device_fingerprint_hash VARCHAR(64),
    android_api_level INTEGER,
    user_id TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_release_events_release_type
    ON public.app_release_events(release_id, event_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_app_release_events_channel_created
    ON public.app_release_events(platform, channel, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_app_release_events_installed_build
    ON public.app_release_events(installed_build, created_at DESC);

-- 3. STRICT RLS (ALL READS/WRITES GO THROUGH VALIDATED SERVER SERVICE_ROLE APIS)
ALTER TABLE public.app_releases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_release_events ENABLE ROW LEVEL SECURITY;

-- 4. PRIVATE APK STORAGE BUCKET (NEVER EXPOSE DRAFTS OR SUSPENDED APKS PUBLICLY)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'app-releases',
    'app-releases',
    FALSE,
    157286400,
    ARRAY['application/vnd.android.package-archive', 'application/octet-stream']
)
ON CONFLICT (id) DO NOTHING;

-- 5. RBAC PERMISSIONS FOR SUPER ADMIN RELEASE GOVERNANCE
INSERT INTO public.permissions (
    permission_key,
    domain,
    risk_tier,
    requires_step_up,
    requires_maker_checker,
    description
) VALUES
    ('release.view', 'Release', 'Medium', FALSE, FALSE, 'View app release dashboard, checksums, signing certificates, and telemetry'),
    ('release.manage', 'Release', 'Critical', TRUE, FALSE, 'Upload, inspect, validate, and draft Android APK releases'),
    ('release.publish', 'Release', 'Critical', TRUE, FALSE, 'Publish, suspend, rollback, archive, and pin signing keys for releases')
ON CONFLICT (permission_key) DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_key, branch_scoped)
SELECT '00000000-0000-4000-8000-000000000001'::uuid, permission_key, FALSE
FROM public.permissions
WHERE permission_key IN ('release.view', 'release.manage', 'release.publish')
ON CONFLICT DO NOTHING;

