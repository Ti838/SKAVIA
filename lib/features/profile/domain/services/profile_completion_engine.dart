import '../../../../app/router/app_routes.dart';
import '../../data/models/user_profile_model.dart';

class MissingProfileField {
  final String key;
  final String label;
  final int weight;
  final String reason;
  final String actionRoute;

  const MissingProfileField({
    required this.key,
    required this.label,
    required this.weight,
    required this.reason,
    required this.actionRoute,
  });
}

class ProfileCompletionResult {
  final int percentage;
  final bool isComplete;
  final List<MissingProfileField> missingFields;
  final MissingProfileField? nextRecommendedAction;

  const ProfileCompletionResult({
    required this.percentage,
    required this.isComplete,
    required this.missingFields,
    this.nextRecommendedAction,
  });
}

/// Dynamic Profile Completion Intelligence Engine.
/// Calculates role-specific completion score, missing attributes, and navigation targets.
class ProfileCompletionEngine {
  static ProfileCompletionResult evaluate(UserProfileModel profile) {
    int score = 0;
    final missing = <MissingProfileField>[];

    // 1. Full Name (15%)
    if (profile.fullName.trim().length >= 3 &&
        profile.fullName != 'SKAVIA Member') {
      score += 15;
    } else {
      missing.add(const MissingProfileField(
        key: 'full_name',
        label: 'Full Name',
        weight: 15,
        reason: 'Required for technician identification and invoices',
        actionRoute: AppRoutes.editDetailedProfile,
      ));
    }

    // 2. Email Address (15%)
    if (profile.email.contains('@') && profile.email.contains('.')) {
      score += 15;
    } else {
      missing.add(const MissingProfileField(
        key: 'email',
        label: 'Email Address',
        weight: 15,
        reason: 'Needed for digital VAT receipts and booking confirmations',
        actionRoute: AppRoutes.editDetailedProfile,
      ));
    }

    // 3. Phone Number (10%)
    if (profile.phone != null && profile.phone!.trim().length >= 8) {
      score += 10;
    } else {
      missing.add(const MissingProfileField(
        key: 'phone',
        label: 'Verified Phone',
        weight: 10,
        reason: 'Needed for SMS OTP and on-site technician coordination',
        actionRoute: AppRoutes.editDetailedProfile,
      ));
    }

    // 4. Profile Picture / Avatar (10%)
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      score += 10;
    } else {
      missing.add(const MissingProfileField(
        key: 'avatar_url',
        label: 'Profile Photo',
        weight: 10,
        reason: 'Helps specialists recognize you upon arrival',
        actionRoute: AppRoutes.editDetailedProfile,
      ));
    }

    // 5. Saved Service Address (20%) - Critical for instant dispatch
    if (profile.savedAddresses.isNotEmpty) {
      score += 20;
    } else {
      missing.add(const MissingProfileField(
        key: 'saved_address',
        label: 'Saved Address',
        weight: 20,
        reason: 'Enables 1-tap booking without entering your location each time',
        actionRoute: AppRoutes.savedAddresses,
      ));
    }

    // 6. Date of Birth & Birthday Preferences (15%)
    if (profile.dateOfBirth != null) {
      score += 15;
    } else {
      missing.add(const MissingProfileField(
        key: 'date_of_birth',
        label: 'Date of Birth',
        weight: 15,
        reason: 'Receive annual birthday discounts and membership gifts',
        actionRoute: AppRoutes.editDetailedProfile,
      ));
    }

    // 7. Emergency Contact (15%)
    if (profile.emergencyContactPhone != null &&
        profile.emergencyContactPhone!.trim().length >= 8) {
      score += 15;
    } else {
      missing.add(const MissingProfileField(
        key: 'emergency_contact',
        label: 'Emergency Contact',
        weight: 15,
        reason: 'Essential for trust, security, and on-site support',
        actionRoute: AppRoutes.editDetailedProfile,
      ));
    }

    final cappedScore = score > 100 ? 100 : score;
    missing.sort((a, b) => b.weight.compareTo(a.weight)); // highest value first

    return ProfileCompletionResult(
      percentage: cappedScore,
      isComplete: cappedScore >= 80,
      missingFields: missing,
      nextRecommendedAction: missing.isNotEmpty ? missing.first : null,
    );
  }
}

