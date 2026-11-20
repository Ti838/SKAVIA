import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/skavia_badge.dart';
import '../../data/models/service_model.dart';

/// Clean catalog card representing a real database-driven SKAVIA service.
/// Never displays fabricated 0.0 ratings or placeholder durations.
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
    final l10n = context.l10n;
    final isBn = context.isBengali;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final hasVerifiedRating =
        service.ratingAverage > 0 && service.totalBookings > 0;
    final hasDuration = service.estimatedDuration.trim().isNotEmpty;

    final bookButton = Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onBook,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            l10n.servicesBookNow,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );

    final metaItems = <Widget>[
      if (hasVerifiedRating)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 15, color: tokens.warning),
            const SizedBox(width: 3),
            Text(
              '${service.ratingAverage.toStringAsFixed(1)} (${service.totalBookings})',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        )
      else
        SkaviaBadge(
          label: isBn ? 'ক্যাটালগ সার্ভিস' : 'Standard Rate',
          icon: Icons.verified_outlined,
          tone: SkaviaBadgeTone.verified,
          compact: true,
        ),
      if (hasDuration)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 14, color: tokens.secondaryText),
            const SizedBox(width: 4),
            Text(
              service.estimatedDuration,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.secondaryText,
              ),
            ),
          ],
        ),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onBook,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      service.basePrice > 0
                          ? '৳ ${service.basePrice.toStringAsFixed(0)}'
                          : (isBn ? 'আলোচনা সাপেক্ষে' : 'Custom Quote'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: AppTypography.tabularFigures,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (service.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.secondaryText,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stackFooter =
                        constraints.maxWidth < 290 || textScale > 1.35;
                    final metaWrap = Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: metaItems,
                    );
                    if (stackFooter) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          metaWrap,
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: bookButton,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: metaWrap),
                        const SizedBox(width: 10),
                        bookButton,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
