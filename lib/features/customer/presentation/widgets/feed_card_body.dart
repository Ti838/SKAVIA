import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../data/models/requirement_model.dart';

/// Middle content section of a feed card: categories, urgency badge, title, description, location and budget.
class FeedCardBody extends StatelessWidget {
  final JobRequirementItem job;

  const FeedCardBody({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final isEmergency = job.urgency.toLowerCase().contains('emergency');
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    final locationChip = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.location_on_rounded,
          size: 15,
          color: AppColors.primarySky,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            job.location,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final budgetLabel = Text(
      '৳ ${job.budgetMin.toStringAsFixed(0)} - ৳ ${job.budgetMax.toStringAsFixed(0)}',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: tokens.brandAccent,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category & Urgency Badges
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (isEmergency)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.softPeachBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBn ? 'জরুরি' : 'Urgent',
                        style: const TextStyle(
                          color: AppColors.accentCoral,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.softBlueBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job.category,
                      style: TextStyle(
                        color: tokens.brandAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                job.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                job.description,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Location & Budget Strip
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: tokens.softBlueBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stackRows = constraints.maxWidth < 330 || textScale > 1.35;
                if (stackRows) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      locationChip,
                      const SizedBox(height: 6),
                      budgetLabel,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: locationChip),
                    const SizedBox(width: 8),
                    budgetLabel,
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
