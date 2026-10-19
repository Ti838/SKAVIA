import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/worker_profile_model.dart';

class WorkerRemoteDataSource {
  final SupabaseClient _client;

  WorkerRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<WorkerProfileModel?> getWorkerProfile(String userId) async {
    try {
      final res = await _client
          .from('worker_profiles')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (res != null) {
        return WorkerProfileModel.fromJson(res);
      }
      return null;
    } catch (e) {
      debugPrint('[WorkerRemoteDataSource] getWorkerProfile notice: $e');
      return null;
    }
  }

  Future<void> updateAvailability(
    String workerProfileId,
    bool isAvailable,
  ) async {
    try {
      await _client
          .from('worker_profiles')
          .update({'is_available': isAvailable})
          .eq('worker_profile_id', workerProfileId);
    } catch (e) {
      debugPrint('[WorkerRemoteDataSource] updateAvailability notice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getIncomingRequests(
    String workerProfileId,
  ) async {
    try {
      final res = await _client
          .from('service_requests')
          .select('*')
          .eq('worker_profile_id', workerProfileId)
          .eq('status', 'Requested')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('[WorkerRemoteDataSource] getIncomingRequests notice: $e');
      return [];
    }
  }

  Future<void> updateRequestStatus(
    String serviceRequestId,
    String status,
  ) async {
    try {
      await _client
          .from('service_requests')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('service_request_id', serviceRequestId);
    } catch (e) {
      debugPrint('[WorkerRemoteDataSource] updateRequestStatus notice: $e');
    }
  }

  Future<double> getTotalEarnings(String workerProfileId) async {
    try {
      final res = await _client
          .from('worker_earnings')
          .select('amount')
          .eq('worker_profile_id', workerProfileId);

      double sum = 0.0;
      for (final row in res) {
        sum += (row['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return sum;
    } catch (e) {
      debugPrint('[WorkerRemoteDataSource] getTotalEarnings notice: $e');
      return 0.0;
    }
  }
}
