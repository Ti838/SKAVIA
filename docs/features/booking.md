# Feature: Booking Lifecycle & Arrival Verification

## 1. 7-Stage Order Lifecycle

Every service order progresses through an immutable state machine:

```
pending ──> accepted ──> en_route ──> in_progress ──> completed ──> reviewed
   │            │           │              │
   └────────────┴───────────┴──────────────┴───────> cancelled / disputed
```

---

## 2. Cryptographic Arrival Handshake (OTP)

To eliminate fraudulent claims of worker visits:
1. Upon booking acceptance, the server generates a 4-digit numeric OTP stored encrypted in `service_requests.arrival_otp`.
2. The OTP is displayed exclusively on the customer's mobile screen.
3. Upon physical arrival at the customer's doorstep, the worker enters the OTP in the app.
4. Calling `verify_arrival_otp` validates the OTP in database memory and transitions status to `in_progress`.
5. Billable labor time is calculated strictly from `arrival_verified_at`.
