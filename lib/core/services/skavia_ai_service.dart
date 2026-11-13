import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../app/config/app_config.dart';
import '../utils/supabase_guard.dart';
import 'skavia_ai_fallback_engine.dart';

class SkaviaAiService {
  final Future<String?> Function()? authTokenProvider;
  final http.Client _httpClient;

  SkaviaAiService({this.authTokenProvider, http.Client? httpClient})
    : _httpClient = httpClient ?? _sharedClient;

  static final http.Client _sharedClient = http.Client();

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

  /// Sends a conversational query to SKAVIA AI (Groq with OpenRouter & Pollinations fallbacks).
  Future<String> askSkaviaAi({
    required String prompt,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _defaultSystemPrompt},
      ...?conversationHistory,
      {'role': 'user', 'content': prompt},
    ];

    if (AppConfig.groqApiKey.isNotEmpty) {
      for (final modelName in ['llama-3.3-70b-versatile', 'llama-3.1-8b-instant']) {
        try {
          final response = await _httpClient
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

    if (AppConfig.openRouterApiKey.isNotEmpty) {
      try {
        final response = await _httpClient
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
            .timeout(const Duration(seconds: 8));

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

    try {
      final encodedPrompt = Uri.encodeComponent(prompt);
      final encodedSystem = Uri.encodeComponent(_defaultSystemPrompt);
      final pollinationsUrl = Uri.parse(
        'https://text.pollinations.ai/$encodedPrompt?system=$encodedSystem&model=openai',
      );
      final response = await _httpClient
          .get(pollinationsUrl)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final bodyText = utf8.decode(response.bodyBytes).trim();
        if (bodyText.isNotEmpty &&
            !bodyText.toLowerCase().contains('free limit reached') &&
            !bodyText.toLowerCase().contains('rate limit')) {
          return bodyText;
        }
      }
    } catch (e) {
      debugPrint('[SkaviaAiService Pollinations notice]: $e');
    }

    return SkaviaAiFallbackEngine.generateChatResponse(prompt);
  }

  Future<String?> _resolveCallerBearerToken() async {
    final provider = authTokenProvider;
    if (provider != null) {
      try {
        final token = await provider();
        if (token != null && token.trim().isNotEmpty) return token.trim();
      } catch (_) {}
    }
    try {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        final idToken = await fbUser.getIdToken();
        if (idToken != null && idToken.trim().isNotEmpty) {
          return idToken.trim();
        }
      }
    } catch (_) {}
    final sbClient = tryGetSupabaseClient();
    final sbToken = sbClient?.auth.currentSession?.accessToken;
    if (sbToken != null && sbToken.trim().isNotEmpty) {
      return sbToken.trim();
    }
    return null;
  }

  /// Diagnoses a customer requirement from natural language using the Edge
  /// Function when signed in, with LLM and deterministic SRS fallbacks.
  Future<Map<String, dynamic>?> diagnoseRequirement(
    String userDescription,
  ) async {
    try {
      final callerToken = await _resolveCallerBearerToken();
      if (callerToken != null && callerToken.isNotEmpty) {
        final baseUrl = AppConfig.supabaseUrl.replaceAll(RegExp(r'/+$'), '');
        final edgeRes = await _httpClient
            .post(
              Uri.parse('$baseUrl/functions/v1/analyze-requirement'),
              headers: {
                'Content-Type': 'application/json',
                'apikey': AppConfig.supabaseAnonKey,
                'Authorization': 'Bearer $callerToken',
              },
              body: jsonEncode({'description': userDescription}),
            )
            .timeout(const Duration(seconds: 8));

        if (edgeRes.statusCode == 200) {
          final parsed =
              jsonDecode(utf8.decode(edgeRes.bodyBytes))
                  as Map<String, dynamic>;
          final catName = parsed['category_name']?.toString() ?? '';
          String catId = 'cat_electrical';
          if (catName.contains('HVAC') || catName.contains('Cooling')) {
            catId = 'cat_ac_hvac';
          } else if (catName.contains('Plumbing')) {
            catId = 'cat_plumbing';
          } else if (catName.contains('Carpentry') ||
              catName.contains('Renovation')) {
            catId = 'cat_civil_carpentry';
          } else if (catName.contains('IT') || catName.contains('Security')) {
            catId = 'cat_it_creative';
          }

          final candidateSkills =
              (parsed['candidate_skills'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              <String>[];
          final ruleFallback = SkaviaAiFallbackEngine.diagnoseRequirement(
            userDescription,
          );
          final estBudget =
              (parsed['estimated_budget'] as num?)?.toDouble() ??
              (ruleFallback['budget_estimate'] as num?)?.toDouble() ??
              1500.0;
          final rawUrgency = parsed['urgency']?.toString() ?? '';
          final urgency = rawUrgency.isNotEmpty ? rawUrgency : 'Medium';

          return {
            'category_id': catId,
            'category_name': catName.isNotEmpty
                ? catName
                : 'Electrical Solutions',
            'suggested_title':
                parsed['suggested_title']?.toString().trim().isNotEmpty == true
                ? parsed['suggested_title']
                : ruleFallback['suggested_title'],
            'budget_estimate': estBudget,
            'requirement_type':
                parsed['requirement_type']?.toString() ?? 'Simple',
            'urgency': urgency,
            'skills': candidateSkills.isNotEmpty
                ? candidateSkills
                : ruleFallback['skills'],
            'technical_summary': candidateSkills.isNotEmpty
                ? 'Required Skills: ${candidateSkills.join(", ")}'
                : ruleFallback['technical_summary'],
            'extracted_location': parsed['extracted_location'],
            'clarifying_questions': parsed['clarifying_questions'] ?? [],
            'is_ai_assisted': parsed['is_ai_assisted'] ?? true,
            'provider': parsed['provider'] ?? 'edge_function',
          };
        }
      }
    } catch (e) {
      debugPrint('[SkaviaAiService Edge Function notice]: $e');
    }

    if (AppConfig.groqApiKey.isNotEmpty ||
        AppConfig.openRouterApiKey.isNotEmpty) {
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
        final ruleFallback = SkaviaAiFallbackEngine.diagnoseRequirement(
          userDescription,
        );
        return {
          'category_id': parsed['category_id'] ?? ruleFallback['category_id'],
          'category_name':
              parsed['category_name'] ?? ruleFallback['category_name'],
          'suggested_title':
              parsed['suggested_title'] ?? ruleFallback['suggested_title'],
          'budget_estimate':
              parsed['budget_estimate'] ?? ruleFallback['budget_estimate'],
          'urgency': parsed['urgency'] ?? ruleFallback['urgency'],
          'skills':
              (parsed['skills'] is List &&
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

    return SkaviaAiFallbackEngine.diagnoseRequirement(userDescription);
  }
}
