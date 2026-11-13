import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/category_resolver.dart';
import '../../../../core/utils/job_otp_util.dart';
import '../../../../core/utils/supabase_guard.dart';

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

  Future<void> _dispatchQuickBooking(
    ScaffoldMessengerState messenger,
    NavigatorState navigator,
  ) async {
    if (currentUserId == null || currentUserId!.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please log in to book a service')),
      );
      return;
    }

    final client = tryGetSupabaseClient();
    if (client == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Booking queued offline — reconnect to confirm dispatch.'),
        ),
      );
      return;
    }

    try {
      final scheduleTime = DateTime.now().add(const Duration(hours: 1));
      final otpCode = JobOtpUtil.generateOtp();
      final notesText =
          '1-Tap Quick Booking: $serviceName in $currentLocationZone | OTP: $otpCode';

      final catUuid = await CategoryResolver.resolveCategoryUuid(
        client,
        categoryId,
      );

      Map<String, dynamic>? candidate;
      if (catUuid != null) {
        candidate = await client
            .from('worker_profiles')
            .select('worker_profile_id')
            .eq('category_id', catUuid)
            .eq('is_available', true)
            .limit(1)
            .maybeSingle();
      }
      candidate ??= await client
          .from('worker_profiles')
          .select('worker_profile_id')
          .eq('is_available', true)
          .limit(1)
          .maybeSingle();

      final wpId = candidate?['worker_profile_id']?.toString();
      if (wpId == null || wpId.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'No instant specialist available right now. Please select from Services.',
            ),
          ),
        );
        navigator.pushNamed(
          AppRoutes.categoryCatalog,
          arguments: {'categoryId': categoryId},
        );
        return;
      }

      await client.from('service_requests').insert({
        'client_id': currentUserId,
        'worker_profile_id': wpId,
        'agreed_price': startingRate,
        'service_notes': '$notesText | Location: $currentFormattedLocation',
        'status': 'Requested',
        'scheduled_at': scheduleTime.toIso8601String(),
      });

      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text(
            'Booking created (OTP: $otpCode)! Specialists in $currentLocationZone alerted.',
          ),
        ),
      );
      onBookingSuccess();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to complete quick booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: colorScheme.outlineVariant,
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
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
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
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
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
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
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accentPeach.withValues(alpha: 0.3),
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
                          Text(
                            'Estimated Dispatch Time',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Immediate • Within 30-45 mins in $currentLocationZone',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons (stack on narrow/2.0x textScale)
              LayoutBuilder(
                builder: (context, constraints) {
                  final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                  final stackButtons =
                      constraints.maxWidth < 310 || textScale > 1.35;

                  final viewRatesBtn = OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  );

                  final bookBtn = ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRoyal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      await _dispatchQuickBooking(messenger, navigator);
                    },
                    child: const Text(
                      'Book Now',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  );

                  if (stackButtons) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        bookBtn,
                        const SizedBox(height: 10),
                        viewRatesBtn,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: viewRatesBtn),
                      const SizedBox(width: 12),
                      Expanded(child: bookBtn),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
