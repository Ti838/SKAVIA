import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_connectivity_service.dart';
import '../../../../core/network/offline_sync_queue_manager.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';

class ComplaintRemoteDataSource {
  final SupabaseClient? _supabase;

  ComplaintRemoteDataSource({SupabaseClient? supabase})
    : _supabase = supabase ?? tryGetSupabaseClient();

  String resolveUserId() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) return uid;
    } catch (_) {}
    final supaUid = _supabase?.auth.currentUser?.id;
    if (supaUid != null && supaUid.isNotEmpty) return supaUid;
    return 'guest';
  }

  List<Map<String, dynamic>> getCachedComplaints(String userId) {
    final cached = LocalCacheService.instance.get('skavia_complaints_$userId');
    if (cached is List) {
      return cached
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> fetchComplaints(String userId) async {
    final client = _supabase;
    if (client == null || userId == 'guest') {
      return getCachedComplaints(userId);
    }

    try {
      final rows = await client
          .from(DatabaseTables.complaints)
          .select(
            'complaint_id, filed_by, service_request_id, project_id, category, description, status, created_at',
          )
          .eq('filed_by', userId)
          .order('created_at', ascending: false)
          .limit(20);
      final list = (rows as List)
          .whereType<Map>()
          .map((r) => Map<String, dynamic>.from(r))
          .toList();
      LocalCacheService.instance.put('skavia_complaints_$userId', list);
      return list;
    } catch (_) {
      return getCachedComplaints(userId);
    }
  }

  Future<bool> submitComplaint({
    required String userId,
    required Map<String, dynamic> payload,
  }) async {
    bool submittedOnline = false;
    final client = _supabase;
    if (client != null &&
        userId != 'guest' &&
        NetworkConnectivityService.instance.currentState !=
            NetworkQualityState.offline) {
      try {
        await client.from(DatabaseTables.complaints).insert(payload);
        submittedOnline = true;
      } catch (_) {}
    }

    if (!submittedOnline) {
      OfflineSyncQueueManager.instance.enqueue(
        operationType: 'submit_complaint',
        payload: payload,
      );
    }

    final existing = getCachedComplaints(userId);
    LocalCacheService.instance.put(
      'skavia_complaints_$userId',
      [payload, ...existing],
    );
    return submittedOnline;
  }
}

