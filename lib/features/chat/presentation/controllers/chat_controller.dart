import 'package:flutter/foundation.dart';

import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';

/// Controller managing real-time chat conversations and active message streaming.
class ChatController extends ChangeNotifier {
  final ChatRemoteDataSource _dataSource;

  ChatController({ChatRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? ChatRemoteDataSource();

  List<ConversationModel> _conversations = [];
  List<ConversationModel> get conversations => _conversations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await _dataSource.getConversations(userId);
    } catch (e) {
      debugPrint('[ChatController] loadConversations notice: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    String? attachmentUrl,
  }) async {
    await _dataSource.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      text: text,
      attachmentUrl: attachmentUrl,
    );
  }
}
