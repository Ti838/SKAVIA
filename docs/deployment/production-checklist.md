# Production Deployment Pre-Flight Checklist

Before deploying updates to production, verify every checkpoint below:

### 1. Security & Secrets
- [ ] No server secret keys (e.g. `SUPABASE_SERVICE_ROLE_KEY`) exist in mobile source code.
- [ ] Database RLS is enabled and active on all 58 PostgreSQL tables.
- [ ] WebAuthn / Passkey relying party ID is configured for the production domain.
- [ ] SSLCommerz IPN endpoint is configured with IP whitelist verification.

### 2. Mobile App Quality
- [ ] `dart analyze --fatal-infos` exits with code 0 (zero errors, zero warnings).
- [ ] All 182 Flutter unit & widget tests pass cleanly (`flutter test`).
- [ ] Release APK is signed with production release keystore.
- [ ] SHA-256 hash matches the database release manifest.
- [ ] Small screen (320dp) and 2.0x font scaling checked with zero RenderFlex overflow.

### 3. Web & Distribution Quality
- [ ] `npm run lint` passes with `--max-warnings=0`.
- [ ] `npm run typecheck` passes with zero errors.
- [ ] All 43 Vitest tests pass cleanly.
- [ ] Production build succeeds (`next build`).
- [ ] Google Fonts loads without run-time failure on Vercel.
