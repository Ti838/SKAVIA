-- ==============================================================================
-- SKAVIA PLATFORM — COMPREHENSIVE STAGING SECURITY REMEDIATION MIGRATION
-- Migration Name: 20261012195500_harden_security_and_settlement.sql
-- Target: Staging Review & Manual Verification (Zero Destructive Drops)
-- Compliance: OWASP Top 10 API, PostgreSQL 15 RLS, SSLCommerz Backend Settlement
-- ==============================================================================

-- ==============================================================================
-- SECTION 1: PUBLIC.USERS PRIVACY HARDENING
-- ==============================================================================
-- 1. Ensure RLS is active on public.users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 2. Drop previously verified permissive SELECT policies
DROP POLICY IF EXISTS "Users Read Access" ON public.users;
DROP POLICY IF EXISTS "Users Owner Read Access" ON public.users;
DROP POLICY IF EXISTS "Users Authenticated Read Access" ON public.users;

-- 3. Enforce Strict Owner-Only SELECT: Authenticated user can ONLY read their own record
CREATE POLICY "Users Owner Read Access"
ON public.users
FOR SELECT
TO authenticated
USING (auth.uid()::text = user_id);

-- 4. Enforce Strict Owner-Only INSERT: User can only insert row matching their auth.uid()
DROP POLICY IF EXISTS "Users Insert Access" ON public.users;
CREATE POLICY "Users Insert Access"
ON public.users
FOR INSERT
TO authenticated
WITH CHECK (auth.uid()::text = user_id);

-- 5. Enforce Strict Owner-Only UPDATE: Cannot modify another user's row or reassign user_id
DROP POLICY IF EXISTS "Users Update Access" ON public.users;
CREATE POLICY "Users Update Access"
ON public.users
FOR UPDATE
TO authenticated
USING (auth.uid()::text = user_id)
WITH CHECK (auth.uid()::text = user_id);

-- 6. Defense-in-depth: Revoke all table-level privileges from anonymous unauthenticated role
REVOKE ALL ON TABLE public.users FROM anon;
GRANT SELECT, INSERT, UPDATE ON TABLE public.users TO authenticated;


-- ==============================================================================
-- SECTION 2: SECURE PUBLIC MARKETPLACE DIRECTORY VIEW (Zero PII Exposure)
-- ==============================================================================
-- Creates non-PII marketplace discovery view using CREATE OR REPLACE to preserve object references.
-- Projects exclusively approved public fields. Excludes phone, email, credentials, and financial metadata.
CREATE OR REPLACE VIEW public.marketplace_public_profiles AS
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
    wp.is_available
FROM public.worker_profiles wp
JOIN public.users u ON u.user_id = wp.user_id
WHERE wp.is_available = TRUE
  AND u.status = 'Active';

-- Grant SELECT explicitly to anonymous visitors and authenticated clients
GRANT SELECT ON public.marketplace_public_profiles TO anon, authenticated;


-- 7. Hardened Uniqueness Constraint on Invoices to guarantee single-invoice per payment
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uq_invoices_payment_id'
    ) THEN
        ALTER TABLE public.invoices ADD CONSTRAINT uq_invoices_payment_id UNIQUE (payment_id);
    END IF;
END $$;

-- 8. Hardened Uniqueness Constraint on Worker Earnings to guarantee single earning per payment
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uq_worker_earnings_payment_id'
    ) THEN
        ALTER TABLE public.worker_earnings ADD CONSTRAINT uq_worker_earnings_payment_id UNIQUE (payment_id);
    END IF;
END $$;


-- ==============================================================================
-- SECTION 3: REBUILD PAYMENT SETTLEMENT RPC (Backend-Only Atomic Settlement)
-- ==============================================================================
-- Drop previous versions to avoid signature ambiguity
DROP FUNCTION IF EXISTS public.complete_payment_transaction(UUID, VARCHAR, VARCHAR, VARCHAR, DECIMAL, DECIMAL, DECIMAL, UUID);

-- Create hardened, ACID atomic payment completion function
-- SECURITY DEFINER: Executes with definer privileges to update payment, invoice, and earnings
-- Hardened search_path: strictly pinned to pg_catalog, public to prevent schema hijacking
CREATE OR REPLACE FUNCTION public.complete_payment_transaction(
    p_payment_id UUID,
    p_gateway_name VARCHAR,
    p_gateway_tx_id VARCHAR,
    p_val_id VARCHAR DEFAULT NULL,
    p_verified_amount DECIMAL DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_payment RECORD;
    v_invoice_number VARCHAR;
    v_invoice_id UUID;
    v_tx_id UUID;
    v_earning_id UUID;
    v_worker_amount DECIMAL(10, 2);
    v_worker_profile_id UUID;
    v_now TIMESTAMP WITH TIME ZONE := NOW();
BEGIN
    -- 1. CONCURRENCY-SAFE ROW LOCK & VALIDATION
    -- Lock payment record exclusively to prevent race conditions & duplicate settlements
    SELECT 
        p.payment_id,
        p.service_request_id,
        p.project_id,
        p.client_id,
        p.total_amount,
        p.skavia_fee,
        p.status,
        u.full_name AS client_name
    INTO v_payment
    FROM public.payments p
    LEFT JOIN public.users u ON u.user_id = p.client_id
    WHERE p.payment_id = p_payment_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error_code', 'PAYMENT_NOT_FOUND',
            'message', 'Payment record does not exist.'
        );
    END IF;

    -- 2. IDEMPOTENCY CHECK: If already settled, return success without duplicate entries
    IF v_payment.status = 'Completed' THEN
        RETURN jsonb_build_object(
            'success', true,
            'idempotent', true,
            'payment_id', p_payment_id,
            'status', 'Completed',
            'message', 'Payment was already settled previously. Duplicate request safely ignored.'
        );
    END IF;

    -- Only Pending payments can transition to Completed
    IF v_payment.status != 'Pending' THEN
        RETURN jsonb_build_object(
            'success', false,
            'error_code', 'INVALID_PAYMENT_STATE',
            'message', 'Payment is in state ' || v_payment.status || ' and cannot be completed.'
        );
    END IF;

    -- 3. AMOUNT INTEGRITY CHECK: Backend verified amount must match expected total_amount
    IF p_verified_amount IS NOT NULL AND v_payment.total_amount != p_verified_amount THEN
        RETURN jsonb_build_object(
            'success', false,
            'error_code', 'AMOUNT_MISMATCH',
            'message', 'Gateway verified amount does not match database record.'
        );
    END IF;

    -- 4. DERIVE WORKER AMOUNT & PROFILE FROM DATABASE (Never trust client)
    v_worker_amount := v_payment.total_amount - v_payment.skavia_fee;

    -- Resolve worker_profile_id if associated with a service_request
    IF v_payment.service_request_id IS NOT NULL THEN
        SELECT worker_profile_id INTO v_worker_profile_id
        FROM public.service_requests
        WHERE service_request_id = v_payment.service_request_id;
    END IF;

    -- 5. UPDATE PAYMENT STATUS TO COMPLETED
    UPDATE public.payments
    SET status = 'Completed',
        paid_at = v_now
    WHERE payment_id = p_payment_id;

    -- 6. RECORD AUDIT TRANSACTION
    INSERT INTO public.transactions (
        payment_id,
        gateway_name,
        gateway_tx_id,
        amount,
        status,
        created_at
    )
    VALUES (
        p_payment_id,
        p_gateway_name,
        p_gateway_tx_id,
        v_payment.total_amount,
        'Completed',
        v_now
    )
    RETURNING transaction_id INTO v_tx_id;

    -- 7. GENERATE DETERMINISTIC UNIQUE INVOICE NUMBER
    -- Format: INV-YYYYMM-<epoch_sub>-<random_hex>
    v_invoice_number := 'INV-' || TO_CHAR(v_now, 'YYYYMM') || '-' || 
                        LPAD((EXTRACT(EPOCH FROM v_now)::BIGINT % 1000000)::TEXT, 6, '0') || '-' || 
                        SUBSTRING(MD5(p_payment_id::TEXT || v_now::TEXT) FROM 1 FOR 4);

    -- 8. RECORD INVOICE
    INSERT INTO public.invoices (
        payment_id,
        invoice_number,
        client_name,
        worker_amount,
        skavia_fee,
        total_amount,
        issued_at
    )
    VALUES (
        p_payment_id,
        v_invoice_number,
        COALESCE(v_payment.client_name, 'SKAVIA Customer'),
        v_worker_amount,
        v_payment.skavia_fee,
        v_payment.total_amount,
        v_now
    )
    RETURNING invoice_id INTO v_invoice_id;

    -- 9. CREDIT WORKER WALLET IF APPLICABLE
    IF v_worker_profile_id IS NOT NULL THEN
        INSERT INTO public.worker_earnings (
            worker_profile_id,
            payment_id,
            amount,
            status,
            created_at
        )
        VALUES (
            v_worker_profile_id,
            p_payment_id,
            v_worker_amount,
            'Available',
            v_now
        )
        RETURNING earning_id INTO v_earning_id;
    END IF;

    -- 10. RETURN STRUCTURED RESULT
    RETURN jsonb_build_object(
        'success', true,
        'idempotent', false,
        'payment_id', p_payment_id,
        'invoice_id', v_invoice_id,
        'invoice_number', v_invoice_number,
        'transaction_id', v_tx_id,
        'earning_id', v_earning_id,
        'status', 'Completed',
        'paid_at', v_now
    );
END;
$$;

-- 11. PRIVILEGE ENFORCEMENT: Strip execution from ALL untrusted roles
REVOKE ALL ON FUNCTION public.complete_payment_transaction(UUID, VARCHAR, VARCHAR, VARCHAR, DECIMAL) FROM PUBLIC, anon, authenticated;

-- Grant execution SOLELY to service_role (Trusted backend Edge Function)
GRANT EXECUTE ON FUNCTION public.complete_payment_transaction(UUID, VARCHAR, VARCHAR, VARCHAR, DECIMAL) TO service_role;


-- ==============================================================================
-- SECTION 4: HARDEN KYC / VERIFICATIONS STORAGE BUCKET
-- ==============================================================================
-- Ensure verifications bucket is strictly private
UPDATE storage.buckets SET public = FALSE WHERE id = 'verifications';

-- Drop previous storage verification policies
DROP POLICY IF EXISTS "Public Read Verifications" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload Verifications" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Worker Upload Verifications" ON storage.objects;
DROP POLICY IF EXISTS "Owner Read Verifications" ON storage.objects;

-- Restricted upload: Only authenticated user uploading into folder matching their auth.uid()
CREATE POLICY "Authenticated Worker Upload Verifications"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'verifications' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Restricted read: Only owner can read files under their own auth.uid() folder
CREATE POLICY "Owner Read Verifications"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'verifications' AND
    (storage.foldername(name))[1] = auth.uid()::text
);
