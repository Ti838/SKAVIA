import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/skavia_badge.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';

/// Role-specific operational dashboard for Business Client & Organization workspaces.
/// Strictly renders real Supabase project & requirement counts with honest empty states.
class BusinessDashboardView extends StatelessWidget {
  final DashboardBusinessStats stats;
  final String currentLocationZone;
  final VoidCallback onSelectServicesTab;
  final VoidCallback onOpenProjectsTab;

  const BusinessDashboardView({
    super.key,
    required this.stats,
    required this.currentLocationZone,
    required this.onSelectServicesTab,
    required this.onOpenProjectsTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final l10n = context.l10n;
    final isBn = context.isBengali;
    final isOrg = stats.customerType.toLowerCase().contains('org');
    final displayTitle =
        (stats.companyName != null && stats.companyName!.trim().isNotEmpty)
            ? stats.companyName!.trim()
            : (isOrg
                ? l10n.organizationWorkspaceTitle
                : l10n.businessWorkspaceTitle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Operational Workspace Header Card (Clean White + Subtle Violet Role Badge)
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
              SkaviaBadge(
                label: isOrg
                    ? l10n.roleOrganization
                    : l10n.roleBusinessClient,
                icon: isOrg
                    ? Icons.apartment_rounded
                    : Icons.business_center_outlined,
                tone: SkaviaBadgeTone.violet,
              ),
              const SizedBox(height: 10),
              Text(
                displayTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isBn
                    ? '$currentLocationZone · সার্ভিস রিকোয়ারমেন্ট ও টিম সমন্বয়'
                    : '$currentLocationZone · Service requirements & active assignments',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      label: l10n.businessActiveProjects,
                      value: Formatters.toBengaliDigits(stats.activeProjectsCount),
                      icon: Icons.folder_open_rounded,
                      bg: colorScheme.secondaryContainer,
                      fg: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      label: l10n.businessOpenRequirements,
                      value: Formatters.toBengaliDigits(stats.openRequirementsCount),
                      icon: Icons.assignment_outlined,
                      bg: colorScheme.primaryContainer,
                      fg: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: l10n.businessCreateRequirement,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.postRequirement,
                      ),
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: l10n.businessBrowseServices,
                      variant: AppButtonVariant.outline,
                      onPressed: onSelectServicesTab,
                      height: 44,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Active Assignments / Projects Overview
        Row(
          children: [
            Expanded(
              child: Text(
                isBn ? 'সক্রিয় প্রজেক্ট ও অ্যাসাইনমেন্ট' : 'Active Projects',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: onOpenProjectsTab,
              child: Text(isBn ? 'সব দেখুন' : 'View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (stats.projects.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tokens.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    size: 28,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.businessNoProjectsTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.businessNoProjectsSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.secondaryText,
                  ),
                ),
              ],
            ),
          )
        else
          ...stats.projects.map((p) {
            final title = p['title']?.toString() ?? 'Untitled Project';
            final status = p['status']?.toString() ?? 'Active';
            final budget = (p['total_budget'] as num?)?.toDouble() ?? 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: tokens.cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  side: BorderSide(color: tokens.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.projectDashboard,
                    arguments: {
                      'projectId': p['project_id']?.toString(),
                      'projectTitle': title,
                    },
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.folder_outlined,
                            color: colorScheme.onSecondaryContainer,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  SkaviaBadge(
                                    label: status,
                                    tone: status == 'Completed'
                                        ? SkaviaBadgeTone.success
                                        : SkaviaBadgeTone.violet,
                                    compact: true,
                                  ),
                                  if (budget > 0) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '৳ ${budget.toStringAsFixed(0)}',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontFeatures:
                                                AppTypography.tabularFigures,
                                            color: tokens.secondaryText,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: tokens.mutedText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color bg,
    required Color fg,
  }) {
    final theme = Theme.of(context);
    final tokens = context.skavia;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.subtleCardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFeatures: AppTypography.tabularFigures,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
