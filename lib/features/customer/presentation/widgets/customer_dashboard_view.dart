import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../shared/widgets/radar_map_artwork_widget.dart';
import '../../../../shared/widgets/radar_map_sheet.dart';
import 'active_booking_card.dart';
import 'dashboard_action_hub_grid.dart';
import 'dashboard_trust_safety_section.dart';
import 'featured_service_pill.dart';
import 'featured_workers_section.dart';
import 'hero_banner_card.dart';
import 'popular_services_section.dart';
import '../../data/datasources/job_feed_seed_data.dart';
import '../../data/models/requirement_model.dart';
import 'feed_composer_prompt_card.dart';
import 'job_requirement_feed_card.dart';
import 'post_composer_sheet.dart';

/// Customer Mode Dashboard View (matching Reference Screen 4 architecture)
class CustomerDashboardView extends StatelessWidget {
  final TextEditingController searchController;
  final String currentLocationZone;
  final String? userIdentifier;
  final Map<String, dynamic>? activeClientBooking;
  final VoidCallback onSelectServicesTab;
  final VoidCallback onOpenChat;
  final VoidCallback onViewOtp;
  final VoidCallback onCallHelpline;
  final void Function(
    String serviceName,
    String categoryId,
    double startingRate,
  )
  onQuickBookService;
  final List<JobRequirementItem> liveRequirements;

  const CustomerDashboardView({
    super.key,
    required this.searchController,
    required this.currentLocationZone,
    required this.userIdentifier,
    required this.activeClientBooking,
    required this.onSelectServicesTab,
    required this.onOpenChat,
    required this.onViewOtp,
    required this.onCallHelpline,
    required this.onQuickBookService,
    this.liveRequirements = const [],
  });

  Widget _buildUniversalSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : AppColors.sheetSurfaceSubtle,
        borderRadius: AppDimensions.roundedPill,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(
              Icons.search_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: AppLanguageService.tr('search_hint'),
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.categoryCatalog,
                    arguments: {'searchQuery': query.trim()},
                  );
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.categoryCatalog);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final feedItems = liveRequirements.isNotEmpty
        ? liveRequirements.take(3).toList()
        : JobFeedSeedData.seedJobs.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Universal Search Bar ("Search services, skills, or people...")
        _buildUniversalSearchBar(context),
        const SizedBox(height: 14),

        // 1b. Facebook-Style Post Composer Prompt Card
        FeedComposerPromptCard(
          userInitial: (userIdentifier?.isNotEmpty ?? false)
              ? userIdentifier![0].toUpperCase()
              : 'U',
          onOpenComposer: () {
            PostComposerSheet.show(
              context,
              onPostCreated: (_) =>
                  Navigator.pushNamed(context, AppRoutes.liveJobFeed),
            );
          },
          isBn: isBn,
        ),
        const SizedBox(height: 14),

        // 2. Hero Banner Card ("Turn Your Ideas Into Reality")
        HeroBannerCard(
          onRequestService: () =>
              Navigator.pushNamed(context, AppRoutes.postRequirement),
        ),
        const SizedBox(height: 22),

        // 3. Popular Services Section (Design, Development, Marketing, Writing)
        PopularServicesSection(onSeeAll: onSelectServicesTab),
        const SizedBox(height: 24),

        // 4. Featured Workers Section (Rahul Ahmed - UI/UX Designer)
        FeaturedWorkersSection(
          onSeeAll: () => Navigator.pushNamed(context, AppRoutes.teamDiscovery),
        ),
        const SizedBox(height: 24),

        // 5. Live Dhaka Vector Radar Map Card with interactive Map Sheet trigger
        RadarMapArtworkWidget(
          locationZone: currentLocationZone,
          activeTechCount: 18,
          onExpand: () => RadarMapSheet.show(
            context,
            locationZone: currentLocationZone,
            onSelectTechnician: (tech) {
              onQuickBookService(
                tech.trade,
                'cat_${tech.trade.toLowerCase()}',
                tech.startingRate,
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // 6. bKash-Style Organized 4-Grid Action Hub (With SKAVIA AI)
        DashboardActionHubGrid(onBookService: onSelectServicesTab),
        const SizedBox(height: 22),

        // 7. Uber/Grab-Style Active Booking Card OR City Bank KYC Tracker
        if (activeClientBooking != null)
          ActiveBookingCard(
            booking: activeClientBooking!,
            locationZone: currentLocationZone,
            onViewOtp: onViewOtp,
            onOpenChat: onOpenChat,
          )
        else
          KycTrustCard(userIdentifier: userIdentifier),
        const SizedBox(height: 24),

        // 8. Featured Services (Reference Screen 3 Design with 1-Tap Booking)
        Row(
          children: [
            Expanded(
              child: Text(
                AppLanguageService.tr('featured_services'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSelectServicesTab,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLanguageService.tr('see_all'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.primary
                          : AppColors.primaryRoyal,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.primaryRoyal,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3 Curated Services with 1-Tap Quick Booking "+" Buttons
        FeaturedServicePill(
          icon: Icons.electric_bolt_rounded,
          title: AppLanguageService.tr('electrical_title'),
          subtitle: AppLanguageService.tr('electrical_desc'),
          accentColor: AppColors.accentPeach,
          startingRate: 500,
          categoryId: 'cat_electrical',
          onQuickBook: () => onQuickBookService(
            AppLanguageService.tr('electrical_title'),
            'cat_electrical',
            500,
          ),
        ),
        const SizedBox(height: 10),
        FeaturedServicePill(
          icon: Icons.ac_unit_rounded,
          title: AppLanguageService.tr('ac_title'),
          subtitle: AppLanguageService.tr('ac_desc'),
          accentColor: AppColors.primarySky,
          startingRate: 800,
          categoryId: 'cat_ac_hvac',
          onQuickBook: () => onQuickBookService(
            AppLanguageService.tr('ac_title'),
            'cat_ac_hvac',
            800,
          ),
        ),
        const SizedBox(height: 10),
        FeaturedServicePill(
          icon: Icons.plumbing_rounded,
          title: AppLanguageService.tr('plumbing_title'),
          subtitle: AppLanguageService.tr('plumbing_desc'),
          accentColor: AppColors.accentAqua,
          startingRate: 450,
          categoryId: 'cat_plumbing',
          onQuickBook: () => onQuickBookService(
            AppLanguageService.tr('plumbing_title'),
            'cat_plumbing',
            450,
          ),
        ),
        const SizedBox(height: 18),

        // 9. Facebook-Style Live Community & Jobs Feed Stream
        LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1.0);
            final stackFeedHeader =
                constraints.maxWidth < 340 || textScale > 1.3;

            final badgeWidget = Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isBn ? '১৮+ সক্রিয়' : '18+ Open',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.successGreen,
                ),
              ),
            );

            final viewAllButton = TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.liveJobFeed),
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: isDark ? colorScheme.primary : AppColors.primaryRoyal,
              ),
              label: Text(
                isBn ? 'সম্পূর্ণ ফিড' : 'View All',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? colorScheme.primary : AppColors.primaryRoyal,
                ),
              ),
            );

            final titleRow = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.dynamic_feed_rounded,
                  color: isDark ? colorScheme.primary : AppColors.primaryRoyal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isBn ? 'লাইভ সোশ্যাল ও কাজের ফিড' : 'Live Marketplace Feed',
                    maxLines: stackFeedHeader ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            );

            if (stackFeedHeader) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleRow,
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      badgeWidget,
                      viewAllButton,
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.dynamic_feed_rounded,
                        color: isDark
                            ? colorScheme.primary
                            : AppColors.primaryRoyal,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isBn
                              ? 'লাইভ সোশ্যাল ও কাজের ফিড'
                              : 'Live Marketplace Feed',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      badgeWidget,
                    ],
                  ),
                ),
                viewAllButton,
              ],
            );
          },
        ),
        const SizedBox(height: 10),

        // Stream of interactive Facebook-style feed cards
        ...feedItems.map(
          (job) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: JobRequirementFeedCard(
              job: job,
              onApply: () =>
                  Navigator.pushNamed(context, AppRoutes.postRequirement),
              onMessage: onOpenChat,
            ),
          ),
        ),

        // Bottom CTA to open full-screen feed
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.liveJobFeed),
            icon: const Icon(Icons.explore_outlined, size: 16),
            label: Text(
              isBn
                  ? 'আরও ১৮+ লাইভ সোশ্যাল পোস্ট ব্রাউজ করুন'
                  : 'Explore All 18+ Live Marketplace Posts',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 18),

        // Turnkey Business & Trust Safety Section
        DashboardTrustSafetySection(
          userIdentifier: userIdentifier,
          onCallHelpline: onCallHelpline,
        ),
      ],
    );
  }
}
