/// Universal platform constants for SKAVIA.
/// References SKAVIA SRS Section 3.1 & 3.2.
abstract class AppConstants {
  // Brand & General
  static const String appName = 'SKAVIA';
  static const String appTagline = 'Every Skill. Every Opportunity.';
  static const String supportHelpline = '16524';
  static const String supportEmail = 'support@skavia.com';

  // Financial & Platform Rules
  static const double defaultPlatformFeePercent =
      0.15; // 15% platform management fee
  static const double minimumServicePrice = 100.0; // BDT 100
  static const double maximumServicePrice = 500000.0; // BDT 500,000
  static const String currencySymbol = '৳';
  static const String currencyCode = 'BDT';

  // SLA & Matching Engine Weights (SRS Section 3.1.G)
  static const double matchWeightSkill = 0.40;
  static const double matchWeightLocation = 0.25;
  static const double matchWeightRating = 0.20;
  static const double matchWeightRate = 0.15;

  // Pagination & Lists
  static const int defaultPageSize = 20;
  static const int maxRecentSearches = 10;
  static const int maxSavedItems = 50;

  // Storage Keys
  static const String tokenStorageKey = 'skavia_auth_token';
  static const String userModeStorageKey = 'skavia_active_mode';
  static const String languageStorageKey = 'skavia_locale';
  static const String themeStorageKey = 'skavia_theme_mode';
}
