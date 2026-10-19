import 'user_address_model.dart';

class UserProfileModel {
  final String id;
  final String email;
  final String? phone;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final DateTime? dateOfBirth;
  final bool birthdayNotificationsEnabled;
  final String? gender;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String preferredLanguage;
  final String timezone;
  final String accountStatus;
  final String verificationStatus;
  final Map<String, dynamic> privacySettings;
  final Map<String, dynamic> notificationPreferences;
  final List<UserAddressModel> savedAddresses;
  final int profileCompletionPercentage;

  UserProfileModel({
    required this.id,
    required this.email,
    this.phone,
    required this.fullName,
    this.avatarUrl,
    this.role = 'Individual Customer',
    this.dateOfBirth,
    this.birthdayNotificationsEnabled = true,
    this.gender,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.preferredLanguage = 'en',
    this.timezone = 'Asia/Dhaka',
    this.accountStatus = 'active',
    this.verificationStatus = 'unverified',
    this.privacySettings = const {
      'profile_visibility': 'public',
      'share_phone_with_assigned_specialist': true,
      'data_sharing_consent': true,
    },
    this.notificationPreferences = const {
      'push_enabled': true,
      'sms_enabled': true,
      'email_enabled': true,
      'urgent_alerts': true,
      'birthday_reminders': true,
      'promotional': false,
    },
    this.savedAddresses = const [],
    this.profileCompletionPercentage = 30,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': role,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'birthday_notifications_enabled': birthdayNotificationsEnabled,
        'gender': gender,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'preferred_language': preferredLanguage,
        'timezone': timezone,
        'account_status': accountStatus,
        'verification_status': verificationStatus,
        'privacy_settings': privacySettings,
        'notification_preferences': notificationPreferences,
        'saved_addresses': savedAddresses.map((a) => a.toJson()).toList(),
        'profile_completion_percentage': profileCompletionPercentage,
      };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    List<UserAddressModel> addresses = [];
    if (json['saved_addresses'] is List) {
      addresses = (json['saved_addresses'] as List)
          .map((a) => UserAddressModel.fromJson(Map<String, dynamic>.from(a)))
          .toList();
    }

    return UserProfileModel(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      fullName: json['full_name']?.toString() ?? 'SKAVIA Member',
      avatarUrl: json['avatar_url']?.toString(),
      role: json['role']?.toString() ?? 'Individual Customer',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'].toString())
          : null,
      birthdayNotificationsEnabled:
          json['birthday_notifications_enabled'] as bool? ?? true,
      gender: json['gender']?.toString(),
      emergencyContactName: json['emergency_contact_name']?.toString(),
      emergencyContactPhone: json['emergency_contact_phone']?.toString(),
      preferredLanguage: json['preferred_language']?.toString() ?? 'en',
      timezone: json['timezone']?.toString() ?? 'Asia/Dhaka',
      accountStatus: json['account_status']?.toString() ?? 'active',
      verificationStatus: json['verification_status']?.toString() ?? 'unverified',
      privacySettings: json['privacy_settings'] is Map
          ? Map<String, dynamic>.from(json['privacy_settings'] as Map)
          : const {
              'profile_visibility': 'public',
              'share_phone_with_assigned_specialist': true,
              'data_sharing_consent': true,
            },
      notificationPreferences: json['notification_preferences'] is Map
          ? Map<String, dynamic>.from(json['notification_preferences'] as Map)
          : const {
              'push_enabled': true,
              'sms_enabled': true,
              'email_enabled': true,
              'urgent_alerts': true,
              'birthday_reminders': true,
              'promotional': false,
            },
      savedAddresses: addresses,
      profileCompletionPercentage:
          (json['profile_completion_percentage'] as num?)?.toInt() ?? 30,
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    String? role,
    DateTime? dateOfBirth,
    bool? birthdayNotificationsEnabled,
    String? gender,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? preferredLanguage,
    String? timezone,
    String? accountStatus,
    String? verificationStatus,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? notificationPreferences,
    List<UserAddressModel>? savedAddresses,
    int? profileCompletionPercentage,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      birthdayNotificationsEnabled:
          birthdayNotificationsEnabled ?? this.birthdayNotificationsEnabled,
      gender: gender ?? this.gender,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
      accountStatus: accountStatus ?? this.accountStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      privacySettings: privacySettings ?? this.privacySettings,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      profileCompletionPercentage:
          profileCompletionPercentage ?? this.profileCompletionPercentage,
    );
  }
}

