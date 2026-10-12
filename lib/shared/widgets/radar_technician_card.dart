import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_language_service.dart';
import '../models/radar_technician.dart';

/// Bottom preview and action card for selected technician on live radar map
class RadarTechnicianCard extends StatelessWidget {
  final RadarTechnician technician;
  final VoidCallback onBook;

  const RadarTechnicianCard({
    super.key,
    required this.technician,
    required this.onBook,
  });

  Future<void> _openInGoogleMaps(
    BuildContext context,
    double lat,
    double lng,
  ) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch Google Maps for ($lat, $lng)'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching Google Maps: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final tech = technician;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tech.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(tech.icon, color: tech.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              tech.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: AppColors.primarySky,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tech.trade} • ${tech.zone}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMedium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                            tech.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${tech.jobs} ${isBn ? "কাজ সম্পন্ন" : "Jobs"}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySky.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${tech.distanceKm} km ${isBn ? "দূরে" : "away"}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primarySky,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isBn ? 'শুরুর রেট' : 'Starting',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMedium,
                      ),
                    ),
                    Text(
                      '৳ ${tech.startingRate.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryRoyal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Actions Row: Open in Google Maps + Book Pro Now
            Row(
              children: [
                // Open in Google Maps App Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: AppColors.primarySky),
                  ),
                  icon: const Icon(
                    Icons.navigation_rounded,
                    size: 16,
                    color: AppColors.primaryRoyal,
                  ),
                  label: Text(
                    isBn ? 'গুগল ম্যাপ' : 'Google Maps',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.primaryRoyal,
                    ),
                  ),
                  onPressed: () =>
                      _openInGoogleMaps(context, tech.latitude, tech.longitude),
                ),
                const SizedBox(width: 10),

                // Book Pro Now
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRoyal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    onPressed: onBook,
                    child: Text(
                      isBn ? 'বুকিং করুন (Book Pro)' : 'Book Pro Now',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
