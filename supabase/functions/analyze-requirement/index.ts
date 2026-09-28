// @ts-nocheck
// SKAVIA Multi-AI Edge Function
// Strictly implements SRS Section 3.1.F (FR-F01 to FR-F06) & Section 4.1
// Enterprise Zero-Leak Architecture: All API Keys remain secure on Supabase Cloud.

declare const Deno: any;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT = `
You are the SKAVIA AI Assistance Layer (SRS Section 3.1.F).
Analyze the user's natural language service request (which may be in English, Bengali, or Banglish) and extract:
1. "category_name": Must be one of:
   - "Electrical Solutions"
   - "HVAC & Cooling Systems"
   - "Plumbing & Waterline"
   - "IT & Security Infrastructure"
   - "Interior Renovation & Paint"
   - "Carpentry & Woodcraft"
2. "candidate_skills": Array of technical skills required.
3. "requirement_type": "Simple" (1 worker/skill) or "Complex" (multi-skill/team).
4. "urgency": "Low", "Medium", "High", or "Emergency".
5. "extracted_location": Location if mentioned (or null).
6. "estimated_budget": Numeric budget in BDT if mentioned (or null).
7. "clarifying_questions": Array of questions if location, timing, or required skill is unclear (SRS FR-F03).

Strict rules:
- Output MUST be valid JSON only. Do not add markdown backticks.
- Do NOT fabricate skills or qualifications (SRS FR-F06).
`;

Deno.serve(async (req: any) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { description } = await req.json();

    if (!description || typeof description !== "string") {
      return new Response(
        JSON.stringify({ error: "Missing or invalid 'description' parameter." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const groqKey = Deno.env.get("GROQ_API_KEY");
    const openRouterKey = Deno.env.get("OPENROUTER_API_KEY");
    const hfToken = Deno.env.get("HUGGINGFACE_TOKEN");

    // 1. Try Groq (Ultra-fast inference)
    if (groqKey) {
      try {
        const groqRes = await fetch("https://api.groq.com/openai/v1/chat/completions", {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${groqKey}`,
            "Content-Type": "application/json",
            "User-Agent": "SKAVIA-Backend/1.0",
          },
          body: JSON.stringify({
            model: "qwen/qwen3.8-27b",
            messages: [
              { role: "system", content: SYSTEM_PROMPT },
              { role: "user", content: description },
            ],
            temperature: 0.1,
          }),
        });

        if (groqRes.ok) {
          const data = await groqRes.json();
          const content = data.choices?.[0]?.message?.content;
          const parsed = parseJson(content);
          if (parsed) {
            return new Response(
              JSON.stringify({ ...parsed, provider: "groq", is_ai_assisted: true }),
              { headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
          }
        }
      } catch (_) {
        // Fall through to OpenRouter
      }
    }

    // 2. Try OpenRouter (Free model failover)
    if (openRouterKey) {
      try {
        const orRes = await fetch("https://openrouter.ai/api/v1/chat/completions", {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${openRouterKey}`,
            "Content-Type": "application/json",
            "HTTP-Referer": "https://skavia.app",
            "X-Title": "SKAVIA",
          },
          body: JSON.stringify({
            model: "nvidia/nemotron-3.5-lightning:free",
            messages: [
              { role: "system", content: SYSTEM_PROMPT },
              { role: "user", content: description },
            ],
            temperature: 0.1,
          }),
        });

        if (orRes.ok) {
          const data = await orRes.json();
          const content = data.choices?.[0]?.message?.content;
          const parsed = parseJson(content);
          if (parsed) {
            return new Response(
              JSON.stringify({ ...parsed, provider: "openrouter", is_ai_assisted: true }),
              { headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
          }
        }
      } catch (_) {
        // Fall through to Hugging Face
      }
    }

    // 3. Try Hugging Face Router
    if (hfToken) {
      try {
        const hfRes = await fetch("https://router.huggingface.co/v1/chat/completions", {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${hfToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo",
            messages: [
              { role: "system", content: SYSTEM_PROMPT },
              { role: "user", content: description },
            ],
            temperature: 0.1,
          }),
        });

        if (hfRes.ok) {
          const data = await hfRes.json();
          const content = data.choices?.[0]?.message?.content;
          const parsed = parseJson(content);
          if (parsed) {
            return new Response(
              JSON.stringify({ ...parsed, provider: "huggingface", is_ai_assisted: true }),
              { headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
          }
        }
      } catch (_) {
        // Fall through to Rule-based
      }
    }

    // 4. Deterministic Rule-Based Fallback (SRS FR-F05)
    const fallback = ruleBasedFallback(description);
    return new Response(
      JSON.stringify({ ...fallback, provider: "local_rule_fallback", is_ai_assisted: false }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

function parseJson(content: string) {
  try {
    return JSON.parse(content);
  } catch (_) {
    try {
      const cleaned = content.replace(/```json\s*/g, "").replace(/```\s*/g, "").trim();
      return JSON.parse(cleaned);
    } catch (_) {
      return null;
    }
  }
}

function ruleBasedFallback(text: string) {
  const lower = text.toLowerCase();
  let category = "Electrical Solutions";
  let skills = ["Three-Phase Industrial Wiring"];
  let requirementType = "Simple";
  let urgency = "Medium";

  if (lower.includes("ac") || lower.includes("cool") || lower.includes("gas") || lower.includes("ঠান্ডা")) {
    category = "HVAC & Cooling Systems";
    skills = ["HVAC Diagnostics", "Freon Gas Charging"];
  } else if (lower.includes("water") || lower.includes("pipe") || lower.includes("leak") || lower.includes("পানি")) {
    category = "Plumbing & Waterline";
    skills = ["Sanitary Plumbing", "Concealed Water Leakage Repair"];
  } else if (lower.includes("cctv") || lower.includes("camera") || lower.includes("wifi") || lower.includes("ক্যামেরা")) {
    category = "IT & Security Infrastructure";
    skills = ["IP Camera Configuration", "MikroTik Networking"];
  } else if (lower.includes("paint") || lower.includes("wall") || lower.includes("রং")) {
    category = "Interior Renovation & Paint";
    skills = ["Wall Waterproofing", "Acrylic Paint Application"];
  } else if (lower.includes("wood") || lower.includes("door") || lower.includes("কাঠ")) {
    category = "Carpentry & Woodcraft";
    skills = ["Solid Wood Door Crafting", "Furniture Fitting"];
  }

  if (lower.includes("urgent") || lower.includes("emergency") || lower.includes("জরুরি")) {
    urgency = "Emergency";
  }

  if ((lower.includes("ac") || lower.includes("cool")) && (lower.includes("paint") || lower.includes("wood"))) {
    requirementType = "Complex";
  }

  return {
    category_name: category,
    candidate_skills: skills,
    requirement_type: requirementType,
    urgency: urgency,
    extracted_location: null,
    estimated_budget: null,
    clarifying_questions: [],
  };
}
