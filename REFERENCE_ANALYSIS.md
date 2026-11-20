# SKAVIA | Reference Reverse Engineering & Design System Specification

## 1. Executive Summary & Objective

This document defines the formal visual, architectural, and user-experience specification reverse-engineered from world-class industry benchmark platforms and design systems, mapped directly onto the **SKAVIA Service & Workforce Platform** digital ecosystem.

SKAVIA is a unified, single-enterprise accountable service and workforce platform operating across 8 internal specialization branches in Bangladesh. This specification establishes strict visual fidelity, responsive ergonomics, and complete separation across distinct product surfaces:
1. **Public Website (`www.skavia.com`)**: Exclusively customer-facing and visitor-facing; introduces SKAVIA's actual services, branches, accountability model, and verified operations, and guides visitors to the official Android mobile app; zero internal admin exposure.
2. **Company Admin Portal (`admin.skavia.com`)**: Internal operations, branch coordination, and field workforce supervision across all operational branches.
3. **Super Admin Portal (`superadmin.skavia.com`)**: Platform governance, administrator RBAC, cryptographic security, and APK release distribution.
4. **Branch Manager Scoped View**: Strictly isolated view within the Admin Portal restricted to the manager's assigned branch only.

---

## 2. Public Website Reference Reverse Engineering Analysis

### Reference 1: Taskrabbit (`https://www.taskrabbit.com/`)
- **Inspected Surfaces**: Homepage hero with search query bar, popular trade tiles, 4-step "How it Works" flow, category showcase.
- **Visual Characteristics**:
  - High-intent search input right in hero ("Need help with..."), visual category cards with real task examples (e.g. "AC Repair", "Furniture Assembly", "Plumbing Help"), trust badges (vetted background checks), upfront hourly/fixed pricing guidelines.
- **Why It Works**: Instantly bridges the gap between what the visitor needs and how quickly they can get someone to help. Eliminates ambiguity about what tasks can be done.
- **What SKAVIA Can Learn**: Add an interactive search/query bar in the hero that immediately filters or directs visitors to the 8 specialization branches and specific trade SOPs, along with quick-select popular trade pills.
- **SKAVIA Application**: Deployed in the **Public Hero & Trade Discovery**: interactive trade search input, quick-filter category pills (AC Service, Electrical, Plumbing, Cleaning, Renovation), and clear 4-step dispatch cards.
- **What Must NOT Be Copied**: Do NOT copy Taskrabbit's unmonitored freelance contractor model where clients directly message unvetted individuals. SKAVIA operates as a single accountable company with NID-verified specialists and mandatory arrival OTP handshakes.

### Reference 2: Thumbtack (`https://www.thumbtack.com/`)
- **Inspected Surfaces**: Service directory, local cost estimate guides, specialist profile cards, project planning tools.
- **Visual Characteristics**:
  - Clean cost estimate blocks ("Average price for electrical work: ৳1,500 - ৳3,000"), upfront checklist of what's included in the service, high-contrast typography, clear CTA to book verified pros.
- **Why It Works**: Customers love knowing the price range before making a call. It removes hesitation and builds immediate pricing confidence.
- **What SKAVIA Can Learn**: Provide clear, upfront BDT price guidelines and turnaround SLAs across every trade in `/services-catalog` and `/services-catalog/[slug]`.
- **SKAVIA Application**: Embedded in the **Services Directory (`/services-catalog`)**: transparent price ranges, estimated duration, included tools, and diagnostic checklists.
- **What Must NOT Be Copied**: Do NOT copy Thumbtack's lead-generation bidding model where contractors pay for leads. On SKAVIA, specialists receive direct dispatches with 90% revenue retention.

### Reference 3: Urban Company (`https://www.urbancompany.com/`)
- **Inspected Surfaces**: Standardized service packages, multi-step booking drawer, safety and hygiene charters, warranty badges.
- **Visual Characteristics**:
  - Standardized service cards with explicit itemized inclusions/exclusions, 30-day service warranty badge, safety-equipped technician photography, clean card borders.
- **Why It Works**: Sets high service quality standards so customers feel they are booking a certified institutional service rather than a random handyman.
- **What SKAVIA Can Learn**: Showcase detailed Trade SOPs, safety equipment kits, property damage guarantees, and revisit protection on `/experience` and service detail pages.
- **SKAVIA Application**: Reflected in **SKAVIA Home & Technical SOPs** and **Customer Experience (`/experience`)**: mandatory 4-digit arrival OTP, property protection guarantee, and automated digital invoices.
- **What Must NOT Be Copied**: Do NOT use low-contrast gray text on white backgrounds or cluttered multi-tier upsell modals.

### Reference 4: Stripe (`https://stripe.com/`)
- **Inspected Surfaces**: Homepage hero, product interactive showcases, developer doc layouts.
- **Visual Characteristics**:
  - Continuous atmospheric mesh gradients, 64px micro-typography scale, interactive live calculation widgets, 1px subtle glass borders (`rgba(255,255,255,0.08)`).
- **Why It Works**: Communicates immense technical reliability, precision, and financial trust. Interactive widgets demonstrate real platform utility upfront before signing up.
- **What SKAVIA Can Learn**: Use live scoping and pricing transparency widgets to let users explore trade service costs and turnaround times upfront without creating an account.
- **SKAVIA Application**: Applied in the **Public Hero & Scoping Engine**: users see upfront price ranges (e.g. ৳ 1,200 – ৳ 2,500) and SLA turnaround times for HVAC, Plumbing, Electrical, and Security.
- **What Must NOT Be Copied**: Do NOT copy Stripe's complex multi-product developer SaaS jargon or abstract isometric illustrations. SKAVIA is an accountable physical service platform in Bangladesh.

### Reference 2: Linear (`https://linear.app/`)
- **Inspected Surfaces**: Product storytelling, feature grids, dark-mode foundational contrast.
- **Visual Characteristics**:
  - High-contrast dark surfaces (`#05080F`), ultra-crisp typography, sub-pixel borders, keyboard-first aesthetic, glowing accent halos (`#15E7CA` / `#3898EC`).
- **Why It Works**: Feels exceptionally fast, intentional, and high-craft. Eliminates visual clutter so every line of text and component carries high semantic density.
- **What SKAVIA Can Learn**: Maintain clean geometric typography, tight vertical rhythm, and subtle border highlights that elevate cards without muddy drop shadows.
- **SKAVIA Application**: Deployed across the **8 Specialization Branches Grid** and **Lifecycle Cards**, providing clear contrast between active and inactive states.
- **What Must NOT Be Copied**: Do NOT create an overly dark, developer-only aesthetic that alienates non-technical consumers or corporate facility managers.

### Reference 3: Vercel (`https://vercel.com/`)
- **Inspected Surfaces**: Navigation bar, design system (Geist), dark/light theme execution.
- **Visual Characteristics**:
  - Dual-theme perfection without color inversion, monochrome base with electric accent highlights, sticky backdrop-blurred navbar, tabular metadata tags.
- **Why It Works**: Flawless legibility in both light and dark modes. Avoids high-saturation background colors that cause eye fatigue during extended viewing.
- **What SKAVIA Can Learn**: Establish explicit CSS variable tokens for surfaces, text, and borders in both themes to prevent color flickering or muddy grays.
- **SKAVIA Application**: Built into **PublicThemeTokens** and **CSS custom properties**: `#05080F` (Dark Surface) / `#F8FAFC` (Light Surface) with calibrated contrast ratios.
- **What Must NOT Be Copied**: Do NOT copy Vercel's heavy cloud-infrastructure abstractions. SKAVIA communicates real field technicians, safety handshakes, and physical services.

### Reference 4: Apple (`https://www.apple.com/`)
- **Inspected Surfaces**: Product showcase pages, hardware feature callouts, rhythmic scrolling.
- **Visual Characteristics**:
  - Generous white/black space, huge high-contrast headline typography, realistic hardware device mockups, content rhythm with clear progressive disclosure.
- **Why It Works**: Commands premium brand perception. Users instinctively trust high-resolution product photography and realistic device mockups over generic stock images.
- **What SKAVIA Can Learn**: Present the official SKAVIA Android application inside realistic, pixel-accurate smartphone mockups showcasing actual app screens (OTP entry, live tracking).
- **SKAVIA Application**: Applied in the **App Download Hub** and **Hero Mockup**: displays the actual dual Client/Worker mode interfaces and 4-digit arrival OTP handoff screen.
- **What Must NOT Be Copied**: Do NOT use massive multi-megabyte scroll animations that degrade performance on budget Android devices or slower mobile networks.

### Reference 5: Wise (`https://wise.com/`)
- **Inspected Surfaces**: Trust guarantees, fee transparency calculators, currency/service switchers.
- **Visual Characteristics**:
  - Upfront fee breakdowns, honest comparative cost tables, high-contrast trust badges, clear CTA buttons with immediate action verbs.
- **Why It Works**: Builds unshakeable financial trust by removing hidden fees and clarifying exactly where money goes before any commitment is made.
- **What SKAVIA Can Learn**: Explain the **90/10 Escrow Split** and transparent pricing model openly on public pages, highlighting that 90% goes directly to the specialist.
- **SKAVIA Application**: Codified into **Pricing & Escrow Explanations** on `/how-it-works`, `/experience`, and `/services`: zero hidden booking fees, funds locked until digital sign-off.
- **What Must NOT Be Copied**: Do NOT mimic Wise's international foreign-exchange rate tickers or banking-only UI. SKAVIA deals in local BDT on-demand workforce dispatches.

### Reference 6: ServiceTitan (`https://www.servicetitan.com/`)
- **Inspected Surfaces**: Trade service categories, commercial contractor positioning, field workflows.
- **Visual Characteristics**:
  - Structured trade taxonomy (HVAC, Electrical, Plumbing), commercial vs. residential segmenting, field technician dignity and tooling focus.
- **Why It Works**: Establishes credibility with both large commercial facility managers and skilled tradespeople. Focuses on field efficiency and accountability.
- **What SKAVIA Can Learn**: Structure services into clear specialization branches: residential maintenance (SKAVIA Home), heavy systems (SKAVIA Technical), and corporate contracts (SKAVIA Business).
- **SKAVIA Application**: Directly adopted in the **8 Specialization Branches architecture**: HOME, TECH, AGRI, LOGI, DIGI, BIZ, CONS, EVNT with explicit trade examples.
- **What Must NOT Be Copied**: Do NOT copy ServiceTitan's US-centric multi-tenant software licensing model. SKAVIA is the single accountable operating company executing the work in Bangladesh.

### Reference 7: Uber (`https://www.uber.com/`)
- **Inspected Surfaces**: Service request flow, map-based arrival concept, mobile-first CTAs.
- **Visual Characteristics**:
  - Two-pillar audience segmentation (Consumers vs. Earners), clear mobile app download CTAs, instant safety guarantee callouts.
- **Why It Works**: Visitors immediately understand whether they are hiring a service or signing up to work. Eliminates navigation confusion with simple two-way entry points.
- **What SKAVIA Can Learn**: Provide clear dual-audience pathways on the public site: one for individuals/businesses requesting services, and one for skilled specialists seeking jobs.
- **SKAVIA Application**: Reflected in navigation and public sections: "Book Services (Get App)" vs. "Become a Verified Specialist (90% Direct Pay)".
- **What Must NOT Be Copied**: Do NOT implement an unmonitored gig-marketplace where anyone can sign up without background check. SKAVIA enforces mandatory NID and trade vetting.

---

## 3. Admin Portal Reference Reverse Engineering Analysis

### Reference 1: Linear (`https://linear.app/`)
- **Inspected Surfaces**: Issue tracking boards, collapsible navigation sidebar, fast filter chips.
- **Visual Characteristics**:
  - Compact 240px sidebar, keyboard shortcuts (`Cmd+K`), instant client-side status filtering, elevated dark cards with clear status icons.
- **Why It Works**: Maximizes screen real estate for data tables. Operators can triage hundreds of tasks without repetitive page reloads or clunky dropdown menus.
- **What SKAVIA Can Learn**: Implement the sleek collapsible sidebar, quick status filters, and instant search across bookings, workers, and branch queues.
- **SKAVIA Application**: Deployed in `AdminShell.tsx`, `TopBar.tsx`, and `DataTable.tsx`: instant filtering across Active, Dispatched, In-Progress, and Completed queues.
- **What Must NOT Be Copied**: Do NOT copy Linear's agile software sprint concepts (story points, cycles) for field trade dispatch operations.

### Reference 2: Stripe Dashboard (`https://dashboard.stripe.com/`)
- **Inspected Surfaces**: Balance summary cards, transaction ledger, dispute arbitration timeline.
- **Visual Characteristics**:
  - Clear numerical ledger alignment (numbers right-aligned), escrow hold balances, dispute evidence submission checklists, chronological audit trails.
- **Why It Works**: Provides total financial clarity and auditability. Every debit, credit, and escrow hold is verifiable with immutable transaction IDs.
- **What SKAVIA Can Learn**: Model the `/finance` and `/disputes` screens after Stripe: clear separation of gross booking value, platform operations fee (10%), and specialist net payout (90%).
- **SKAVIA Application**: Applied in `/finance` (escrow holds, weekly MFS settlement batches) and `/disputes` (photo evidence viewer, technician GPS timestamp, OTP logs).
- **What Must NOT Be Copied**: Do NOT implement multi-currency international merchant payment routing. SKAVIA operations settle in Bangladeshi Taka (BDT) via SSLCommerz, bKash, and Nagad.

### Reference 3: Vercel Dashboard (`https://vercel.com/dashboard`)
- **Inspected Surfaces**: Deployment logs, project status cards, team environment switchers.
- **Visual Characteristics**:
  - Clean scope switcher in header, real-time status dots (green pulsing for active, amber for building, rose for failed), monospace commit/release hashes.
- **Why It Works**: Gives instant operational situational awareness. Users can immediately identify anomalies or failing builds with zero cognitive overhead.
- **What SKAVIA Can Learn**: Use branch-scoping selectors in the `TopBar` and monospace cryptographic hashes for APK releases, audit logs, and transaction references.
- **SKAVIA Application**: Implemented in `/releases` (SHA-256 binary validation, ARM64 vs ARMv7 staging) and `TopBar` (global branch selector for Company Admin, locked for Branch Manager).
- **What Must NOT Be Copied**: Do NOT incorporate git push/deploy workflows into service workforce management.

### Reference 4: Supabase Studio (`https://supabase.com/dashboard`)
- **Inspected Surfaces**: Table editor, SQL runner, role-based access control policies.
- **Visual Characteristics**:
  - Dense tabular data grid, quick search across all columns, pagination controls, slide-over detail drawers for editing individual rows.
- **Why It Works**: Allows administrators to inspect complex relational data without navigating away from the main list view. Prevents loss of pagination context.
- **What SKAVIA Can Learn**: Use slide-over detail drawers (`SideDrawer.tsx`) for inspecting worker NID documents, booking details, and administrator invitation profiles.
- **SKAVIA Application**: Implemented in `AdminDetailDrawer`, `ReleaseDetailDrawer`, and worker verification inspection panels.
- **What Must NOT Be Copied**: Do NOT expose raw database schemas, SQL consoles, or table altering controls to internal operational staff or branch managers.

### Reference 5: Ramp (`https://ramp.com/`)
- **Inspected Surfaces**: Corporate card spend management, maker-checker approval workflows.
- **Visual Characteristics**:
  - High-impact metric KPI cards with percentage trends, dual-signature approval banners, clear status badges (`Verified`, `Pending`, `Flagged`).
- **Why It Works**: Prevents fraudulent payouts and unauthorized administrative actions by enforcing explicit maker-checker workflows for financial changes.
- **What SKAVIA Can Learn**: Enforce maker-checker approval workflows on high-value refunds, technician payout batches, and administrator permission overrides.
- **SKAVIA Application**: Built into `/finance` and `/verifications`: two-step verification for technician document approval and payout reconciliation runs.
- **What Must NOT Be Copied**: Do NOT build corporate expense credit-card issuing features. SKAVIA finances focus on specialist escrow and client payments.

### Reference 6: WorkOS (`https://workos.com/`)
- **Inspected Surfaces**: Enterprise directory sync, SSO configuration, audit log streams.
- **Visual Characteristics**:
  - Clean audit log streams with timestamps, IP addresses, actor identities, and affected resource IDs; fail-closed permission matrices.
- **Why It Works**: Enterprise compliance and security teams demand transparent, tamper-proof activity logs for every administrative action taken.
- **What SKAVIA Can Learn**: Implement immutable audit logging for all admin mutations (role changes, dispute resolutions, rate modifications) in `/security`.
- **SKAVIA Application**: Captured in `SupabaseGovernanceStore` and visualized in `/security`: searchable audit log stream with actor UID, IP, user-agent, and before/after payloads.
- **What Must NOT Be Copied**: Do NOT implement complex SAML SSO enterprise federations for standard branch managers. Simple Google Workspace SSO + WebAuthn is appropriate.

### Reference 7: Clerk (`https://clerk.com/`)
- **Inspected Surfaces**: User authentication settings, active session termination, passkey credentials.
- **Visual Characteristics**:
  - Seamless WebAuthn / FIDO2 passkey registration, active session cards showing device type, browser, location, and instant revoke buttons.
- **Why It Works**: Simplifies complex cryptographic security into intuitive user controls, drastically reducing unauthorized account takeovers.
- **What SKAVIA Can Learn**: Provide administrators with self-service WebAuthn passkey management and the ability to view and terminate active administrative sessions in `/settings` & `/security`.
- **SKAVIA Application**: Directly codified in `/api/admin/auth/passkey/*` and `/security`: administrators can register biometric/hardware keys and terminate suspicious sessions.
- **What Must NOT Be Copied**: Do NOT use third-party hosted auth modals that break brand immersion. All auth forms are natively styled within the SKAVIA design system.

---

## 4. Strict SKAVIA Design System Tokens

### A. Color Palette & Semantics
- **Brand Primary**: Royal Blue (`#003399` / `#1D4ED8` hover / `#002266` active)
- **Brand Accent**: Aqua Cyan (`#15E7CA` / `#06B6D4`)
- **Secondary Accent**: Electric Sky (`#3898EC`)
- **Neutral Dark Base**: `#05080F` (Surface Foundation), `#090D16` (Card Surface), `#0F172A` (Elevated Card)
- **Neutral Light Base**: `#F8FAFC` (Surface Foundation), `#FFFFFF` (Card Surface), `#F1F5F9` (Elevated Surface)
- **Borders**:
  - Dark Mode: `rgba(255, 255, 255, 0.08)` / subtle `rgba(255, 255, 255, 0.15)`
  - Light Mode: `rgba(0, 0, 0, 0.08)` / subtle `rgba(0, 0, 0, 0.12)`
- **Semantic Colors**:
  - Success / Active: Emerald Green (`#10B981`)
  - Warning / Alert: Amber Gold (`#F59E0B`)
  - Error / Critical: Crimson Rose (`#EF4444`)
  - Info / Secondary: Sky Blue (`#0EA5E9`)

### B. Typography Scale & Fonts
- **English Font**: Inter / Geist Sans (`font-sans`)
- **Bangla Font**: Noto Sans Bengali / Hind Siliguri (`font-sans`) with proper Unicode normalization and kerning.
- **Monospace & Code**: JetBrains Mono (`font-mono-code`)
- **Type Scale**:
  - Display / Hero Heading: `text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight`
  - Section Heading: `text-2xl sm:text-3xl lg:text-4xl font-extrabold tracking-tight`
  - Card Title: `text-base sm:text-lg font-bold`
  - Body Text: `text-sm sm:text-base leading-relaxed`
  - Metadata / Badges: `text-xs font-mono-code uppercase tracking-wider`

### C. Spacing, Radius & Shadows
- **Card Radius**: `rounded-2xl` (16px) for standard cards; `rounded-3xl` (24px) for hero and major containers.
- **Button Radius**: `rounded-full` (9999px) for primary pills; `rounded-xl` (12px) for structured action buttons.
- **Shadows**:
  - Subtle: `shadow-sm`
  - Elevated: `shadow-lg shadow-blue-900/10 dark:shadow-blue-950/30`
  - Radiant Glow: `shadow-[0_0_50px_-12px_rgba(21,231,202,0.25)]`
