# Supabase Integration & Stored Procedures

## 1. PostgREST & Realtime Architecture

SKAVIA communicates with PostgreSQL via:
1. **Typed PostgREST Client:** Performs relational filtering, joins, and pagination over HTTPS.
2. **PostgreSQL Change Data Capture (CDC) via WebSockets:** Real-time channels for instant dispatch alerts, live chat messages, and order status updates.

---

## 2. Key Atomic Stored Procedures (RPC)

Financial and security-critical state transitions execute exclusively through atomic PostgreSQL functions:

### A. `verify_arrival_otp`
```sql
CREATE OR REPLACE FUNCTION verify_arrival_otp(
  p_order_id UUID,
  p_input_otp VARCHAR(4)
) RETURNS BOOLEAN AS $$
DECLARE
  v_correct_otp VARCHAR(4);
BEGIN
  SELECT arrival_otp INTO v_correct_otp
  FROM service_requests
  WHERE id = p_order_id AND status = 'accepted';

  IF v_correct_otp = p_input_otp THEN
    UPDATE service_requests
    SET status = 'in_progress', arrival_verified_at = NOW()
    WHERE id = p_order_id;
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### B. `release_escrow_settlement`
```sql
CREATE OR REPLACE FUNCTION release_escrow_settlement(
  p_order_id UUID
) RETURNS VOID AS $$
DECLARE
  v_escrow_amount NUMERIC;
  v_worker_id UUID;
  v_worker_share NUMERIC;
  v_platform_share NUMERIC;
BEGIN
  -- Lock escrow row to prevent race conditions
  SELECT amount, worker_id INTO v_escrow_amount, v_worker_id
  FROM escrow_accounts
  WHERE order_id = p_order_id AND status = 'held'
  FOR UPDATE;

  v_worker_share := v_escrow_amount * 0.90;
  v_platform_share := v_escrow_amount * 0.10;

  UPDATE escrow_accounts SET status = 'released', settled_at = NOW() WHERE order_id = p_order_id;
  INSERT INTO worker_earnings (worker_id, order_id, amount, status) VALUES (v_worker_id, p_order_id, v_worker_share, 'available');
  UPDATE service_requests SET status = 'completed' WHERE id = p_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```
