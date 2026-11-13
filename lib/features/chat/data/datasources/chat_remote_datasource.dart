import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../data/tables/database_tables.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final SupabaseClient? _supabase;

  // Local optimistic message cache: conversationId -> List<ChatMessageModel>
  static final Map<String, List<ChatMessageModel>> _localMessages = {};
  // Broadcast stream controller for instant real-time optimistic delivery
  static final StreamController<ChatMessageModel> _optimisticMessageBus =
      StreamController<ChatMessageModel>.broadcast();

  ChatRemoteDataSource({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? tryGetSupabaseClient();

  Stream<List<ChatMessageModel>> _createLocalStream(String conversationId) {
    final localList = _localMessages[conversationId] ?? <ChatMessageModel>[];
    final controller = StreamController<List<ChatMessageModel>>();
    controller.add(List<ChatMessageModel>.from(localList));

    final sub = _optimisticMessageBus.stream
        .where((m) => m.conversationId == conversationId)
        .listen((newMsg) {
          final target = _localMessages.putIfAbsent(
            conversationId,
            () => <ChatMessageModel>[],
          );
          if (!target.any((m) => m.messageId == newMsg.messageId)) {
            target.add(newMsg);
          }
          controller.add(List<ChatMessageModel>.from(target));
        });

    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  /// Real-Time WebSocket stream of messages for a specific conversation (SRS 3.1.N)
  /// Combines remote Supabase stream with optimistic client-side messaging for zero-latency.
  Stream<List<ChatMessageModel>> getMessagesStream(String rawConversationId) {
    final conversationId = rawConversationId.trim();
    final localList = _localMessages[conversationId] ?? <ChatMessageModel>[];
    final client = _supabase;

    if (client == null || !UuidUtil.isValidUuid(conversationId)) {
      return _createLocalStream(conversationId);
    }

    try {
      final remoteStream = client
          .from(DatabaseTables.messages)
          .stream(primaryKey: ['message_id'])
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true)
          .map((rows) {
            final remoteMsgs = rows
                .map((r) => ChatMessageModel.fromJson(r))
                .toList();
            final combined = List<ChatMessageModel>.from(remoteMsgs);
            final pending = _localMessages[conversationId] ?? [];
            for (final local in pending) {
              if (!combined.any((m) => m.messageId == local.messageId)) {
                combined.add(local);
              }
            }
            combined.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            return combined;
          })
          .handleError((error) {
            debugPrint('[ChatRemoteDataSource Stream HandleError]: $error');
            return List<ChatMessageModel>.from(localList);
          });

      return remoteStream;
    } catch (e) {
      debugPrint('[ChatRemoteDataSource Stream Error]: $e');
      return _createLocalStream(conversationId);
    }
  }

  /// Sends a secure message and updates conversation last_message_at.
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    String? attachmentUrl,
  }) async {
    final validConvId = conversationId.trim();
    final messageId = UuidUtil.generateV4();
    final now = DateTime.now();

    final localMsg = ChatMessageModel(
      messageId: messageId,
      conversationId: validConvId,
      senderId: senderId,
      messageText: text.trim(),
      attachmentUrl: attachmentUrl,
      isRead: false,
      createdAt: now,
    );

    // 1. Optimistic instant local storage & broadcast
    _localMessages.putIfAbsent(validConvId, () => []).add(localMsg);
    _optimisticMessageBus.add(localMsg);

    // 2. Persist to Supabase if initialized and valid UUID
    final client = _supabase;
    if (client != null && UuidUtil.isValidUuid(validConvId)) {
      try {
        final res = await client
            .from(DatabaseTables.messages)
            .insert({
              'message_id': messageId,
              'conversation_id': validConvId,
              'sender_id': senderId,
              'message_text': text.trim(),
              'attachment_url': attachmentUrl,
              'is_read': false,
              'created_at': now.toIso8601String(),
            })
            .select()
            .maybeSingle();

        try {
          await client
              .from(DatabaseTables.conversations)
              .update({'last_message_at': now.toIso8601String()})
              .eq('conversation_id', validConvId);
        } catch (_) {}

        if (res != null) {
          return ChatMessageModel.fromJson(res);
        }
      } catch (e) {
        debugPrint('[ChatRemoteDataSource sendMessage Supabase notice]: $e');
      }
    }

    return localMsg;
  }

  /// Retrieves all real conversations for the user, populating the other participant's details.
  Future<List<ConversationModel>> getConversations(String userId) async {
    final client = _supabase;
    if (client == null) return [];

    try {
      final res = await client
          .from(DatabaseTables.conversations)
          .select('''
            conversation_id,
            service_request_id,
            project_id,
            participant_one,
            participant_two,
            last_message_at,
            created_at
          ''')
          .or('participant_one.eq.$userId,participant_two.eq.$userId')
          .order('last_message_at', ascending: false);

      final rawList = (res as List)
          .whereType<Map>()
          .map((raw) => Map<String, dynamic>.from(raw))
          .toList();

      if (rawList.isEmpty) return [];

      final otherUserIds = <String>{};
      final conversationIds = <String>[];
      for (final convMap in rawList) {
        final p1 = convMap['participant_one'] as String? ?? '';
        final p2 = convMap['participant_two'] as String? ?? '';
        final otherId = p1 == userId ? p2 : p1;
        if (otherId.isNotEmpty) otherUserIds.add(otherId);
        final convId = convMap['conversation_id']?.toString() ?? '';
        if (convId.isNotEmpty) conversationIds.add(convId);
      }

      final usersById = <String, Map<String, dynamic>>{};
      final lastMsgByConv = <String, String>{};
      final unreadCountByConv = <String, int>{};

      await Future.wait([
        () async {
          if (otherUserIds.isEmpty) return;
          try {
            final users = await client
                .from(DatabaseTables.users)
                .select('user_id, full_name, avatar_url')
                .inFilter('user_id', otherUserIds.toList());
            for (final row in (users as List).whereType<Map>()) {
              final map = Map<String, dynamic>.from(row);
              final uid = map['user_id']?.toString();
              if (uid != null && uid.isNotEmpty) {
                usersById[uid] = map;
              }
            }
          } catch (_) {}
        }(),
        () async {
          if (conversationIds.isEmpty) return;
          try {
            final msgs = await client
                .from(DatabaseTables.messages)
                .select('conversation_id, message_text, is_read, sender_id, created_at')
                .inFilter('conversation_id', conversationIds)
                .order('created_at', ascending: false);
            for (final row in (msgs as List).whereType<Map>()) {
              final convId = row['conversation_id']?.toString() ?? '';
              if (convId.isEmpty) continue;
              if (!lastMsgByConv.containsKey(convId) &&
                  row['message_text'] != null) {
                lastMsgByConv[convId] = row['message_text'].toString();
              }
              final isRead = row['is_read'] as bool? ?? true;
              final senderId = row['sender_id']?.toString() ?? '';
              if (!isRead && senderId != userId) {
                unreadCountByConv[convId] =
                    (unreadCountByConv[convId] ?? 0) + 1;
              }
            }
          } catch (_) {}
        }(),
      ]);

      final List<ConversationModel> conversations = [];
      for (final convMap in rawList) {
        final p1 = convMap['participant_one'] as String? ?? '';
        final p2 = convMap['participant_two'] as String? ?? '';
        final otherId = p1 == userId ? p2 : p1;
        final convId = convMap['conversation_id']?.toString() ?? '';
        final userRes = usersById[otherId];

        convMap['other_name'] =
            userRes?['full_name'] as String? ?? 'SKAVIA Member';
        convMap['other_avatar'] = userRes?['avatar_url'] as String?;
        convMap['last_message_text'] = lastMsgByConv[convId];
        convMap['unread_count'] = unreadCountByConv[convId] ?? 0;

        conversations.add(
          ConversationModel.fromJson(convMap, currentUserId: userId),
        );
      }

      return conversations;
    } catch (e) {
      debugPrint('[ChatRemoteDataSource getConversations Error]: $e');
      return [];
    }
  }

  /// Finds existing conversation between two users or creates a new one with a valid UUID.
  Future<ConversationModel> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
    String? serviceRequestId,
    String? projectId,
  }) async {
    final now = DateTime.now();
    final client = _supabase;

    if (client != null) {
      try {
        final existing = await client
            .from(DatabaseTables.conversations)
            .select()
            .or(
              'and(participant_one.eq.$currentUserId,participant_two.eq.$otherUserId),'
              'and(participant_one.eq.$otherUserId,participant_two.eq.$currentUserId)',
            )
            .maybeSingle();

        if (existing != null) {
          return ConversationModel.fromJson(
            Map<String, dynamic>.from(existing),
            currentUserId: currentUserId,
          );
        }
      } catch (e) {
        debugPrint('[ChatRemoteDataSource checkExisting notice]: $e');
      }
    }

    final newConvId = UuidUtil.generateV4();

    if (client != null) {
      try {
        final newConv = await client
            .from(DatabaseTables.conversations)
            .insert({
              'conversation_id': newConvId,
              'participant_one': currentUserId,
              'participant_two': otherUserId,
              'service_request_id': serviceRequestId,
              'project_id': projectId,
              'last_message_at': now.toIso8601String(),
              'created_at': now.toIso8601String(),
            })
            .select()
            .maybeSingle();

        if (newConv != null) {
          return ConversationModel.fromJson(
            Map<String, dynamic>.from(newConv),
            currentUserId: currentUserId,
          );
        }
      } catch (e) {
        debugPrint('[ChatRemoteDataSource createConversation notice]: $e');
      }
    }

    return ConversationModel(
      conversationId: newConvId,
      participantOne: currentUserId,
      participantTwo: otherUserId,
      serviceRequestId: serviceRequestId,
      projectId: projectId,
      lastMessageAt: now,
      createdAt: now,
    );
  }

  /// Marks unread messages in conversation as read for the current recipient.
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    final client = _supabase;
    if (client == null || !UuidUtil.isValidUuid(conversationId)) return;
    try {
      await client
          .from(DatabaseTables.messages)
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', currentUserId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('[ChatRemoteDataSource markMessagesAsRead notice]: $e');
    }
  }
}
