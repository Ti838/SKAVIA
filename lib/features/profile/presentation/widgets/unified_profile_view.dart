import 'package:flutter/material.dart';

import '../../../../shared/enums/app_role_mode.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../customer/presentation/widgets/avatar_picker_sheet.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/services/profile_completion_engine.dart';
import '../controllers/profile_controller.dart';
import 'profile_completion_banner_card.dart';
import 'profile_header_card.dart';
import 'profile_menu_section.dart';
import 'profile_stats_grid.dart';

/// Screen 16 Complete Unified Profile View with live stats, completion strength, and menu tiles.
class UnifiedProfileView extends StatefulWidget {
  final AuthController authController;
  final ProfileController? profileController;
  final String? customAvatarUrl;
  final String? customCoverUrl;
  final AppRoleMode currentMode;
  final VoidCallback onAvatarPick;
  final VoidCallback? onCoverPick;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenServices;
  final VoidCallback onOpenProjects;
  final VoidCallback onCallHelpline;
  final VoidCallback onSwitchRole;
  final VoidCallback onLogout;

  const UnifiedProfileView({
    super.key,
    required this.authController,
    this.profileController,
    this.customAvatarUrl,
    this.customCoverUrl,
    required this.currentMode,
    required this.onAvatarPick,
    this.onCoverPick,
    required this.onOpenSettings,
    required this.onOpenServices,
    required this.onOpenProjects,
    required this.onCallHelpline,
    required this.onSwitchRole,
    required this.onLogout,
  });

  @override
  State<UnifiedProfileView> createState() => _UnifiedProfileViewState();
}

class _UnifiedProfileViewState extends State<UnifiedProfileView> {
  ProfileController get _profileController =>
      widget.profileController ?? ProfileController.shared;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = widget.authController.user;
      _profileController.loadCurrentUserIfNeeded(
        userId: user?.uid,
        fallbackEmail: user?.email,
        fallbackName: user?.displayName,
        fallbackPhone: user?.phoneNumber,
        fallbackAvatarUrl: widget.customAvatarUrl ?? user?.photoURL,
      );
    });
  }

  void _handleCoverTap(String? effectiveCoverUrl, String? userId) {
    if (widget.onCoverPick != null) {
      widget.onCoverPick!();
      return;
    }
    AvatarPickerSheet.show(
      context,
      currentAvatarUrl: effectiveCoverUrl,
      userId: userId,
      slot: ProfileMediaSlot.cover,
      onAvatarSelected: (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.user;

    return ListenableBuilder(
      listenable: _profileController,
      builder: (context, _) {
        final profile = _profileController.profile;
        final stats = _profileController.stats;

        final displayName =
            (profile?.fullName.isNotEmpty == true &&
                profile!.fullName != 'SKAVIA Member')
            ? profile.fullName
            : (user?.displayName?.isNotEmpty == true
                  ? user!.displayName!
                  : 'SKAVIA Member');

        final contactLabel =
            (profile?.email.isNotEmpty == true &&
                profile!.email != 'user@skavia.com')
            ? profile.email
            : (user?.email?.isNotEmpty == true
                  ? user!.email!
                  : (user?.phoneNumber ?? 'contact@skavia.com'));

        final rawAvatarUrl =
            widget.customAvatarUrl ??
            (profile?.avatarUrl?.isNotEmpty == true
                ? profile!.avatarUrl
                : user?.photoURL);
        final effectiveAvatarUrl =
            (rawAvatarUrl != null &&
                rawAvatarUrl.trim().isNotEmpty &&
                (rawAvatarUrl.startsWith('http://') ||
                    rawAvatarUrl.startsWith('https://')))
            ? rawAvatarUrl.trim()
            : null;

        final rawCoverUrl = widget.customCoverUrl ?? profile?.coverUrl;
        final effectiveCoverUrl =
            (rawCoverUrl != null &&
                rawCoverUrl.trim().isNotEmpty &&
                (rawCoverUrl.startsWith('http://') ||
                    rawCoverUrl.startsWith('https://')))
            ? rawCoverUrl.trim()
            : null;

        final effectiveProfile =
            profile ??
            UserProfileModel(
              id: user?.uid ?? 'guest',
              email: user?.email ?? '',
              fullName: displayName,
              avatarUrl: effectiveAvatarUrl,
              coverUrl: effectiveCoverUrl,
              phone: user?.phoneNumber,
            );

        final completionResult = ProfileCompletionEngine.evaluate(
          effectiveProfile,
        );

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileHeaderCard(
                profile: effectiveProfile,
                displayName: displayName,
                contactLabel: contactLabel,
                effectiveAvatarUrl: effectiveAvatarUrl,
                effectiveCoverUrl: effectiveCoverUrl,
                currentMode: widget.currentMode,
                onAvatarPick: widget.onAvatarPick,
                onCoverPick: () => _handleCoverTap(
                  effectiveCoverUrl,
                  user?.uid ?? profile?.id,
                ),
                onOpenSettings: widget.onOpenSettings,
              ),
              const SizedBox(height: 20),
              ProfileStatsGrid(stats: stats),
              const SizedBox(height: 16),
              ProfileCompletionBannerCard(
                result: completionResult,
                onActionTap: completionResult.nextRecommendedAction != null
                    ? () => Navigator.pushNamed(
                        context,
                        completionResult.nextRecommendedAction!.actionRoute,
                        arguments: _profileController,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              ProfileMenuSection(
                profileController: _profileController,
                currentMode: widget.currentMode,
                onOpenServices: widget.onOpenServices,
                onOpenProjects: widget.onOpenProjects,
                onCallHelpline: widget.onCallHelpline,
                onSwitchRole: widget.onSwitchRole,
                onLogout: widget.onLogout,
              ),
            ],
          ),
        );
      },
    );
  }
}
