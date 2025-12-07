part of 'api_manager.dart';

extension MessageApi on ApiManager {
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required TypeMessage kind,
    String? text,
    String? imgUrl,
  }) async {
    final response = await post('/messages', {
      'chat_id': chatId,
      'sender_id': senderId,
      'kind': kind.toWireStr(),
      if (text != null) 'text': text,
      if (imgUrl != null) 'img_url': imgUrl,
    });
    return MessageModel.fromJson(response.data);
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    final response = await get('/chats/$chatId/messages');
    return (response.data as List)
        .map((json) => MessageModel.fromJson(json))
        .toList();
  }
}
