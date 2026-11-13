import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final isDark = theme.brightness == Brightness.dark;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    final bookPill = Material(
      color: AppColors.primarySky,
      borderRadius: AppDimensions.roundedPill,
      child: InkWell(
        onTap: onBook,
        borderRadius: AppDimensions.roundedPill,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            'Book Now',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    final metricsWrap = Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
            const SizedBox(width: 3),
            Text(
              service.ratingAverage.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              '(${service.totalBookings})',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 13,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 3),
            Text(
              service.estimatedDuration,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                          color: tokens.softPeachBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          service.popularBadge!,
                          style: TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.accentPeach
                                : AppColors.accentCoral,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      service.name,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Base Price
              Text(
                '৳ ${service.basePrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: tokens.brandAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackFooter = constraints.maxWidth < 300 || textScale > 1.35;
              if (stackFooter) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    metricsWrap,
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: bookPill),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: metricsWrap),
                  const SizedBox(width: 8),
                  bookPill,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
