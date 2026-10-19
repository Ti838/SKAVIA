# SKAVIA — API & External Integration Architecture Guide

<p align="center">
  <img src="../assets/images/skavia_logo.png" alt="SKAVIA Logo" width="220"/>
</p>

<p align="center">
  <strong>Comprehensive Technical Integration Manual: Supabase PostgREST, Realtime WebSockets, SSLCommerz v4, Firebase Auth & Storage</strong><br>
  <em>Production Standard • High-Concurrency Architecture</em>
</p>

---

## 📑 1. Integration Ecosystem Overview

The SKAVIA platform orchestrates multiple best-in-class cloud and payment infrastructures:

```mermaid
graph TB
    subgraph ClientApp ["📱 SKAVIA Client (Flutter 3.38+ / Dart 3.10+)"]
        ClientCore["Client Runtime & Remote DataSources"]
    end

    subgraph SupabaseCloud ["☁️ Supabase Cloud (AWS eu-central-1)"]
        PostgREST["PostgREST RESTful Data Gateway"]
        Realtime["Realtime Engine (WebSockets)"]
        SettlementRPC["PostgreSQL complete_payment_transaction() RPC"]
    end

    subgraph FirebaseCloud ["🔥 Google Firebase (Identity & Cloud Storage)"]
        PhoneAuth["Firebase Phone Auth (SMS OTP)"]
        FirebaseStorage["Firebase Cloud Storage (Buckets: KYC, Portfolios)"]
    end

    subgraph BankingRails ["💳 Financial & MFS Infrastructure (Bangladesh)"]
        SSLCommerz["SSLCommerz Hosted Payment Gateway v4"]
        bKash["bKash MFS Direct Checkout"]
        Nagad["Nagad Digital Financial Rail"]
    end

    subgraph AICloud ["🤖 Natural Language Scope Processing"]
        SkaviaAI["SKAVIA AI Natural Language Decomposition Engine"]
    end

    ClientCore <-->|RESTful HTTPS| PostgREST
    ClientCore <-->|WebSocket WSS| Realtime
    ClientCore <-->|Multipart Upload| FirebaseStorage
    ClientCore -->|SMS Verification| PhoneAuth
    ClientCore -->|Hosted Redirection| SSLCommerz
    ClientCore -->|AI Prompt Breakdown| SkaviaAI
    
    SSLCommerz -->|Server Settlement Trigger| SettlementRPC
```

---

## 💳 2. Payment Gateway Integration: SSLCommerz v4 & MFS

### Sequence Diagram: Payment Initialization, Redirect & Atomic Settlement

```mermaid
sequenceDiagram
    autonumber
    actor Customer as 👤 Customer
    participant App as 📱 Mobile Client
    participant SSL as 🌐 SSLCommerz Gateway
    participant Bank as 🏦 Bank / MFS (bKash/Nagad)
    participant Supabase as 🗄️ Supabase PostgreSQL 15

    Customer->>App: Taps 'Confirm & Pay' (BDT 1,500)
    App->>SSL: POST /gwprocess/v4/api.php (Session Init)
    Note over SSL: Validates store_id, total_amount, currency='BDT'
    SSL-->>App: Emits GatewayPageURL (Hosted Checkout URL)
    
    App->>App: Opens Hosted Webview with GatewayPageURL
    Customer->>Bank: Selects bKash / Card & Enters Wallet PIN
    Bank-->>SSL: Transaction Authorized (tran_id: 'TRX-98214')
    SSL-->>App: Redirects to Success URL with tran_id & val_id

    critical Server-Side Atomic Settlement
        App->>Supabase: rpc('complete_payment_transaction', {p_amount, p_trx_id: 'TRX-98214', p_currency: 'BDT'})
        Note over Supabase: Validates BDT currency<br/>Ensures no duplicate tran_id<br/>Inserts into payments (status='completed')<br/>Updates service_requests (status='confirmed')<br/>Credits Worker Wallet (85%)<br/>Generates Invoice (INV-XXXX)
        Supabase-->>App: Emits {status: 'success', invoice_id: 'INV-...'}
    end

    App-->>Customer: Displays PaymentSuccessScreen & Booking Timeline
```

### SSLCommerz Sandbox Request Payload:
```json
{
  "store_id": "skaviabox",
  "store_passwd": "skavia_sandbox_secret",
  "total_amount": 1500.00,
  "currency": "BDT",
  "tran_id": "SKV-20261109-0012",
  "success_url": "https://api.skavia.com/payment/success",
  "fail_url": "https://api.skavia.com/payment/fail",
  "cancel_url": "https://api.skavia.com/payment/cancel",
  "cus_name": "Rahim Ahmed",
  "cus_email": "rahim@skavia.com",
  "cus_phone": "+8801700000000",
  "cus_add1": "House 14, Road 5, Banani",
  "cus_city": "Dhaka",
  "shipping_method": "NO"
}
```

---

## 💬 3. Real-Time Chat WebSocket Integration (Supabase Realtime)

### Sequence Diagram: Live Message Transmission & Status Delivery

```mermaid
sequenceDiagram
    autonumber
    actor Customer as 👤 Customer
    participant ClientA as 📱 Customer Client
    participant WSS as ⚡ Supabase Realtime WSS
    participant PostgREST as 🗄️ PostgreSQL 15 (messages Table)
    participant ClientB as 🔧 Worker Client
    actor Worker as 🔧 Specialist

    Customer->>ClientA: Types "I'm at the gate" & taps Send
    ClientA->>ClientA: Optimistic Bubble Insertion (status='sent')
    ClientA->>PostgREST: INSERT INTO public.messages (conversation_id, sender_id, content)
    PostgREST-->>ClientA: Confirmation (Returns message UUID & timestamp)
    
    PostgREST->>WSS: Broadcasts postgres_changes event (INSERT)
    WSS-->>ClientB: Pushes new message payload over WSS
    ClientB->>ClientB: Renders incoming message bubble with sound chime
    
    ClientB->>PostgREST: UPDATE messages SET status = 'read' WHERE id = message_id
    PostgREST->>WSS: Broadcasts postgres_changes event (UPDATE: status='read')
    WSS-->>ClientA: Pushes status update over WSS
    ClientA->>ClientA: Updates tick to double blue checkmarks
```

---

## 📱 4. Firebase Authentication: Phone SMS OTP Handshake

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 User
    participant App as 📱 Mobile Client
    participant AuthCtrl as ⚙️ AuthController
    participant Firebase as 🔥 Firebase Auth
    participant Telco as 📡 SMS Gateway
    participant DB as 🗄️ PostgreSQL users

    User->>App: Enters Phone (+8801700000000)
    App->>AuthCtrl: signInWithPhone(phoneNumber)
    AuthCtrl->>Firebase: verifyPhoneNumber()
    Firebase->>Telco: Dispatch 6-digit SMS OTP
    Telco-->>User: Delivers SMS: "Your SKAVIA code is 849201"
    Firebase-->>AuthCtrl: Emits verificationId (string)
    
    User->>App: Enters 8-4-9-2-0-1 (Auto-advancing 6 digits)
    App->>Firebase: PhoneAuthProvider.credential(verificationId, smsCode)
    Firebase-->>AuthCtrl: Returns UserCredential (JWT token)
    
    AuthCtrl->>DB: Synchronizes Supabase session & fetches User Profile
    DB-->>AuthCtrl: Emits UserAccountModel
    AuthCtrl-->>App: Routes to MainScaffoldScreen
```

---

## 🤖 5. SKAVIA AI Requirement Decomposition Architecture

```mermaid
sequenceDiagram
    autonumber
    actor Customer as 👤 Customer
    participant UI as 📱 PostRequirementScreen
    participant AI as 🤖 SkaviaAiScreen / AiChatView
    participant Engine as ⚙️ NLP Classification Engine

    Customer->>UI: Taps 'Ask AI to Structure Scope'
    UI->>AI: Launches with initial prompt: "AC making rattling sound, water leaking"
    AI->>Engine: Ingests unstructured diagnostic text
    Note over Engine: Classifies Trade -> HVAC<br/>Extracts Category -> Electrical Diagnostics<br/>Estimates Hours -> 1.5 - 2.0 hrs<br/>Suggests Budget -> BDT 1,200 - 1,800
    Engine-->>AI: Emits structured scope card
    Customer->>AI: Taps 'Apply to Requirement'
    AI-->>UI: Populates PostComposerFields automatically
    UI-->>Customer: Ready to publish requirement to marketplace
```

---

## 🌐 6. Environment Configurations (`.env`)

```env
# Supabase Cloud Gateway
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...

# Firebase Cloud Engine
FIREBASE_PROJECT_ID=skavia-prod
FIREBASE_STORAGE_BUCKET=gs://skavia-prod.appspot.com

# SSLCommerz Payment Gateway
SSLCOMMERZ_STORE_ID=skaviabox
SSLCOMMERZ_STORE_PASSWORD=skavia_sandbox_secret
SSLCOMMERZ_IS_SANDBOX=true

# AI Engine
SKAVIA_AI_MODEL=llama-3.3-70b-versatile
```
