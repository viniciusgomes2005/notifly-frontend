class ChatModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final bool isSystem;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.isSystem,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> j) {
    return ChatModel(
      id: (j['chat_id'] ?? j['id']).toString(),
      user1Id: (j['user_1_id'] ?? '').toString(),
      user2Id: (j['user_2_id'] ?? '').toString(),
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
      'is_system': isSystem,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  ChatModel copyWeird({
    String? id,
    String? user1Id,
    String? user2Id,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatList {
  final List<ChatModel> chats;
  final int totalCount;

  ChatList({required this.chats, this.totalCount = 0});

  factory ChatList.fromJson(List<dynamic> jsonList) {
    List<ChatModel> chatModels = jsonList
        .map((jsonItem) => ChatModel.fromJson(jsonItem))
        .toList();
    return ChatList(chats: chatModels, totalCount: chatModels.length);
  }
}
