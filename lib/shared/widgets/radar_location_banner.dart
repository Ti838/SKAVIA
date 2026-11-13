import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/app_language_service.dart';
import '../../../core/services/location_service.dart';

/// Banner displaying custom selected coordinates and reverse-geocoded address with a Save/Select button.
class RadarLocationBanner extends StatelessWidget {
  final LatLng selectedPoint;
  final String? selectedAddress;
  final bool isReverseGeocoding;
  final ValueChanged<String>? onLocationSelected;

  const RadarLocationBanner({
    super.key,
    required this.selectedPoint,
    required this.selectedAddress,
    required this.isReverseGeocoding,
    this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.softBlueBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primarySky.withValues(alpha: 0.35)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340;
          final addressColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isReverseGeocoding
                    ? (isBn
                        ? 'ঠিকানা খোঁজা হচ্ছে...'
                        : 'Resolving street address...')
                    : (selectedAddress ?? 'Selected Coordinates'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${selectedPoint.latitude.toStringAsFixed(4)}, ${selectedPoint.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );

          final actionButton = ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRoyal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final chosenAddress =
                  selectedAddress ??
                  '${selectedPoint.latitude}, ${selectedPoint.longitude}';
              LocationService.syncLocationToSupabase(chosenAddress);
              onLocationSelected?.call(chosenAddress);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBn
                        ? 'নির্বাচিত এলাকা সংরক্ষিত হয়েছে: $chosenAddress'
                        : 'Location saved: $chosenAddress',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              isBn ? 'এই লোকেশন নিন' : 'Set Location',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.pin_drop_rounded,
                      color: AppColors.accentCoral,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: addressColumn),
                  ],
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: actionButton),
              ],
            );
          }

          return Row(
            children: [
              const Icon(
                Icons.pin_drop_rounded,
                color: AppColors.accentCoral,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(child: addressColumn),
              const SizedBox(width: 8),
              actionButton,
            ],
          );
        },
      ),
    );
  }
}
