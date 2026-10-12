import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/tables/database_tables.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final SupabaseClient _supabase;

  ChatRemoteDataSource({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Real-Time WebSocket stream of messages for a specific conversation (SRS 3.1.N)
  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId) {
    try {
      return _supabase
          .from(DatabaseTables.messages)
          .stream(primaryKey: ['message_id'])
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true)
          .map(
            (rows) => rows.map((r) => ChatMessageModel.fromJson(r)).toList(),
          );
    } catch (e) {
      debugPrint('[ChatRemoteDataSource Stream Error]: $e');
      return const Stream.empty();
    }
  }

  /// Sends a secure message and updates conversation last_message_at
  Future<ChatMessageModel?> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    String? attachmentUrl,
  }) async {
    final now = DateTime.now().toIso8601String();
    try {
      final res = await _supabase
          .from(DatabaseTables.messages)
          .insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'message_text': text.trim(),
            'attachment_url': ?attachmentUrl,
            'is_read': false,
            'created_at': now,
          })
          .select()
          .maybeSingle();

      // Update conversation timestamp
      await _supabase
          .from(DatabaseTables.conversations)
          .update({'last_message_at': now})
          .eq('conversation_id', conversationId);

      if (res != null) {
        return ChatMessageModel.fromJson(res);
      }
    } catch (e) {
      debugPrint('[ChatRemoteDataSource sendMessage Error]: $e');
      rethrow;
    }
    return null;
  }

  /// Retrieves all real conversations for the user, populating the other participant's details
  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      final res = await _supabase
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

      final List<ConversationModel> conversations = [];

      for (final raw in (res as List)) {
        final convMap = Map<String, dynamic>.from(raw as Map);
        final p1 = convMap['participant_one'] as String? ?? '';
        final p2 = convMap['participant_two'] as String? ?? '';
        final otherId = p1 == userId ? p2 : p1;

        // Fetch other participant's real name and avatar
        String otherName = 'SKAVIA Member';
        String? otherAvatar;

        try {
          final userRes = await _supabase
              .from(DatabaseTables.users)
              .select('full_name, avatar_url')
              .eq('user_id', otherId)
              .maybeSingle();

          if (userRes != null) {
            otherName = userRes['full_name'] as String? ?? 'SKAVIA Member';
            otherAvatar = userRes['avatar_url'] as String?;
          }
        } catch (_) {}

        // Fetch last message preview
        String? lastMessage;
        int unreadCount = 0;
        try {
          final lastMsgRes = await _supabase
              .from(DatabaseTables.messages)
              .select('message_text, is_read, sender_id')
              .eq('conversation_id', convMap['conversation_id'])
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          if (lastMsgRes != null) {
            lastMessage = lastMsgRes['message_text'] as String?;
          }

          // Count unread messages received by current user
          final unreadRes = await _supabase
              .from(DatabaseTables.messages)
              .select('message_id')
              .eq('conversation_id', convMap['conversation_id'])
              .eq('is_read', false)
              .neq('sender_id', userId);

          unreadCount = (unreadRes as List).length;
        } catch (_) {}

        convMap['other_name'] = otherName;
        convMap['other_avatar'] = otherAvatar;
        convMap['last_message_text'] = lastMessage;
        convMap['unread_count'] = unreadCount;

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

  /// Finds existing conversation between two users or creates a new one
  Future<ConversationModel> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
    String? serviceRequestId,
    String? projectId,
  }) async {
    try {
      // Check if conversation already exists
      final existing = await _supabase
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

      // Create new conversation
      final now = DateTime.now().toIso8601String();
      final newConv = await _supabase
          .from(DatabaseTables.conversations)
          .insert({
            'participant_one': currentUserId,
            'participant_two': otherUserId,
            'service_request_id': ?serviceRequestId,
            'project_id': ?projectId,
            'last_message_at': now,
            'created_at': now,
          })
          .select()
          .single();

      return ConversationModel.fromJson(
        Map<String, dynamic>.from(newConv),
        currentUserId: currentUserId,
      );
    } catch (e) {
      debugPrint('[ChatRemoteDataSource getOrCreateConversation Error]: $e');
      rethrow;
    }
  }

  /// Marks unread messages in conversation as read for the current recipient
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    try {
      await _supabase
          .from(DatabaseTables.messages)
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', currentUserId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('[ChatRemoteDataSource markMessagesAsRead Error]: $e');
    }
  }
}
