# SKAVIA | Reference Reverse Engineering & Design System Specification

## 1. Executive Summary & Objective

This document defines the formal visual, architectural, and user-experience specification reverse-engineered from world-class industry benchmark platforms and design systems, mapped directly onto the **SKAVIA Service & Workforce Platform** digital ecosystem.

SKAVIA is a unified, single-enterprise accountable service and workforce platform operating across 8 internal specialization branches in Bangladesh. This specification establishes strict visual fidelity, responsive ergonomics, and complete separation across three distinct product surfaces:
1. **Public Website (`www.skavia.com`)**: Exclusively customer-facing; zero internal admin exposure.
2. **Company Admin Portal (`admin.skavia.com`)**: Internal operations, branch management, and field workforce supervision.
3. **Super Admin Portal (`superadmin.skavia.com`)**: Platform governance, administrator RBAC, cryptographic security, and APK release distribution.

---

## 2. Reverse-Engineered Reference Analysis

### Reference 1: Urban Company & Taskrabbit (Public Marketplace & Service Discovery)
- **Reference URLs**: `https://www.urbancompany.com/`, `https://www.taskrabbit.com/`
- **Inspected Surfaces**: Homepage hero, service category grids, dynamic requirement scoping, upfront transparent pricing, worker trust guarantees.
- **Visual Characteristics**:
  - **Grid & Layout**: Centered content containers (`max-w-7xl`, `1280px`), responsive 12-column bento grids.
  - **Typography**: Bold, high-contrast headings with compact, readable body text.
  - **Trust Architecture**: Prominent badges highlighting background verification, fixed pricing, insurance coverage, and damage protection.
  - **Card Proportions**: Rounded cards (`rounded-2xl` to `rounded-3xl`) with 1px subtle borders (`border-slate-200` light, `border-slate-800` dark), micro-hover elevations (`scale-[1.01]`, `shadow-md`).
- **SKAVIA Architectural Application**:
  - Direct inspiration for the **Public Website Hero & Live Scoping Engine** (`PublicWorkflowSections.tsx`) and **8 Specialization Branches Grid**.
  - Replaced Urban Company's multi-vendor open listings with SKAVIA's **single-enterprise accountability** model: client requests are assigned to SKAVIA-verified internal specialists with guaranteed **4-digit arrival handshake OTP** verification.

### Reference 2: Stripe & Vercel (Visual Hierarchy, Gradients & Engineering Polish)
- **Reference URLs**: `https://stripe.com/`, `https://vercel.com/`
- **Inspected Surfaces**: Product landing pages, technical interactive demos, design systems (Geist).
- **Visual Characteristics**:
  - **Atmospheric Lighting**: Radiant mesh radial gradients with high-blur diffusion (`blur-3xl`, 10–25% opacity), dark slate foundations (`#05080F`).
  - **Typography Scale**: Strict geometric sans typography, high-contrast monochrome bases with deliberate color accents.
  - **Status Indicators**: Pulsing live dots, monospace metadata tags (`font-mono-code text-[11px] uppercase tracking-wider`).
  - **Interactive Demos**: Embedded live calculating widgets that demonstrate real product utility without requiring sign-in.
- **SKAVIA Architectural Application**:
  - **Atmospheric Canvas & Ambient Mesh Lights**: Deployed in `HeroSection` and `DownloadSection`.
  - **Real-time Telemetry & Download Hub**: Replaced generic store links with an interactive Android hardware detection engine (`ARM64-v8a` vs `ARMv7`) and cryptographic SHA-256 verification.

### Reference 3: Stripe Dashboard & Shopify Polaris (Financial & Order Management)
- **Reference URLs**: `https://dashboard.stripe.com/`, `https://polaris.shopify.com/`
- **Inspected Surfaces**: Balance summary cards, transaction ledgers, dispute arbitration timelines, order management workflows.
- **Visual Characteristics**:
  - **Information Density**: Compact, high-utility table rows (40–48px height), clear column alignments (numbers right-aligned, text left-aligned).
  - **Financial Clarity**: Distinct visual separation between gross revenue, escrow holds, and net payout balances.
  - **Dispute Workflows**: Evidence submission checklists, chronological audit trails, and status-driven action banners.
- **SKAVIA Architectural Application**:
  - **Finance Management (`/finance`)**: Modeled after Stripe Dashboard to manage SKAVIA's **90/10 Escrow Split** (90% direct specialist payout, 10% platform operations/insurance) with weekly MFS/bank settlement batches.
  - **Disputes Screen (`/disputes`)**: Clear arbitration interfaces connecting customer complaint photos, technician GPS timestamps, and handshake OTP verification logs.

### Reference 4: Linear & Supabase Studio (Speed, Navigation & Clean Architecture)
- **Reference URLs**: `https://linear.app/`, `https://supabase.com/dashboard`
- **Inspected Surfaces**: Collapsible administrative sidebars, keyboard shortcuts, fast status filter chips, dark-mode elevated surfaces.
- **Visual Characteristics**:
  - **Sidebar Ergonomics**: 240–260px fixed width on desktop, collapsible to 64px or slide-over drawer on mobile (`< 1024px`).
  - **Elevated Surfaces**: Dark mode foundation (`#090D16` / `#05080F`), secondary surface (`#0F172A`), tertiary cards (`#1E293B`), subtle border contrast (`rgba(255,255,255,0.08)`).
  - **Interactive Filter Chips**: Pill-shaped status toggles with subtle background highlights and instantaneous client-side filtering.
- **SKAVIA Architectural Application**:
  - **Admin Shell & Navigation (`AdminShell.tsx`, `TopBar.tsx`)**: Re-architected with Linear-style sleek iconography, branch scope selectors, and active state indicators.
  - **Bookings & Verifications Queues (`/bookings`, `/verifications`)**: Instant status switching across Active, Pending, Dispatched, In-Progress, and Completed states.

### Reference 5: Atlassian Jira & Retool (Enterprise Governance & RBAC)
- **Reference URLs**: `https://www.atlassian.com/software/jira`, `https://retool.com/`
- **Inspected Surfaces**: Role & permission matrices, audit logging consoles, team formation drawers, and operational oversight screens.
- **Visual Characteristics**:
  - **Permission-Aware Interfaces**: Conditional action triggers, step-up MFA badges, fail-closed access indicators.
  - **Inspection Panels**: Slide-over detail drawers that allow operators to review deep records without losing table context.
- **SKAVIA Architectural Application**:
  - **Admins Management (`/admins`)**: Super Admin interface for managing administrative invitations, role assignments (Super Admin, Company Admin, Branch Manager), and explicit permission overrides (`ALLOW` / `DENY`).
  - **Security & Session Controls (`/security`)**: Live audit log explorer, WebAuthn passkey management, and active session termination.

### Reference 6: Google Material Design 3 (M3) (Mobile Ergonomics & Touch Targets)
- **Reference URL**: `https://m3.material.io/`
- **Inspected Surfaces**: Adaptive mobile layouts, responsive bottom sheets, segmented buttons, touch-target standards (min 44x44px).
- **Visual Characteristics**:
  - **Zero Horizontal Overflow**: Fluid container widths with flexible min-width constraints.
  - **Thumb-Zone Navigation**: Primary action buttons positioned in the bottom third of mobile viewports.
  - **Card Stacking**: Mobile table transformations into responsive data cards at `< 768px`.
- **SKAVIA Architectural Application**:
  - Mobile responsiveness across all 11 required viewports (320px, 360px, 375px, 390px, 414px, 430px, 768px, 1024px, 1280px, 1440px, 1920px).
  - Mobile Nav Drawer with full bilingual support, zone selector, and mode previews.

---

## 3. Reference-to-Route Mapping Architecture

| SKAVIA Route | Environment | Primary Reference | Secondary Reference | Key Architectural Features |
| :--- | :--- | :--- | :--- | :--- |
| `/` | Public Website | Urban Company / Stripe | Vercel / Airbnb | Full-bleed hero, live scoping engine, 8-branch bento, delivery lifecycle, APK download telemetry, operations desk |
| `/privacy`, `/terms` | Public Website | Vercel / Stripe | Atlassian | Dual-script bilingual legal governance, clear typography, structured sections |
| `/login` | Auth Gateway | Stripe / Linear | Vercel Geist | WebAuthn FIDO2 passkeys, Google Workspace SSO, TOTP MFA challenge, role routing |
| `/activate` | Auth Gateway | Linear | Supabase | Cryptographic invitation token preview, branch scope assignment, credential setup |
| `/access-denied` | Auth Gateway | Atlassian | Linear | Fail-closed 403 RBAC alert, clear escalation cues, switch account trigger |
| `/dashboard` | Company Admin | Linear / Vercel | Stripe Dashboard | Real-time operational dispatch counters, branch throughput metrics, urgent alert feed |
| `/bookings` | Company Admin | Shopify Polaris | Linear | Multi-branch booking queue, technician dispatch assignment, 4-digit OTP status, lifecycle timeline |
| `/workers` | Company Admin | Shopify / Taskrabbit | Retool | Verified field specialist directory, trade skill badges, availability toggle, rating scores |
| `/customers` | Company Admin | Shopify Polaris | Retool | Customer directory categorized by Individual, Business Client, and Organization |
| `/branches` | Company Admin | Linear | Supabase Studio | 8 internal branch oversight, assigned Branch Managers, active capacity metrics |
| `/services` | Company Admin | Shopify Polaris | Urban Company | 8-branch service catalog, rate card configuration, SLA parameters |
| `/teams` | Company Admin | Atlassian Jira | Retool | Multi-trade team coordination, assigned Team Leaders, commercial milestone tracking |
| `/finance` | Company Admin | Stripe Dashboard | Shopify Polaris | 90/10 Escrow split tracking, weekly MFS/bank settlement batches, revenue reconciliation |
| `/disputes` | Company Admin | Stripe Dashboard | Atlassian | Customer-technician dispute cases, escrow hold arbitration, photo evidence viewer |
| `/verifications` | Company Admin | Retool | Taskrabbit | Worker NID verification queue, document inspection, trade assessment approval |
| `/reports` | Company Admin | Stripe / Vercel | Shopify | Branch performance analytics, financial export reports, worker satisfaction scores |
| `/admins` | Super Admin | Atlassian Jira | Linear | Platform administrator directory, role assignments, granular permission overrides |
| `/security` | Super Admin | Vercel / Supabase | Atlassian | Audit log stream, active session management, security incidents, WebAuthn passkey credentials |
| `/releases` | Super Admin | Vercel | GitHub Releases | APK binary release distribution, SHA-256 verification, ARM64 vs ARMv7 staging, changelog management |
| `/settings` | Super Admin / Admin | Linear | Vercel | Personal profile, security credentials, notification preferences, system defaults |
| `/customer-portal` | Customer Web | Airbnb / Taskrabbit | Urban Company | Customer active service bookings, 4-digit arrival OTP view, receipt downloads |
| `/worker-console` | Worker Web | Taskrabbit | Stripe Dashboard | Worker active assignments, arrival OTP verification, weekly earnings balance |
| `/business-portal` | Business Web | Stripe / Atlassian | Shopify | Corporate multi-branch service requests, facility contracts, formal business invoicing |

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

---

## 5. Absolute Surface Separation Architecture

### Public Website Boundary (`www.skavia.com`)
- **Customer & Visitor Exclusive**: All pages and components serve public visitors, households, and business clients exploring services.
- **Strict Isolation**: No administrative sidebars, no admin links in header or footer, no internal reports, no branch management buttons.
- **Direct App Link**: Prominent CTA directing visitors to download the official Android application for live booking and technician tracking.

### Company Admin Boundary (`admin.skavia.com`)
- **Staff Exclusive**: Accessible only via verified administrative credentials or invitation token.
- **Role-Aware RBAC**: Company Admin oversees all operational branches; Branch Manager is automatically scoped to their assigned branch.
- **Branch Selector**: Global branch filter in `TopBar` for multi-branch administrators; locked for Branch Managers.

### Super Admin Boundary (`superadmin.skavia.com`)
- **Platform Governance**: Restricted strictly to users with `isPrimarySuperAdmin: true`.
- **Exclusive Modules**:
  - `/admins`: Create invitations, configure fine-grained permissions, revoke administrative access.
  - `/security`: Review real-time audit logs, terminate suspicious sessions, enforce hardware passkeys.
  - `/releases`: Stage production APK binaries, compute SHA-256 hashes, configure mandatory vs optional update policies.

---

## 6. Zero-Flicker Localization Architecture

1. **Preloaded In-Memory Dictionaries**: English (`en`) and Bengali (`bn`) dictionaries loaded in `translations.ts` without client-side network roundtrips.
2. **Instant Non-Blocking React Context**: `useTranslation()` updates text nodes without remounting page trees, resetting form states, or refreshing the browser.
3. **Typography Elasticity**: Dynamic min-heights and flexible flexbox containers prevent layout shifts when switching between compact English and longer Bengali text.
4. **Persistent Preference**: Synced instantaneously to `localStorage('skavia-lang')`, cookie, and `document.documentElement.lang`.
