import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';

/// Bottom action bar for feed cards: like, comment, share, save, and apply/bid.
class FeedCardActions extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final int commentsCount;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback? onApply;

  const FeedCardActions({
    super.key,
    required this.isLiked,
    required this.likesCount,
    required this.commentsCount,
    required this.isSaved,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final muted = colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                // Like Action
                InkWell(
                  onTap: onLike,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: isLiked ? AppColors.accentCoral : muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$likesCount',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isLiked ? AppColors.accentCoral : muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Comment Action
                InkWell(
                  onTap: onComment,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16,
                          color: muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$commentsCount',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Share Action
                InkWell(
                  onTap: onShare,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      Icons.share_outlined,
                      size: 17,
                      color: muted,
                    ),
                  ),
                ),

                // Save Action
                InkWell(
                  onTap: onSave,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 17,
                      color: isSaved ? tokens.brandAccent : muted,
                    ),
                  ),
                ),
              ],
            ),

            // Apply / Bid Action Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.brandAccent,
                foregroundColor: tokens.onBrandAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: onApply,
              child: Text(
                isBn ? 'আবেদন' : 'Apply / Bid',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
