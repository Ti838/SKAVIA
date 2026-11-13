import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/category_resolver.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../domain/entities/requirement_entity.dart';

class CustomerRemoteDataSource {
  final SupabaseClient? _injectedClient;

  CustomerRemoteDataSource({SupabaseClient? client})
    : _injectedClient = client;

  SupabaseClient? get _client => _injectedClient ?? tryGetSupabaseClient();

  Future<List<RequirementEntity>> getCustomerRequirements(
    String clientId,
  ) async {
    final client = _client;
    if (client == null) return [];
    try {
      final res = await client
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
          isComplexProject:
              row['requirement_type']?.toString().toLowerCase() == 'complex',
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
    final client = _client;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }

    final resolvedCategoryUuid = await CategoryResolver.resolveCategoryUuid(
      client,
      req.categoryId,
    );
    final insertData = <String, dynamic>{
      'submitted_by': req.clientId,
      'title': req.title,
      'description': req.description,
      'category_id': ?resolvedCategoryUuid,
      'requirement_type': req.isComplexProject ? 'Complex' : 'Simple',
      'location': req.location,
      'budget': req.budget,
      'status': req.status,
    };

    final res = await client
        .from('requirements')
        .insert(insertData)
        .select('requirement_id')
        .single();
    final createdId = res['requirement_id']?.toString();
    if (createdId == null || createdId.isEmpty) {
      throw StateError('Database did not return a requirement_id.');
    }
    return createdId;
  }

  Future<List<Map<String, dynamic>>> getActiveBookings(String clientId) async {
    final client = _client;
    if (client == null) return [];
    try {
      final res = await client
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
