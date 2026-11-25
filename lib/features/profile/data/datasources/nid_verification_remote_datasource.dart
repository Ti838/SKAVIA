import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/config/app_config.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../models/nid_verification_status_model.dart';

/// Handles NID submission and status inspection for any customer or worker
class NidVerificationRemoteDataSource {
  static const String _cachePrefix = 'skavia_nid_status_';

  SupabaseClient? get _supabase => tryGetSupabaseClient();

  /// Reads cached status for immediate UI response
  NidVerificationStatusModel? getCachedStatus(String userId) {
    try {
      final raw = LocalCacheService.instance.get('$_cachePrefix$userId');
      if (raw is Map) {
        return NidVerificationStatusModel.fromJson(Map<String, dynamic>.from(raw));
      }
    } catch (_) {}
    return null;
  }

  /// Fetches current verification status from cloud API or Supabase
  Future<NidVerificationStatusModel> fetchStatus(String userId) async {
    // 1. Try Vercel API
    try {
      final url = Uri.parse(
        '${AppConfig.releaseApiBaseUrl}/api/public/user/nid-verification?userId=$userId',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final model = NidVerificationStatusModel.fromJson(data);
        _cacheModel(userId, model);
        return model;
      }
    } catch (e) {
      debugPrint('[NidVerification Fetch Cloud Warning]: $e');
    }

    // 2. Direct Supabase Fallback
    try {
      final client = _supabase;
      if (client != null) {
        final row = await client
            .from('users')
            .select('verification_status, privacy_settings, full_name')
            .eq('user_id', userId)
            .maybeSingle();

        if (row != null) {
          final rawStatus = row['verification_status']?.toString() ?? 'unverified';
          final privacy = (row['privacy_settings'] as Map<String, dynamic>?) ?? {};
          final model = NidVerificationStatusModel(
            status: switch (rawStatus.toLowerCase()) {
              'verified' => NidStatus.verified,
              'pending' => NidStatus.pending,
              'rejected' => NidStatus.rejected,
              _ => NidStatus.unverified,
            },
            nidNumber: privacy['nid_number']?.toString(),
            fullName: row['full_name']?.toString(),
            submittedAt: privacy['nid_submitted_at'] != null
                ? DateTime.tryParse(privacy['nid_submitted_at'].toString())
                : null,
          );
          _cacheModel(userId, model);
          return model;
        }
      }
    } catch (e) {
      debugPrint('[NidVerification Fetch Supabase Warning]: $e');
    }

    return getCachedStatus(userId) ??
        const NidVerificationStatusModel(status: NidStatus.unverified);
  }

  /// Submits NID verification request
  Future<bool> submitVerification({
    required String userId,
    required String nidNumber,
    required String fullName,
    required String dateOfBirth,
    String? frontImageUrl,
    String? backImageUrl,
    String documentType = 'National ID (NID)',
  }) async {
    final cleanNid = nidNumber.replaceAll(RegExp(r'\D'), '');

    // 1. Submit to Cloud Backend API
    try {
      final url = Uri.parse(
        '${AppConfig.releaseApiBaseUrl}/api/public/user/nid-verification',
      );
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'nidNumber': cleanNid,
              'fullName': fullName,
              'dateOfBirth': dateOfBirth,
              'frontImageUrl': frontImageUrl,
              'backImageUrl': backImageUrl,
              'documentType': documentType,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final model = NidVerificationStatusModel(
          status: NidStatus.pending,
          nidNumber: cleanNid,
          fullName: fullName,
          submittedAt: DateTime.now(),
        );
        _cacheModel(userId, model);
        return true;
      }
    } catch (e) {
      debugPrint('[NidVerification Submit Cloud Warning]: $e');
    }

    // 2. Direct Supabase Fallback
    try {
      final client = _supabase;
      if (client != null) {
        final nowIso = DateTime.now().toIso8601String();
        await client.from('users').update({
          'verification_status': 'pending',
          'privacy_settings': {
            'nid_number': cleanNid,
            'nid_dob': dateOfBirth,
            'nid_full_name': fullName,
            'nid_front_url': frontImageUrl,
            'nid_back_url': backImageUrl,
            'nid_submitted_at': nowIso,
          },
          'updated_at': nowIso,
        }).eq('user_id', userId);

        final model = NidVerificationStatusModel(
          status: NidStatus.pending,
          nidNumber: cleanNid,
          fullName: fullName,
          submittedAt: DateTime.now(),
        );
        _cacheModel(userId, model);
        return true;
      }
    } catch (e) {
      debugPrint('[NidVerification Direct Supabase Error]: $e');
    }

    return false;
  }

  void _cacheModel(String userId, NidVerificationStatusModel model) {
    try {
      LocalCacheService.instance.put('$_cachePrefix$userId', model.toJson());
    } catch (_) {}
  }
}
