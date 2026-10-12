import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_routes.dart';

/// Screen 4 Featured Workers Section featuring Rahul Ahmed (or passed list)
class FeaturedWorkersSection extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const FeaturedWorkersSection({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Workers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap:
                  onSeeAll ??
                  () => Navigator.pushNamed(context, AppRoutes.teamDiscovery),
              child: const Text(
                'See All',
                style: TextStyle(
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
              'name': 'Rahul Ahmed',
              'title': 'UI/UX Designer',
              'rating': 4.8,
              'reviewsCount': 32,
            },
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
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
                  backgroundColor: const Color(0xFFEFF6FF),
                  backgroundImage: const NetworkImage(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rahul Ahmed',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'UI/UX Designer',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF59E0B),
                            size: 16,
                          ),
                          SizedBox(width: 3),
                          Text(
                            '4.8 (32 reviews)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
