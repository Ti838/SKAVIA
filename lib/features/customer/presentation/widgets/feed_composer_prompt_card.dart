import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Top card in the live feed prompting user to create a post, job, or service request.
class FeedComposerPromptCard extends StatelessWidget {
  final String userInitial;
  final VoidCallback onOpenComposer;
  final bool isBn;

  const FeedComposerPromptCard({
    super.key,
    required this.userInitial,
    required this.onOpenComposer,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: tokens.softBlueBg,
                child: Text(
                  userInitial,
                  style: TextStyle(
                    color: tokens.brandAccent,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: tokens.subtleCardBg,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: onOpenComposer,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Text(
                        isBn
                            ? 'একটি কাজ পোস্ট করুন বা সেবা চান...'
                            : 'Share an opportunity, post a job, or request a service...',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
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
          const SizedBox(height: 10),
          Divider(height: 1, color: tokens.border),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 10,
              runSpacing: 8,
              children: [
                _buildActionItem(
                  context: context,
                  icon: Icons.work_outline_rounded,
                  color: tokens.brandAccent,
                  label: isBn ? 'কাজের পোস্ট' : 'Post Job',
                  onTap: onOpenComposer,
                ),
                _buildActionItem(
                  context: context,
                  icon: Icons.handyman_outlined,
                  color: AppColors.accentAqua,
                  label: isBn ? 'সেবা চান' : 'Request Service',
                  onTap: onOpenComposer,
                ),
                _buildActionItem(
                  context: context,
                  icon: Icons.campaign_outlined,
                  color: AppColors.accentCoral,
                  label: isBn ? 'আপডেট' : 'Share Update',
                  onTap: onOpenComposer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
