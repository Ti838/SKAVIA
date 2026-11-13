import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';

class AdminRemoteDataSource {
  final SupabaseClient? _client;

  AdminRemoteDataSource({SupabaseClient? client})
    : _client = client ?? tryGetSupabaseClient();

  Future<Map<String, dynamic>> getPlatformMetrics() async {
    final client = _client;
    if (client == null) {
      return {
        'totalUsers': 0,
        'activeRequests': 0,
        'totalVolume': 0.0,
        'isLive': false,
      };
    }

    try {
      final usersRes = await client
          .from(DatabaseTables.users)
          .select('user_id');
      final activeReqRes = await client
          .from(DatabaseTables.serviceRequests)
          .select('service_request_id');
      final paymentsRes = await client
          .from(DatabaseTables.payments)
          .select('total_amount');

      double totalVolume = 0.0;
      for (final p in (paymentsRes as List)) {
        totalVolume += (p['total_amount'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'totalUsers': (usersRes as List).length,
        'activeRequests': (activeReqRes as List).length,
        'totalVolume': totalVolume,
        'isLive': true,
      };
    } catch (e) {
      debugPrint('[AdminRemoteDataSource] getPlatformMetrics notice: $e');
      return {
        'totalUsers': 0,
        'activeRequests': 0,
        'totalVolume': 0.0,
        'isLive': false,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    final client = _client;
    if (client == null) return [];

    try {
      final res = await client
          .from(DatabaseTables.verifications)
          .select('*')
          .eq('status', 'Pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      debugPrint('[AdminRemoteDataSource] getPendingVerifications notice: $e');
      return [];
    }
  }

  Future<void> reviewVerification(
    String verificationId,
    bool isApproved,
  ) async {
    final client = _client;
    if (client == null) return;

    try {
      await client
          .from(DatabaseTables.verifications)
          .update({
            'status': isApproved ? 'Approved' : 'Rejected',
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('verification_id', verificationId);
    } catch (e) {
      debugPrint('[AdminRemoteDataSource] reviewVerification notice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOpenDisputes() async {
    final client = _client;
    if (client == null) return [];

    try {
      final res = await client
          .from(DatabaseTables.disputes)
          .select('*')
          .eq('status', 'Open')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      debugPrint('[AdminRemoteDataSource] getOpenDisputes notice: $e');
      return [];
    }
  }

  Future<void> resolveDispute(String disputeId, String resolution) async {
    final client = _client;
    if (client == null) return;

    try {
      await client
          .from(DatabaseTables.disputes)
          .update({
            'status': 'Resolved',
            'resolution': resolution,
            'resolved_at': DateTime.now().toIso8601String(),
          })
          .eq('dispute_id', disputeId);
    } catch (e) {
      debugPrint('[AdminRemoteDataSource] resolveDispute notice: $e');
    }
  }
}
