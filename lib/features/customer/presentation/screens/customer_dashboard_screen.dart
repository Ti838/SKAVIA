import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/job_otp_util.dart';
import '../../../../shared/dialogs/notification_permission_sheet.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';
import '../../data/models/requirement_model.dart';
import '../widgets/customer_dashboard_view.dart';
import '../widgets/job_otp_dialog.dart';
import '../widgets/quick_booking_sheet.dart';

/// Full screen wrapper for Customer Dashboard when accessed directly or via deep link.
class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AuthController _authController = AuthController();
  final DashboardRepository _dashboardRepository = DashboardRepository();

  Timer? _permissionTimer;
  String _currentZone = 'Dhanmondi';
  Map<String, dynamic>? _activeClientBooking;
  List<JobRequirementItem> _liveRequirements = [];

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadDashboard();
    _scheduleNotificationPermissionCheck();
  }

  void _scheduleNotificationPermissionCheck() {
    _permissionTimer?.cancel();
    _permissionTimer = Timer(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      try {
        final status =
            await NotificationService.instance.checkPermissionStatus();
        if (!status.isGranted && mounted) {
          await NotificationPermissionSheet.show(context);
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _permissionTimer?.cancel();
    _authController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  dynamic _safeCurrentUser() {
    try {
      return _authController.user;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadLocation() async {
    try {
      final loc = await LocationService.getRealTimeLocation();
      if (mounted) {
        setState(() => _currentZone = loc.zone);
      }
    } catch (_) {}
  }

  Future<void> _loadDashboard() async {
    final user = _safeCurrentUser();
    try {
      final liveReqs = await _dashboardRepository.getOpenRequirements();
      Map<String, dynamic>? booking;
      if (user != null) {
        booking = await _dashboardRepository.getActiveClientBooking(user.uid);
      }
      if (mounted) {
        setState(() {
          _liveRequirements = liveReqs;
          _activeClientBooking = booking;
        });
      }
    } catch (_) {}
  }

  Future<void> _callHelpline() async {
    final uri = Uri(scheme: 'tel', path: '16524');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency Hotline: 16524 (SKAVIA 24/7 Helpline)'),
        ),
      );
    }
  }

  void _handleViewOtp() {
    final booking = _activeClientBooking;
    if (booking == null) return;
    final id = booking['service_request_id']?.toString() ?? 'REQ';
    final otp = JobOtpUtil.extractOtp(
      booking['service_notes']?.toString(),
      fallbackRequestId: id,
    );
    JobOtpDialog.show(context, bookingId: id, otpCode: otp);
  }

  @override
  Widget build(BuildContext context) {
    final user = _safeCurrentUser();
    final identifier =
        user?.email ?? user?.phoneNumber ?? user?.displayName ?? 'Valued Client';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'SKAVIA Discovery',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.postRequirement),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: CustomerDashboardView(
          searchController: _searchController,
          currentLocationZone: _currentZone,
          userIdentifier: identifier,
          activeClientBooking: _activeClientBooking,
          onSelectServicesTab: () =>
              Navigator.pushNamed(context, AppRoutes.categoryCatalog),
          onOpenChat: () => Navigator.pushNamed(context, AppRoutes.chatList),
          onViewOtp: _handleViewOtp,
          onCallHelpline: _callHelpline,
          onQuickBookService: (serviceName, categoryId, startingRate) {
            QuickBookingSheet.show(
              context,
              serviceName: serviceName,
              categoryId: categoryId,
              startingRate: startingRate,
              currentLocationZone: _currentZone,
              currentFormattedLocation: '$_currentZone, Dhaka',
              currentUserId: user?.uid,
              onBookingSuccess: _loadDashboard,
            );
          },
          liveRequirements: _liveRequirements,
        ),
      ),
    );
  }
}
