import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/conversation_tile.dart';

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
        setState(() => _isLoading = false);
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

    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final userId = _authController.user?.uid ?? 'guest_user';

    final content = RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Direct Messages',
                        style: TextStyle(
                          fontFamily: AppTypography.headingFont,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: tokens.brandAccent,
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
                    color: tokens.mutedText,
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
                color: tokens.subtleCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tokens.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: tokens.mutedText,
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
                          color: tokens.mutedText,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 18,
                        color: tokens.mutedText,
                      ),
                      onPressed: () => setState(() => _searchQuery = ''),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (filtered.isEmpty)
            const ChatEmptyState(shrinkWrap: true)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                indent: 72,
                color: tokens.border,
              ),
              itemBuilder: (context, index) {
                return ConversationTile(
                  conversation: filtered[index],
                  currentUserId: userId,
                  onReturn: _loadConversations,
                );
              },
            ),
        ],
      ),
    );

    if (widget.isTab) {
      return Container(color: tokens.sheetBg, child: content);
    }

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: const AppAppBar(title: 'Messages'),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: tokens.sheetBg,
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
}
