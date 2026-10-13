import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/services/app_language_service.dart';

/// Screen 4 Featured Trade Specialist Section aligned with SRS Section 3.1.B & 3.1.C
class FeaturedWorkersSection extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const FeaturedWorkersSection({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isBn ? 'শীর্ষ দক্ষ কারিগর' : 'Featured Specialists',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap:
                  onSeeAll ??
                  () => Navigator.pushNamed(context, AppRoutes.teamDiscovery),
              child: Text(
                AppLanguageService.tr('see_all'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRoyal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.workerProfile,
            arguments: {
              'name': isBn ? 'মোঃ তরিকুল ইসলাম' : 'Md. Tariqul Islam',
              'title': isBn
                  ? 'সনদপ্রাপ্ত মাস্টার ইলেকট্রিশিয়ান'
                  : 'Certified Master Electrician',
              'rating': 4.95,
              'reviewsCount': 48,
              'completedJobs': 124,
              'location': 'Dhanmondi, Dhaka',
            },
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: const Icon(
                    Icons.engineering_rounded,
                    color: AppColors.primarySky,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              isBn ? 'মোঃ তরিকুল ইসলাম' : 'Md. Tariqul Islam',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.successGreen,
                                  size: 11,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isBn ? 'যাচাইকৃত' : 'Verified',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isBn
                            ? 'মাস্টার ইলেকট্রিশিয়ান • ধানমন্ডি'
                            : 'Master Electrician • Dhanmondi',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF59E0B),
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isBn
                                ? '৪.৯৫ (৪৮টি রিভিউ • ১২৪টি সম্পন্ন কাজ)'
                                : '4.95 (48 reviews • 124 completed)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
