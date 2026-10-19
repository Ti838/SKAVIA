import '../../domain/entities/user_entity.dart';

/// Data model mapping between Supabase users table and UserEntity.
class UserAccountModel extends UserEntity {
  const UserAccountModel({
    required super.userId,
    required super.fullName,
    super.email,
    super.phone,
    super.activeMode,
    super.status,
    super.avatarUrl,
    super.location,
    super.roles,
  });

  factory UserAccountModel.fromJson(Map<String, dynamic> json) {
    return UserAccountModel(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'User',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      activeMode: json['active_mode']?.toString() ?? 'client',
      status: json['status']?.toString() ?? 'Active',
      avatarUrl: json['avatar_url']?.toString(),
      location: json['location']?.toString() ?? 'Dhaka, Bangladesh',
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Customer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'active_mode': activeMode,
      'status': status,
      'avatar_url': avatarUrl,
      'location': location,
    };
  }
}
