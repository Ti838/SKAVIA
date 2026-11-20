# Troubleshooting & Developer FAQ

## 1. Common Flutter Issues & Solutions

### A. RenderFlex Overflow on Small Screens
- **Symptom:** Yellow-and-black striped overflow banner during layout testing on 320dp width.
- **Cause:** Placing `Text` or unconstrained widgets directly inside a horizontal `Row` without wrapping in `Flexible` or `Expanded`.
- **Solution:** Wrap the text in `Flexible` or `Expanded` and provide `maxLines: 1` with `overflow: TextOverflow.ellipsis`.

### B. Vercel Font Loading Crash (`next/font/google`)
- **Symptom:** Vercel deployment fails during build with `TypeError: Cannot read properties of null (reading '1')` in `@next/font/dist/google/loader.js`.
- **Cause:** Next.js font loader failing on specific Bengali Google Fonts kits.
- **Solution:** Use standard CSS `@import` in `admin-web/src/app/globals.css` instead of `next/font/google` loader.

### C. Android In-App Update Fails with `INSTALL_FAILED_UPDATE_INCOMPATIBLE`
- **Symptom:** Android OS displays "App not installed as package appears to be invalid".
- **Cause:** The installed app and downloaded APK were signed with different keystores (e.g., debug keystore vs release keystore).
- **Solution:** Ensure consistent signing certificate fingerprints across builds using `android/key.properties`.

---

## 2. Common Supabase & Database Issues

### A. RLS Policy Denies Read/Write
- **Symptom:** Supabase queries return empty results or `403 Forbidden`.
- **Cause:** The user's active JWT does not match the table's RLS policy conditions (e.g., `user_id = auth.uid()`).
- **Solution:** Verify that the user is authenticated and has the required `user_roles` record in the database.
