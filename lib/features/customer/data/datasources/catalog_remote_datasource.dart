import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/tables/database_tables.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';

class CatalogRemoteDataSource {
  final SupabaseClient? _client;

  CatalogRemoteDataSource([this._client]);

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Fetch all active categories from Supabase with graceful default fallback
  Future<List<CategoryModel>> getCategories() async {
    final client = _supabase;
    if (client != null) {
      try {
        final response = await client
            .from(DatabaseTables.categories)
            .select()
            .eq('is_active', true)
            .order('name');

        final List<dynamic> data = response as List<dynamic>;
        if (data.isNotEmpty) {
          return data
              .map(
                (json) => CategoryModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      } catch (e) {
        debugPrint('[CatalogRemoteDataSource] Using default categories: $e');
      }
    }
    return CategoryModel.defaultCategories;
  }

  /// Fetch services for a specific category or all services
  Future<List<ServiceModel>> getServices({String? categoryId}) async {
    final client = _supabase;
    if (client != null) {
      try {
        var query = client.from(DatabaseTables.services).select();
        if (categoryId != null &&
            categoryId.isNotEmpty &&
            categoryId != 'all') {
          query = query.eq('category_id', categoryId);
        }
        final response = await query.order('name');
        final List<dynamic> data = response as List<dynamic>;
        if (data.isNotEmpty) {
          return data
              .map(
                (json) => ServiceModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      } catch (e) {
        debugPrint('[CatalogRemoteDataSource] Using default services: $e');
      }
    }

    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      final filtered = ServiceModel.defaultServices
          .where((s) => s.categoryId == categoryId)
          .toList();
      return filtered.isNotEmpty ? filtered : ServiceModel.defaultServices;
    }
    return ServiceModel.defaultServices;
  }

  /// Search services by name or description
  Future<List<ServiceModel>> searchServices(String queryText) async {
    final query = queryText.trim().toLowerCase();
    if (query.isEmpty) {
      return getServices();
    }
    final client = _supabase;
    if (client != null) {
      try {
        final response = await client
            .from(DatabaseTables.services)
            .select()
            .ilike('name', '%$query%')
            .limit(20);

        final List<dynamic> data = response as List<dynamic>;
        if (data.isNotEmpty) {
          return data
              .map(
                (json) => ServiceModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      } catch (e) {
        debugPrint('[CatalogRemoteDataSource Search]: $e');
      }
    }

    return ServiceModel.defaultServices
        .where(
          (s) =>
              s.name.toLowerCase().contains(query) ||
              s.description.toLowerCase().contains(query),
        )
        .toList();
  }
}
