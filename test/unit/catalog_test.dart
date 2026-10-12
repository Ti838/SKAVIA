import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/features/customer/data/models/category_model.dart';
import 'package:skavia/features/customer/data/models/service_model.dart';
import 'package:skavia/features/customer/data/datasources/catalog_remote_datasource.dart';

void main() {
  group('SKAVIA SRS Section 3.1.C — Taxonomy & Service Catalog Unit Tests', () {
    test(
      'FR-C01: 8 Standard trade categories are defined per SRS Section 3.1.C',
      () {
        final categories = CategoryModel.defaultCategories;
        expect(categories.length, equals(8));

        final slugs = categories.map((c) => c.slug).toList();
        expect(slugs, contains('electrical'));
        expect(slugs, contains('plumbing'));
        expect(slugs, contains('ac_hvac'));
        expect(slugs, contains('it_software'));
        expect(slugs, contains('civil_carpentry'));
        expect(slugs, contains('automotive'));
        expect(slugs, contains('industrial'));
        expect(slugs, contains('appliances'));
      },
    );

    test(
      'FR-C02: CategoryModel JSON serialization preserves all Supabase fields',
      () {
        final category = CategoryModel(
          categoryId: 'cat_test_uuid',
          name: 'Electrical Testing',
          slug: 'electrical_test',
          iconName: 'electric_bolt_rounded',
          description: 'Test category description',
          serviceCount: 12,
          isActive: true,
        );

        final json = category.toJson();
        expect(json['category_id'], equals('cat_test_uuid'));
        expect(json['name'], equals('Electrical Testing'));
        expect(json['slug'], equals('electrical_test'));

        final fromJson = CategoryModel.fromJson(json);
        expect(fromJson.categoryId, equals(category.categoryId));
        expect(fromJson.name, equals(category.name));
        expect(fromJson.serviceCount, equals(12));
      },
    );

    test(
      'FR-C03: ServiceModel JSON roundtrip preserves pricing and duration',
      () {
        final service = ServiceModel(
          serviceId: 'srv_test_01',
          categoryId: 'cat_ac_hvac',
          name: 'AC Gas Refill',
          description: 'Eco refrigerant top-up with leak check',
          basePrice: 1500.0,
          estimatedDuration: '2 Hours',
          ratingAverage: 4.9,
          totalBookings: 250,
          popularBadge: 'TOP DEMAND 🔥',
        );

        final json = service.toJson();
        expect(json['service_id'], equals('srv_test_01'));
        expect(json['base_price'], equals(1500.0));

        final fromJson = ServiceModel.fromJson(json);
        expect(fromJson.serviceId, equals(service.serviceId));
        expect(fromJson.basePrice, equals(1500.0));
        expect(fromJson.estimatedDuration, equals('2 Hours'));
        expect(fromJson.popularBadge, equals('TOP DEMAND 🔥'));
      },
    );

    test('FR-C04: CatalogRemoteDataSource searches services by keyword case-insensitively', () async {
      final dataSource = CatalogRemoteDataSource();

      // Search for 'ac'
      final acResults = await dataSource.searchServices('ac');
      expect(acResults.isNotEmpty, isTrue);
      expect(acResults.any((s) => s.name.toLowerCase().contains('ac')), isTrue);

      // Search for 'circuit'
      final circuitResults = await dataSource.searchServices('circuit');
      expect(circuitResults.isNotEmpty, isTrue);
      expect(
        circuitResults.any((s) => s.name.toLowerCase().contains('circuit')),
        isTrue,
      );

      // Search with empty query returns all services
      final allResults = await dataSource.searchServices('');
      expect(allResults.length, equals(ServiceModel.defaultServices.length));
    });

    test('FR-C05: CatalogRemoteDataSource filters services by category ID correctly', () async {
      final dataSource = CatalogRemoteDataSource();

      final acServices = await dataSource.getServices(
        categoryId: 'cat_ac_hvac',
      );
      for (final s in acServices) {
        expect(s.categoryId, equals('cat_ac_hvac'));
      }
    });
  });
}
