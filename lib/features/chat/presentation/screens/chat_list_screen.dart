import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/empty_states/empty_data_view.dart';
import '../../../../shared/error_states/error_view.dart';
import '../../../../shared/loaders/list_shimmer_skeleton.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/skavia_search_field.dart';
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
  final TextEditingController _searchController = TextEditingController();

  List<ConversationModel> _conversations = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final userId = _authController.user?.uid ?? '';
    if (userId.isEmpty) {
      if (mounted) {
        setState(() {
          _conversations = [];
          _isLoading = false;
        });
      }
      return;
    }
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
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final l10n = context.l10n;
    final userId = _authController.user?.uid ?? '';

    final filtered = _conversations.where((c) {
      if (_searchQuery.trim().isEmpty) return true;
      final name = c.otherParticipantName?.toLowerCase() ?? '';
      final msg = c.lastMessageText?.toLowerCase() ?? '';
      final q = _searchQuery.trim().toLowerCase();
      return name.contains(q) || msg.contains(q);
    }).toList();

    final content = RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.messagesTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.messagesSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.secondaryText,
                  ),
                ),
                if (_conversations.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SkaviaSearchField(
                    controller: _searchController,
                    hintText: l10n.messagesSearchHint,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: ListShimmerSkeleton(itemCount: 4),
            )
          else if (_hasError)
            ErrorView(
              scrollable: false,
              title: l10n.messagesErrorTitle,
              message: l10n.commonConnectionError,
              retryText: l10n.commonRetry,
              onRetry: _loadConversations,
            )
          else if (_conversations.isEmpty)
            const ChatEmptyState(shrinkWrap: true)
          else if (filtered.isEmpty)
            EmptyDataView(
              scrollable: false,
              isFiltered: true,
              title: l10n.messagesFilteredEmptyTitle,
              message: l10n.messagesFilteredEmptyMessage,
              actionText: l10n.commonClearFilters,
              onAction: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      return Container(color: theme.scaffoldBackgroundColor, child: content);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppAppBar(title: l10n.messagesTitle),
      body: SafeArea(child: content),
    );
  }
}
