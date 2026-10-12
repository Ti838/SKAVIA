import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../data/models/service_model.dart';

/// Card representing a service offering in the category catalog
class CatalogServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onBook;

  const CatalogServiceCard({
    super.key,
    required this.service,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (service.popularBadge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accentPeach.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          service.popularBadge!,
                          style: const TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentCoral,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Base Price
              Text(
                '৳ ${service.basePrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryRoyal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textMedium,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 3),
              Text(
                service.ratingAverage.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${service.totalBookings})',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.textMedium,
              ),
              const SizedBox(width: 4),
              Text(
                service.estimatedDuration,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onBook,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySky,
                    borderRadius: AppDimensions.roundedPill,
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
