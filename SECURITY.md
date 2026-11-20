# Security Policy

## 1. Supported Versions

Security updates and vulnerability remediation are actively maintained for the following versions:

| Version | Status | Supported Until |
| :--- | :--- | :--- |
| `1.0.x` | ✅ Active (Current Production) | Ongoing |
| `< 1.0.0` | ❌ Discontinued | N/A |

---

## 2. Reporting a Vulnerability

Security is a fundamental priority for the SKAVIA ecosystem. If you discover a potential security vulnerability, security loophole, or authorization flaw within SKAVIA Mobile (`lib/`), Backend PostgreSQL RLS Policies (`supabase/`), or Web Administration Surfaces (`admin-web/`), please report it privately.

> [!IMPORTANT]
> **Do not open public GitHub issues or public discussions for suspected security vulnerabilities.**

### Responsible Disclosure Protocol

1. **Direct Communication:**  
   Submit details of the finding directly to the independent author via GitHub Security Advisory or direct message:
   - **Repository:** [https://github.com/Ti838/SKAVIA/security/advisories](https://github.com/Ti838/SKAVIA/security/advisories)
   - **Developer Identity:** Timon Biswas (GitHub: [@Ti838](https://github.com/Ti838))
2. **Information to Include:**
   - Detailed description of the vulnerability.
   - Attack vector, severity rating, and potential business/privacy impact.
   - Minimal reproduction steps, proof-of-concept (PoC) scripts, or HTTP payload traces.
   - Affected components (`Mobile Client`, `Supabase RPC / RLS`, `admin-web API / Passkey Auth`).
3. **Acknowledgment & Remediation Timeline:**
   - **Initial Response:** Within 48 hours of receipt.
   - **Triage & Assessment:** Within 5 business days.
   - **Patch Release:** Coordinated disclosure after deployment of a verified hotfix.

---

## 3. Core Security Principles & Boundaries

The SKAVIA codebase adheres strictly to the following security architectures:
- **Zero-Trust Client Boundary:** The client mobile app is considered untrusted. All authorizations and state transitions are enforced strictly in PostgreSQL via Row-Level Security (RLS) and stored procedures.
- **No Unsafe Cryptographic Storage:** Sensitive tokens and credentials must reside in `flutter_secure_storage` (Android EncryptedSharedPreferences / KeyStore) rather than unencrypted shared preferences.
- **Strict Network Pinning:** Edge communications require HTTPS TLS 1.3 with SHA-256 binary validation on updates.
- **Privacy Telemetry Isolation:** Zero IMEI, zero phone serial numbers, and zero exact GPS coordinates are collected during device diagnostics.
