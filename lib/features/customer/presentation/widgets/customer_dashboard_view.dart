import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/radar_map_artwork_widget.dart';
import '../../../../shared/widgets/radar_map_sheet.dart';
import '../../../../shared/widgets/skavia_badge.dart';
import '../../../../shared/widgets/skavia_search_field.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';
import '../../data/models/requirement_model.dart';
import 'active_booking_card.dart';
import 'business_dashboard_view.dart';
import 'dashboard_trust_safety_section.dart';
import 'featured_workers_section.dart';
import 'job_requirement_feed_card.dart';
import 'live_job_bid_sheet.dart';
import 'popular_services_section.dart';

/// Role-aware Customer & Business/Organization Home Dashboard.
/// Strictly database-driven with zero fabricated counts, demo banners, or duplicate CTAs.
class CustomerDashboardView extends StatelessWidget {
  final TextEditingController searchController;
  final String currentLocationZone;
  final String? userIdentifier;
  final String? userAvatarUrl;
  final bool isEnterpriseMode;
  final DashboardBusinessStats? businessStats;
  final Map<String, dynamic>? activeClientBooking;
  final VoidCallback onSelectServicesTab;
  final VoidCallback onOpenChat;
  final VoidCallback? onOpenProjectsTab;
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
    this.userAvatarUrl,
    this.isEnterpriseMode = false,
    this.businessStats,
    required this.activeClientBooking,
    required this.onSelectServicesTab,
    required this.onOpenChat,
    this.onOpenProjectsTab,
    required this.onViewOtp,
    required this.onCallHelpline,
    required this.onQuickBookService,
    this.liveRequirements = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final l10n = context.l10n;
    final isBn = context.isBengali;

    // Business Client & Organization get their dedicated operational dashboard
    if (isEnterpriseMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BusinessDashboardView(
            stats: businessStats ?? const DashboardBusinessStats(),
            currentLocationZone: currentLocationZone,
            onSelectServicesTab: onSelectServicesTab,
            onOpenProjectsTab:
                onOpenProjectsTab ??
                () => Navigator.pushNamed(context, AppRoutes.projectDashboard),
          ),
          const SizedBox(height: 20),
          DashboardTrustSafetySection(
            userIdentifier: userIdentifier,
            onCallHelpline: onCallHelpline,
          ),
        ],
      );
    }

    final feedItems = liveRequirements.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Clean Universal Search Bar
        SkaviaSearchField(
          controller: searchController,
          hintText: AppLanguageService.tr('search_hint'),
          onSubmitted: (query) {
            if (query.trim().isNotEmpty) {
              Navigator.pushNamed(
                context,
                AppRoutes.categoryCatalog,
                arguments: {'searchQuery': query.trim()},
              );
            }
          },
          trailing: IconButton(
            tooltip: isBn ? 'সার্ভিস ফিল্টার' : 'Browse services',
            icon: Icon(
              Icons.tune_rounded,
              color: tokens.secondaryText,
              size: 20,
            ),
            onPressed: onSelectServicesTab,
          ),
        ),
        const SizedBox(height: 16),

        // 2. Active Booking Overview (only if a genuine booking exists)
        if (activeClientBooking != null) ...[
          ActiveBookingCard(
            booking: activeClientBooking!,
            locationZone: currentLocationZone,
            onViewOtp: onViewOtp,
            onOpenChat: onOpenChat,
          ),
          const SizedBox(height: 16),
        ],

        // 3. Clean Operational Action Card (Single clear primary action + subtle violet AI)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: tokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn
                    ? 'আপনার কী সার্ভিস প্রয়োজন?'
                    : 'What service do you need today?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isBn
                    ? 'সরাসরি ক্যাটালগ থেকে বুক করুন অথবা আপনার কাজের বিবরণ পোস্ট করুন।'
                    : 'Book directly from the SKAVIA catalogue or post a custom requirement.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.secondaryText,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                  final stackActions =
                      constraints.maxWidth < 290 || textScale > 1.35;
                  final browseBtn = AppButton(
                    text: l10n.businessBrowseServices,
                    onPressed: onSelectServicesTab,
                    height: 44,
                  );
                  final postBtn = AppButton(
                    text: l10n.homeRequestService,
                    variant: AppButtonVariant.outline,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.postRequirement),
                    height: 44,
                  );
                  if (stackActions) {
                    return Column(
                      children: [
                        browseBtn,
                        const SizedBox(height: 8),
                        postBtn,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: browseBtn),
                      const SizedBox(width: 10),
                      Expanded(child: postBtn),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Material(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.skaviaAi),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isBn
                                ? 'SKAVIA AI দিয়ে সমস্যা বিশ্লেষণ ও আনুমানিক খরচ জানুন'
                                : 'Diagnose an issue or estimate scope with SKAVIA AI',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. Service Categories Grid
        PopularServicesSection(onSeeAll: onSelectServicesTab),
        const SizedBox(height: 20),

        // 5. Available Verified Specialists (Live Supabase Query)
        FeaturedWorkersSection(
          onSeeAll: () => Navigator.pushNamed(context, AppRoutes.teamDiscovery),
        ),
        const SizedBox(height: 20),

        // 6. Live Dhaka Service Area Map Card
        RadarMapArtworkWidget(
          locationZone: currentLocationZone,
          activeTechCount: 0,
          onExpand: () => RadarMapSheet.show(
            context,
            locationZone: currentLocationZone,
            onSelectTechnician: (tech) {
              onQuickBookService(tech.trade, 'cat_electrical', tech.startingRate);
            },
          ),
        ),
        const SizedBox(height: 20),

        // 7. Recent Marketplace Feed (Honest count only — zero fake "18+ Open")
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.homeRecentOpportunities,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (liveRequirements.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    SkaviaBadge(
                      label: '${liveRequirements.length}',
                      tone: SkaviaBadgeTone.primary,
                      compact: true,
                    ),
                  ],
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.liveJobFeed),
              child: Text(l10n.commonSeeAll),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (feedItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: tokens.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.dynamic_feed_outlined,
                  size: 28,
                  color: tokens.mutedText,
                ),
                const SizedBox(height: 8),
                Text(
                  isBn ? 'এখনও কোনো পোস্ট নেই' : 'No Marketplace Posts Yet',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isBn
                      ? 'প্রথম সার্ভিস রিকোয়েস্ট বা জব পোস্ট করুন।'
                      : 'When community members post requirements, they will appear here.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.secondaryText,
                  ),
                ),
              ],
            ),
          )
        else
          ...feedItems.map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobRequirementFeedCard(
                job: job,
                onApply: () => LiveJobBidSheet.show(context, job),
                onMessage: onOpenChat,
              ),
            ),
          ),
        const SizedBox(height: 16),

        // 8. Trust & Safety Support Section
        DashboardTrustSafetySection(
          userIdentifier: userIdentifier,
          onCallHelpline: onCallHelpline,
        ),
      ],
    );
  }
}
