# Authentication Architecture & Identity Flow

## 1. Multi-Provider Hybrid Authentication

SKAVIA implements an accountable, zero-cost hybrid identity architecture combining **Cloud OTP Engine with Mailjet SMTP / Multi-Provider SMS**, **Firebase Authentication Bridge** (for client sessions without costly Firebase Blaze plans), and **Supabase PostgreSQL Identity** (for authoritative Row-Level Security, RBAC roles, and operational profile storage).

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 App User / Admin
    participant Flutter as 📱 SKAVIA App / Web
    participant ApiServer as ⚙️ SKAVIA Server (Vercel)
    participant Mailjet as ✉️ Mailjet SMTP / SMS
    participant Supabase as ☁️ Supabase PostgreSQL
    participant Firebase as 🔥 Firebase Auth (Spark Bridge)

    %% Section 1: User Phone/Email OTP Authentication
    rect rgb(240, 248, 255)
        Note over User,Firebase: FLOW 1: User Phone & Email OTP Authentication
        User->>Flutter: Inputs BD Phone (+880...) + Optional Email
        Flutter->>ApiServer: POST /api/public/auth/phone/send-otp
        ApiServer->>ApiServer: Generate 6-Digit OTP + Compute HMAC-SHA256 Hash
        ApiServer->>Supabase: Save Challenge in user_sessions (device_id, ip_address, 5m TTL)
        alt Mailjet SMTP Configured
            ApiServer->>Mailjet: Dispatch Branded OTP Email (HTML)
            Mailjet-->>User: Delivers 6-Digit OTP to Inbox
        else SMS Provider Configured
            ApiServer->>Mailjet: Dispatch SMS via BD Gateway
            Mailjet-->>User: Delivers SMS to SIM
        else In-App Demo Fallback (No Gateway/Email)
            ApiServer-->>Flutter: Return OTP in payload (Dev only)
        end
        ApiServer-->>Flutter: 200 OK (verificationId, deliveryChannel)
        User->>Flutter: Enters 6-Digit Code
        Flutter->>ApiServer: POST /api/public/auth/phone/verify-otp (code, verificationId)
        ApiServer->>ApiServer: Verify HMAC Hash + Rate Limit (max 5 attempts)
        ApiServer->>Supabase: Mark Challenge Session as Revoked (Single-Use)
        ApiServer->>ApiServer: Derive Deterministic Firebase Bridge Creds (HMAC)
        ApiServer-->>Flutter: 200 OK (bridgeEmail, bridgePassword, user info)
        Flutter->>Firebase: signInWithEmailAndPassword(bridgeEmail, bridgePassword)
        alt Account Not Yet Created in Firebase
            Firebase-->>Flutter: error: user-not-found
            Flutter->>Firebase: createUserWithEmailAndPassword(bridgeEmail, bridgePassword)
        end
        Firebase-->>Flutter: UserCredential (UID & Auth Tokens)
        Flutter->>Supabase: _syncUserToSupabase(UID, name, phone, role)
        Supabase-->>Flutter: Profile & Session Registered
        Flutter-->>User: Route to Dashboard (Client/Worker Mode)
    end

    %% Section 2: Admin One-Time Invitation & Activation
    rect rgb(255, 248, 240)
        Note over User,Firebase: FLOW 2: Internal Admin Invitation & Activation
        actor SuperAdmin as 👔 Super Admin
        SuperAdmin->>ApiServer: POST /api/admin/invitations (name, email, role, branches)
        ApiServer->>ApiServer: Generate 32-Byte Secure Token + Compute SHA-256 Hash
        ApiServer->>Supabase: INSERT INTO admin_invitations (token_hash, status: 'Invited')
        ApiServer->>Mailjet: sendAdminInvitationEmail(activationUrl, role, branches)
        Mailjet-->>User: Official Invitation Email Delivered
        User->>ApiServer: GET /api/public/invitations/verify?token=...
        ApiServer->>Supabase: Lookup by tokenHash -> Verify Expiry/Revocation -> Update status: 'Opened'
        ApiServer-->>User: Invitation Details (masked email, role, branches)
        User->>Flutter: Authenticate with Firebase (Google or Email)
        Flutter->>ApiServer: POST /api/public/invitations/activate (token, idToken)
        ApiServer->>Firebase: verifyFirebaseIdToken(idToken)
        ApiServer->>ApiServer: Verify Authenticated Email matches Invitation Email
        ApiServer->>Supabase: activateInvitedAdmin() -> INSERT INTO admin_profiles
        ApiServer->>Supabase: Record Audit Log (admin.invitation.activated)
        ApiServer-->>Flutter: 200 OK (status: Active / PendingApproval)
        Flutter-->>User: Access Granted to Internal Admin Portal
    end
```

---

## 2. Zero-Cost Phone OTP Architecture (The Bridge Pattern)

### A. The Challenge with Cellular SMS in Bangladesh
Direct SMS verification via Firebase Phone Auth requires a Google Cloud Blaze (credit card) billing plan and incurs recurring SMS per-message fees in Bangladesh (+880). 

### B. The SKAVIA Solution: Dual-Channel OTP + Bridge Credentials
1. **Server-Side Challenge (`issueOtpChallenge`):**
   - The user requests an OTP with their Bangladesh mobile number (`+8801[3-9]\d{8}`).
   - An optional email address can be supplied (or looked up from existing user records in Supabase).
   - A 6-digit numeric OTP is generated and hashed using **HMAC-SHA256** keyed by the server's `ADMIN_SESSION_SECRET`.
   - The hash and verification state are stored in `user_sessions` with synthetic key `otp_pending:<e164phone>` with a 5-minute TTL.
2. **Mailjet SMTP Email Delivery:**
   - Transactional emails are dispatched through Mailjet SMTP (`in-v3.mailjet.com:587`) using verified sender `SKAVIA Security <timonbiswas29@gmail.com>`.
   - Supports 300 free emails per day (9,000/month).
   - HTML template displays the 6-digit passcode, target phone number, and expiry alert.
3. **SMS Gateway Support (Plug-and-Play):**
   - Built-in multi-provider dispatch supports `BulkSMS BD`, `SSL Wireless`, `Greenweb`, and custom HTTP webhooks when configured in server environment variables.
4. **Deterministic Firebase Bridge:**
   - Upon verification (`verifyOtpChallenge`), the backend validates the code with brute-force lockout (maximum 5 attempts).
   - Once verified, the server derives deterministic bridge credentials via HMAC:
     - `bridgeEmail`: `phone_<digits>@skavia.internal`
     - `bridgePassword`: derived HMAC digest (minimum 32 characters, non-reconstructible by client)
   - The Flutter app authenticates to Firebase using standard Email/Password authentication on the free Spark plan, obtaining a genuine Firebase UID.
   - Flutter syncs the UID to Supabase (`_syncUserToSupabase`), ensuring unified identity across client and worker profiles.

---

## 3. Internal Admin Invitation & Activation Lifecycle

To prevent unauthorized administrative account creation, SKAVIA uses a single-use cryptographic invitation flow:

1. **Invitation Issuance (`POST /api/admin/invitations`):**
   - Only the **Primary Super Admin** (or users with `admin.invite` permission) can issue invitations.
   - A 32-byte cryptographically random token is generated.
   - The SHA-256 hash of the token is saved in `admin_invitations` alongside assigned branches, role, and expiry (default 24 hours).
   - Mailjet sends the invitation email containing a single-use activation URL (`https://admin.skavia.com/activate?token=...`).
2. **Verification (`GET /api/public/invitations/verify`):**
   - Validates that the token hash exists, is not expired, not revoked, and not already used.
   - Updates invitation status to `Opened`.
3. **Activation & Identity Binding (`POST /api/public/invitations/activate`):**
   - The invited administrator signs in via Google OAuth or Firebase Auth with their invited email.
   - The backend verifies the Firebase ID token cryptographically.
   - Confirms that the verified email matches the invitation email.
   - Consumes the single-use token and creates the authoritative record in `admin_profiles`.
   - Records an immutable audit log entry in `audit_logs`.

---

## 4. Token Security & Storage Lifecycle

1. **Persistent Mobile Keystore Storage:**  
   Session tokens and active user modes (`client` vs `worker`) are stored securely via `FlutterSecureStorage` using hardware-backed `EncryptedSharedPreferences` (AES-256 GCM) on Android and Keychain Services on iOS.
2. **Session Revocation & Clean Sign-Out:**  
   Signing out clears all static OTP cache parameters, invalidates `FlutterSecureStorage` tokens, and triggers both `FirebaseAuth.instance.signOut()` and `Supabase.instance.client.auth.signOut()`.
3. **Web Administration Security (`admin-web`):**  
   Admins and Super Admins authenticate via WebAuthn/FIDO2 hardware passkeys or encrypted session cookies with `HttpOnly`, `Secure`, and `SameSite=Strict` attributes, preventing XSS and CSRF token theft.
