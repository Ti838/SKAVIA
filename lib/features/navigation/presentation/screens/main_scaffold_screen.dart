import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../customer/presentation/screens/category_catalog_screen.dart';
import '../../../customer/presentation/widgets/account_deletion_dialog.dart';
import '../../../customer/presentation/widgets/avatar_picker_sheet.dart';
import '../../../customer/presentation/widgets/customer_dashboard_view.dart';
import '../../../customer/presentation/widgets/dashboard_location_sheet.dart';
import '../../../customer/presentation/widgets/dashboard_notifications_sheet.dart';
import '../../../customer/presentation/widgets/job_otp_dialog.dart';
import '../../../customer/presentation/widgets/quick_booking_sheet.dart';
import '../../../customer/presentation/widgets/unified_profile_view.dart';
import '../../../reviews/presentation/screens/worker_reputation_screen.dart';
import '../../../team_project/presentation/screens/project_dashboard_screen.dart';
import '../../../worker/presentation/screens/incoming_requests_screen.dart';
import '../../../worker/presentation/widgets/worker_dashboard_view.dart';
import '../widgets/dashboard_bottom_nav_bar.dart';
import '../widgets/dashboard_settings_sheet.dart';
import '../widgets/dashboard_top_app_bar.dart';

enum AppRoleMode { customer, worker }

class MainScaffoldScreen extends StatefulWidget {
  const MainScaffoldScreen({super.key});

  @override
  State<MainScaffoldScreen> createState() => _MainScaffoldScreenState();
}

class _MainScaffoldScreenState extends State<MainScaffoldScreen> {
  AppRoleMode _currentMode = AppRoleMode.customer;
  int _navIndex = 0;
  final AuthController _authController = AuthController();

  // Profile Avatar & Identity
  String? _customAvatarUrl;

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

  // Notifications State
  bool _hasUnreadNotifications = true;

  @override
  void initState() {
    super.initState();
    _initRealTimeLocation();
    _loadDashboardData();
  }

  @override
  void dispose() {
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

  /// 2. Load Real Supabase Data for Dashboard
  Future<void> _loadDashboardData() async {
    final user = _authController.user;
    if (user == null) return;

    try {
      final client = Supabase.instance.client;

      // Check for active client booking (Requested, Accepted, or In Progress)
      final activeBookingRes = await client
          .from('service_requests')
          .select(
            'service_request_id, agreed_price, service_notes, scheduled_at, status, '
            'worker_profiles ( title, rating_average, users ( full_name, phone_number, avatar_url ) )',
          )
          .eq('client_id', user.uid)
          .inFilter('status', ['Requested', 'Accepted', 'In Progress'])
          .order('scheduled_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // Check current user profile avatar
      final userRecord = await client
          .from('users')
          .select('avatar_url')
          .eq('user_id', user.uid)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _activeClientBooking = activeBookingRes;
          if (userRecord != null && userRecord['avatar_url'] != null) {
            _customAvatarUrl = userRecord['avatar_url'] as String?;
          }
        });
      }

      // Load worker stats
      final workerProfile = await client
          .from('worker_profiles')
          .select(
            'worker_profile_id, completed_jobs, rating_average, is_available',
          )
          .eq('user_id', user.uid)
          .maybeSingle();

      if (workerProfile != null) {
        final wpId = workerProfile['worker_profile_id'];
        final jobs = (workerProfile['completed_jobs'] as num?)?.toInt() ?? 0;
        final rating =
            (workerProfile['rating_average'] as num?)?.toDouble() ?? 5.0;
        final available = workerProfile['is_available'] as bool? ?? true;

        final earningsRes = await client
            .from('worker_earnings')
            .select('net_amount')
            .eq('worker_profile_id', wpId)
            .eq('status', 'Credited');

        double earningsSum = 0.0;
        if (earningsRes.isNotEmpty) {
          for (final row in earningsRes) {
            earningsSum += (row['net_amount'] as num?)?.toDouble() ?? 0.0;
          }
        }

        final requestsRes = await client
            .from('service_requests')
            .select(
              'service_request_id, agreed_price, service_notes, scheduled_at, location',
            )
            .eq('worker_profile_id', wpId)
            .eq('status', 'Requested')
            .limit(5);

        if (mounted) {
          setState(() {
            _workerCompletedJobs = jobs;
            _workerRating = rating;
            _workerEarnings = earningsSum;
            _isWorkerAvailable = available;
            _liveJobRequests = List<Map<String, dynamic>>.from(requestsRes);
          });
        }
      }
    } catch (_) {}
  }

  /// Switch between Client and Worker mode
  void _switchMode(AppRoleMode mode) {
    setState(() => _currentMode = mode);
    _loadDashboardData();

    final user = _authController.user;
    if (user != null) {
      try {
        Supabase.instance.client
            .from('users')
            .update({
              'active_mode': mode == AppRoleMode.customer ? 'client' : 'worker',
            })
            .eq('user_id', user.uid)
            .then((_) {})
            .catchError((_) {});
      } catch (_) {}
    }
  }

  /// Toggle Worker online availability status in Supabase
  Future<void> _toggleWorkerAvailability(bool val) async {
    setState(() => _isWorkerAvailable = val);
    final user = _authController.user;
    if (user != null) {
      try {
        await Supabase.instance.client
            .from('worker_profiles')
            .update({'is_available': val})
            .eq('user_id', user.uid);
      } catch (_) {}
    }
  }

  Future<void> _handleLogout() async {
    await _authController.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  void _showAvatarPickerModal() {
    AvatarPickerSheet.show(
      context,
      currentAvatarUrl: _customAvatarUrl,
      userId: _authController.user?.uid,
      onAvatarSelected: (url) => setState(() => _customAvatarUrl = url),
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

  void _showNotificationsSheet() {
    DashboardNotificationsSheet.show(
      context,
      locationZone: _currentLocationZone,
      hasUnread: _hasUnreadNotifications,
      onMarkAllRead: () => setState(() => _hasUnreadNotifications = false),
    );
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
      currentUserId: _authController.user?.uid,
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

  /// Current Tab Content Router
  Widget _buildCurrentTabContent() {
    switch (_navIndex) {
      case 0:
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: _currentMode == AppRoleMode.customer
              ? CustomerDashboardView(
                  searchController: _searchController,
                  currentLocationZone: _currentLocationZone,
                  userIdentifier:
                      _authController.user?.email ??
                      _authController.user?.phoneNumber,
                  activeClientBooking: _activeClientBooking,
                  onSelectServicesTab: () => setState(() => _navIndex = 1),
                  onOpenChat: () => setState(() => _navIndex = 2),
                  onViewOtp: () {
                    final id =
                        _activeClientBooking!['service_request_id']
                            ?.toString() ??
                        'REQ';
                    final otp = id.length >= 4
                        ? id.substring(id.length - 4).toUpperCase()
                        : '4892';
                    _showJobOtpDialog(id, otp);
                  },
                  onCallHelpline: _callHelpline,
                  onQuickBookService: (name, catId, rate) =>
                      _showQuickBookingSheet(name, catId, rate),
                )
              : WorkerDashboardView(
                  workerEarnings: _workerEarnings,
                  workerCompletedJobs: _workerCompletedJobs,
                  workerRating: _workerRating,
                  isWorkerAvailable: _isWorkerAvailable,
                  locationZone: _currentLocationZone,
                  liveJobRequests: _liveJobRequests,
                  onToggleAvailability: _toggleWorkerAvailability,
                ),
        );
      case 1:
        if (_currentMode == AppRoleMode.customer) {
          return const CategoryCatalogScreen(isTab: true);
        } else {
          return const IncomingRequestsScreen(isTab: true);
        }
      case 2:
        return const ChatListScreen(isTab: true);
      case 3:
        return const ProjectDashboardScreen();
      case 4:
        if (_currentMode == AppRoleMode.customer) {
          return UnifiedProfileView(
            authController: _authController,
            customAvatarUrl: _customAvatarUrl,
            isCustomerMode: _currentMode == AppRoleMode.customer,
            onAvatarPick: _showAvatarPickerModal,
            onOpenSettings: _showSettingsModal,
            onOpenServices: () => setState(() => _navIndex = 1),
            onOpenProjects: () => setState(() => _navIndex = 3),
            onCallHelpline: _callHelpline,
            onSwitchRole: () {
              _switchMode(
                _currentMode == AppRoleMode.customer
                    ? AppRoleMode.worker
                    : AppRoleMode.customer,
              );
              setState(() => _navIndex = 0);
            },
            onLogout: _handleLogout,
          );
        } else {
          return const WorkerReputationScreen();
        }
      default:
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: CustomerDashboardView(
            searchController: _searchController,
            currentLocationZone: _currentLocationZone,
            userIdentifier:
                _authController.user?.email ??
                _authController.user?.phoneNumber,
            activeClientBooking: _activeClientBooking,
            onSelectServicesTab: () => setState(() => _navIndex = 1),
            onOpenChat: () => setState(() => _navIndex = 2),
            onViewOtp: () {
              final id =
                  _activeClientBooking!['service_request_id']?.toString() ??
                  'REQ';
              final otp = id.length >= 4
                  ? id.substring(id.length - 4).toUpperCase()
                  : '4892';
              _showJobOtpDialog(id, otp);
            },
            onCallHelpline: _callHelpline,
            onQuickBookService: (name, catId, rate) =>
                _showQuickBookingSheet(name, catId, rate),
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
          backgroundColor: Colors.white,
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
                  onNotificationsTap: _showNotificationsSheet,
                  onLocationTap: _showLocationPickerSheet,
                  onModeSwitch: _switchMode,
                ),

                // 2. Tab Content View
                Expanded(child: _buildCurrentTabContent()),
              ],
            ),
          ),
          // Floating Action Button in Customer Mode (SRS Section 3.1.E)
          floatingActionButton:
              (_currentMode == AppRoleMode.customer && _navIndex == 0)
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
