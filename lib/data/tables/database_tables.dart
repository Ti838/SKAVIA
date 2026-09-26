/// Central registry of all Supabase table and storage bucket names
/// perfectly aligned with SKAVIA SRS (50 Pages, Sections 4.4, 4.5 & 4.8).
abstract class DatabaseTables {
  // Identity, Roles & Branches
  static const String users = 'users';
  static const String roles = 'roles';
  static const String userRoles = 'user_roles';
  static const String branches = 'branches';
  static const String customerProfiles = 'customer_profiles';

  // Taxonomy & Catalog
  static const String categories = 'categories';
  static const String services = 'services';
  static const String skills = 'skills';

  // Worker Profile, Skills & Verification
  static const String workerProfiles = 'worker_profiles';
  static const String workerSkills = 'worker_skills';
  static const String portfolioItems = 'portfolio_items';
  static const String certificates = 'certificates';
  static const String availabilitySlots = 'availability_slots';
  static const String verifications = 'verifications';

  // Requirements & Matching Engine
  static const String requirements = 'requirements';
  static const String requirementSkills = 'requirement_skills';
  static const String matchResults = 'match_results';

  // Execution: Service Requests & Complex Team Projects
  static const String serviceRequests = 'service_requests';
  static const String projects = 'projects';
  static const String teams = 'teams';
  static const String teamMembers = 'team_members';
  static const String tasks = 'tasks';

  // Financials & Earnings
  static const String payments = 'payments';
  static const String invoices = 'invoices';
  static const String transactions = 'transactions';
  static const String workerEarnings = 'worker_earnings';

  // Reputation & Quality Control
  static const String reviews = 'reviews';
  static const String reputations = 'reputations';

  // Complaints & Dispute Management
  static const String complaints = 'complaints';
  static const String disputes = 'disputes';

  // Communication & Operations
  static const String conversations = 'conversations';
  static const String messages = 'messages';
  static const String notifications = 'notifications';
  static const String auditLogs = 'audit_logs';
}

/// Central registry of Supabase Storage bucket identifiers.
abstract class StorageBuckets {
  static const String avatars = 'avatars';
  static const String portfolios = 'portfolios';
  static const String certificates = 'certificates';
  static const String verifications = 'verifications';
  static const String attachments = 'attachments';
}
