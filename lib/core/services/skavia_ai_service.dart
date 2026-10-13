import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../app/config/app_config.dart';

class SkaviaAiService {
  static const String _groqEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _openRouterEndpoint =
      'https://openrouter.ai/api/v1/chat/completions';

  static const String _defaultSystemPrompt = '''
You are SKAVIA AI (skavia AI), the official ultra-fast intelligent copilot and technical consultant for the SKAVIA platform in Bangladesh.
SKAVIA is the premier on-demand skilled workforce and turnkey business project platform in Dhaka and across Bangladesh.

Key Knowledge & Guidelines:
1. Provide accurate advice for skilled trades: Electrical, Plumbing, HVAC/AC Repair, Carpentry, Painting & Polish, Masonry & Tiles, Appliance Repair, and Corporate IT/Security.
2. Provide realistic pricing estimates in Bangladeshi Taka (৳ BDT) based on prevailing market rates in Dhaka.
3. For business clients, guide them through Turnkey Business Projects (restaurants, offices, retail stores, clinics) with multi-trade team coordination.
4. Emphasize SKAVIA's safety guarantees: 100% Escrow Protection, Anti-fraud 4-digit Job OTP verification, and Verified Background-checked Specialists.
5. Communicate fluently in English or Bengali (বাংলা) depending on user preference. Keep responses polite, highly structured, practical, and concise.
''';

  /// Sends a conversational query to SKAVIA AI (Groq ultra-fast with OpenRouter fallback)
  Future<String> askSkaviaAi({
    required String prompt,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _defaultSystemPrompt},
      ...?conversationHistory,
      {'role': 'user', 'content': prompt},
    ];

    // 1. Try Groq (Ultra-fast LLM inference)
    if (AppConfig.groqApiKey.isNotEmpty) {
      for (final modelName in ['openai/gpt-oss-120b', 'qwen/qwen3.8-27b']) {
        try {
          final response = await http
              .post(
                Uri.parse(_groqEndpoint),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer ${AppConfig.groqApiKey}',
                },
                body: jsonEncode({
                  'model': modelName,
                  'messages': messages,
                  'temperature': 0.7,
                  'max_tokens': 1024,
                }),
              )
              .timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final data = jsonDecode(utf8.decode(response.bodyBytes));
            final reply =
                data['choices']?[0]?['message']?['content'] as String?;
            if (reply != null && reply.trim().isNotEmpty) {
              return reply.trim();
            }
          }
        } catch (e) {
          debugPrint('[SkaviaAiService Groq $modelName notice]: $e');
        }
      }
    }

    // 2. Fallback to OpenRouter (Meta Llama 3.3 70B Instruct)
    if (AppConfig.openRouterApiKey.isNotEmpty) {
      try {
        final response = await http
            .post(
              Uri.parse(_openRouterEndpoint),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${AppConfig.openRouterApiKey}',
                'HTTP-Referer': 'https://skavia.com',
                'X-Title': 'SKAVIA AI Mobile',
              },
              body: jsonEncode({
                'model': 'meta-llama/llama-3.3-70b-instruct',
                'messages': messages,
                'temperature': 0.7,
                'max_tokens': 1024,
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final reply = data['choices']?[0]?['message']?['content'] as String?;
          if (reply != null && reply.trim().isNotEmpty) {
            return reply.trim();
          }
        }
      } catch (e) {
        debugPrint('[SkaviaAiService OpenRouter notice]: $e');
      }
    }

    // 3. Resilient Grounded Trade Knowledge Engine (Dhaka Trade & Escrow Intelligence)
    return _generateGroundedTradeResponse(prompt);
  }

  /// Diagnoses a customer requirement from natural language:
  /// First calls Supabase Edge Function `analyze-requirement` (server-side keys).
  /// Falls back to direct Groq/OpenRouter if configured, or deterministic trade rule engine.
  Future<Map<String, dynamic>?> diagnoseRequirement(
    String userDescription,
  ) async {
    // 1. Try Supabase Edge Function (Zero API key exposure)
    try {
      final edgeRes = await http
          .post(
            Uri.parse('${AppConfig.supabaseUrl}/functions/v1/analyze-requirement'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': AppConfig.supabaseAnonKey,
              'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
            },
            body: jsonEncode({'description': userDescription}),
          )
          .timeout(const Duration(seconds: 8));

      if (edgeRes.statusCode == 200) {
        final parsed = jsonDecode(utf8.decode(edgeRes.bodyBytes)) as Map<String, dynamic>;
        final catName = parsed['category_name']?.toString() ?? '';
        String catId = 'cat_electrical';
        if (catName.contains('HVAC') || catName.contains('Cooling')) {
          catId = 'cat_ac_hvac';
        } else if (catName.contains('Plumbing')) {
          catId = 'cat_plumbing';
        } else if (catName.contains('Carpentry')) {
          catId = 'cat_civil_carpentry';
        }

        final candidateSkills = (parsed['candidate_skills'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final estBudget = (parsed['estimated_budget'] as num?)?.toDouble() ?? 1500.0;

        return {
          'category_id': catId,
          'category_name': catName.isNotEmpty ? catName : 'Electrical Solutions',
          'suggested_title': parsed['suggested_title'] ?? 'Certified Trade Requirement',
          'budget_estimate': estBudget,
          'urgency': parsed['urgency'] ?? 'Standard',
          'skills': candidateSkills,
          'technical_summary': candidateSkills.isNotEmpty
              ? 'Required Skills: ${candidateSkills.join(", ")}'
              : 'Verified Trade Assessment',
          'provider': parsed['provider'] ?? 'edge_function',
        };
      }
    } catch (e) {
      debugPrint('[SkaviaAiService Edge Function notice]: $e');
    }

    // 2. Direct Groq / OpenRouter Fallback if compile-time keys provided
    if (AppConfig.groqApiKey.isNotEmpty || AppConfig.openRouterApiKey.isNotEmpty) {
      const diagnosticPrompt = '''
Analyze the user's service requirement in Bangladesh. Return ONLY a valid JSON object without markdown fences:
{
  "category_id": "cat_electrical" | "cat_plumbing" | "cat_ac_hvac" | "cat_civil_carpentry",
  "category_name": "Trade Category Name",
  "suggested_title": "Concise professional title (max 5 words)",
  "budget_estimate": 1500,
  "urgency": "Standard" | "Emergency",
  "skills": ["Primary Skill", "Secondary Skill"],
  "technical_summary": "1 sentence technical summary of trade tools and scope"
}
''';
      try {
        final reply = await askSkaviaAi(
          prompt: '$diagnosticPrompt\n\nUser request: "$userDescription"',
        );
        String cleaned = reply.trim();
        if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
        if (cleaned.startsWith('```')) cleaned = cleaned.substring(3);
        if (cleaned.endsWith('```')) {
          cleaned = cleaned.substring(0, cleaned.length - 3);
        }

        final parsed = jsonDecode(cleaned.trim()) as Map<String, dynamic>;
        final ruleFallback = _ruleBasedTradeDiagnosis(userDescription);
        return {
          'category_id': parsed['category_id'] ?? ruleFallback['category_id'],
          'category_name':
              parsed['category_name'] ?? ruleFallback['category_name'],
          'suggested_title':
              parsed['suggested_title'] ?? ruleFallback['suggested_title'],
          'budget_estimate':
              parsed['budget_estimate'] ?? ruleFallback['budget_estimate'],
          'urgency': parsed['urgency'] ?? ruleFallback['urgency'],
          'skills': (parsed['skills'] is List &&
                  (parsed['skills'] as List).isNotEmpty)
              ? (parsed['skills'] as List).map((e) => e.toString()).toList()
              : ruleFallback['skills'],
          'technical_summary':
              parsed['technical_summary'] ?? ruleFallback['technical_summary'],
          'provider': 'ai_inference',
        };
      } catch (e) {
        debugPrint('[SkaviaAiService direct model error]: $e');
      }
    }

    // 3. Deterministic Grounded Trade Classifier (SRS Section 3.1.F / FR-F05)
    return _ruleBasedTradeDiagnosis(userDescription);
  }

  /// Grounded trade classification engine strictly based on SKAVIA SRS Section 3.1.C & 3.1.F
  Map<String, dynamic> _ruleBasedTradeDiagnosis(String text) {
    final lower = text.toLowerCase();
    String catId = 'cat_electrical';
    String catName = 'Electrical Solutions';
    String title = 'Electrical Wiring & Circuit Inspection';
    double budget = 1200.0;
    String urgency = 'Standard';
    List<String> skills = ['Circuit Diagnostics', 'Switchboard Repair'];

    if (lower.contains('ac') ||
        lower.contains('cool') ||
        lower.contains('gas') ||
        lower.contains('air') ||
        lower.contains('এসি') ||
        lower.contains('ঠান্ডা')) {
      catId = 'cat_ac_hvac';
      catName = 'HVAC & Cooling Systems';
      title = 'AC Servicing & Gas Refill';
      budget = 2000.0;
      skills = ['Inverter AC Servicing', 'Freon Gas Leak Testing'];
    } else if (lower.contains('water') ||
        lower.contains('pipe') ||
        lower.contains('leak') ||
        lower.contains('sink') ||
        lower.contains('toilet') ||
        lower.contains('পানি') ||
        lower.contains('প্লাম্বার')) {
      catId = 'cat_plumbing';
      catName = 'Sanitary & Waterline';
      title = 'Sanitary Plumbing & Leakage Repair';
      budget = 1000.0;
      skills = ['Concealed Leakage Repair', 'PVC Pipe Fitting'];
    } else if (lower.contains('wood') ||
        lower.contains('door') ||
        lower.contains('lock') ||
        lower.contains('furniture') ||
        lower.contains('কাঠ') ||
        lower.contains('ফার্নিচার')) {
      catId = 'cat_civil_carpentry';
      catName = 'Civil & Carpentry Woodcraft';
      title = 'Furniture & Woodcraft Installation';
      budget = 1500.0;
      skills = ['Door Lock Alignment', 'Solid Wood Restoration'];
    }

    if (lower.contains('urgent') ||
        lower.contains('emergency') ||
        lower.contains('asap') ||
        lower.contains('জরুরি')) {
      urgency = 'Emergency';
    }

    return {
      'category_id': catId,
      'category_name': catName,
      'suggested_title': title,
      'budget_estimate': budget,
      'urgency': urgency,
      'skills': skills,
      'technical_summary': 'Required Trade Scope: ${skills.join(", ")}',
      'provider': 'deterministic_srs_engine',
    };
  }

  /// Grounded Dhaka trade & turnkey project knowledge assistant (zero-latency fallback)
  String _generateGroundedTradeResponse(String prompt) {
    final lower = prompt.toLowerCase();
    final isBengali = RegExp(r'[\u0980-\u09FF]').hasMatch(prompt) ||
        lower.contains('khoroch') ||
        lower.contains('lagbe') ||
        lower.contains('koto') ||
        lower.contains('ki vabe');

    if (lower.contains('ac') ||
        lower.contains('cool') ||
        lower.contains('গরম') ||
        lower.contains('বাতাস') ||
        lower.contains('এসি') ||
        lower.contains('gas') ||
        lower.contains('ঠান্ডা')) {
      if (isBengali) {
        return '''🔧 **SKAVIA AI — এসি (AC) ডায়াগনস্টিক ও ঢাকা মার্কেট রেট**

আপনার এসিতে গরম বাতাস আসা বা কুলিং কম হওয়ার প্রধান কারণ ও সম্ভাব্য খরচ:
1. **ইনডোর ফিল্টার ও জেট ওয়াশ:** ময়লা জমে বাতাস চলাচল ব্যাহত হওয়া। মাস্টার ক্লিনিং: **৳ ৮০০ – ১,২০০**।
2. **রেফ্রিজার্যান্ট (গ্যাস) লিকেজ:** পাইপ বা গ্যাস ভালভ পরীক্ষা ও রিফিল (R32 / R410A): **৳ ২,০০০ – ৩,২০০**।
3. **ক্যাপাসিটর সমস্যা:** আউটডোর কম্প্রেসর চালু না হওয়া। পার্টস ও ফিটিং: **৳ ১,২০০ – ১,৮০০**।

🛡️ **SKAVIA নিরাপত্তা:** কাজ শুরুর আগে ৪-ডিজিট ওটিপি (OTP) দিন এবং সন্তুষ্ট হয়ে কাজ শেষে এসক্রো (Escrow) পেমেন্ট রিলিজ করুন। 'Post Requirement' চেপে এখনই টেকনিশিয়ান বুক করতে পারেন!''';
      } else {
        return '''🔧 **SKAVIA AI — AC Diagnostic & Dhaka Market Estimates**

Probable causes and estimated repair costs in Dhaka:
1. **Clogged Filter / Jet Cleaning:** Reduces airflow. Master servicing: **৳800 – ৳1,200**.
2. **Refrigerant Gas Leakage:** Pressure testing & full gas recharge (R32/R410A): **৳2,000 – ৳3,200**.
3. **Capacitor Failure:** If compressor fails to kick in. Replacement: **৳1,200 – ৳1,800**.

🛡️ **SKAVIA Guarantee:** All jobs feature 100% Escrow Protection and 4-digit Job OTP verification. Use the 'Post Requirement' button to connect with certified technicians near you!''';
      }
    }

    if (lower.contains('electric') ||
        lower.contains('কারেন্ট') ||
        lower.contains('বিদ্যুৎ') ||
        lower.contains('wiring') ||
        lower.contains('switch') ||
        lower.contains('fuse') ||
        lower.contains('mcb')) {
      if (isBengali) {
        return '''⚡ **SKAVIA AI — ইলেকট্রিক্যাল ডায়াগনস্টিক ও সার্ভিস রেট**

1. **সার্কিট ব্রেকার / MCB বারবার ট্রিপিং:** শর্ট সার্কিট বা ওভারলোডের লক্ষণ। চেকিং ও সমাধান: **৳ ৫০০ – ৮০০**।
2. **সুইচবোর্ড বা সকেট রিপ্লেসমেন্ট:** প্রিমিয়াম গ্যাং সুইচ ফিটিং: **৳ ৩০০ – ৫০০** (প্রতি পয়েন্ট)।
3. **কনসিল্ড ওয়্যারিং ফল্ট ডিটেকশন:** মেগার টেস্ট ও ক্যাবল ট্রেসিং: **৳ ১,০০০ – ২,০০০**।

🛡️ SKAVIA প্ল্যাটফর্মে সকল ইলেকট্রিশিয়ান গভঃ অনুমোদিত ট্রেড সার্টিফিকেট ভেরিফাইড।''';
      } else {
        return '''⚡ **SKAVIA AI — Electrical Diagnosis & Rate Card**

1. **MCB / Breaker Tripping:** Short circuit diagnosis: **৳500 – ৳800**.
2. **Switchboard & Socket Installation:** Standard gang switch setup: **৳300 – ৳500** per point.
3. **Concealed Wiring Fault Inspection:** Cable tracing & fault isolation: **৳1,000 – ৳2,000**.

🛡️ Backed by SKAVIA 100% Escrow Protection.''';
      }
    }

    if (lower.contains('water') ||
        lower.contains('pipe') ||
        lower.contains('plumb') ||
        lower.contains('পানি') ||
        lower.contains('লিক') ||
        lower.contains('প্লাম্বার')) {
      if (isBengali) {
        return '''🚰 **SKAVIA AI — স্যানিটারি ও প্লাম্বিং সমাধান**

1. **কনসিল্ড পাইপ লিকেজ মেরামত:** দেওয়াল না ভেঙে প্রেসার টেস্টিং ও জয়েন্ট রিপেয়ার: **৳ ১,২০০ – ২,৫০০**।
2. **কমোড / বেসিন ফিটিং:** নতুন স্যানিটারি ওয়্যার ইনস্টলেশন: **৳ ৮০০ – ১,৫০০**।
3. **পানির পাম্প সার্ভিসিং:** মোটর বিয়ারিং বা সিল রিপ্লেসমেন্ট: **৳ ১,৫০০ – ২,৫০০**।

🛡️ SKAVIA ভেরিফাইড প্লাম্বারদের মাধ্যমে নিশ্চিত পান দীর্ঘস্থায়ী ওয়াটারপ্রুফিং ও গ্যারান্টি।''';
      } else {
        return '''🚰 **SKAVIA AI — Sanitary & Plumbing Diagnosis**

1. **Concealed Pipe Leak Repair:** Leak detection & joint fix: **৳1,200 – ৳2,500**.
2. **Basin & Commode Fitting:** Sanitary ware installation: **৳800 – ৳1,500**.
3. **Water Pump Servicing:** Seal or bearing repair: **৳1,500 – ৳2,500**.

🛡️ Verified technicians with genuine parts guarantee.''';
      }
    }

    if (lower.contains('wood') ||
        lower.contains('carpenter') ||
        lower.contains('door') ||
        lower.contains('lock') ||
        lower.contains('furniture') ||
        lower.contains('কাঠ') ||
        lower.contains('দরজা') ||
        lower.contains('ফার্নিচার')) {
      if (isBengali) {
        return '''🪚 **SKAVIA AI — কার্পেন্ট্রি ও উডক্রাফট সমাধান**

1. **দরজার লক ও হিঞ্জ ফিটিং:** সিকিউরিটি লক বা মাস্টার লক ইনস্টলেশন: **৳ ৪০০ – ৮০০**।
2. **ফার্নিচার মেরামত ও পলিশ:** বার্নিশ বা ল্যাকার পলিশ সার্ভিস: **৳ ১,২০০ – ৩,৫০০**।
3. **কিচেন কেবিনেট ও কাঠের কাজ:** মডুলার উডওয়ার্ক ও শিট ফিটিং: প্রজেক্ট সাইজ অনুযায়ী রেট।

🛡️ ১০০% প্রিমিয়াম ফিনিশিং ও এসক্রো সিকিউরিটি নিশ্চিত।''';
      } else {
        return '''🪚 **SKAVIA AI — Carpentry & Woodcraft Diagnosis**

1. **Door Lock & Hinge Fitting:** Lock installation & alignment: **৳400 – ৳800**.
2. **Furniture Restoration & Polish:** Lacquer / French polish: **৳1,200 – ৳3,500**.
3. **Kitchen Cabinet Repair:** Modular woodwork & hydraulic hinge replacement: **৳1,500 – ৳4,000**.

🛡️ Verified carpenters with 100% Escrow Protection.''';
      }
    }

    if (lower.contains('app') ||
        lower.contains('flutter') ||
        lower.contains('developer') ||
        lower.contains('code') ||
        lower.contains('software') ||
        lower.contains('website')) {
      if (isBengali) {
        return '''💻 **SKAVIA AI — আইটি ও মোবাইল অ্যাপ প্রজেক্ট সমাধান**

SKAVIA অ্যাপে আপনি ফুল-স্ট্যাক ডেভেলপার, UI/UX ডিজাইনার ও QA স্পেশালিস্টের সমন্বয়ে কাস্টম টিম তৈরি করতে পারেন।

📌 **প্রস্তাবিত টিম স্ট্রাকচার:**
1. **Lead Flutter Engineer:** ক্রস-প্ল্যাটফর্ম মোবাইল অ্যাপ ও স্টেট ম্যানেজমেন্ট।
2. **Backend & Supabase / Node.js Architect:** ডেটাবেস, API ও এসক্রো পেমেন্ট গেটওয়ে।
3. **Product UI/UX Designer:** ফিগমা প্রোটোটাইপিং ও ইউজার জার্নি ডিজাইন।

💡 উপরের **'Match'** ট্যাবে ক্লিক করে আপনার রিকোয়ারমেন্টের ভিত্তিতে টিম স্ট্রাকচার ও বাজেট রিভিও করতে পারেন!''';
      } else {
        return '''💻 **SKAVIA AI — Software & App Development Consulting**

SKAVIA enables you to assemble agile teams with certified developers, designers, and QA engineers across Bangladesh.

📌 **Recommended Team:**
1. **Lead Flutter Engineer:** Mobile frontend, reactive UI, and state architecture.
2. **Backend Architect:** Supabase / PostgreSQL, payment gateways, and security.
3. **UI/UX Designer:** Modern mobile wireframes and interactive prototypes.

💡 Switch to the **'Match'** tab at the top to review complete team compositions and budget breakdowns!''';
      }
    }

    if (isBengali) {
      return '''✨ **SKAVIA AI — আপনার বিশ্বস্ত প্রজেক্ট ও ট্রেড সহকারী**

আমি SKAVIA AI। ঢাকা ও সারাদেশে দক্ষ টেকনিশিয়ান (ইলেকট্রিশিয়ান, এসি ইঞ্জিনিয়ার, প্লাম্বার, কার্পেন্টার) এবং আইটি/বিজনেস প্রজেক্টের সমাধান দিতে প্রস্তুত।

💡 **আপনি কী জানতে চান?**
- এসি, ওয়্যারিং বা প্লাম্বিং সমস্যার সমাধান ও বাজারমূল্য (৳ BDT)
- বাসা বা অফিসের জন্য প্রজেক্ট টিম গঠন ও বাজেট এস্টিমেশন
- এসক্রো (Escrow) পেমেন্ট নিরাপত্তা ও ৪-ডিজিট জব ওটিপি ভেরিফিকেশন

আপনার নির্দিষ্ট প্রয়োজন বা সমস্যাটি লিখুন, আমি তৎক্ষণাৎ সমাধান ও সহায়তা প্রদান করছি!''';
    } else {
      return '''✨ **SKAVIA AI — Your Intelligent Trade & Project Assistant**

I am SKAVIA AI, your enterprise copilot for skilled workforce matching and turnkey project execution across Bangladesh.

💡 **How can I assist you today?**
- Real-time diagnostic guidance and Dhaka rate cards (৳ BDT) for AC, Electrical, Plumbing & Carpentry
- Project team composition matching for turnkey residential & commercial renovations
- Safe job transactions backed by 100% Escrow Protection and 4-digit verification OTP

Please describe your technical requirement or question, and I will assist you immediately!''';
    }
  }
}

