import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final tech = technician;
    final isLargeText = MediaQuery.textScalerOf(context).scale(1) > 1.35;

    final infoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                tech.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
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
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: isLargeText ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.accentPeach,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    tech.rating.toStringAsFixed(1),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${tech.jobs} ${isBn ? "কাজ সম্পন্ন" : "Jobs"}',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: tokens.softBlueBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${tech.distanceKm.toStringAsFixed(1)} km ${isBn ? "দূরে" : "away"}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: tokens.brandAccent,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final rateColumn = Column(
      crossAxisAlignment: isLargeText
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          isBn ? 'শুরুর রেট' : 'Starting',
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '৳ ${tech.startingRate.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: tokens.brandAccent,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        border: Border(top: BorderSide(color: tokens.border)),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tech.color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(tech.icon, color: tech.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(child: infoColumn),
                if (!isLargeText) ...[
                  const SizedBox(width: 8),
                  rateColumn,
                ],
              ],
            ),
            if (isLargeText) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: tokens.softBlueBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      isBn ? 'শুরুর রেট' : 'Starting',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '৳ ${tech.startingRate.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: tokens.brandAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Actions: Open in Google Maps + Book Pro Now (wraps safely on narrow screens/2x scale)
            LayoutBuilder(
              builder: (context, constraints) {
                final mapsButton = OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: tokens.brandAccent),
                  ),
                  icon: Icon(
                    Icons.navigation_rounded,
                    size: 16,
                    color: tokens.brandAccent,
                  ),
                  label: Text(
                    isBn ? 'গুগল ম্যাপ' : 'Google Maps',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: tokens.brandAccent,
                    ),
                  ),
                  onPressed: () =>
                      _openInGoogleMaps(context, tech.latitude, tech.longitude),
                );

                final bookButton = ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRoyal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onBook,
                  child: Text(
                    isBn ? 'বুকিং করুন' : 'Book Pro Now',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                );

                if (constraints.maxWidth < 310 ||
                    MediaQuery.textScalerOf(context).scale(1) > 1.35) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      bookButton,
                      const SizedBox(height: 8),
                      mapsButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    mapsButton,
                    const SizedBox(width: 10),
                    Expanded(child: bookButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
