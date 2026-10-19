import '../../app/router/app_routes.dart';
import '../../features/profile/data/models/user_profile_model.dart';

enum AppFeature {
  bookService,
  acceptJob,
  requestPayout,
  postTurnkeyProject,
}

class FeatureEligibilityResult {
  final bool isEligible;
  final String featureName;
  final List<String> missingRequirements;
  final String? requiredActionRoute;
  final String? requiredActionLabel;

  const FeatureEligibilityResult({
    required this.isEligible,
    required this.featureName,
    this.missingRequirements = const [],
    this.requiredActionRoute,
    this.requiredActionLabel,
  });
}

/// Centralized Progressive Feature Eligibility Service.
/// Implements just-in-time profile requirements checks at the presentation and domain boundary.
class FeatureEligibilityService {
  static FeatureEligibilityResult checkEligibility({
    required AppFeature feature,
    required UserProfileModel? profile,
  }) {
    if (profile == null) {
      return const FeatureEligibilityResult(
        isEligible: false,
        featureName: 'Authentication',
        missingRequirements: ['You must be signed in to perform this action.'],
        requiredActionRoute: AppRoutes.login,
        requiredActionLabel: 'Sign In',
      );
    }

    if (profile.accountStatus != 'active') {
      return FeatureEligibilityResult(
        isEligible: false,
        featureName: 'Account Status',
        missingRequirements: [
          'Your account is currently ${profile.accountStatus}. Please contact support.',
        ],
      );
    }

    switch (feature) {
      case AppFeature.bookService:
        final missing = <String>[];
        String? actionRoute;
        String? actionLabel;

        if (profile.savedAddresses.isEmpty) {
          missing.add('A delivery address is required for doorstep dispatch.');
          actionRoute = AppRoutes.savedAddresses;
          actionLabel = 'Add Address';
        }

        if (profile.phone == null || profile.phone!.trim().length < 8) {
          missing.add('A verified phone number is required for technician contact.');
          actionRoute ??= AppRoutes.editDetailedProfile;
          actionLabel ??= 'Add Phone';
        }

        return FeatureEligibilityResult(
          isEligible: missing.isEmpty,
          featureName: 'Book Service',
          missingRequirements: missing,
          requiredActionRoute: actionRoute,
          requiredActionLabel: actionLabel,
        );

      case AppFeature.acceptJob:
        final missing = <String>[];
        String? actionRoute;
        String? actionLabel;

        if (profile.verificationStatus != 'verified') {
          missing.add('National ID (NID) and police clearance verification are required before accepting jobs.');
          actionRoute = AppRoutes.verificationQueue;
          actionLabel = 'Verify NID';
        }

        return FeatureEligibilityResult(
          isEligible: missing.isEmpty,
          featureName: 'Accept Job',
          missingRequirements: missing,
          requiredActionRoute: actionRoute,
          requiredActionLabel: actionLabel,
        );

      case AppFeature.requestPayout:
        final missing = <String>[];
        String? actionRoute;
        String? actionLabel;

        if (profile.phone == null || profile.phone!.isEmpty) {
          missing.add('A verified mobile number (bKash/Nagad) is required for payout transfer.');
          actionRoute = AppRoutes.editDetailedProfile;
          actionLabel = 'Add Mobile Number';
        }

        return FeatureEligibilityResult(
          isEligible: missing.isEmpty,
          featureName: 'Request Payout',
          missingRequirements: missing,
          requiredActionRoute: actionRoute,
          requiredActionLabel: actionLabel,
        );

      case AppFeature.postTurnkeyProject:
        final missing = <String>[];
        String? actionRoute;
        String? actionLabel;

        if (profile.phone == null || profile.phone!.isEmpty) {
          missing.add('Contact phone number is required for corporate project management.');
          actionRoute = AppRoutes.editDetailedProfile;
          actionLabel = 'Add Phone';
        }

        return FeatureEligibilityResult(
          isEligible: missing.isEmpty,
          featureName: 'Turnkey Project Tender',
          missingRequirements: missing,
          requiredActionRoute: actionRoute,
          requiredActionLabel: actionLabel,
        );
    }
  }
}
