# Authentication Architecture & Identity Flow

## 1. Multi-Provider Hybrid Authentication

SKAVIA implements a secure, hybrid identity architecture combining **Firebase Authentication** (for frictionless cellular SMS OTP and Google Sign-In) with **Supabase PostgreSQL Identity** (for authoritative Row-Level Security, user roles, and profile storage).

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 Mobile User
    participant Flutter as 📱 SKAVIA App
    participant Firebase as 🔥 Firebase Auth
    participant Supabase as ☁️ Supabase Cloud (PostgreSQL)

    User->>Flutter: Enters Bangladesh Phone Number (+880...)
    Flutter->>Firebase: verifyPhoneNumber(phoneNumber)
    Firebase-->>User: Sends 6-Digit SMS OTP
    User->>Flutter: Inputs OTP
    Flutter->>Firebase: PhoneAuthProvider.credential(code)
    Firebase-->>Flutter: UserCredential (Firebase ID Token)

    rect rgb(240, 248, 255)
        Note over Flutter,Supabase: Handshake & Database Sync
        Flutter->>Supabase: Exchange Firebase Token / Query Profile (users table)
        alt User Exists in Database
            Supabase-->>Flutter: UserRecord (id, primary_role, status)
            Flutter->>Flutter: Cache Session in FlutterSecureStorage
            Flutter->>User: Route to MainScaffoldScreen (Dashboard)
        else First-Time User Registration
            Flutter->>User: Route to RoleSelectionScreen
            User->>Flutter: Selects Role (Customer / Worker / Business)
            Flutter->>Supabase: INSERT INTO users & user_roles
            Supabase-->>Flutter: Registration Confirmed
            Flutter->>User: Route to Profile Completion Wizard
        end
    end
```

---

## 2. Token Security & Storage Lifecycle

1. **Persistent Android Keystore Storage:**  
   Authentication session tokens, refresh tokens, and active user roles are stored securely via `FlutterSecureStorage` using Android's hardware-backed `EncryptedSharedPreferences` and AES-256 GCM encryption.
2. **Session Revocation & Sign-Out:**  
   Signing out invalidates local secure storage keys, clears cached user profiles from `shared_preferences`, and triggers `FirebaseAuth.instance.signOut()` to ensure clean session teardown.
3. **Web Administration Security (`admin-web`):**  
   Admins and Super Admins authenticate via WebAuthn/FIDO2 hardware passkeys or encrypted session cookies with HttpOnly, Secure, and SameSite=Strict attributes, preventing cross-site scripting (XSS) and token theft.
