import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/empty_states/empty_data_view.dart';
import '../../../../shared/error_states/error_view.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';

class ChatRoomScreen extends StatefulWidget {
  final String conversationId;
  final String otherParticipantName;
  final String? otherParticipantAvatar;
  final String otherParticipantId;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.otherParticipantName,
    this.otherParticipantAvatar,
    required this.otherParticipantId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatRemoteDataSource _chatDataSource = ChatRemoteDataSource();
  final AuthController _authController = AuthController();

  bool _isSending = false;
  int _lastMessageCount = 0;
  late final String _currentUserId;
  late final String _conversationId;
  late Stream<List<ChatMessageModel>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authController.user?.uid ?? '';
    _conversationId = widget.conversationId.isNotEmpty
        ? widget.conversationId
        : 'conv_${widget.otherParticipantId}';
    _messagesStream = _chatDataSource.getMessagesStream(_conversationId);
    _markRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _authController.dispose();
    super.dispose();
  }

  void _markRead() {
    if (_currentUserId.isEmpty) return;
    _chatDataSource.markMessagesAsRead(
      conversationId: _conversationId,
      currentUserId: _currentUserId,
    );
  }

  void _resubscribe() {
    setState(() {
      _messagesStream = _chatDataSource.getMessagesStream(_conversationId);
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    if (_currentUserId.isEmpty) {
      UiFeedbackHelper.showError(context, 'Please sign in to send messages.');
      return;
    }

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _chatDataSource.sendMessage(
        conversationId: _conversationId,
        senderId: _currentUserId,
        text: text,
      );

      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      if (mounted) {
        _messageController.text = text;
        UiFeedbackHelper.showError(
          context,
          'Could not send message. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('hh:mm a');
    final tokens = context.skavia;
    final colorScheme = theme.colorScheme;
    final roomTitle = widget.otherParticipantName.isNotEmpty
        ? widget.otherParticipantName
        : 'SKAVIA Chat';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            UserAvatar(
              imageUrl: widget.otherParticipantAvatar,
              name: roomTitle,
              radius: 17,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                roomTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurface),
            color: tokens.cardBg,
            onSelected: (value) {
              if (value == 'report') {
                Navigator.pushNamed(context, AppRoutes.submitComplaint);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(
                      Icons.report_problem_outlined,
                      size: 18,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Report Conversation',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: _messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ErrorView(
                      title: 'Connection Interrupted',
                      message: 'Unable to load messages for this conversation.',
                      onRetry: _resubscribe,
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return EmptyDataView(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Start the Conversation',
                      message:
                          'Send a message to coordinate service details with $roomTitle.',
                    );
                  }

                  if (messages.length > _lastMessageCount) {
                    _lastMessageCount = messages.length;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == _currentUserId;

                      return ChatMessageBubble(
                        message: msg,
                        isMe: isMe,
                        timeFormat: timeFormat,
                      );
                    },
                  );
                },
              ),
            ),
            ChatInputBar(
              controller: _messageController,
              isSending: _isSending,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
