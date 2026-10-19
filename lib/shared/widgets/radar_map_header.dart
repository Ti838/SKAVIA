import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_language_service.dart';

/// Top grabber and header bar for RadarMapSheet.
class RadarMapHeader extends StatelessWidget {
  final String locationZone;
  final VoidCallback onClose;

  const RadarMapHeader({
    super.key,
    required this.locationZone,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primarySky.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: AppColors.primaryRoyal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn
                            ? 'লাইভ গুগল ম্যাপ ও রাডার'
                            : 'Live Street Map & Radar',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        isBn
                            ? 'সারা দেশব্যাপী ভেরিফায়েড টেকনিশিয়ান'
                            : 'Nationwide Verified Technicians • $locationZone',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
