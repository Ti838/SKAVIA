# Coding Guidelines & Architectural Standards

## 1. Core Principles

1. **Strict File Responsibility:** Never consolidate multiple unrelated features or entire feature lifecycles into a single file.
2. **Predictable File Sizing:**
   - Page screens: **100–250 lines**. Split sub-sections into widgets when responsibilities diverge.
   - Reusable widgets: **30–150 lines**.
   - Controllers/Services: **100–250 lines**.
3. **Zero Deprecation Policy:** Avoid deprecated methods (e.g., use `color.withValues(alpha: ...)` instead of `withOpacity()`).
4. **Zero Analyzer Warnings:** All code must pass `dart analyze --fatal-infos` with zero warnings or hints.

---

## 2. Layout & Responsive Constraints

To ensure compatibility across budget 320dp phones up to flagship tablets:
- **No Unconstrained Flex Rows:** Never place plain unconstrained text or expanding widgets inside an unconstrained horizontal `Row` without wrapping in `Flexible` or `Expanded`.
- **Text Truncation:** Always pair `maxLines: 1` with `overflow: TextOverflow.ellipsis` on single-line header labels.
- **Dynamic Text Scaling Test:** Every widget test must verify rendering with `textScaler: TextScaler.linear(1.5)` or `2.0` on a simulated `Size(320, 640)` screen.

---

## 3. Privacy & Security Rules

1. **Zero Device Serial / IMEI Query:** Never call native APIs that retrieve hardware serial numbers, IMEI, or IMSI.
2. **Zero Unsolicited GPS Logging:** Do not query GPS latitude/longitude during basic diagnostics; only inspect `isLocationServiceEnabled()` and permission grant states.
3. **No Hardcoded Server Secrets:** `SUPABASE_SERVICE_ROLE_KEY` and payment merchant credentials must never exist inside the Flutter client binary.
