-- ==============================================================================
-- PART 07: APP RELEASES, APK DISTRIBUTION & OTA TELEMETRY
-- Domain: Production Release Registry, Checksum Verification & Install Telemetry
-- Consumers: Admin Web Releases Console + Flutter In-App Updater + Public Website
-- ==============================================================================

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

-- Private APK Storage Bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'app-releases',
    'app-releases',
    FALSE,
    157286400,
    ARRAY['application/vnd.android.package-archive', 'application/octet-stream']
)
ON CONFLICT (id) DO UPDATE SET
    public = FALSE,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;
