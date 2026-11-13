/// Deterministic, offline-ready Dhaka trade rate card and classification engine
/// shared by [SkaviaAiService] when remote LLM inference is unavailable.
abstract class SkaviaAiFallbackEngine {
  static final RegExp _acPattern = RegExp(
    r'\b(ac|a/c|hvac|cool|cooling|cooler|chiller|freon|refrigerant|compressor|thermostat|gas\s*refill|air\s*con(?:ditioner|ditioning)?)\b',
  );
  static final RegExp _plumbingPattern = RegExp(
    r'\b(water|pipe|pipes|piping|leak|leakage|leaking|plumb|plumber|plumbing|sink|toilet|commode|bathroom|basin|drain|faucet|tap|sanitary|pump)\b',
  );
  static final RegExp _carpentryPattern = RegExp(
    r'\b(wood|woodcraft|carpenter|carpentry|door|doors|lock|hinge|furniture|cabinet|polish|varnish|shelf|table)\b',
  );
  static final RegExp _electricalPattern = RegExp(
    r'\b(electric|electrical|electrician|wiring|rewire|switch|switchboard|socket|breaker|mcb|fuse|circuit|voltage|short\s*circuit|light|fan)\b',
  );

  /// Grounded trade classification engine based on SKAVIA SRS Section 3.1.C & 3.1.F.
  static Map<String, dynamic> diagnoseRequirement(String text) {
    final lower = text.toLowerCase();
    String catId = 'cat_electrical';
    String catName = 'Electrical Solutions';
    String title = 'Electrical Wiring & Circuit Inspection';
    double budget = 1200.0;
    String urgency = 'Standard';
    List<String> skills = ['Circuit Diagnostics', 'Switchboard Repair'];

    if (_acPattern.hasMatch(lower) ||
        lower.contains('এসি') ||
        lower.contains('ঠান্ডা')) {
      catId = 'cat_ac_hvac';
      catName = 'HVAC & Cooling Systems';
      title = 'AC Servicing & Gas Refill';
      budget = 2000.0;
      skills = ['Inverter AC Servicing', 'Freon Gas Leak Testing'];
    } else if (_plumbingPattern.hasMatch(lower) ||
        lower.contains('পানি') ||
        lower.contains('প্লাম্বার')) {
      catId = 'cat_plumbing';
      catName = 'Sanitary & Waterline';
      title = 'Sanitary Plumbing & Leakage Repair';
      budget = 1000.0;
      skills = ['Concealed Leakage Repair', 'PVC Pipe Fitting'];
    } else if (_carpentryPattern.hasMatch(lower) ||
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

  /// Grounded Dhaka trade & turnkey project knowledge assistant (zero-latency fallback).
  static String generateChatResponse(String prompt) {
    final lower = prompt.toLowerCase();
    final isBengali =
        RegExp(r'[\u0980-\u09FF]').hasMatch(prompt) ||
        lower.contains('khoroch') ||
        lower.contains('lagbe') ||
        lower.contains('koto') ||
        lower.contains('ki vabe');

    if (lower == 'hi' ||
        lower == 'hello' ||
        lower == 'hey' ||
        lower.contains('kire') ||
        lower.contains('kemon') ||
        lower.contains('kemon aso') ||
        lower.contains('kemon acho') ||
        lower.contains('salam') ||
        lower.contains('assalamu') ||
        lower.contains('ki obostha') ||
        lower.contains('ki korso')) {
      if (isBengali) {
        return 'ওয়ালাইকুমুস সালাম! আমি SKAVIA AI — আলহামদুলিল্লাহ্‌ বেশ ভালো আছি! 😊\n\nআপনার বাসা বা অফিসের কোনো টেকনিক্যাল সার্ভিস (ইলেকট্রিশিয়ান, এসি, প্লাম্বিং, কাঠের কাজ) বা প্রজেক্ট সম্পর্কিত বিষয়ে কি সহযোগিতা করতে পারি? যেকোনো প্রশ্ন নির্দ্বিধায় জিজ্ঞাসা করুন!';
      } else {
        return 'Hello! I am SKAVIA AI, feeling great and ready to assist you! 😊\n\nHow can I help you today? Whether you need price estimation, technical diagnostics for AC/Electrical/Plumbing, or verified technicians in Dhaka, I am right here!';
      }
    }

    if (lower.contains('timon') ||
        lower.contains('biswas') ||
        lower.contains('তিমোন') ||
        lower.contains('creator') ||
        lower.contains('banise') ||
        lower.contains('who made')) {
      return isBengali
          ? '🌟 **SKAVIA** প্ল্যাটফর্মটি **তিমোন বিশ্বাস (Timon Biswas)** কর্তৃক একক দক্ষতায় সম্পূর্ণ আর্কিটেক্টেড ও ডেভেলপ করা হয়েছে। এটি বাংলাদেশের অন-ডিমান্ড টেকনিক্যাল ওয়ার্কফোর্স ও টার্নকি প্রজেক্ট ব্যবস্থাপনার একটি প্রিমিয়াম প্ল্যাটফর্ম।'
          : '🌟 **SKAVIA** is envisioned, architected, and built by **Timon Biswas** as a high-integrity on-demand skilled workforce and turnkey project platform for Bangladesh.';
    }

    if (lower.contains('rate') ||
        lower.contains('dam') ||
        lower.contains('khoroch') ||
        lower.contains('koto taka') ||
        lower.contains('price') ||
        lower.contains('charge') ||
        lower.contains('খরচ') ||
        lower.contains('দাম কত')) {
      if (isBengali) {
        return '''📊 **SKAVIA অফিসিয়াল রেট কার্ড (ঢাকা মেট্রো):**

1. ⚡ **ইলেকট্রিক্যাল সার্ভিস:**
   - বেসিক ভিজিট ও ফল্ট ডায়াগনস্টিক: ৳ ৩০০ – ৫০০
   - গ্যাং সুইচ / পাওয়ার সকেট ফিটিং: ৳ ২০০ – ৩৫০
   - সার্কিট ব্রেকার / DB মেরামত: ৳ ৮০০ – ১,৫০০

2. ❄️ **এসি (AC) সার্ভিসিং:**
   - ইনডোর-আউটডোর জেট ওয়াশ: ৳ ৮০০ – ১,২০০
   - ফ্রিন গ্যাস রিফিল (R32 / R410A): ৳ ২,০০০ – ৩,২০০
   - কম্প্রেসর ও ক্যাপাসিটর মেরামত: ৳ ১,২০০ – ১,৮০০

3. 🚰 **প্লাম্বিং ও স্যানিটারি:**
   - পাইপ লিকেজ মেরামত: ৳ ৫০০ – ৮০০
   - ট্যাপ, শাওয়ার বা কমোড ফিটিং: ৳ ৪০০ – ৭০০
   - পানির মোটর ও পাম্প ইন্সটলেশন: ৳ ১,০০০ – ১,৮০০

4. 🪚 **সিভিল ও কার্পেন্ট্রি:**
   - দরজার লক ও হ্যান্ডেল ফিটিং: ৳ ৪০০ – ৬০০
   - ফার্নিচার মেরামত ও পলিশ: ৳ ১,২০০ – ৩,০০০

🛡️ **১০০% এসক্রো সুরক্ষা:** কাজ সম্পূর্ণ হওয়ার আগে নগদ টাকা দেওয়ার কোনো ঝামেলা নেই। ওটিপি দিয়ে কাজ ভেরিফাই করার পরেই টাকা রিলিজ হয়।''';
      }
    }

    if (_acPattern.hasMatch(lower) ||
        lower.contains('গরম') ||
        lower.contains('বাতাস') ||
        lower.contains('এসি') ||
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

    if (_electricalPattern.hasMatch(lower) ||
        lower.contains('কারেন্ট') ||
        lower.contains('বিদ্যুৎ')) {
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
      return 'ধন্যবাদ আপনার মেসেজের জন্য! আমি SKAVIA AI।\n\n'
          'আপনার বাসা বা অফিসের যেকোনো টেকনিক্যাল সমস্যা (যেমন: এসি কুলিং বা গ্যাস, ইলেকট্রিক ব্রেকার বা ওয়্যারিং, পানির মোটর বা পাইপ লিকেজ, কাঠের কাজ) অথবা যেকোনো কাজের বাজেট জানতে চাইলে বলুন। আমি সঠিক ঢাকা মার্কেট রেট ও সমাধান জানিয়ে দিচ্ছি!';
    } else {
      return 'Thank you for your message! I am SKAVIA AI.\n\n'
          'I am ready to help you with technical diagnostics, service rate cards in Dhaka (AC, Electrical, Plumbing, Carpentry, IT), or booking certified technicians with 100% Escrow Protection. Please describe your requirement, and I will assist you immediately!';
    }
  }
}

