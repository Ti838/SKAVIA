import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../data/models/chat_message_model.dart';
import '../screens/chat_room_screen.dart';

/// Conversation list tile displaying avatar, contact name, last message snippet, timestamp, and unread badge.
class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final VoidCallback onReturn;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onReturn,
  });

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

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final timeStr = _formatTimestamp(conversation.lastMessageAt);
    final otherId = conversation.participantOne == currentUserId
        ? conversation.participantTwo
        : conversation.participantOne;
    final otherName = conversation.otherParticipantName ?? 'SKAVIA Member';

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              conversationId: conversation.conversationId,
              otherParticipantName: otherName,
              otherParticipantAvatar: conversation.otherParticipantAvatar,
              otherParticipantId: otherId,
            ),
          ),
        );
        onReturn();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: conversation.otherParticipantAvatar,
              name: otherName,
              radius: 26,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessageText ??
                              'Conversation started',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: conversation.unreadCount > 0
                                ? colorScheme.onSurface
                                : tokens.mutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.brandAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: TextStyle(
                              color: tokens.onBrandAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
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
  }
}
