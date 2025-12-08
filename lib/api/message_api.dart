part of 'api_manager.dart';

extension MessageApi on ApiManager {
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required TypeMessage kind,
    String? text,
    String? imgUrl,
  }) async {
    final box = Hive.box('userData');
    final tok = box.get('token') as String? ?? '';

    final response = await post(
      'messages',
      {
        'chat_id': chatId,
        'sender_id': senderId,
        'type': kind.toWireStr(),
        if (text != null) 'text_content': text,
        if (imgUrl != null) 'img_url': imgUrl,
      },
      headers: {if (tok.isNotEmpty) 'Authorization': 'Bearer $tok'},
    );

    return MessageModel.fromJson(response['message']);
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    final box = Hive.box('userData');
    final tok = box.get('token') as String? ?? '';

    final response = await get(
      'messages/chat/$chatId',
      headers: {if (tok.isNotEmpty) 'Authorization': 'Bearer $tok'},
    );

    final raw = (response['messages'] as List?) ?? [];
    return raw
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
