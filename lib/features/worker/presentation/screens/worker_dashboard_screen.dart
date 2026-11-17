import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/dialogs/notification_permission_sheet.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';
import '../widgets/worker_dashboard_view.dart';

/// Full-page screen wrapper for Worker Dashboard when accessed directly or via deep link.
class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  final DashboardRepository _dashboardRepository = DashboardRepository();

  double _earnings = 0.0;
  int _completedJobs = 0;
  double _rating = 0.0;
  bool _isAvailable = true;
  String _currentZone = 'Dhanmondi';
  List<Map<String, dynamic>> _incomingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadWorkerData();
    _checkNotificationPermission();
  }

  Future<void> _loadWorkerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final stats = await _dashboardRepository.getWorkerStats(user.uid);
        if (mounted) {
          setState(() {
            _earnings = stats.totalEarnings;
            _completedJobs = stats.completedJobs;
            _rating = stats.ratingAverage;
            _isAvailable = stats.isAvailable;
            _incomingRequests = stats.incomingRequests;
            _isLoading = false;
          });
        }
        return;
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _checkNotificationPermission() async {
    // Polite post-render check (1.5s delay following on-demand app onboarding standards)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final status = await NotificationService.instance.checkPermissionStatus();
    if (!status.isGranted && mounted) {
      await NotificationPermissionSheet.show(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Worker Hub'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.availabilityCalendar),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.workerEarnings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : WorkerDashboardView(
              isWorkerAvailable: _isAvailable,
              onToggleAvailability: (val) {
                setState(() => _isAvailable = val);
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  _dashboardRepository.updateWorkerAvailability(user.uid, val);
                }
              },
              workerEarnings: _earnings,
              workerCompletedJobs: _completedJobs,
              workerRating: _rating,
              locationZone: _currentZone,
              liveJobRequests: _incomingRequests,
            ),
    );
  }
}
