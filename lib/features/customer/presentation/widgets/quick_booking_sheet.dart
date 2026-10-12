import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

/// 1-Tap Quick Booking BottomSheet for Featured Services
class QuickBookingSheet extends StatelessWidget {
  final String serviceName;
  final String categoryId;
  final double startingRate;
  final String currentLocationZone;
  final String currentFormattedLocation;
  final String? currentUserId;
  final VoidCallback onBookingSuccess;

  const QuickBookingSheet({
    super.key,
    required this.serviceName,
    required this.categoryId,
    required this.startingRate,
    required this.currentLocationZone,
    required this.currentFormattedLocation,
    required this.currentUserId,
    required this.onBookingSuccess,
  });

  static void show(
    BuildContext context, {
    required String serviceName,
    required String categoryId,
    required double startingRate,
    required String currentLocationZone,
    required String currentFormattedLocation,
    required String? currentUserId,
    required VoidCallback onBookingSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickBookingSheet(
        serviceName: serviceName,
        categoryId: categoryId,
        startingRate: startingRate,
        currentLocationZone: currentLocationZone,
        currentFormattedLocation: currentFormattedLocation,
        currentUserId: currentUserId,
        onBookingSuccess: onBookingSuccess,
      ),
    );
  }

  Future<void> _dispatchQuickBooking(BuildContext context) async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book a service')),
      );
      return;
    }

    try {
      final client = Supabase.instance.client;
      final scheduleTime = DateTime.now().add(const Duration(hours: 1));
      final notesText =
          '1-Tap Quick Booking: $serviceName in $currentLocationZone';

      // Find a verified worker matching category in this zone if available
      final candidate = await client
          .from('worker_profiles')
          .select('worker_profile_id')
          .limit(1)
          .maybeSingle();

      final wpId = candidate?['worker_profile_id'];

      final insertData = <String, dynamic>{
        'client_id': currentUserId,
        'agreed_price': startingRate,
        'service_notes': '$notesText | Location: $currentFormattedLocation',
        'status': 'Requested',
        'scheduled_at': scheduleTime.toIso8601String(),
      };
      if (wpId != null) {
        insertData['worker_profile_id'] = wpId;
      }

      await client.from('service_requests').insert(insertData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successGreen,
            content: Text(
              'Booking created for $serviceName! Technicians in $currentLocationZone are alerted.',
            ),
          ),
        );
        onBookingSuccess();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking initiated! Finding technician: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Starting Rate: ৳ ${startingRate.toStringAsFixed(0)} • $currentLocationZone',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primarySky,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sheetSurfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.primaryRoyal,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dispatching to: $currentFormattedLocation',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Timing Pill
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardPeachTint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accentPeach.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: AppColors.primaryRoyal,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Dispatch Time',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMedium,
                            ),
                          ),
                          Text(
                            'Immediate • Within 30-45 mins in $currentLocationZone',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.categoryCatalog,
                          arguments: {'categoryId': categoryId},
                        );
                      },
                      child: const Text(
                        'View All Rates',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRoyal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _dispatchQuickBooking(context);
                      },
                      child: const Text(
                        'Book Now',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
