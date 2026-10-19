import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/requirement_entity.dart';

class CustomerRemoteDataSource {
  final SupabaseClient _client;

  CustomerRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<RequirementEntity>> getCustomerRequirements(
    String clientId,
  ) async {
    try {
      final res = await _client
          .from('requirements')
          .select('*')
          .eq('submitted_by', clientId)
          .order('created_at', ascending: false);

      return (res as List).map((row) {
        return RequirementEntity(
          requirementId: row['requirement_id']?.toString() ?? '',
          clientId: row['submitted_by']?.toString() ?? clientId,
          title: row['title']?.toString() ?? 'Requirement',
          description: row['description']?.toString() ?? '',
          categoryId: row['category_id']?.toString() ?? '',
          location: row['location']?.toString() ?? 'Dhaka',
          budget: (row['budget'] as num?)?.toDouble() ?? 1000.0,
          status: row['status']?.toString() ?? 'Open',
          createdAt: row['created_at'] != null
              ? DateTime.parse(row['created_at'])
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint(
        '[CustomerRemoteDataSource] getCustomerRequirements notice: $e',
      );
      return [];
    }
  }

  Future<String> createRequirement(RequirementEntity req) async {
    try {
      final insertData = {
        'submitted_by': req.clientId,
        'title': req.title,
        'description': req.description,
        'category_id': req.categoryId,
        'location': req.location,
        'budget': req.budget,
        'status': req.status,
      };
      final res = await _client
          .from('requirements')
          .insert(insertData)
          .select('requirement_id')
          .single();
      return res['requirement_id']?.toString() ??
          'req_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('[CustomerRemoteDataSource] createRequirement notice: $e');
      return 'req_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<List<Map<String, dynamic>>> getActiveBookings(String clientId) async {
    try {
      final res = await _client
          .from('service_requests')
          .select('*, worker_profiles(*)')
          .eq('client_id', clientId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('[CustomerRemoteDataSource] getActiveBookings notice: $e');
      return [];
    }
  }
}
