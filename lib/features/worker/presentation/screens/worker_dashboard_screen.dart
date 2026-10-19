import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/dialogs/notification_permission_sheet.dart';
import '../widgets/worker_dashboard_view.dart';

/// Full-page screen wrapper for Worker Dashboard when accessed directly or via deep link.
class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  final double _earnings = 18450.0;
  final int _completedJobs = 28;
  final double _rating = 4.9;
  bool _isAvailable = true;
  String _currentZone = 'Dhanmondi';

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _checkNotificationPermission();
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
      body: WorkerDashboardView(
        isWorkerAvailable: _isAvailable,
        onToggleAvailability: (val) => setState(() => _isAvailable = val),
        workerEarnings: _earnings,
        workerCompletedJobs: _completedJobs,
        workerRating: _rating,
        locationZone: _currentZone,
        liveJobRequests: const [],
      ),
    );
  }
}
