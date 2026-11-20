/// Aggregated dashboard data container for worker profile stats.
class DashboardWorkerStats {
  final int completedJobs;
  final int totalReviews;
  final double ratingAverage;
  final bool isAvailable;
  final String verificationStatus;
  final double totalEarnings;
  final List<Map<String, dynamic>> incomingRequests;
  final Map<String, dynamic>? activeJob;

  const DashboardWorkerStats({
    required this.completedJobs,
    this.totalReviews = 0,
    required this.ratingAverage,
    required this.isAvailable,
    this.verificationStatus = 'Unverified',
    required this.totalEarnings,
    required this.incomingRequests,
    this.activeJob,
  });

  factory DashboardWorkerStats.empty() {
    return const DashboardWorkerStats(
      completedJobs: 0,
      totalReviews: 0,
      ratingAverage: 0.0,
      isAvailable: false,
      verificationStatus: 'Unverified',
      totalEarnings: 0.0,
      incomingRequests: [],
      activeJob: null,
    );
  }
}

/// Aggregated dashboard data container for Business Client / Organization mode.
class DashboardBusinessStats {
  final String customerType;
  final String? companyName;
  final int activeProjectsCount;
  final int openRequirementsCount;
  final List<Map<String, dynamic>> projects;

  const DashboardBusinessStats({
    this.customerType = 'Business Client',
    this.companyName,
    this.activeProjectsCount = 0,
    this.openRequirementsCount = 0,
    this.projects = const [],
  });
}

/// Authorized workspace role summary for a user.
class AuthorizedRoleSummary {
  final bool hasCustomer;
  final bool hasEnterprise;
  final bool hasWorker;
  final String? customerType;

  const AuthorizedRoleSummary({
    this.hasCustomer = true,
    this.hasEnterprise = false,
    this.hasWorker = false,
    this.customerType,
  });
}
