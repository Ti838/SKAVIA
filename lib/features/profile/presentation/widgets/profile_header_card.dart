import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/enums/app_role_mode.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../data/models/user_profile_model.dart';

/// Header card displaying cover banner, circular avatar with verification status,
/// user display name, contact info, and role badge.
class ProfileHeaderCard extends StatelessWidget {
  final UserProfileModel profile;
  final String displayName;
  final String contactLabel;
  final String? effectiveAvatarUrl;
  final String? effectiveCoverUrl;
  final AppRoleMode currentMode;
  final VoidCallback onAvatarPick;
  final VoidCallback onCoverPick;
  final VoidCallback onOpenSettings;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.displayName,
    required this.contactLabel,
    required this.effectiveAvatarUrl,
    required this.effectiveCoverUrl,
    required this.currentMode,
    required this.onAvatarPick,
    required this.onCoverPick,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final isBn = context.isBengali;

    final roleLabel = currentMode == AppRoleMode.worker
        ? l10n.roleSpecialistWorker
        : (currentMode == AppRoleMode.enterprise
              ? (profile.customerType == 'Organization'
                    ? l10n.roleOrganization
                    : l10n.roleBusinessClient)
              : l10n.roleIndividualCustomer);

    final roleAccent = currentMode == AppRoleMode.worker
        ? AppColors.accent
        : (currentMode == AppRoleMode.enterprise
              ? AppColors.successGreen
              : tokens.brandAccent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Facebook-style Cover Banner + Overlapping Circular Profile Photo
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Container(
                height: 152,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tokens.border),
                  gradient: effectiveCoverUrl == null
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryRoyal.withValues(alpha: 0.9),
                            tokens.brandAccent.withValues(alpha: 0.78),
                          ],
                        )
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (effectiveCoverUrl != null)
                      Image.network(
                        effectiveCoverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryRoyal.withValues(alpha: 0.9),
                                tokens.brandAccent.withValues(alpha: 0.78),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.36),
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Settings',
                          onPressed: onOpenSettings,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: InkWell(
                        onTap: onCoverPick,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.56),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                effectiveCoverUrl == null
                                    ? (isBn ? 'কভার যোগ করুন' : 'Add Cover')
                                    : (isBn ? 'কভার বদলান' : 'Edit Cover'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onAvatarPick,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: UserAvatar(
                      imageUrl: effectiveAvatarUrl,
                      name: displayName,
                      radius: 40,
                      isVerified: profile.verificationStatus == 'verified',
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: tokens.brandAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: tokens.onBrandAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          contactLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if ((profile.companyName ?? '').isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            profile.companyName!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tokens.brandAccent,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: roleAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            roleLabel,
            style: TextStyle(
              color: roleAccent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
