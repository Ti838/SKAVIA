import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/dialogs/notification_permission_sheet.dart';
import '../widgets/customer_dashboard_view.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text('SKAVIA Discovery'),
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
      body: CustomerDashboardView(
        searchController: _searchController,
        currentLocationZone: _currentZone,
        userIdentifier: 'Valued Client',
        activeClientBooking: null,
        onSelectServicesTab: () =>
            Navigator.pushNamed(context, AppRoutes.categoryCatalog),
        onOpenChat: () => Navigator.pushNamed(context, AppRoutes.chatList),
        onViewOtp: () {},
        onCallHelpline: () {},
        onQuickBookService: (serviceName, categoryId, startingRate) {
          QuickBookingSheet.show(
            context,
            serviceName: serviceName,
            categoryId: categoryId,
            startingRate: startingRate,
            currentLocationZone: _currentZone,
            currentFormattedLocation: '$_currentZone, Dhaka',
            currentUserId: 'client',
            onBookingSuccess: () {},
          );
        },
      ),
    );
  }
}
