import 'package:flutter/foundation.dart';

@immutable
class ChatMessageModel {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String messageText;
  final String? attachmentUrl;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.messageText,
    this.attachmentUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['message_id'] as String? ?? '',
      conversationId: json['conversation_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      messageText: json['message_text'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message_text': messageText,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

@immutable
class ConversationModel {
  final String conversationId;
  final String? serviceRequestId;
  final String? projectId;
  final String participantOne;
  final String participantTwo;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final String? otherParticipantName;
  final String? otherParticipantAvatar;
  final String? lastMessageText;
  final int unreadCount;

  const ConversationModel({
    required this.conversationId,
    this.serviceRequestId,
    this.projectId,
    required this.participantOne,
    required this.participantTwo,
    required this.lastMessageAt,
    required this.createdAt,
    this.otherParticipantName,
    this.otherParticipantAvatar,
    this.lastMessageText,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final p1 = json['participant_one'] as String? ?? '';
    final p2 = json['participant_two'] as String? ?? '';

    return ConversationModel(
      conversationId: json['conversation_id'] as String? ?? '',
      serviceRequestId: json['service_request_id'] as String?,
      projectId: json['project_id'] as String?,
      participantOne: p1,
      participantTwo: p2,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      otherParticipantName: json['other_name'] as String?,
      otherParticipantAvatar: json['other_avatar'] as String?,
      lastMessageText: json['last_message_text'] as String?,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }

  ConversationModel copyWith({
    String? otherParticipantName,
    String? otherParticipantAvatar,
    String? lastMessageText,
    int? unreadCount,
  }) {
    return ConversationModel(
      conversationId: conversationId,
      serviceRequestId: serviceRequestId,
      projectId: projectId,
      participantOne: participantOne,
      participantTwo: participantTwo,
      lastMessageAt: lastMessageAt,
      createdAt: createdAt,
      otherParticipantName: otherParticipantName ?? this.otherParticipantName,
      otherParticipantAvatar:
          otherParticipantAvatar ?? this.otherParticipantAvatar,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
