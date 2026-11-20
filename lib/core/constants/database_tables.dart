/// Central registry of all Supabase table and storage bucket names
/// perfectly aligned with SKAVIA SRS (Sections 4.4, 4.5 & 4.8).
abstract class DatabaseTables {
  // Identity, Roles & Branches
  static const String users = 'users';
  static const String roles = 'roles';
  static const String userRoles = 'user_roles';
  static const String permissions = 'permissions';
  static const String rolePermissions = 'role_permissions';
  static const String branches = 'branches';
  static const String customerProfiles = 'customer_profiles';
  static const String businessProfiles = 'business_profiles';
  static const String organizationProfiles = 'organization_profiles';
  static const String organizationMembers = 'organization_members';
  static const String marketplacePublicProfiles = 'marketplace_public_profiles';

  // Taxonomy & Catalog
  static const String categories = 'categories';
  static const String services = 'services';
  static const String skills = 'skills';

  // Worker Profile, Skills & Verification
  static const String workerProfiles = 'worker_profiles';
  static const String workerSkills = 'worker_skills';
  static const String portfolioItems = 'portfolio_items';
  static const String workerPortfolioItems = 'worker_portfolio_items';
  static const String certificates = 'certificates';
  static const String availabilitySlots = 'availability_slots';
  static const String verifications = 'verifications';

  // Requirements, Feed & Matching Engine
  static const String requirements = 'requirements';
  static const String requirementSkills = 'requirement_skills';
  static const String matchResults = 'match_results';
  static const String postComments = 'post_comments';
  static const String postBids = 'post_bids';

  // Execution: Service Requests & Complex Team Projects
  static const String serviceRequests = 'service_requests';
  static const String projects = 'projects';
  static const String teams = 'teams';
  static const String teamMembers = 'team_members';
  static const String tasks = 'tasks';

  // Financials, Wallets & Earnings
  static const String payments = 'payments';
  static const String invoices = 'invoices';
  static const String transactions = 'transactions';
  static const String workerEarnings = 'worker_earnings';
  static const String payoutRequests = 'payout_requests';
  static const String wallets = 'wallets';
  static const String paymentGatewayEvents = 'payment_gateway_events';
  static const String idempotencyKeys = 'idempotency_keys';

  // Reputation & Quality Control
  static const String reviews = 'reviews';
  static const String reputations = 'reputations';

  // Complaints, Support & Dispute Management
  static const String complaints = 'complaints';
  static const String disputes = 'disputes';
  static const String supportTickets = 'support_tickets';
  static const String ticketMessages = 'ticket_messages';

  // Identity, Profiles, Addresses, Devices & Sessions
  static const String userAddresses = 'user_addresses';
  static const String userSessions = 'user_sessions';
  static const String userDevices = 'user_devices';
  static const String fcmTokens = 'fcm_tokens';
  static const String offlineSyncQueue = 'offline_sync_queue';
  static const String userNotifications = 'user_notifications';

  // App Releases & OTA Updates
  static const String appReleases = 'app_releases';
  static const String appUpdatePolicies = 'app_update_policies';
  static const String appUpdateAuditLogs = 'app_update_audit_logs';

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
  static const String appReleases = 'app-releases';
}
