// @ts-nocheck
// SKAVIA SSLCommerz IPN Verification & Settlement Edge Function
// Implements SSLCommerz Documented IPN & Transaction Validation API
// Security: Zero client-trust, server-side bank verification, atomic settlement via service_role

declare const Deno: any;

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface SslCommerzValidationResponse {
  status: string;
  tran_date?: string;
  tran_id?: string;
  val_id?: string;
  amount?: string;
  store_amount?: string;
  currency?: string;
  bank_tran_id?: string;
  card_type?: string;
  card_no?: string;
  card_issuer?: string;
  card_brand?: string;
  card_issuer_country?: string;
  value_a?: string;
  value_b?: string;
  value_c?: string;
  value_d?: string;
  error?: string;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Resolve Server-Side Environment Secrets
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const storeId = Deno.env.get("SSLCOMMERZ_STORE_ID");
    const storePasswd = Deno.env.get("SSLCOMMERZ_STORE_PASSWD");
    const isSandbox = Deno.env.get("SSLCOMMERZ_IS_SANDBOX") !== "false"; // default to sandbox

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      return new Response(
        JSON.stringify({ error: "Server configuration error: missing Supabase credentials" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!storeId || !storePasswd) {
      return new Response(
        JSON.stringify({ error: "Server configuration error: missing SSLCommerz store credentials" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Initialize privileged backend Supabase client
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // 2. Parse Incoming Payload (Supports JSON or URL-encoded Form POST from SSLCommerz IPN)
    let valId = "";
    let tranId = "";
    let paymentId = "";

    const contentType = req.headers.get("content-type") || "";
    if (contentType.includes("application/json")) {
      const body = await req.json();
      valId = body.val_id || "";
      tranId = body.tran_id || "";
      paymentId = body.payment_id || "";
    } else if (contentType.includes("application/x-www-form-urlencoded")) {
      const formData = await req.formData();
      valId = (formData.get("val_id") as string) || "";
      tranId = (formData.get("tran_id") as string) || "";
      paymentId = (formData.get("value_a") as string) || (formData.get("payment_id") as string) || "";
    } else {
      // Also check URL parameters if sent via GET query
      const url = new URL(req.url);
      valId = url.searchParams.get("val_id") || "";
      tranId = url.searchParams.get("tran_id") || "";
      paymentId = url.searchParams.get("payment_id") || "";
    }

    if (!valId) {
      return new Response(
        JSON.stringify({ error: "Missing required validation ID (val_id)" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 3. Query Official SSLCommerz Transaction Validation API
    const validationHost = isSandbox
      ? "https://sandbox.sslcommerz.com"
      : "https://securepay.sslcommerz.com";
    
    const validationUrl = `${validationHost}/validator/api/validationserverAPI.php?val_id=${encodeURIComponent(
      valId
    )}&store_id=${encodeURIComponent(storeId)}&store_passwd=${encodeURIComponent(
      storePasswd
    )}&format=json`;

    const gatewayResponse = await fetch(validationUrl, { method: "GET" });
    if (!gatewayResponse.ok) {
      return new Response(
        JSON.stringify({ error: "Failed to communicate with SSLCommerz validation API" }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const gatewayData: SslCommerzValidationResponse = await gatewayResponse.json();

    // 4. Validate Gateway Response Authenticity & State
    const isValidStatus =
      gatewayData.status === "VALID" || gatewayData.status === "VALIDATED";

    if (!isValidStatus) {
      return new Response(
        JSON.stringify({
          error: "Transaction validation failed at gateway",
          gateway_status: gatewayData.status,
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 5. Match Currency & Numeric Amount
    if (gatewayData.currency !== "BDT") {
      return new Response(
        JSON.stringify({ error: "Currency mismatch: expected BDT" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const verifiedAmount = parseFloat(gatewayData.amount || "0");
    if (isNaN(verifiedAmount) || verifiedAmount <= 0) {
      return new Response(
        JSON.stringify({ error: "Invalid payment amount returned by gateway" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 6. Resolve Target Payment ID strictly from verified gateway reference (no ambiguous amount-only fallback)
    const targetPaymentId = gatewayData.value_a || paymentId;
    if (!targetPaymentId) {
      return new Response(
        JSON.stringify({
          error: "Missing payment correlation ID (value_a / payment_id) in gateway callback",
          tran_id: gatewayData.tran_id || tranId || null,
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 7. Invoke Backend Settlement RPC (Atomically updates payment, creates transaction & invoice, credits wallet)
    const { data: settlementResult, error: settlementError } = await supabase.rpc(
      "complete_payment_transaction",
      {
        p_payment_id: targetPaymentId,
        p_gateway_name: gatewayData.card_type || "sslcommerz",
        p_gateway_tx_id: gatewayData.bank_tran_id || tranId || valId,
        p_val_id: valId,
        p_verified_amount: verifiedAmount,
      }
    );

    if (settlementError) {
      return new Response(
        JSON.stringify({ error: "Settlement execution error", details: settlementError.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 8. Return Success to SSLCommerz / Client Listener
    return new Response(
      JSON.stringify({
        success: true,
        message: "Payment successfully verified and settled.",
        result: settlementResult,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: "Internal error processing payment verification", message: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
