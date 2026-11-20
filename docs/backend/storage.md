# Storage Architecture & Bucket Policies

## 1. Storage Providers & Use Cases

SKAVIA utilizes two distinct object storage environments based on privacy and compliance requirements:

| Storage Provider | Bucket Name | Access Level | Asset Types |
| :--- | :--- | :--- | :--- |
| **Firebase Cloud Storage** | `avatars` | Public Read, Authenticated Write | User profile photos, service category thumbnails. |
| **Firebase Cloud Storage** | `work_proofs` | Authenticated Read (Order Participants only) | Before-and-after work completion photos, technician field evidence. |
| **Firebase Cloud Storage** | `verification_docs` | Private (Admin Only) | National ID (NID) scans, trade certifications, and background checks. |
| **Supabase Private Storage** | `app-releases` | Authenticated / Signed URL Stream | Production Android APK binaries, release signature manifests. |

---

## 2. Storage Upload & Verification Flow

1. **Client Pre-Processing:** Images captured in the app are automatically compressed and resized via `ImageCropResizeScreen` before upload to conserve mobile bandwidth.
2. **File Validation:** The server strictly checks MIME types (`image/jpeg`, `image/png`, `application/pdf`) and enforces a maximum file size of 5 MB per document.
3. **Encrypted Access:** Verification documents are accessed only via time-limited signed URLs generated on-demand by the Admin Web API.
