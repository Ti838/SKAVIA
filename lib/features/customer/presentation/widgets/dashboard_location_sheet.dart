import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/location_service.dart';

/// Interactive Dhaka Zone Selector and real-time GPS refresh bottom sheet.
class DashboardLocationSheet extends StatelessWidget {
  final String currentLocationZone;
  final ValueChanged<String> onZoneSelected;
  final VoidCallback onDetectGps;

  const DashboardLocationSheet({
    super.key,
    required this.currentLocationZone,
    required this.onZoneSelected,
    required this.onDetectGps,
  });

  static void show(
    BuildContext context, {
    required String currentLocationZone,
    required ValueChanged<String> onZoneSelected,
    required VoidCallback onDetectGps,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DashboardLocationSheet(
        currentLocationZone: currentLocationZone,
        onZoneSelected: onZoneSelected,
        onDetectGps: onDetectGps,
      ),
    );
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
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Service Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
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
              const SizedBox(height: 4),
              const Text(
                'SKAVIA dispatches verified local technicians across Dhaka metropolitan zones.',
                style: TextStyle(fontSize: 12, color: AppColors.textMedium),
              ),
              const SizedBox(height: 16),

              // Button to trigger real hardware GPS refresh
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onDetectGps();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySky.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primarySky.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRoyal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detect Real GPS Location',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryRoyal,
                              ),
                            ),
                            Text(
                              'Auto-locate via hardware GPS sensor',
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
                        size: 12,
                        color: AppColors.primaryRoyal,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              const Text(
                'Dhaka Operating Zones',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              // Grid of selectable Dhaka zones
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LocationService.dhakaZones.map((zone) {
                  final isSelected =
                      currentLocationZone.toLowerCase() == zone.toLowerCase();
                  return ChoiceChip(
                    label: Text(zone),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        Navigator.pop(context);
                        onZoneSelected(zone);
                      }
                    },
                    selectedColor: AppColors.primaryRoyal,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.sheetSurfaceSubtle,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryRoyal
                          : AppColors.borderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
