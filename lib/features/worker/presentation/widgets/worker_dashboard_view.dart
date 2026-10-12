import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/services/app_language_service.dart';

/// Worker Mode Dashboard View (matching Reference Screen 2 architecture)
class WorkerDashboardView extends StatefulWidget {
  final double workerEarnings;
  final int workerCompletedJobs;
  final double workerRating;
  final bool isWorkerAvailable;
  final String locationZone;
  final List<Map<String, dynamic>> liveJobRequests;
  final ValueChanged<bool> onToggleAvailability;

  const WorkerDashboardView({
    super.key,
    required this.workerEarnings,
    required this.workerCompletedJobs,
    required this.workerRating,
    required this.isWorkerAvailable,
    required this.locationZone,
    required this.liveJobRequests,
    required this.onToggleAvailability,
  });

  @override
  State<WorkerDashboardView> createState() => _WorkerDashboardViewState();
}

class _WorkerDashboardViewState extends State<WorkerDashboardView> {
  String _selectedWorkDay = 'mo';

  Widget _buildDayPill(String day) {
    final isSelected = _selectedWorkDay == day;
    return GestureDetector(
      onTap: () => setState(() => _selectedWorkDay = day),
      child: Container(
        width: 36,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySky
              : AppColors.sheetSurfaceSubtle,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primarySky : AppColors.borderLight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textMedium,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Weekly Day Selector Pill Bar (Reference Screen 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDayPill('su'),
            _buildDayPill('mo'),
            _buildDayPill('tu'),
            _buildDayPill('we'),
            _buildDayPill('th'),
            _buildDayPill('fr'),
            _buildDayPill('sa'),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Online / Offline Availability Radar Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isWorkerAvailable
                ? AppColors.successGreen.withValues(alpha: 0.1)
                : AppColors.sheetSurfaceSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isWorkerAvailable
                  ? AppColors.successGreen.withValues(alpha: 0.4)
                  : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.isWorkerAvailable
                          ? AppColors.successGreen
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.isWorkerAvailable
                        ? 'Available for Jobs in ${widget.locationZone}'
                        : 'Currently Offline',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: widget.isWorkerAvailable,
                activeTrackColor: AppColors.successGreen,
                onChanged: widget.onToggleAvailability,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. Dual Stat Cards (Reference Screen 2: Peach Earnings & Blue Jobs)
        Row(
          children: [
            // Peach Earnings Card
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.workerEarnings),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardPeachTint,
                    borderRadius: BorderRadius.circular(AppDimensions.radius20),
                    border: Border.all(
                      color: AppColors.accentPeach.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Earnings',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMedium,
                            ),
                          ),
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.accentCoral,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '৳ ${widget.workerEarnings.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.workerEarnings > 0
                            ? 'Verified balance'
                            : 'Zero balance',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.workerEarnings > 0
                              ? AppColors.successGreen
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Blue Jobs Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBlueTint,
                  borderRadius: BorderRadius.circular(AppDimensions.radius20),
                  border: Border.all(
                    color: AppColors.primarySky.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMedium,
                          ),
                        ),
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.primarySky,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.workerCompletedJobs} Jobs',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.accentPeach,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Rating ${widget.workerRating.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryRoyal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 4. Worker KYC & Verification Action Card (SRS Section 3.1.B & 3.1.R)
        GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.workerProfile,
            arguments: {'isEdit': true},
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySky.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primarySky.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.primaryRoyal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Worker Verification & Bio',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Upload NID, set hourly rate & working zones',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.primaryRoyal,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),

        // 5. Incoming Job Requests Section Title & Open Jobs Feed Link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLanguageService.isBengali
                  ? 'ইনকামিং জব রিকোয়েস্ট'
                  : 'Incoming Job Requests',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.liveJobFeed),
              child: Row(
                children: [
                  Text(
                    AppLanguageService.isBengali
                        ? 'সব কাজ দেখুন'
                        : 'Open Jobs Feed',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primarySky,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: AppColors.primarySky,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (widget.liveJobRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sheetSurfaceSubtle,
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.radar_rounded,
                  color: AppColors.primarySky,
                  size: 24,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No pending job requests',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Radar active • You will be alerted when a client books nearby',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...widget.liveJobRequests.map((req) {
            final price = (req['agreed_price'] as num?)?.toDouble() ?? 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.sheetSurfaceSubtle,
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: AppColors.accentCoral,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Incoming Service Request',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Agreed Fare: ৳ ${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySky,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.incomingRequests,
                    ),
                    child: const Text(
                      'Review',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
