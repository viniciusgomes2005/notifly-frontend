part of 'api_manager.dart';

extension ChatApi on ApiManager {
  Future<ChatModel> createChat({
    required String user1Id,
    required String user2Email,
    bool isSystem = false,
  }) async {
    final box = Hive.box('userData');
    final tok = box.get('token') as String? ?? '';

    final response = await post(
      'chats',
      {'user_1_id': user1Id, 'user_2_email': user2Email, 'is_system': isSystem},
      headers: {if (tok.isNotEmpty) 'Authorization': 'Bearer $tok'},
    );

    return ChatModel.fromJson(response['chat']);
  }

  Future<ChatList> getUserChats(String userId) async {
    final box = Hive.box('userData');
    final tok = box.get('token') as String? ?? '';

    final response = await get(
      'chats/user/$userId',
      headers: {if (tok.isNotEmpty) 'Authorization': 'Bearer $tok'},
    );
    return ChatList.fromJson(response['chats']);
  }
}
