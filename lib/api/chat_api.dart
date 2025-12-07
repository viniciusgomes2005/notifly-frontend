part of 'api_manager.dart';

extension ChatApi on ApiManager {
  Future<ChatModel> createChat({
    required String user1Id,
    required String user2Id,
    bool isSystem = false,
  }) async {
    final response = await post('/chats', {
      'user_1_id': user1Id,
      'user_2_id': user2Id,
      'is_system': isSystem,
    });
    return ChatModel.fromJson(response.data);
  }

  Future<ChatList> getUserChats(String userId) async {
    final response = await get('/users/$userId/chats');
    return ChatList.fromJson(response.data);
  }
}
