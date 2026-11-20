# Feature: Payments, Escrow & Worker Wallet

## 1. Escrow Architecture

SKAVIA guarantees payment safety through an automated escrow vault:
- **Upfront Escrow Deposit:** Customer deposits order funds prior to technician dispatch via SSLCommerz (bKash, Nagad, Visa, Mastercard).
- **Funds Lock:** Funds remain locked in `escrow_accounts` with status `held`. Neither the platform nor the worker can withdraw during active execution.
- **Atomic Settlement:** Upon customer approval of completion proof, the `release_escrow_settlement` RPC function executes:
  - 90% credited to `worker_earnings` (`status = 'available'`).
  - 10% retained as platform technology maintenance fee.

---

## 2. Invoicing & Ledger Transparency

Detailed digital invoices (`InvoiceScreen`) provide line-item transparency:
- Base service fee
- Consumed materials / parts
- Applicable VAT / AIT taxes
- Downloadable PDF receipt with unique QR transaction code
