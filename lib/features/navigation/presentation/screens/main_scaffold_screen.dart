import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/job_otp_util.dart';
import '../../../app_update/presentation/widgets/app_update_banner.dart';
import '../../../app_update/presentation/widgets/app_update_dialog.dart';
import '../../../app_update/providers/app_update_provider.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../customer/presentation/screens/category_catalog_screen.dart';
import '../../../customer/presentation/screens/live_job_feed_screen.dart';
import '../../../../shared/dialogs/account_deletion_dialog.dart';
import '../../../../shared/widgets/offline_sync_banner.dart';
import '../../../customer/presentation/widgets/avatar_picker_sheet.dart';
import '../../../customer/presentation/widgets/customer_dashboard_view.dart';
import '../../../customer/presentation/widgets/dashboard_location_sheet.dart';
import '../../../customer/presentation/widgets/job_otp_dialog.dart';
import '../../../customer/presentation/widgets/quick_booking_sheet.dart';
import '../../../profile/presentation/widgets/unified_profile_view.dart';
import '../../../team_project/presentation/screens/project_dashboard_screen.dart';
import '../../../worker/presentation/screens/incoming_requests_screen.dart';
import '../../../worker/presentation/widgets/worker_dashboard_view.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../widgets/dashboard_bottom_nav_bar.dart';
import '../widgets/dashboard_settings_sheet.dart';
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
  final AuthController _authController = AuthController();
  final DashboardRepository _dashboardRepository = DashboardRepository();

  // Profile Avatar, Cover Banner & Identity
  String? _customAvatarUrl;
  String? _customCoverUrl;

  // Real-Time GPS Location State
  String _currentLocationZone = 'Dhanmondi';
  String _currentFormattedLocation = 'Dhanmondi, Dhaka';
  bool _isLocating = false;
  bool _isGpsVerified = false;

  // Real-time Active Booking State (Client)
  Map<String, dynamic>? _activeClientBooking;

  // Worker Mode Metrics (Worker)
  double _workerEarnings = 0.0;
  int _workerCompletedJobs = 0;
  double _workerRating = 5.0;
  bool _isWorkerAvailable = true;
  List<Map<String, dynamic>> _liveJobRequests = [];

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
    _initRealTimeLocation();
    _loadDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluateAndPresentAppUpdate();
      unawaited(
        AppUpdateProvider.instance
            .checkForUpdates(trigger: 'dashboard_mount')
            .then<void>((_) {}, onError: (_, _) {}),
      );
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
      return _authController.user;
    } catch (_) {
      return null;
    }
  }

  /// 2. Load Real Supabase Data for Dashboard via DashboardRepository
  Future<void> _loadDashboardData() async {
    final user = _safeCurrentUser();
    if (user == null) return;

    try {
      final activeBookingRes = await _dashboardRepository
          .getActiveClientBooking(user.uid);
      final userRecord = await _dashboardRepository.getUserProfileRecord(
        user.uid,
      );
      final workerStats = await _dashboardRepository.getWorkerStats(user.uid);
      final liveReqs = await _dashboardRepository.getOpenRequirements();
      final hasUnread = await _dashboardRepository.hasUnreadNotifications(
        user.uid,
      );

      if (mounted) {
        setState(() {
          _activeClientBooking = activeBookingRes;
          if (userRecord != null) {
            if (userRecord['avatar_url'] != null) {
              _customAvatarUrl = userRecord['avatar_url'] as String?;
            }
            if (userRecord['cover_url'] != null) {
              _customCoverUrl = userRecord['cover_url'] as String?;
            }
            final modeStr = userRecord['active_mode']?.toString().toLowerCase();
            if (modeStr == 'worker') {
              _currentMode = AppRoleMode.worker;
            } else if (modeStr == 'enterprise' || modeStr == 'business') {
              _currentMode = AppRoleMode.enterprise;
            } else if (modeStr == 'client' || modeStr == 'customer') {
              _currentMode = AppRoleMode.customer;
            }
            if (userRecord['location'] != null &&
                (userRecord['location'] as String).isNotEmpty) {
              _currentFormattedLocation = userRecord['location'] as String;
            }
          }
          _workerCompletedJobs = workerStats.completedJobs;
          _workerRating = workerStats.ratingAverage;
          _workerEarnings = workerStats.totalEarnings;
          _isWorkerAvailable = workerStats.isAvailable;
          _liveJobRequests = workerStats.incomingRequests;
          _liveRequirements = liveReqs;
          _hasUnreadNotifications = hasUnread;
        });
      }
    } catch (_) {}
  }

  /// Switch between Customer, Enterprise and Worker mode
  void _switchMode(AppRoleMode mode) {
    setState(() => _currentMode = mode);
    _loadDashboardData();

    final user = _safeCurrentUser();
    if (user != null) {
      final modeStr = mode == AppRoleMode.worker
          ? 'worker'
          : (mode == AppRoleMode.enterprise ? 'enterprise' : 'customer');
      _dashboardRepository.updateActiveMode(user.uid, modeStr);
    }
  }

  /// Toggle Worker online availability status via DashboardRepository
  Future<void> _toggleWorkerAvailability(bool val) async {
    setState(() => _isWorkerAvailable = val);
    final user = _safeCurrentUser();
    if (user != null) {
      await _dashboardRepository.updateWorkerAvailability(user.uid, val);
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _activeClientBooking = null;
      _workerEarnings = 0.0;
      _workerCompletedJobs = 0;
      _workerRating = 5.0;
      _liveJobRequests = [];
      _customAvatarUrl = null;
      _customCoverUrl = null;
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
      currentAvatarUrl: _customAvatarUrl,
      userId: _safeCurrentUser()?.uid,
      slot: ProfileMediaSlot.avatar,
      onAvatarSelected: (url) => setState(() => _customAvatarUrl = url),
    );
  }

  void _showCoverPickerModal() {
    AvatarPickerSheet.show(
      context,
      currentAvatarUrl: _customCoverUrl,
      userId: _safeCurrentUser()?.uid,
      slot: ProfileMediaSlot.cover,
      onAvatarSelected: (url) => setState(() => _customCoverUrl = url),
    );
  }

  void _showAccountDeletionDialog() {
    AccountDeletionDialog.show(context, authController: _authController);
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
      currentUserId: _safeCurrentUser()?.uid,
      onBookingSuccess: _loadDashboardData,
    );
  }

  void _showSettingsModal() {
    DashboardSettingsSheet.show(
      context,
      onDeleteAccount: _showAccountDeletionDialog,
    );
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
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 88),
          child: _currentMode == AppRoleMode.worker
              ? WorkerDashboardView(
                  workerEarnings: _workerEarnings,
                  workerCompletedJobs: _workerCompletedJobs,
                  workerRating: _workerRating,
                  isWorkerAvailable: _isWorkerAvailable,
                  locationZone: _currentLocationZone,
                  liveJobRequests: _liveJobRequests,
                  onToggleAvailability: _toggleWorkerAvailability,
                )
              : CustomerDashboardView(
                  searchController: _searchController,
                  currentLocationZone: _currentLocationZone,
                  userIdentifier:
                      currentUser?.email ?? currentUser?.phoneNumber,
                  activeClientBooking: _activeClientBooking,
                  onSelectServicesTab: () => setState(() => _navIndex = 1),
                  onOpenChat: () => setState(() => _navIndex = 2),
                  onViewOtp: _handleViewActiveBookingOtp,
                  onCallHelpline: _callHelpline,
                  onQuickBookService: (name, catId, rate) =>
                      _showQuickBookingSheet(name, catId, rate),
                  liveRequirements: _liveRequirements,
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
          customAvatarUrl: _customAvatarUrl,
          customCoverUrl: _customCoverUrl,
          currentMode: _currentMode,
          onAvatarPick: _showAvatarPickerModal,
          onCoverPick: _showCoverPickerModal,
          onOpenSettings: _showSettingsModal,
          onOpenServices: () => setState(() => _navIndex = 1),
          onOpenProjects: () => setState(() => _navIndex = 3),
          onCallHelpline: _callHelpline,
          onSwitchRole: () {
            RoleSwitchBottomSheet.show(
              context,
              currentMode: _currentMode,
              onRoleSelected: (newMode) {
                _switchMode(newMode);
                setState(() => _navIndex = 0);
              },
            );
          },
          onLogout: _handleLogout,
        );
      default:
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 88),
          child: CustomerDashboardView(
            searchController: _searchController,
            currentLocationZone: _currentLocationZone,
            userIdentifier: currentUser?.email ?? currentUser?.phoneNumber,
            activeClientBooking: _activeClientBooking,
            onSelectServicesTab: () => setState(() => _navIndex = 1),
            onOpenChat: () => setState(() => _navIndex = 2),
            onViewOtp: _handleViewActiveBookingOtp,
            onCallHelpline: _callHelpline,
            onQuickBookService: (name, catId, rate) =>
                _showQuickBookingSheet(name, catId, rate),
            liveRequirements: _liveRequirements,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguageService.localeNotifier,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Top Brand Header with Avatar, SKAVIA Brand Logo, Bell & Quick Actions
                DashboardTopAppBar(
                  customAvatarUrl: _customAvatarUrl,
                  hasUnreadNotifications: _hasUnreadNotifications,
                  currentLocationZone: _currentLocationZone,
                  isLocating: _isLocating,
                  isGpsVerified: _isGpsVerified,
                  currentMode: _currentMode,
                  onAvatarTap: () => setState(() => _navIndex = 4),
                  onNotificationsTap: () =>
                      Navigator.pushNamed(context, AppRoutes.notificationCenter),
                  onLocationTap: _showLocationPickerSheet,
                  onModeSwitch: _switchMode,
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
          // Floating Action Button in Customer & Enterprise Home Modes (SRS Section 3.1.E)
          floatingActionButton:
              (_currentMode != AppRoleMode.worker && _navIndex == 0)
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.primaryRoyal,
                  elevation: 4,
                  icon: const Icon(
                    Icons.add_task_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    AppLanguageService.tr('post_job'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.postRequirement),
                )
              : null,
          // Universal Bottom Navigation Bar (5 Tabs matching Reference Board)
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
