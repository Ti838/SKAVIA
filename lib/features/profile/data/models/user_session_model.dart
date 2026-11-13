import '../../../../core/utils/uuid_util.dart';

/// Represents an authenticated device session synced with `public.user_sessions`.
class UserSessionModel {
  final String id;
  final String userId;
  final String deviceId;
  final String deviceName;
  final String deviceOs;
  final String appVersion;
  final String? ipAddress;
  final DateTime lastActiveAt;
  final bool isRevoked;
  final bool isCurrentDevice;

  const UserSessionModel({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceOs,
    required this.appVersion,
    this.ipAddress,
    required this.lastActiveAt,
    this.isRevoked = false,
    this.isCurrentDevice = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'device_id': deviceId,
        'device_name': deviceName,
        'device_os': deviceOs,
        'app_version': appVersion,
        'ip_address': ipAddress,
        'last_active_at': lastActiveAt.toIso8601String(),
        'is_revoked': isRevoked,
      };

  factory UserSessionModel.fromJson(
    Map<String, dynamic> json, {
    String? currentDeviceId,
  }) {
    final devId = json['device_id']?.toString() ?? '';
    return UserSessionModel(
      id: json['id']?.toString() ?? UuidUtil.generateUuidV4(),
      userId: json['user_id']?.toString() ?? '',
      deviceId: devId,
      deviceName: json['device_name']?.toString() ?? 'SKAVIA Device',
      deviceOs: json['device_os']?.toString() ?? 'mobile',
      appVersion: json['app_version']?.toString() ?? '1.0.0',
      ipAddress: json['ip_address']?.toString(),
      lastActiveAt:
          DateTime.tryParse(json['last_active_at']?.toString() ?? '') ??
          DateTime.now(),
      isRevoked: json['is_revoked'] as bool? ?? false,
      isCurrentDevice: currentDeviceId != null && devId == currentDeviceId,
    );
  }

  UserSessionModel copyWith({
    bool? isRevoked,
    DateTime? lastActiveAt,
    bool? isCurrentDevice,
  }) {
    return UserSessionModel(
      id: id,
      userId: userId,
      deviceId: deviceId,
      deviceName: deviceName,
      deviceOs: deviceOs,
      appVersion: appVersion,
      ipAddress: ipAddress,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isRevoked: isRevoked ?? this.isRevoked,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
    );
  }
}

