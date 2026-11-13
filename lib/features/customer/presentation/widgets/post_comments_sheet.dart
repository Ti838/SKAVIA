import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/models/requirement_model.dart';

/// Interactive modal sheet to view and post comments on a feed opportunity
class PostCommentsSheet extends StatefulWidget {
  final JobRequirementItem job;
  final VoidCallback? onCommentAdded;

  const PostCommentsSheet({super.key, required this.job, this.onCommentAdded});

  static void show(
    BuildContext context, {
    required JobRequirementItem job,
    VoidCallback? onCommentAdded,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          PostCommentsSheet(job: job, onCommentAdded: onCommentAdded),
    );
  }

  @override
  State<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<PostCommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final AuthController _authController = AuthController();
  final List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  String get _cacheKey => 'skavia_feed_comments_${widget.job.id}';

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _authController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _loadCachedComments() {
    final raw = LocalCacheService.instance.get(_cacheKey);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoading = true);
    final list = <Map<String, dynamic>>[];
    final client = tryGetSupabaseClient();

    if (client != null && UuidUtil.isValidUuid(widget.job.id)) {
      try {
        final res = await client
            .from('messages')
            .select(
              'message_id, sender_id, message_text, created_at, users(full_name)',
            )
            .eq('conversation_id', widget.job.id)
            .order('created_at', ascending: true)
            .limit(50);

        for (final r in (res as List<dynamic>)) {
          final users = r['users'] as Map<String, dynamic>?;
          list.add({
            'id': r['message_id']?.toString() ?? '',
            'author': users?['full_name'] ?? 'Verified Member',
            'body': r['message_text'] ?? '',
            'time': 'Recent',
          });
        }
      } catch (e) {
        debugPrint('[PostCommentsSheet fetch notice]: $e');
      }
    }

    if (list.isEmpty) {
      list.addAll(_loadCachedComments());
    }

    if (mounted) {
      setState(() {
        _comments.clear();
        _comments.addAll(list);
        _isLoading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    final user = _authController.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to comment.')),
      );
      return;
    }

    setState(() => _isSending = true);
    final userName =
        user.displayName ?? user.email?.split('@').first ?? 'Member';

    final entry = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'author': userName,
      'body': text,
      'time': 'Just now',
    };

    setState(() {
      _comments.add(entry);
      _commentController.clear();
      _isSending = false;
    });

    LocalCacheService.instance.put(_cacheKey, _comments);
    widget.onCommentAdded?.call();

    final client = tryGetSupabaseClient();
    if (client != null && UuidUtil.isValidUuid(widget.job.id)) {
      try {
        await client.from('messages').insert({
          'conversation_id': widget.job.id,
          'sender_id': user.uid,
          'message_text': text,
        });
      } catch (e) {
        debugPrint('[PostCommentsSheet remote sync notice]: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: tokens.sheetBg,
        borderRadius: AppDimensions.roundedSheet,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'আলোচনা ও কমেন্ট' : 'Community Discussion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          widget.job.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 16, color: tokens.border),

            // Comment List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          isBn
                              ? 'এখনও কোনো কমেন্ট নেই। প্রথম কমেন্ট করুন!'
                              : 'No comments yet. Be the first to inquire!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      itemCount: _comments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, idx) {
                        final c = _comments[idx];
                        final author = c['author']?.toString() ?? 'Member';
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: tokens.softBlueBg,
                              child: Text(
                                author.isNotEmpty
                                    ? author[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: tokens.brandAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: tokens.subtleCardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: tokens.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            author,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          c['time']?.toString() ?? 'Recent',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c['body']?.toString() ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurface,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Comment Input Field
            Container(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottomInset),
              decoration: BoxDecoration(
                color: tokens.sheetBg,
                border: Border(
                  top: BorderSide(color: tokens.border),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: tokens.subtleCardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: tokens.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _commentController,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: isBn
                              ? 'একটি প্রশ্ন বা প্রস্তাব লিখুন...'
                              : 'Write an inquiry or comment...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: tokens.brandAccent,
                          ),
                    onPressed: _sendComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
