import 'user_address_model.dart';

class UserProfileModel {
  final String id;
  final String email;
  final String? phone;
  final String fullName;
  final String? avatarUrl;
  final String? coverUrl;
  final String role;
  final String customerType;
  final String? companyName;
  final String? tradeLicense;
  final String? billingAddress;
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
    this.coverUrl,
    this.role = 'Individual Customer',
    this.customerType = 'Individual',
    this.companyName,
    this.tradeLicense,
    this.billingAddress,
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

  bool get isCorporateClient =>
      customerType == 'Business Client' || customerType == 'Organization';

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'cover_url': coverUrl,
        'role': role,
        'customer_type': customerType,
        'company_name': companyName,
        'trade_license': tradeLicense,
        'billing_address': billingAddress,
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
          .whereType<Map>()
          .map((a) => UserAddressModel.fromJson(Map<String, dynamic>.from(a)))
          .toList();
    }

    final rawCustType = json['customer_type']?.toString() ?? 'Individual';
    final normalizedCustType = rawCustType == 'Business'
        ? 'Business Client'
        : rawCustType;

    final parsedPrivacy = json['privacy_settings'] is Map
        ? Map<String, dynamic>.from(json['privacy_settings'] as Map)
        : const {
            'profile_visibility': 'public',
            'share_phone_with_assigned_specialist': true,
            'data_sharing_consent': true,
          };
    final resolvedCoverUrl =
        json['cover_url']?.toString() ??
        parsedPrivacy['cover_url']?.toString();

    return UserProfileModel(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      fullName: json['full_name']?.toString() ?? 'SKAVIA Member',
      avatarUrl: json['avatar_url']?.toString(),
      coverUrl: resolvedCoverUrl,
      role: json['role']?.toString() ?? 'Individual Customer',
      customerType: normalizedCustType,
      companyName: json['company_name']?.toString(),
      tradeLicense: json['trade_license']?.toString(),
      billingAddress: json['billing_address']?.toString(),
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
      privacySettings: parsedPrivacy,
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
    String? coverUrl,
    String? role,
    String? customerType,
    String? companyName,
    String? tradeLicense,
    String? billingAddress,
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
      coverUrl: coverUrl ?? this.coverUrl,
      role: role ?? this.role,
      customerType: customerType ?? this.customerType,
      companyName: companyName ?? this.companyName,
      tradeLicense: tradeLicense ?? this.tradeLicense,
      billingAddress: billingAddress ?? this.billingAddress,
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
