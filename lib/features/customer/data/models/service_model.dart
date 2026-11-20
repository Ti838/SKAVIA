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

  /// Offline system-defined service catalog definitions (used only when Supabase
  /// is uninitialized in isolated unit tests). Zero fabricated ratings, bookings,
  /// or promotional badges.
  static const List<ServiceModel> defaultServices = [
    ServiceModel(
      serviceId: 'srv_ac_master',
      categoryId: 'cat_ac_hvac',
      name: 'Inverter AC Master Jet Wash',
      description:
          'Complete high-pressure chemical wash, indoor evaporator coil, blower and outdoor unit cleaning.',
      basePrice: 1200.0,
    ),
    ServiceModel(
      serviceId: 'srv_circuit_breaker',
      categoryId: 'cat_electrical',
      name: 'Circuit Breaker & Short Circuit Fix',
      description:
          'Electrical diagnostic, DB loop breaker replacement, and load balance testing.',
      basePrice: 1800.0,
    ),
    ServiceModel(
      serviceId: 'srv_water_pump',
      categoryId: 'cat_plumbing',
      name: 'Concealed Water Leakage Repair',
      description:
          'Pipe pressure testing, concealed joint leakage repair, and water pump inspection.',
      basePrice: 2200.0,
    ),
    ServiceModel(
      serviceId: 'srv_cctv_setup',
      categoryId: 'cat_it_creative',
      name: '4-Channel IP CCTV Installation',
      description:
          'DVR/NVR network configuration, remote viewing setup, and structured cable trunking.',
      basePrice: 3500.0,
    ),
    ServiceModel(
      serviceId: 'srv_fridge_gas',
      categoryId: 'cat_appliance',
      name: 'Refrigerator Gas Refill & Compressor Check',
      description:
          'Eco refrigerant top-up, condenser leak testing, relay check, and thermostat calibration.',
      basePrice: 1800.0,
    ),
    ServiceModel(
      serviceId: 'srv_door_lock',
      categoryId: 'cat_civil_carpentry',
      name: 'Smart & Mechanical Door Lock Fitting',
      description:
          'Precision wood mortise lock installation, keypad alignment, and latch adjustment.',
      basePrice: 850.0,
    ),
  ];
}
