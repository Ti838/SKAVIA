import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/user_avatar.dart';

/// Top card in the Feed prompting the user to create a Job, Service Request, or Update.
/// Displays the synchronized user avatar and 3 evenly-aligned single-row actions.
class FeedComposerPromptCard extends StatelessWidget {
  final String userInitial;
  final String? userName;
  final String? userAvatarUrl;
  final VoidCallback onOpenComposer;
  final ValueChanged<String>? onOpenComposerWithType;
  final bool isBn;
  final EdgeInsetsGeometry margin;

  const FeedComposerPromptCard({
    super.key,
    required this.userInitial,
    this.userName,
    this.userAvatarUrl,
    required this.onOpenComposer,
    this.onOpenComposerWithType,
    required this.isBn,
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 12),
  });

  void _triggerType(String type) {
    if (onOpenComposerWithType != null) {
      onOpenComposerWithType!(type);
    } else {
      onOpenComposer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final l10n = context.l10n;
    final effectiveName =
        (userName != null && userName!.trim().isNotEmpty) ? userName! : userInitial;

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(
                imageUrl: userAvatarUrl,
                name: effectiveName,
                radius: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: tokens.subtleCardBg,
                  borderRadius: AppDimensions.roundedPill,
                  child: InkWell(
                    onTap: onOpenComposer,
                    borderRadius: AppDimensions.roundedPill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppDimensions.roundedPill,
                        border: Border.all(color: tokens.border),
                      ),
                      child: Text(
                        l10n.feedComposerPlaceholder,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: tokens.mutedText,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: tokens.border),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.work_outline_rounded,
                  color: colorScheme.primary,
                  label: l10n.homePostJob,
                  onTap: () => _triggerType('Job'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.handyman_outlined,
                  color: tokens.tealAccent,
                  label: l10n.homeRequestService,
                  onTap: () => _triggerType('Service Request'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.campaign_outlined,
                  color: tokens.violetAccent,
                  label: l10n.homeShareUpdate,
                  onTap: () => _triggerType('Professional Update'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
