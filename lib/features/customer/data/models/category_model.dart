/// Represents a service category aligned with Supabase `categories` table
/// and SKAVIA SRS Section 3.1.C (50 Pages).
class CategoryModel {
  final String categoryId;
  final String name;
  final String slug;
  final String iconName;
  final String description;
  final int serviceCount;
  final bool isActive;

  const CategoryModel({
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.iconName,
    this.description = '',
    this.serviceCount = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id']?.toString() ?? '',
      name: json['name'] as String? ?? 'General Service',
      slug: json['slug'] as String? ?? 'general',
      iconName: json['icon_name'] as String? ?? 'handyman',
      description: json['description'] as String? ?? '',
      serviceCount: (json['service_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'icon_name': iconName,
      'description': description,
      'service_count': serviceCount,
      'is_active': isActive,
    };
  }

  /// Official default SKAVIA categories defined in SRS Section 3.1.C & Page 18
  static const List<CategoryModel> defaultCategories = [
    CategoryModel(
      categoryId: 'cat_electrical',
      name: 'Electrical & Power',
      slug: 'electrical',
      iconName: 'electric_bolt_rounded',
      description: 'Certified electricians, wiring, DB boards, circuit breakers & generators.',
      serviceCount: 24,
    ),
    CategoryModel(
      categoryId: 'cat_plumbing',
      name: 'Plumbing & Sanitary',
      slug: 'plumbing',
      iconName: 'plumbing_rounded',
      description:
          'Pipe fittings, water pumps, bathroom fittings & drainage repair.',
      serviceCount: 18,
    ),
    CategoryModel(
      categoryId: 'cat_ac_hvac',
      name: 'AC & HVAC Cooling',
      slug: 'ac_hvac',
      iconName: 'ac_unit_rounded',
      description: 'AC servicing, gas refill, compressor maintenance & inverter PCB repair.',
      serviceCount: 15,
    ),
    CategoryModel(
      categoryId: 'cat_it_creative',
      name: 'IT, Software & Creative',
      slug: 'it_software',
      iconName: 'code_rounded',
      description:
          'Mobile/Web apps, UI/UX, network setup, CCTV & tech automation.',
      serviceCount: 32,
    ),
    CategoryModel(
      categoryId: 'cat_civil_carpentry',
      name: 'Civil & Carpentry',
      slug: 'civil_carpentry',
      iconName: 'carpenter_rounded',
      description:
          'Furniture crafting, gypsum ceiling, tiles laying & masonry work.',
      serviceCount: 20,
    ),
    CategoryModel(
      categoryId: 'cat_automotive',
      name: 'Automotive Mechanics',
      slug: 'automotive',
      iconName: 'directions_car_rounded',
      description: 'Car maintenance, hybrid battery check, engine tune-up & electrical diagnostics.',
      serviceCount: 14,
    ),
    CategoryModel(
      categoryId: 'cat_industrial',
      name: 'Industrial Machinery',
      slug: 'industrial',
      iconName: 'precision_manufacturing_rounded',
      description: 'Industrial PLC, boiler maintenance, textile machinery & high-torque motors.',
      serviceCount: 11,
    ),
    CategoryModel(
      categoryId: 'cat_appliance',
      name: 'Appliance & Home Care',
      slug: 'appliances',
      iconName: 'home_repair_service_rounded',
      description:
          'Refrigerator, washing machine, microwave & kitchen chimney repair.',
      serviceCount: 28,
    ),
  ];
}
