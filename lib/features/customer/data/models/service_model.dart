/// Represents an on-demand service item aligned with Supabase `services` table
/// and SKAVIA SRS Section 3.1.C & 3.1.D.
class ServiceModel {
  final String serviceId;
  final String categoryId;
  final String name;
  final String description;
  final double basePrice;
  final String estimatedDuration;
  final double ratingAverage;
  final int totalBookings;
  final String? popularBadge;

  const ServiceModel({
    required this.serviceId,
    required this.categoryId,
    required this.name,
    this.description = '',
    required this.basePrice,
    this.estimatedDuration = '',
    this.ratingAverage = 0.0,
    this.totalBookings = 0,
    this.popularBadge,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['service_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      name: json['name'] as String? ?? 'General Service',
      description: json['description'] as String? ?? '',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      estimatedDuration: (json['duration_est'] as String?)?.trim() ?? '',
      ratingAverage: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      totalBookings: (json['total_bookings'] as num?)?.toInt() ?? 0,
      popularBadge: json['popular_badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'duration_est': estimatedDuration,
      'rating_avg': ratingAverage,
      'total_bookings': totalBookings,
      'popular_badge': popularBadge,
    };
  }

  /// System-defined service catalog definitions. Zero fabricated prices or
  /// demo records on fresh production environments.
  static const List<ServiceModel> defaultServices = [];
}
