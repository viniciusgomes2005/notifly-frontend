class ChatModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? user1Name;
  final String? user2Name;
  final bool isSystem;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.user1Name,
    this.user2Name,
    required this.isSystem,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> j) {
    return ChatModel(
      id: (j['chat_id'] ?? j['id']).toString(),
      user1Id: (j['user_1_id'] ?? '').toString(),
      user2Id: (j['user_2_id'] ?? '').toString(),
      user1Name: j['user_1_name'] as String?,
      user2Name: j['user_2_name'] as String?,
      isSystem: (j['is_system'] as bool?) ?? false,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())
          : null,
      updatedAt: j['updated_at'] != null
          ? DateTime.tryParse(j['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'chat_id': id,
      'user_1_id': user1Id,
      'user_2_id': user2Id,
      'user_1_name': user1Name,
      'user_2_name': user2Name,
      'is_system': isSystem,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

class ChatList {
  final List<ChatModel> chats;
  final int totalCount;

  ChatList({required this.chats, this.totalCount = 0});

  factory ChatList.fromJson(List<dynamic> jsonList) {
    final items = jsonList
        .map((jsonItem) => ChatModel.fromJson(jsonItem))
        .toList();
    return ChatList(chats: items, totalCount: items.length);
  }
}
