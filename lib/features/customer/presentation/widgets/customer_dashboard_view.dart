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
import '../../data/models/requirement_model.dart';

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
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Universal Search Bar ("Search services, skills, or people...")
        _buildUniversalSearchBar(context),
        const SizedBox(height: 18),

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLanguageService.tr('featured_services'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: onSelectServicesTab,
              child: Row(
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

        // Live Marketplace Jobs Feed Banner
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.liveJobFeed),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : AppColors.sheetSurfaceSubtle,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.dynamic_feed_rounded,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.primaryRoyal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLanguageService.isBengali
                                ? 'লাইভ কাজের ফিড'
                                : 'Live Jobs & Requests Feed',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
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
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              AppLanguageService.isBengali
                                  ? '১৮+ সক্রিয়'
                                  : '18+ Open',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.successGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLanguageService.isBengali
                            ? 'সারা দেশের ক্লায়েন্টদের পোস্ট করা কাজ দেখুন ও সরাসরি বিড করুন'
                            : 'Explore open requirements across Bangladesh and submit direct bids',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.primaryRoyal,
                ),
              ],
            ),
          ),
        ),
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
