# Cloud Infrastructure & Topology

## 1. Multi-Cloud Topology Overview

The SKAVIA platform leverages a high-availability, multi-cloud infrastructure designed for resilience, security, and low-latency delivery across Bangladesh.

```mermaid
graph TB
    subgraph Client_Edge ["🌐 Client & Edge Delivery"]
        MobileClient["📱 Android & iOS Mobile Client<br/>(Flutter Engine)"]
        BrowserClient["💻 Web Portals & Download Gateway<br/>(Vercel Edge Network)"]
    end

    subgraph Compute_and_Hosting ["☁️ Compute & Application Layer"]
        VercelHost["▲ Vercel Production Environment<br/>(Next.js 15 App Router / Serverless Functions)"]
        SupabaseEdge["⚡ Supabase Edge Runtime<br/>(Deno TypeScript Serverless Functions)"]
    end

    subgraph Data_and_Storage ["🗄️ Relational Store & Asset Storage"]
        PostgresDB["🐘 Supabase PostgreSQL 15<br/>(Primary Relational Store, PostgREST & Realtime)"]
        FirebaseCore["🔥 Firebase Cloud<br/>(Phone Auth Engine & Media Storage Buckets)"]
        ReleaseStorage["📦 Private Release Bucket<br/>(Cryptographically Verified Production APKs)"]
    end

    subgraph External_APIs ["💳 External Rails & APIs"]
        SSLCommerz["💳 SSLCommerz Bangladesh MFS / Card Gateway"]
        CloudflareEdge["🛡️ Cloudflare Anycast CDN & 1.1.1.1 Latency Probe"]
    end

    MobileClient -->|HTTPS REST / WSS| PostgresDB
    MobileClient -->|Phone Auth & Photos| FirebaseCore
    MobileClient -->|RTT Latency Probe| CloudflareEdge
    MobileClient -->|In-App Update Download| VercelHost

    BrowserClient -->|HTTPS TLS 1.3| VercelHost
    VercelHost -->|Service Role PostgREST| PostgresDB
    VercelHost -->|Signed Asset Download| ReleaseStorage
    SupabaseEdge -->|Webhook Notification| PostgresDB
    SSLCommerz -->|Server-to-Server IPN| VercelHost
```

---

## 2. Infrastructure Component Specifications

| Infrastructure Layer | Technology / Service | Location / Region | Responsibility |
| :--- | :--- | :--- | :--- |
| **Relational Database** | PostgreSQL 15 (Supabase Cloud) | AWS ap-southeast-1 (Singapore) | Primary transactional data, RLS enforcement, real-time WebSockets, and ACID ledger. |
| **Media & Auth Cloud** | Google Firebase (`skavia-113a3`) | Google Cloud (asia-south1) | Phone SMS OTP authentication, Google OAuth, and user profile photo storage. |
| **Web & Administration** | Vercel Edge Cloud | Global Anycast Edge (iad1 / sin1) | Next.js 15 web portal, Super Admin console, and public APK download distribution. |
| **Payment Gateway** | SSLCommerz v4 Gateway | Dhaka, Bangladesh | Merchant acquisition, bKash/Nagad/Rocket MFS integration, and credit card processing. |
| **Network & Latency Probe** | Cloudflare Anycast (1.1.1.1) | Dhaka / Regional Edges | Millisecond edge ping measurement in mobile device diagnostics. |
