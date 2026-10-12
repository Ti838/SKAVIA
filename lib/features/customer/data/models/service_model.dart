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
    this.estimatedDuration = '1-2 Hours',
    this.ratingAverage = 4.9,
    this.totalBookings = 120,
    this.popularBadge,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['service_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      name: json['name'] as String? ?? 'General Service',
      description: json['description'] as String? ?? '',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 500.0,
      estimatedDuration: json['duration_est'] as String? ?? '1-2 Hours',
      ratingAverage: (json['rating_avg'] as num?)?.toDouble() ?? 4.9,
      totalBookings: (json['total_bookings'] as num?)?.toInt() ?? 85,
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

  /// Default high-demand on-demand services for instant offline/seed browsing
  static const List<ServiceModel> defaultServices = [
    ServiceModel(
      serviceId: 'srv_ac_master',
      categoryId: 'cat_ac_hvac',
      name: 'Master AC Deep Jet Wash',
      description: 'Complete high-pressure chemical wash, indoor evaporator coil, blower and outdoor unit cleaning with antibacterial foam.',
      basePrice: 1200.0,
      estimatedDuration: '1.5 Hours',
      ratingAverage: 4.95,
      totalBookings: 540,
      popularBadge: 'TOP DEMAND',
    ),
    ServiceModel(
      serviceId: 'srv_circuit_breaker',
      categoryId: 'cat_electrical',
      name: 'Circuit Breaker & Short Circuit Fix',
      description: 'Emergency electrical diagnostic, DB loop breaker replacement, and load balance testing by certified technician.',
      basePrice: 950.0,
      estimatedDuration: '1 Hour',
      ratingAverage: 4.88,
      totalBookings: 410,
      popularBadge: 'EMERGENCY',
    ),
    ServiceModel(
      serviceId: 'srv_water_pump',
      categoryId: 'cat_plumbing',
      name: 'Submersible Water Pump Repair',
      description: 'Motor coil inspection, capacitor replacement, pressure pipe joint leakage repair and prime pressure restoration.',
      basePrice: 1500.0,
      estimatedDuration: '2 Hours',
      ratingAverage: 4.92,
      totalBookings: 320,
    ),
    ServiceModel(
      serviceId: 'srv_cctv_setup',
      categoryId: 'cat_it_creative',
      name: 'Enterprise CCTV & IP Camera Installation',
      description: '4-8 Channel DVR/NVR network configuration, remote mobile phone streaming setup, and cable trunking.',
      basePrice: 2500.0,
      estimatedDuration: '3 Hours',
      ratingAverage: 4.97,
      totalBookings: 190,
      popularBadge: 'SECURITY',
    ),
    ServiceModel(
      serviceId: 'srv_fridge_gas',
      categoryId: 'cat_appliance',
      name: 'Refrigerator Gas Refill & Compressor Check',
      description: 'R134a/R600a eco gas top-up, condenser leak testing, relay replacement, and cooling thermostat calibration.',
      basePrice: 1800.0,
      estimatedDuration: '2 Hours',
      ratingAverage: 4.85,
      totalBookings: 280,
    ),
    ServiceModel(
      serviceId: 'srv_door_lock',
      categoryId: 'cat_civil_carpentry',
      name: 'Smart & Mechanical Door Lock Fitting',
      description: 'Precision wood mortise lock installation, biometric keypad alignment, and anti-tamper latch adjustment.',
      basePrice: 850.0,
      estimatedDuration: '1 Hour',
      ratingAverage: 4.90,
      totalBookings: 375,
    ),
  ];
}
