# API Reference & Endpoint Catalog

## 1. Public Release & Distribution Endpoints (`admin-web`)

### `GET /api/public/distribution`
- **Description:** Returns the active official Android release metadata, download URLs, SHA-256 hashes, and release notes.
- **Response Example:**
  ```json
  {
    "android": {
      "version": "1.0.0",
      "versionCode": 1,
      "apkUrl": "/downloads/skavia-v1.0.0-arm64-v8a.apk",
      "armv7Url": "/downloads/skavia-v1.0.0-armeabi-v7a.apk",
      "sha256Checksum": "c2ff57a1c6c6b64f1f52ecff435419bb63353486e4940cdb853b04b64ec365e3",
      "isMandatory": false,
      "publishedAt": "2026-11-20T12:00:00.000Z"
    }
  }
  ```

### `GET /api/public/releases/[releaseId]/download`
- **Description:** Streams the verified Android APK binary with appropriate `Content-Disposition` and `application/vnd.android.package-archive` MIME headers.

---

## 2. Admin Web Internal Endpoints

All admin endpoints require an authenticated admin session cookie or signed bearer token:

- `GET /api/admin/verifications`: Retrieves pending worker KYC submissions.
- `POST /api/admin/verifications/[id]/decision`: Approves or rejects a worker's trade application with feedback.
- `GET /api/admin/disputes`: Lists escalated complaints requiring operational mediation.
- `POST /api/admin/disputes/[id]/resolve`: Issues binding escrow refund or payout resolution.
- `GET /api/admin/releases`: Lists full history of uploaded releases, drafts, and rollout rings.
