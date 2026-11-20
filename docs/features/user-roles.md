# Feature: User Roles & Multi-Mode Profiles

## 1. Supported User Roles

1. **Customer Mode (`AppRoleMode.customer`):**  
   Tailored for home and personal service consumers. Surfaces immediate category discovery, urgent technician dispatch, order tracking, and escrow status.
2. **Worker Mode (`AppRoleMode.worker`):**  
   Tailored for skilled technicians. Surfaces nearby incoming dispatches, real-time Haversine distance to customer, job start/completion timers, and digital wallet earnings.
3. **Business Client Mode (`AppRoleMode.businessClient`):**  
   Tailored for facility managers and corporate clients. Surfaces multi-phase project tracking, milestone deliverables, team rosters, and invoice archives.

---

## 2. In-App Role Switching

Users switch modes dynamically via the unified profile menu (`ProfileMenuSection`) without logging out. The global `AppRoleMode` provider updates the dashboard scaffold instantly and persists the active mode to local storage.
