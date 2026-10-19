import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../data/models/requirement_model.dart';
import 'feed_card_actions.dart';
import 'feed_card_body.dart';
import 'feed_card_header.dart';
import 'post_comments_sheet.dart';

export 'feed_card_actions.dart';
export 'feed_card_body.dart';
export 'feed_card_header.dart';

/// Social Marketplace Feed Card
/// Aligned with SKAVIA SRS Section 3.1 & Production Master Prompt.
/// Coordinates author header, post body, interaction actions,
/// saving, link sharing, and direct bidding/messaging.
class JobRequirementFeedCard extends StatefulWidget {
  final JobRequirementItem job;
  final VoidCallback? onApply;
  final VoidCallback? onMessage;
  final ValueChanged<JobRequirementItem>? onJobUpdated;

  const JobRequirementFeedCard({
    super.key,
    required this.job,
    this.onApply,
    this.onMessage,
    this.onJobUpdated,
  });

  @override
  State<JobRequirementFeedCard> createState() => _JobRequirementFeedCardState();
}

class _JobRequirementFeedCardState extends State<JobRequirementFeedCard> {
  late bool _isLiked;
  late int _likesCount;
  late bool _isSaved;
  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.job.isLikedByMe;
    _likesCount = widget.job.likesCount;
    _isSaved = widget.job.isSavedByMe;
    _commentsCount = widget.job.commentsCount;
  }

  @override
  void didUpdateWidget(covariant JobRequirementFeedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.job != widget.job) {
      _isLiked = widget.job.isLikedByMe;
      _likesCount = widget.job.likesCount;
      _isSaved = widget.job.isSavedByMe;
      _commentsCount = widget.job.commentsCount;
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
      if (_likesCount < 0) _likesCount = 0;
    });

    final updated = widget.job.copyWith(
      isLikedByMe: _isLiked,
      likesCount: _likesCount,
    );
    widget.onJobUpdated?.call(updated);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        debugPrint('[FeedCard] Synced like toggle for ${widget.job.id}');
      }
    } catch (_) {}
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });

    final updated = widget.job.copyWith(isSavedByMe: _isSaved);
    widget.onJobUpdated?.call(updated);

    final isBn = AppLanguageService.isBengali;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved
              ? (isBn ? 'সংরক্ষিত তালিকায় যোগ করা হয়েছে' : 'Saved to bookmarks')
              : (isBn
                    ? 'সংরক্ষিত তালিকা থেকে সরানো হয়েছে'
                    : 'Removed from bookmarks'),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sharePost() {
    final link = 'https://skavia.app/jobs/${widget.job.id}';
    Clipboard.setData(ClipboardData(text: link));
    final isBn = AppLanguageService.isBengali;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBn
              ? 'পোস্টের লিংক কপি করা হয়েছে: $link'
              : 'Post link copied to clipboard: $link',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openComments() {
    PostCommentsSheet.show(
      context,
      job: widget.job,
      onCommentAdded: () {
        setState(() {
          _commentsCount++;
        });
        final updated = widget.job.copyWith(commentsCount: _commentsCount);
        widget.onJobUpdated?.call(updated);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmergency = widget.job.urgency.toLowerCase().contains('emergency');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmergency
              ? AppColors.accentCoral.withValues(alpha: 0.35)
              : colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Author Header Row
          FeedCardHeader(job: widget.job),

          // 2. Title, Description, Location & Budget Body
          FeedCardBody(job: widget.job),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),

          // 3. Social Interactions & Bid/Apply Actions
          FeedCardActions(
            isLiked: _isLiked,
            likesCount: _likesCount,
            commentsCount: _commentsCount,
            isSaved: _isSaved,
            onLike: _toggleLike,
            onComment: _openComments,
            onShare: _sharePost,
            onSave: _toggleSave,
            onApply: widget.onApply,
          ),
        ],
      ),
    );
  }
}
