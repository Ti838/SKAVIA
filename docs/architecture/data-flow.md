# Data Flow & Lifecycle Management

## 1. End-to-End Service Fulfillment Data Flow

The diagram below traces the end-to-end data lifecycle from order creation through dispatch, arrival handshake, and escrow financial settlement:

```mermaid
sequenceDiagram
    autonumber
    actor Customer as 👤 Customer
    participant App as 📱 Mobile App
    participant DB as ☁️ Supabase PostgreSQL
    actor Worker as 🔧 Worker
    participant Payment as 💳 SSLCommerz Gateway

    Customer->>App: Discovers Service & Confirms Booking
    App->>Payment: Redirect to SSLCommerz Checkout
    Customer->>Payment: Authorizes bKash / Card Payment
    Payment-->>DB: Server-to-Server IPN (Payment Verified)
    DB->>DB: Lock Funds in escrow_accounts (HOLD)
    DB->>DB: INSERT INTO service_requests (status: 'pending')

    DB-->>Worker: Realtime WSS: Dispatch Alert (Nearby Worker Radar)
    Worker->>App: Accepts Request
    App->>DB: UPDATE service_requests SET status = 'accepted', worker_id = ...
    DB-->>Customer: Realtime WSS: Worker Assigned & En Route

    Note over Customer,Worker: Physical Arrival Handshake
    Customer->>App: Views Generated 4-Digit Arrival OTP
    Worker->>App: Enters Customer's 4-Digit OTP on Arrival
    App->>DB: RPC verify_arrival_otp(order_id, otp)
    DB->>DB: UPDATE status = 'in_progress', arrival_timestamp = NOW()
    DB-->>Customer: Alert: Job Officially Started

    Note over Worker,Customer: Job Execution & Completion
    Worker->>App: Uploads Completion Proof & Marks Done
    App->>DB: UPDATE status = 'completed'
    Customer->>App: Reviews Work & Approves Completion
    Customer->>DB: Approve Completion
    DB->>DB: RPC release_escrow_settlement(order_id)
    DB->>DB: Credit worker_earnings (90%), Credit platform_fee (10%)
    DB-->>Worker: Wallet Updated & Ready for Withdrawal
```

---

## 2. Offline Resilience & Sync Queue

For field specialists operating in areas with intermittent cellular connectivity:
1. **Local Action Queuing:** Critical actions (such as status updates or notes) are appended to a persistent local SQLite/Preferences sync queue (`OfflineSyncQueue`).
2. **Network State Monitoring:** The app listens to `connectivity_plus` streams.
3. **Automatic Replay:** Once an active IP connection is restored, pending actions are sequentially replayed with idempotency keys (`dedupKey`), preventing duplicate database writes.
