import '../../../../core/utils/uuid_util.dart';

class UserAddressModel {
  final String id;
  final String userId;
  final String label;
  final String? recipientName;
  final String? recipientPhone;
  final String addressLine;
  final String zone;
  final String city;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime? createdAt;

  UserAddressModel({
    required this.id,
    required this.userId,
    this.label = 'Home',
    this.recipientName,
    this.recipientPhone,
    required this.addressLine,
    this.zone = 'Dhaka North',
    this.city = 'Dhaka',
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'label': label,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'address_line': addressLine,
        'zone': zone,
        'city': city,
        'postal_code': postalCode,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
        'created_at': createdAt?.toIso8601String(),
      };

  factory UserAddressModel.fromJson(Map<String, dynamic> json) =>
      UserAddressModel(
        id: json['id']?.toString() ?? UuidUtil.generateUuidV4(),
        userId: json['user_id']?.toString() ?? '',
        label: json['label']?.toString() ?? 'Home',
        recipientName: json['recipient_name']?.toString(),
        recipientPhone: json['recipient_phone']?.toString(),
        addressLine: json['address_line']?.toString() ?? '',
        zone: json['zone']?.toString() ?? 'Dhaka North',
        city: json['city']?.toString() ?? 'Dhaka',
        postalCode: json['postal_code']?.toString(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        isDefault: json['is_default'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );

  UserAddressModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? recipientName,
    String? recipientPhone,
    String? addressLine,
    String? zone,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return UserAddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      addressLine: addressLine ?? this.addressLine,
      zone: zone ?? this.zone,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

