import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/category_resolver.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';

class CatalogRemoteDataSource {
  final SupabaseClient? _client;

  CatalogRemoteDataSource([this._client]);

  SupabaseClient? get _supabase => _client ?? tryGetSupabaseClient();

  /// Fetch all active categories strictly from Supabase when connected.
  /// Throws on network/DB failure so the UI displays a genuine error state.
  Future<List<CategoryModel>> getCategories() async {
    final client = _supabase;
    if (client == null) {
      return CategoryModel.defaultCategories;
    }

    final response = await client
        .from(DatabaseTables.categories)
        .select()
        .eq('is_active', true)
        .order('name');

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch services for a specific category or all services strictly from Supabase.
  /// Never fabricates fallback services when an authentic DB category has 0 rows.
  Future<List<ServiceModel>> getServices({String? categoryId}) async {
    final client = _supabase;
    if (client == null) {
      return const [];
    }

    String? dbCategoryUuid;
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      dbCategoryUuid = await CategoryResolver.resolveCategoryUuid(
        client,
        categoryId,
      );
      if (dbCategoryUuid == null) {
        return const [];
      }
    }

    var query = client.from(DatabaseTables.services).select();
    if (dbCategoryUuid != null) {
      query = query.eq('category_id', dbCategoryUuid);
    }
    final response = await query.order('name');
    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Search services by name or description strictly against Supabase when connected.
  Future<List<ServiceModel>> searchServices(String queryText) async {
    final query = queryText.trim();
    if (query.isEmpty) {
      return getServices();
    }

    final client = _supabase;
    if (client == null) {
      return const [];
    }

    final safeQuery = query.replaceAll(',', ' ');
    final response = await client
        .from(DatabaseTables.services)
        .select()
        .or('name.ilike.%$safeQuery%,description.ilike.%$safeQuery%')
        .order('name')
        .limit(30);

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
