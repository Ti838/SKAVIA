# Feature: Authentication & Onboarding

## 1. Overview

The `authentication` module provides complete user identity lifecycle management:
- **Dual-Channel Cloud OTP:** 6-digit numeric OTP generated via server-side HMAC-SHA256 challenge, delivered through **Mailjet SMTP** (transactional email) or cellular SMS gateways, with deterministic **Firebase Spark Bridge** authentication.
- **Google Sign-In:** One-tap OAuth integration with automatic Supabase account synchronization.
- **Email & Password Authentication:** Standard direct credentials sign-up and sign-in.
- **Terms & Privacy Consent:** Explicit opt-in checkbox before account creation (`AuthTermsCheckbox`).
- **Dynamic Role Selection:** Interactive role picker with explanatory feature cards for Customer, Specialist (Worker), and Business Client.
- **Delivery Channel Awareness:** Informs users in real-time whether the OTP was dispatched via Email or SMS, with built-in 30-second cooldown and 5-minute expiry timers.

---

## 2. Component Decomposition

- `LoginScreen` (`lib/features/authentication/presentation/screens/login_screen.dart`): Primary entrance with Phone, Email, and Google authentication tabs.
- `PhoneLoginForm` (`lib/features/authentication/presentation/widgets/phone_login_form.dart`): Form accepting a Bangladesh mobile number with optional email delivery input.
- `RegisterScreen` (`lib/features/authentication/presentation/screens/register_screen.dart`): User registration with name, phone, and password inputs (`RegistrationFormFields`).
- `OtpVerificationScreen` (`lib/features/authentication/presentation/screens/otp_verification_screen.dart`): 6-digit pin input with auto-paste, resend countdown timer, and dynamic delivery badge (Email vs SMS).
- `RoleSelectionScreen` (`lib/features/authentication/presentation/screens/role_selection_screen.dart`): Role cards for Customer, Specialist (Worker), and Business Client.
- `AuthRemoteDataSource` (`lib/features/authentication/data/datasources/auth_remote_datasource.dart`): Central orchestrator connecting client Flutter code with the SKAVIA Cloud OTP API, Firebase Auth, and Supabase PostgreSQL.
- `AuthController` (`lib/features/authentication/presentation/controllers/auth_controller.dart`): State controller managing loading states, error handling, OTP session IDs, and active session teardown.

---

## 3. Server-Side Identity Engine (`admin-web/`)

- `/api/public/auth/phone/send-otp`: Generates HMAC-SHA256 challenge, rate-limits requests, and dispatches OTP via Mailjet SMTP or SMS provider.
- `/api/public/auth/phone/verify-otp`: Validates 6-digit code against HMAC hash, guards against brute-force (max 5 attempts), and derives Firebase bridge credentials.
- `/api/public/auth/email/send-otp`: Standalone email OTP dispatch endpoint.
- `/api/public/auth/email/verify-otp`: Standalone email OTP verification endpoint.
- `/api/admin/invitations`: Super Admin invitation issuance with 32-byte cryptographic single-use tokens and Mailjet invitation email dispatch.
- `/api/public/invitations/verify`: Validates token hash, status, and expiry before displaying onboarding screen.
- `/api/public/invitations/activate`: Cryptographically binds Firebase ID token identity to the invited email, provisioning the `admin_profiles` record.
