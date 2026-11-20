import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/skavia_badge.dart';
import '../screens/main_scaffold_screen.dart';

/// Interactive modal sheet for switching between authorized SKAVIA account modes
/// or initiating guided onboarding for an additional workspace role.
class RoleSwitchBottomSheet extends StatelessWidget {
  final AppRoleMode currentMode;
  final Set<AppRoleMode>? authorizedModes;
  final ValueChanged<AppRoleMode> onRoleSelected;
  final ValueChanged<AppRoleMode>? onSetupRole;

  const RoleSwitchBottomSheet({
    super.key,
    required this.currentMode,
    this.authorizedModes,
    required this.onRoleSelected,
    this.onSetupRole,
  });

  static Future<void> show(
    BuildContext context, {
    required AppRoleMode currentMode,
    Set<AppRoleMode>? authorizedModes,
    required ValueChanged<AppRoleMode> onRoleSelected,
    ValueChanged<AppRoleMode>? onSetupRole,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => RoleSwitchBottomSheet(
        currentMode: currentMode,
        authorizedModes: authorizedModes,
        onRoleSelected: (mode) {
          Navigator.of(ctx).pop();
          onRoleSelected(mode);
        },
        onSetupRole: onSetupRole != null
            ? (mode) {
                Navigator.of(ctx).pop();
                onSetupRole(mode);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final l10n = context.l10n;
    final isBn = context.isBengali;

    final roles = [
      (
        mode: AppRoleMode.customer,
        title: l10n.roleIndividualCustomer,
        subtitle: isBn
            ? 'যাচাইকৃত টেকনিশিয়ান বুকিং, সার্ভিস রিকোয়েস্ট এবং ওটিপি সুরক্ষা।'
            : 'Book verified home services, post requirements, and track bookings with OTP verification.',
        icon: Icons.person_outline_rounded,
        bg: colorScheme.primaryContainer,
        fg: colorScheme.onPrimaryContainer,
        accent: colorScheme.primary,
        tone: SkaviaBadgeTone.primary,
      ),
      (
        mode: AppRoleMode.enterprise,
        title: '${l10n.roleBusinessClient} & ${l10n.roleOrganization}',
        subtitle: isBn
            ? 'প্রজেক্ট সমন্বয়, সার্ভিস রিকোয়ারমেন্ট, টিম অ্যাসাইনমেন্ট এবং ইনভয়েস ব্যবস্থাপনা।'
            : 'Coordinate commercial service requirements, active project teams, and business billing.',
        icon: Icons.business_center_outlined,
        bg: colorScheme.secondaryContainer,
        fg: colorScheme.onSecondaryContainer,
        accent: colorScheme.secondary,
        tone: SkaviaBadgeTone.violet,
      ),
      (
        mode: AppRoleMode.worker,
        title: l10n.roleSpecialistWorker,
        subtitle: isBn
            ? 'কাজের অনুরোধ গ্রহণ, সক্রিয় কাজ পরিচালনা এবং আয় ট্র্যাকিং।'
            : 'Manage availability, accept incoming job requests, and track verified earnings.',
        icon: Icons.handyman_outlined,
        bg: colorScheme.tertiaryContainer,
        fg: colorScheme.onTertiaryContainer,
        accent: colorScheme.tertiary,
        tone: SkaviaBadgeTone.verified,
      ),
    ];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.switchAccountMode,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: tokens.secondaryText,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text(
              l10n.chooseWorkspaceSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            ...roles.map((r) {
              final isCurrent = currentMode == r.mode;
              final isAuthorized =
                  authorizedModes == null ||
                  authorizedModes!.contains(r.mode) ||
                  isCurrent;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: isCurrent
                      ? r.bg.withValues(alpha: 0.45)
                      : tokens.cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    side: BorderSide(
                      color: isCurrent ? r.accent : tokens.border,
                      width: isCurrent ? 1.8 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      if (isAuthorized || onSetupRole == null) {
                        onRoleSelected(r.mode);
                      } else {
                        onSetupRole!(r.mode);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: r.bg,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(r.icon, color: r.fg, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        r.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              color: colorScheme.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isCurrent)
                                      SkaviaBadge(
                                        label: l10n.roleStatusActive,
                                        tone: r.tone,
                                        compact: true,
                                      )
                                    else if (!isAuthorized)
                                      SkaviaBadge(
                                        label: l10n.roleStatusSetup,
                                        tone: SkaviaBadgeTone.neutral,
                                        compact: true,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r.subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: tokens.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
