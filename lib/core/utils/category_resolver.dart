import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/tables/database_tables.dart';
import 'uuid_util.dart';

/// Shared helper for normalizing category identifiers, requirement types,
/// and urgency values to match PostgreSQL schema constraints in
/// `supabase_schema.sql`.
abstract class CategoryResolver {
  static const Map<String, List<String>> _slugAliases = {
    'cat_electrical': ['electrical', 'electrical-solutions', 'electrical_power'],
    'cat_ac_hvac': ['ac-cooling', 'ac_hvac', 'hvac', 'hvac-cooling'],
    'cat_plumbing': ['plumbing', 'plumbing-waterline', 'sanitary'],
    'cat_it_creative': [
      'it-security',
      'it_software',
      'it-creative',
      'technology',
    ],
    'cat_civil_carpentry': [
      'carpentry',
      'civil_carpentry',
      'carpentry-woodcraft',
    ],
    'cat_renovation': [
      'renovation-paint',
      'renovation',
      'interior-renovation',
      'paint',
    ],
    'cat_automotive': ['automotive', 'mechanics'],
    'cat_industrial': ['industrial', 'machinery'],
    'cat_appliance': ['appliances', 'appliance', 'home-care'],
    'electrical': ['cat_electrical', 'electrical'],
    'ac & hvac': ['cat_ac_hvac', 'ac-cooling', 'ac_hvac'],
    'plumbing': ['cat_plumbing', 'plumbing'],
    'it & creative': ['cat_it_creative', 'it-security', 'it_software'],
    'carpentry': ['cat_civil_carpentry', 'carpentry', 'civil_carpentry'],
  };

  static const Map<String, String> _knownSeedUuids = {
    'a1111111-1111-4111-8111-111111111111': 'Electrical Solutions',
    'a2222222-2222-4222-8222-222222222222': 'HVAC & Cooling Systems',
    'a3333333-3333-4333-8333-333333333333': 'Plumbing & Waterline',
    'a4444444-4444-4444-8444-444444444444': 'IT & Security Infrastructure',
    'a5555555-5555-4555-8555-555555555555': 'Interior Renovation & Paint',
    'a6666666-6666-4666-8666-666666666666': 'Carpentry & Woodcraft',
  };

  /// Returns a schema-valid `requirement_type` ('Simple' | 'Complex').
  static String normalizeRequirementType(String? raw) {
    final lower = (raw ?? '').trim().toLowerCase();
    if (lower == 'complex' ||
        lower == 'team' ||
        lower == 'team project' ||
        lower == 'turnkey') {
      return 'Complex';
    }
    return 'Simple';
  }

  /// Returns a schema-valid `urgency` ('Low' | 'Medium' | 'High' | 'Emergency').
  static String normalizeUrgency(String? raw) {
    final lower = (raw ?? '').trim().toLowerCase();
    switch (lower) {
      case 'low':
        return 'Low';
      case 'high':
      case 'urgent':
        return 'High';
      case 'emergency':
        return 'Emergency';
      case 'medium':
      case 'standard':
      case 'normal':
      default:
        return 'Medium';
    }
  }

  /// Returns a human-readable category display name from a UUID, local slug, or label.
  static String displayName(String? rawCategoryOrUuid) {
    final value = (rawCategoryOrUuid ?? '').trim();
    if (value.isEmpty) return 'Trade & Service';

    final seedMatch = _knownSeedUuids[value.toLowerCase()];
    if (seedMatch != null) return seedMatch;

    switch (value.toLowerCase()) {
      case 'cat_electrical':
      case 'electrical':
        return 'Electrical Solutions';
      case 'cat_ac_hvac':
      case 'ac-cooling':
      case 'ac_hvac':
        return 'HVAC & Cooling Systems';
      case 'cat_plumbing':
      case 'plumbing':
        return 'Plumbing & Waterline';
      case 'cat_it_creative':
      case 'it-security':
      case 'it_software':
        return 'IT & Security Infrastructure';
      case 'cat_civil_carpentry':
      case 'carpentry':
      case 'civil_carpentry':
        return 'Civil & Carpentry';
      case 'renovation-paint':
        return 'Interior Renovation & Paint';
      case 'cat_automotive':
      case 'automotive':
        return 'Automotive Mechanics';
      case 'cat_industrial':
      case 'industrial':
        return 'Industrial Machinery';
      case 'cat_appliance':
      case 'appliances':
        return 'Appliance & Home Care';
      default:
        if (!UuidUtil.isValidUuid(value)) {
          return value;
        }
        return 'Trade & Service';
    }
  }

  /// Resolves a local slug, display name, or UUID string into a valid database
  /// `categories.category_id` UUID, or `null` if unknown/unavailable.
  ///
  /// Never returns non-UUID strings (such as `'cat_electrical'`) for UUID columns.
  static Future<String?> resolveCategoryUuid(
    SupabaseClient? client,
    String? rawCategory,
  ) async {
    final trimmed = (rawCategory ?? '').trim();
    if (trimmed.isEmpty) return null;
    if (UuidUtil.isValidUuid(trimmed)) {
      return trimmed.toLowerCase();
    }

    final lower = trimmed.toLowerCase();
    final aliases = <String>{
      lower,
      lower.replaceFirst('cat_', ''),
      lower.replaceAll('_', '-'),
      ...?_slugAliases[lower],
    };

    if (client != null) {
      try {
        final rows = await client
            .from(DatabaseTables.categories)
            .select('category_id, slug, name')
            .eq('is_active', true);

        for (final row in rows as List<dynamic>) {
          final slug = (row['slug']?.toString() ?? '').trim().toLowerCase();
          final name = (row['name']?.toString() ?? '').trim().toLowerCase();
          final catUuid = row['category_id']?.toString();
          if (catUuid == null || !UuidUtil.isValidUuid(catUuid)) continue;

          if (aliases.contains(slug) || aliases.contains(name)) {
            return catUuid.toLowerCase();
          }
          for (final alias in aliases) {
            if (alias.length >= 3 &&
                (slug.contains(alias) || name.contains(alias))) {
              return catUuid.toLowerCase();
            }
          }
        }
      } catch (e) {
        debugPrint('[CategoryResolver] DB category lookup notice: $e');
      }
    }

    // Fallback check against canonical seed IDs only if DB lookup couldn't match
    // (returns valid RFC-4122 seed UUID for the 6 seeded categories in supabase_schema.sql,
    // or null for unseeded local categories so inserts never fail with 22P02).
    if (aliases.contains('electrical')) {
      return 'a1111111-1111-4111-8111-111111111111';
    }
    if (aliases.contains('ac-cooling') ||
        aliases.contains('ac_hvac') ||
        aliases.contains('hvac')) {
      return 'a2222222-2222-4222-8222-222222222222';
    }
    if (aliases.contains('plumbing')) {
      return 'a3333333-3333-4333-8333-333333333333';
    }
    if (aliases.contains('it-security') || aliases.contains('it_software')) {
      return 'a4444444-4444-4444-8444-444444444444';
    }
    if (aliases.contains('renovation-paint')) {
      return 'a5555555-5555-4555-8555-555555555555';
    }
    if (aliases.contains('carpentry') || aliases.contains('civil_carpentry')) {
      return 'a6666666-6666-4666-8666-666666666666';
    }
    return null;
  }
}

