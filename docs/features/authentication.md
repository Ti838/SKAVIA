# Feature: Authentication & Onboarding

## 1. Overview

The `authentication` module provides user identity lifecycle management:
- **Phone Number SMS OTP:** Secure 6-digit OTP delivery via Firebase Auth.
- **Google Sign-In:** One-tap OAuth integration.
- **Terms & Privacy Consent:** Explicit opt-in checkbox before account creation (`AuthTermsCheckbox`).
- **Dynamic Role Selection:** Interactive role picker with explanatory feature cards (`RoleOptionCard`).

---

## 2. Component Decomposition

- `LoginScreen` (`lib/features/authentication/presentation/screens/login_screen.dart`): Primary entrance.
- `RegisterScreen` (`lib/features/authentication/presentation/screens/register_screen.dart`): User registration with name, phone, and password inputs (`RegistrationFormFields`).
- `OtpVerificationScreen` (`lib/features/authentication/presentation/screens/otp_verification_screen.dart`): 6-digit pin input with auto-paste and resend countdown timer (`OtpPinInputRow`).
- `RoleSelectionScreen` (`lib/features/authentication/presentation/screens/role_selection_screen.dart`): Role cards for Customer, Specialist (Worker), and Business Client.
