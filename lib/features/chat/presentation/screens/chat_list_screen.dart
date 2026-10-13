import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';
import 'chat_room_screen.dart';

import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  final bool isTab;

  const ChatListScreen({super.key, this.isTab = false});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatRemoteDataSource _chatDataSource = ChatRemoteDataSource();
  final AuthController _authController = AuthController();

  List<ConversationModel> _conversations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    final userId = _authController.user?.uid ?? 'guest_user';
    try {
      final list = await _chatDataSource.getConversations(userId);
      if (mounted) {
        setState(() {
          _conversations = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _conversations.where((c) {
      final name = c.otherParticipantName?.toLowerCase() ?? '';
      final msg = c.lastMessageText?.toLowerCase() ?? '';
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || msg.contains(q);
    }).toList();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Direct Messages',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.4,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: colorScheme.primary,
                    ),
                    onPressed: _loadConversations,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Instant coordination between clients & verified specialists',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : AppColors.sheetSurfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search chats or names...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _searchQuery = ''),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Body: List or Empty State
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            indent: 72,
                            color: AppColors.borderLight,
                          ),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final timeStr = _formatTimestamp(
                              item.lastMessageAt,
                            );
                            final otherId =
                                item.participantOne ==
                                    (_authController.user?.uid ?? '')
                                ? item.participantTwo
                                : item.participantOne;

                            return InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatRoomScreen(
                                      conversationId: item.conversationId,
                                      otherParticipantName:
                                          item.otherParticipantName ??
                                          'SKAVIA Member',
                                      otherParticipantAvatar:
                                          item.otherParticipantAvatar,
                                      otherParticipantId: otherId,
                                    ),
                                  ),
                                );
                                _loadConversations();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: AppColors.primarySky
                                          .withValues(alpha: 0.15),
                                      backgroundImage:
                                          item.otherParticipantAvatar != null
                                          ? NetworkImage(
                                              item.otherParticipantAvatar!,
                                            )
                                          : null,
                                      child: item.otherParticipantAvatar == null
                                          ? Text(
                                              (item
                                                          .otherParticipantName
                                                          ?.isNotEmpty ??
                                                      false)
                                                  ? item.otherParticipantName![0]
                                                        .toUpperCase()
                                                  : 'U',
                                              style: const TextStyle(
                                                color: AppColors.primaryRoyal,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 14),

                                    // Name & snippet
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  item.otherParticipantName ??
                                                      'SKAVIA Member',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: colorScheme.onSurface,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                timeStr,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.lastMessageText ??
                                                      'Conversation started',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        item.unreadCount > 0
                                                        ? FontWeight.w700
                                                        : FontWeight.w400,
                                                    color: item.unreadCount > 0
                                                        ? colorScheme.onSurface
                                                        : colorScheme.onSurfaceVariant,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (item.unreadCount > 0)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: AppColors
                                                            .primarySky,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: Text(
                                                    '${item.unreadCount}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );

    if (widget.isTab) {
      return Container(color: colorScheme.surface, child: content);
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppDimensions.roundedSheet,
          ),
          child: ClipRRect(
            borderRadius: AppDimensions.roundedSheet,
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainerHighest
                      : AppColors.cardBlueTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.forum_outlined,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Conversations Yet',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'When you book a specialist, post a requirement, or accept a job assignment, your direct real-time communication will be listed here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return DateFormat('hh:mm a').format(dt);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat('EEE').format(dt);
    } else {
      return DateFormat('dd MMM').format(dt);
    }
  }
}
