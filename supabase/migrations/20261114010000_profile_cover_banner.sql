-- ==============================================================================
-- SKAVIA PROFILE COVER BANNER COLUMN (ADDITIVE / NON-DESTRUCTIVE)
-- Adds dedicated cover_url column to public.users for Facebook-style profile banners.
-- ==============================================================================

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS cover_url TEXT;

