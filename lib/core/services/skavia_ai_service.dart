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

    // 1. Try Groq (Llama 3.3 70B Versatile - Sub-second latency)
    try {
      if (AppConfig.groqApiKey.isNotEmpty) {
        final response = await http
            .post(
              Uri.parse(_groqEndpoint),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${AppConfig.groqApiKey}',
              },
              body: jsonEncode({
                'model': 'llama-3.3-70b-versatile',
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
      }
    } catch (e) {
      debugPrint('[SkaviaAiService Groq fallback]: $e');
    }

    // 2. Fallback to OpenRouter
    try {
      if (AppConfig.openRouterApiKey.isNotEmpty) {
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
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final reply = data['choices']?[0]?['message']?['content'] as String?;
          if (reply != null && reply.trim().isNotEmpty) {
            return reply.trim();
          }
        }
      }
    } catch (e) {
      debugPrint('[SkaviaAiService OpenRouter Error]: $e');
    }

    return 'SKAVIA AI is currently synchronizing with the central engine. Please try again in a few moments, or connect with our live verified specialists directly!';
  }

  /// Diagnoses a customer requirement from natural language and suggests category, title, & BDT budget
  Future<Map<String, dynamic>?> diagnoseRequirement(
    String userDescription,
  ) async {
    const diagnosticPrompt = '''
You are SKAVIA AI diagnostic engine. Analyze the user's service requirement description in Bangladesh.
Return ONLY a valid JSON object without markdown or code fences, with the following fields:
{
  "category_id": "cat_electrical" | "cat_plumbing" | "cat_ac_repair" | "cat_carpentry" | "cat_painting" | "cat_masonry" | "cat_appliances" | "cat_turnkey",
  "suggested_title": "Short professional title (max 6 words)",
  "budget_estimate": 1500,
  "urgency": "Emergency (Within 2 hours)" | "Standard (Within 24h)" | "Flexible Schedule",
  "technical_summary": "1-2 sentence technical summary of tools/scope needed in BDT context"
}
''';

    try {
      final response = await askSkaviaAi(
        prompt: '$diagnosticPrompt\n\nUser description: "$userDescription"',
      );

      // Clean response of potential markdown fences
      String cleaned = response.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      }
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }

      final parsed = jsonDecode(cleaned.trim()) as Map<String, dynamic>;
      return parsed;
    } catch (e) {
      debugPrint('[SkaviaAiService diagnoseRequirement Error]: $e');
      return null;
    }
  }
}
