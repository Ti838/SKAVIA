# Row-Level Security (RLS) & Database Policies

## 1. Zero-Trust Security Model

Every single table in the SKAVIA database enforces `ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;`. No table allows public unauthenticated reads or unconstrained writes.

---

## 2. Typical Security Policies

### A. Customers Only Access Their Own Records
```sql
CREATE POLICY "Customers view own bookings"
ON service_requests FOR SELECT
TO authenticated
USING (customer_id = auth.uid());
```

### B. Workers View Assigned Dispatches or Open Pool
```sql
CREATE POLICY "Workers view assigned or open dispatches"
ON service_requests FOR SELECT
TO authenticated
USING (
  worker_id = auth.uid() OR
  (status = 'pending' AND branch_id IN (
    SELECT branch_id FROM worker_profiles WHERE user_id = auth.uid()
  ))
);
```

### C. Financial Ledgers Immutable from Client
```sql
-- Direct INSERT, UPDATE, or DELETE on escrow_accounts is blocked for standard authenticated users
CREATE POLICY "Prevent direct escrow modification"
ON escrow_accounts FOR ALL
TO authenticated
USING (FALSE);
-- Only service_role or SECURITY DEFINER RPC functions can mutate escrow
```
