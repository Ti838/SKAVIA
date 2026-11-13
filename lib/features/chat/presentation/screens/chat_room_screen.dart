import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
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
  late final String _currentUserId;
  late String _conversationId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authController.user?.uid ?? 'guest_user';
    _conversationId = widget.conversationId.isNotEmpty
        ? widget.conversationId
        : 'conv_${widget.otherParticipantId}';
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
    _chatDataSource.markMessagesAsRead(
      conversationId: _conversationId,
      currentUserId: _currentUserId,
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _chatDataSource.sendMessage(
        conversationId: _conversationId,
        senderId: _currentUserId,
        text: text,
      );

      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('[ChatRoomScreen] Send message fallback notice: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final roomTitle = widget.otherParticipantName.isNotEmpty
        ? widget.otherParticipantName
        : 'SKAVIA Chat';

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppAppBar(
        title: roomTitle,
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurface),
            color: tokens.cardBg,
            onSelected: (value) {
              if (value == 'call_info') {
                UiFeedbackHelper.showInfo(
                  context,
                  'In-app voice & video calls are not enabled on this build yet. Coordinate securely via direct text chat.',
                );
              } else if (value == 'report') {
                Navigator.pushNamed(context, AppRoutes.submitComplaint);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'call_info',
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_in_talk_outlined,
                      size: 18,
                      color: tokens.brandAccent,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Voice & Video Info',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
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
                stream: _chatDataSource.getMessagesStream(_conversationId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: tokens.softBlueBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 40,
                                color: tokens.brandAccent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Secure Chat Initialized',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Send a message to coordinate service details with $roomTitle.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: tokens.mutedText,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
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
