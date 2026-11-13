import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';

class WorkerProfileRemoteDataSource {
  static const String _draftCacheKey = 'worker_edit_profile_draft_v1';

  final SupabaseClient? _supabase;

  WorkerProfileRemoteDataSource({SupabaseClient? supabase})
    : _supabase = supabase ?? tryGetSupabaseClient();

  Map<String, dynamic>? loadCachedDraft() {
    final draft = LocalCacheService.instance.get(_draftCacheKey);
    if (draft is Map) {
      return Map<String, dynamic>.from(draft);
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchWorkerProfile(String userId) async {
    final client = _supabase;
    if (client == null || userId.isEmpty) return null;
    try {
      final response = await client
          .from(DatabaseTables.workerProfiles)
          .select(
            'title, expected_rate, bio, working_area, verification_status, is_available',
          )
          .eq('user_id', userId)
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('[WorkerProfileRemoteDataSource] Fetch error: $e');
      return null;
    }
  }

  Future<void> saveWorkerProfile({
    required String? userId,
    required String title,
    required double expectedRate,
    required String workingArea,
    required String bio,
    required bool isAvailable,
    required bool nidUploaded,
    required bool certUploaded,
  }) async {
    LocalCacheService.instance.put(_draftCacheKey, {
      'title': title,
      'rate': expectedRate.toStringAsFixed(0),
      'workingArea': workingArea,
      'bio': bio,
      'isAvailable': isAvailable,
      'nidUploaded': nidUploaded,
      'certUploaded': certUploaded,
    });

    final client = _supabase;
    if (userId != null && client != null) {
      await client.from(DatabaseTables.workerProfiles).upsert({
        'user_id': userId,
        'title': title,
        'expected_rate': expectedRate,
        'working_area': workingArea,
        'bio': bio,
        'is_available': isAvailable,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    }
  }
}

