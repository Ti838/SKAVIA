# Feature: Dual-Language Architecture & Localization

## 1. Bilingual Support (English & Bengali)

The SKAVIA platform provides complete, native localization in both English (`en`) and Bengali (`bn`) across:
- All mobile screens, widgets, buttons, and error feedback.
- Date, time, and currency formatters (e.g., Bengali numeral and date styles `bn-BD`).
- Public website landing pages and download telemetry cards.

---

## 2. In-App Language Toggling

- Controlled via `AppLanguageService` and `AppLocaleScope`.
- Instantly switchable from the Settings screen without requiring an application restart.
- Persisted to local device storage to remember user preference across sessions.
