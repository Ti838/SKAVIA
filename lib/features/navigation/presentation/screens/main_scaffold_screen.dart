import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/job_otp_util.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../shared/widgets/offline_sync_banner.dart';
import '../../../app_update/presentation/widgets/app_update_banner.dart';
import '../../../app_update/presentation/widgets/app_update_dialog.dart';
import '../../../app_update/providers/app_update_provider.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../customer/presentation/screens/category_catalog_screen.dart';
import '../../../customer/presentation/screens/live_job_feed_screen.dart';
import '../../../customer/presentation/widgets/avatar_picker_sheet.dart';
import '../../../customer/presentation/widgets/customer_dashboard_view.dart';
import '../../../customer/presentation/widgets/dashboard_location_sheet.dart';
import '../../../customer/presentation/widgets/job_otp_dialog.dart';
import '../../../customer/presentation/widgets/quick_booking_sheet.dart';
import '../../../notifications/presentation/controllers/notification_center_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/widgets/unified_profile_view.dart';
import '../../../team_project/presentation/screens/project_dashboard_screen.dart';
import '../../../worker/presentation/screens/incoming_requests_screen.dart';
import '../../../worker/presentation/widgets/worker_dashboard_view.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../widgets/dashboard_bottom_nav_bar.dart';
import '../widgets/dashboard_top_app_bar.dart';
import '../widgets/role_switch_bottom_sheet.dart';

enum AppRoleMode { customer, enterprise, worker }

class MainScaffoldScreen extends StatefulWidget {
  const MainScaffoldScreen({super.key});

  @override
  State<MainScaffoldScreen> createState() => _MainScaffoldScreenState();
}

class _MainScaffoldScreenState extends State<MainScaffoldScreen>
    with WidgetsBindingObserver {
  AppRoleMode _currentMode = AppRoleMode.customer;
  int _navIndex = 0;
  int _modeRevision = 0;
  final AuthController _authController = AuthController();
  final DashboardRepository _dashboardRepository = DashboardRepository();

  // Synchronized Profile Identity
  String? _customAvatarUrl;
  String? _customCoverUrl;
  String? _userFullName;
  AuthorizedRoleSummary _authorizedRoles = const AuthorizedRoleSummary();
  DashboardBusinessStats _businessStats = const DashboardBusinessStats();

  // Real-Time GPS Location State
  String _currentLocationZone = 'Dhaka';
  String _currentFormattedLocation = 'Dhaka, Bangladesh';
  bool _isLocating = false;
  bool _isGpsVerified = false;

  // Real-time Active Booking State (Client)
  Map<String, dynamic>? _activeClientBooking;

  // Worker Mode Metrics (Worker)
  double _workerEarnings = 0.0;
  int _workerCompletedJobs = 0;
  int _workerTotalReviews = 0;
  double _workerRating = 0.0;
  bool _isWorkerAvailable = false;
  String _workerVerificationStatus = 'Unverified';
  List<Map<String, dynamic>> _liveJobRequests = [];
  Map<String, dynamic>? _activeWorkerJob;

  // Search Query Controller
  final TextEditingController _searchController = TextEditingController();

  // Live Requirements
  List<JobRequirementItem> _liveRequirements = [];

  // Notifications State
  bool _hasUnreadNotifications = false;
  bool _initializedFromArgs = false;
  bool _updatePromptScheduled = false;
  bool _mandatoryScreenPushed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppUpdateProvider.instance.addListener(_onUpdateStateChanged);
    ProfileController.shared.addListener(_onProfileChanged);
    NotificationCenterController.instance.addListener(_onNotificationsChanged);
    _initRealTimeLocation();
    _loadDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluateAndPresentAppUpdate();
      unawaited(
        AppUpdateProvider.instance
            .checkForUpdates(trigger: 'dashboard_mount')
            .then<void>((_) {}, onError: (_, _) {}),
      );
      unawaited(
        NotificationCenterController.instance
            .syncFromBackend()
            .then<void>((_) {}, onError: (_, _) {}),
      );
    });
  }

  void _onProfileChanged() {
    if (!mounted) return;
    final profile = ProfileController.shared.profile;
    if (profile == null) return;
    setState(() {
      if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
        _customAvatarUrl = profile.avatarUrl;
      }
      if (profile.coverUrl != null && profile.coverUrl!.isNotEmpty) {
        _customCoverUrl = profile.coverUrl;
      }
      if (profile.fullName.trim().isNotEmpty) {
        _userFullName = profile.fullName.trim();
      }
    });
  }

  void _onNotificationsChanged() {
    if (!mounted) return;
    setState(() {
      _hasUnreadNotifications =
          NotificationCenterController.instance.unreadCount > 0;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        AppUpdateProvider.instance
            .checkForUpdates(trigger: 'foreground_resume')
            .then<void>((_) {}, onError: (_, _) {}),
      );
    }
  }

  void _onUpdateStateChanged() {
    _evaluateAndPresentAppUpdate();
  }

  void _evaluateAndPresentAppUpdate() {
    if (!mounted || _updatePromptScheduled) return;
    final provider = AppUpdateProvider.instance;
    final eval = provider.evaluation;
    if (eval == null) return;

    if (eval.requiresImmediateBlockingUpdate && !_mandatoryScreenPushed) {
      _mandatoryScreenPushed = true;
      _updatePromptScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updatePromptScheduled = false;
        if (!mounted) return;
        Navigator.of(context).pushNamed(
          AppRoutes.appUpdate,
          arguments: {'blocking': true},
        );
      });
      return;
    }

    if (provider.shouldShowAutomaticDialog && !_mandatoryScreenPushed) {
      _updatePromptScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _updatePromptScheduled = false;
        if (!mounted) return;
        await AppUpdateDialog.show(
          context,
          evaluation: eval,
          provider: provider,
        );
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedFromArgs) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final modeStr = args?['initialMode']?.toString().toLowerCase();
      if (modeStr != null) {
        if (modeStr == 'worker') {
          _currentMode = AppRoleMode.worker;
        } else if (modeStr == 'enterprise' || modeStr == 'business') {
          _currentMode = AppRoleMode.enterprise;
        } else {
          _currentMode = AppRoleMode.customer;
        }
      }
      _initializedFromArgs = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppUpdateProvider.instance.removeListener(_onUpdateStateChanged);
    ProfileController.shared.removeListener(_onProfileChanged);
    NotificationCenterController.instance.removeListener(
      _onNotificationsChanged,
    );
    _authController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 1. Real-Time Hardware GPS Location Initialization
  Future<void> _initRealTimeLocation() async {
    setState(() => _isLocating = true);
    try {
      final loc = await LocationService.getRealTimeLocation();
      if (mounted) {
        setState(() {
          _currentLocationZone = loc.zone;
          _currentFormattedLocation = loc.formattedAddress;
          _isGpsVerified = loc.isFromGps;
          _isLocating = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  dynamic _safeCurrentUser() {
    try {
      final user = _authController.user;
      if (user != null) return user;
    } catch (_) {}
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  String? _safeCurrentUserId() {
    try {
      final uid = _authController.user?.uid;
      if (uid != null && uid.isNotEmpty) return uid;
    } catch (_) {}
    try {
      final fbUid = FirebaseAuth.instance.currentUser?.uid;
      if (fbUid != null && fbUid.isNotEmpty) return fbUid;
    } catch (_) {}
    try {
      final suUid = tryGetSupabaseClient()?.auth.currentUser?.id;
      if (suUid != null && suUid.isNotEmpty) return suUid;
    } catch (_) {}
    try {
      final sessionUid = tryGetSupabaseClient()?.auth.currentSession?.user.id;
      if (sessionUid != null && sessionUid.isNotEmpty) return sessionUid;
    } catch (_) {}
    return null;
  }

  String? get _effectiveAvatarUrl {
    final profileUrl = ProfileController.shared.profile?.avatarUrl;
    final firebasePhoto = _safeCurrentUser()?.photoURL as String?;
    for (final candidate in [_customAvatarUrl, profileUrl, firebasePhoto]) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return null;
  }

  String get _effectiveUserName {
    final profileName = ProfileController.shared.profile?.fullName;
    final user = _safeCurrentUser();
    final fbName = user?.displayName as String?;
    final fbEmail = user?.email as String?;
    for (final candidate in [_userFullName, profileName, fbName, fbEmail]) {
      if (candidate != null &&
          candidate.trim().isNotEmpty &&
          candidate.trim() != 'SKAVIA Member') {
        return candidate.trim();
      }
    }
    return '';
  }

  Set<AppRoleMode> get _authorizedModeSet {
    final modes = <AppRoleMode>{AppRoleMode.customer, _currentMode};
    if (_authorizedRoles.hasEnterprise) modes.add(AppRoleMode.enterprise);
    if (_authorizedRoles.hasWorker) modes.add(AppRoleMode.worker);
    return modes;
  }

  /// 2. Load Real Supabase Data for Dashboard via DashboardRepository
  Future<void> _loadDashboardData({bool respectLocalMode = false}) async {
    final uid = _safeCurrentUserId();
    if (uid == null) return;
    final startRevision = _modeRevision;

    try {
      final results = await Future.wait([
        _dashboardRepository.getActiveClientBooking(uid),
        _dashboardRepository.getUserProfileRecord(uid),
        _dashboardRepository.getWorkerStats(uid),
        _dashboardRepository.getOpenRequirements(),
        _dashboardRepository.hasUnreadNotifications(uid),
        _dashboardRepository.getAuthorizedRoles(uid),
        _dashboardRepository.getBusinessStats(uid),
      ]);

      final activeBookingRes = results[0] as Map<String, dynamic>?;
      final userRecord = results[1] as Map<String, dynamic>?;
      final workerStats = results[2] as DashboardWorkerStats;
      final liveReqs = results[3] as List<JobRequirementItem>;
      final hasUnread = results[4] as bool;
      final authRoles = results[5] as AuthorizedRoleSummary;
      final bizStats = results[6] as DashboardBusinessStats;

      if (mounted) {
        setState(() {
          _activeClientBooking = activeBookingRes;
          _authorizedRoles = authRoles;
          _businessStats = bizStats;
          if (userRecord != null) {
            if (userRecord['full_name'] != null &&
                (userRecord['full_name'] as String).trim().isNotEmpty) {
              _userFullName = (userRecord['full_name'] as String).trim();
            }
            if (userRecord['avatar_url'] != null &&
                (userRecord['avatar_url'] as String).trim().isNotEmpty) {
              _customAvatarUrl = userRecord['avatar_url'] as String?;
            }
            if (userRecord['cover_url'] != null &&
                (userRecord['cover_url'] as String).trim().isNotEmpty) {
              _customCoverUrl = userRecord['cover_url'] as String?;
            }
            // Only apply remote active_mode if user didn't switch locally mid-flight
            if (!respectLocalMode && startRevision == _modeRevision) {
              final modeStr = userRecord['active_mode']
                  ?.toString()
                  .toLowerCase();
              if (modeStr == 'worker') {
                _currentMode = AppRoleMode.worker;
              } else if (modeStr == 'enterprise' || modeStr == 'business') {
                _currentMode = AppRoleMode.enterprise;
              } else if (modeStr == 'client' || modeStr == 'customer') {
                _currentMode = AppRoleMode.customer;
              }
            }
            if (userRecord['location'] != null &&
                (userRecord['location'] as String).isNotEmpty) {
              _currentFormattedLocation = userRecord['location'] as String;
            }
          }
          _workerCompletedJobs = workerStats.completedJobs;
          _workerTotalReviews = workerStats.totalReviews;
          _workerRating = workerStats.ratingAverage;
          _workerEarnings = workerStats.totalEarnings;
          _isWorkerAvailable = workerStats.isAvailable;
          _workerVerificationStatus = workerStats.verificationStatus;
          _liveJobRequests = workerStats.incomingRequests;
          _activeWorkerJob = workerStats.activeJob;
          _liveRequirements = liveReqs;
          _hasUnreadNotifications =
              hasUnread ||
              NotificationCenterController.instance.unreadCount > 0;
        });
      }
    } catch (_) {}
  }

  /// Switch between authorized Customer, Enterprise and Worker modes without race conditions.
  Future<void> _switchMode(AppRoleMode mode) async {
    _modeRevision++;
    setState(() {
      _currentMode = mode;
      if (_navIndex == 1 || _navIndex == 3) {
        _navIndex = 0;
      }
    });

    final uid = _safeCurrentUserId();
    if (uid != null) {
      final modeStr = mode == AppRoleMode.worker
          ? 'worker'
          : (mode == AppRoleMode.enterprise ? 'enterprise' : 'customer');
      await _dashboardRepository.updateActiveMode(uid, modeStr);
    }
    await _loadDashboardData(respectLocalMode: true);
  }

  void _handleSetupRole(AppRoleMode mode) {
    if (mode == AppRoleMode.worker) {
      Navigator.pushNamed(
        context,
        AppRoutes.workerProfile,
        arguments: {'isEdit': true},
      ).then((_) => _loadDashboardData(respectLocalMode: true));
    } else {
      Navigator.pushNamed(
        context,
        AppRoutes.roleSelection,
      ).then((_) => _loadDashboardData(respectLocalMode: true));
    }
  }

  /// Toggle Worker online availability status via DashboardRepository
  Future<void> _toggleWorkerAvailability(bool val) async {
    final prev = _isWorkerAvailable;
    setState(() => _isWorkerAvailable = val);
    final uid = _safeCurrentUserId();
    if (uid != null) {
      final ok = await _dashboardRepository.updateWorkerAvailability(uid, val);
      if (!ok && mounted) {
        setState(() => _isWorkerAvailable = prev);
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _activeClientBooking = null;
      _workerEarnings = 0.0;
      _workerCompletedJobs = 0;
      _workerTotalReviews = 0;
      _workerRating = 0.0;
      _liveJobRequests = [];
      _activeWorkerJob = null;
      _customAvatarUrl = null;
      _customCoverUrl = null;
      _userFullName = null;
      _currentMode = AppRoleMode.customer;
      _navIndex = 0;
    });
    await _authController.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  void _showAvatarPickerModal() {
    AvatarPickerSheet.show(
      context,
      currentAvatarUrl: _effectiveAvatarUrl,
      userId: _safeCurrentUserId(),
      slot: ProfileMediaSlot.avatar,
      onAvatarSelected: (url) {
        setState(() => _customAvatarUrl = url.isEmpty ? null : url);
        _loadDashboardData(respectLocalMode: true);
      },
    );
  }

  void _showCoverPickerModal() {
    AvatarPickerSheet.show(
      context,
      currentAvatarUrl: _customCoverUrl,
      userId: _safeCurrentUserId(),
      slot: ProfileMediaSlot.cover,
      onAvatarSelected: (url) {
        setState(() => _customCoverUrl = url.isEmpty ? null : url);
        _loadDashboardData(respectLocalMode: true);
      },
    );
  }

  void _showLocationPickerSheet() {
    DashboardLocationSheet.show(
      context,
      currentLocationZone: _currentLocationZone,
      onZoneSelected: (zone) {
        setState(() {
          _currentLocationZone = zone;
          _currentFormattedLocation = '$zone, Dhaka';
          _isGpsVerified = false;
        });
        LocationService.syncLocationToSupabase('$zone, Dhaka');
      },
      onDetectGps: _initRealTimeLocation,
    );
  }

  void _showJobOtpDialog(String bookingId, String otpCode) {
    JobOtpDialog.show(context, bookingId: bookingId, otpCode: otpCode);
  }

  void _showQuickBookingSheet(
    String serviceName,
    String categoryId,
    double startingRate,
  ) {
    QuickBookingSheet.show(
      context,
      serviceName: serviceName,
      categoryId: categoryId,
      startingRate: startingRate,
      currentLocationZone: _currentLocationZone,
      currentFormattedLocation: _currentFormattedLocation,
      currentUserId: _safeCurrentUserId(),
      onBookingSuccess: () => _loadDashboardData(respectLocalMode: true),
    );
  }

  void _openSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  /// Launch Emergency Call Dialer
  Future<void> _callHelpline() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '16524');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency Hotline: 16524 (SKAVIA 24/7 Helpline)'),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency Hotline: 16524 (SKAVIA 24/7 Helpline)'),
          ),
        );
      }
    }
  }

  void _handleViewActiveBookingOtp() {
    final booking = _activeClientBooking;
    if (booking == null) return;
    final id = booking['service_request_id']?.toString() ?? 'REQ';
    final otp = JobOtpUtil.extractOtp(
      booking['service_notes']?.toString(),
      fallbackRequestId: id,
    );
    _showJobOtpDialog(id, otp);
  }

  /// Current Tab Content Router
  Widget _buildCurrentTabContent() {
    final currentUser = _safeCurrentUser();
    switch (_navIndex) {
      case 0:
        return RefreshIndicator(
          onRefresh: () => _loadDashboardData(respectLocalMode: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: _currentMode == AppRoleMode.worker
                ? WorkerDashboardView(
                    workerEarnings: _workerEarnings,
                    workerCompletedJobs: _workerCompletedJobs,
                    workerRating: _workerTotalReviews > 0 ? _workerRating : 0.0,
                    isWorkerAvailable: _isWorkerAvailable,
                    locationZone: _currentLocationZone,
                    liveJobRequests: _liveJobRequests,
                    onToggleAvailability: _toggleWorkerAvailability,
                    verificationStatus: _workerVerificationStatus,
                    activeJob: _activeWorkerJob,
                  )
                : CustomerDashboardView(
                    searchController: _searchController,
                    currentLocationZone: _currentLocationZone,
                    userIdentifier: _effectiveUserName.isNotEmpty
                        ? _effectiveUserName
                        : (currentUser?.email ?? currentUser?.phoneNumber),
                    userAvatarUrl: _effectiveAvatarUrl,
                    isEnterpriseMode: _currentMode == AppRoleMode.enterprise,
                    businessStats: _businessStats,
                    activeClientBooking: _activeClientBooking,
                    onSelectServicesTab: () => setState(() => _navIndex = 1),
                    onOpenChat: () => setState(() => _navIndex = 2),
                    onOpenProjectsTab: () => setState(() => _navIndex = 3),
                    onViewOtp: _handleViewActiveBookingOtp,
                    onCallHelpline: _callHelpline,
                    onQuickBookService: (name, catId, rate) =>
                        _showQuickBookingSheet(name, catId, rate),
                    liveRequirements: _liveRequirements,
                  ),
          ),
        );
      case 1:
        if (_currentMode == AppRoleMode.worker) {
          return const IncomingRequestsScreen(isTab: true);
        } else {
          return const CategoryCatalogScreen(isTab: true);
        }
      case 2:
        return const ChatListScreen(isTab: true);
      case 3:
        if (_currentMode == AppRoleMode.customer) {
          return const LiveJobFeedScreen(isTab: true);
        } else {
          return const ProjectDashboardScreen(isTab: true);
        }
      case 4:
        return UnifiedProfileView(
          authController: _authController,
          customAvatarUrl: _effectiveAvatarUrl,
          customCoverUrl: _customCoverUrl,
          currentMode: _currentMode,
          onAvatarPick: _showAvatarPickerModal,
          onCoverPick: _showCoverPickerModal,
          onOpenSettings: _openSettings,
          onOpenServices: () => setState(() => _navIndex = 1),
          onOpenProjects: () => setState(() => _navIndex = 3),
          onCallHelpline: _callHelpline,
          onSwitchRole: () {
            RoleSwitchBottomSheet.show(
              context,
              currentMode: _currentMode,
              authorizedModes: _authorizedModeSet,
              onRoleSelected: (newMode) => _switchMode(newMode),
              onSetupRole: _handleSetupRole,
            );
          },
          onLogout: _handleLogout,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguageService.localeNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Global Synchronized Brand Header & Responsive Utility Strip
                DashboardTopAppBar(
                  customAvatarUrl: _effectiveAvatarUrl,
                  userName: _effectiveUserName,
                  hasUnreadNotifications: _hasUnreadNotifications,
                  unreadNotificationCount:
                      NotificationCenterController.instance.unreadCount,
                  currentLocationZone: _currentLocationZone,
                  isLocating: _isLocating,
                  isGpsVerified: _isGpsVerified,
                  currentMode: _currentMode,
                  customerTypeLabel: _authorizedRoles.customerType,
                  authorizedModes: _authorizedModeSet,
                  onAvatarTap: () => setState(() => _navIndex = 4),
                  onNotificationsTap: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.notificationCenter,
                    );
                    if (mounted) {
                      unawaited(
                        NotificationCenterController.instance.syncFromBackend(),
                      );
                    }
                  },
                  onLocationTap: _showLocationPickerSheet,
                  onModeSwitch: _switchMode,
                  onSetupRole: _handleSetupRole,
                ),

                // 2. Real-time Offline Connectivity & Synchronization Banner
                const OfflineSyncBanner(),

                // 3. Deferred / Important App Update Banner
                const AppUpdateBanner(),

                // 4. Tab Content View
                Expanded(child: _buildCurrentTabContent()),
              ],
            ),
          ),
          // Universal 5-Tab Bottom Navigation Bar (no competing floating Post Job FAB)
          bottomNavigationBar: DashboardBottomNavBar(
            currentIndex: _navIndex,
            currentMode: _currentMode,
            onTabSelected: (index) => setState(() => _navIndex = index),
          ),
        );
      },
    );
  }
}
