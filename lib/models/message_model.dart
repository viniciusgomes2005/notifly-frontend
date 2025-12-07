enum TypeMessage { text, image }

extension TypeMessageX on TypeMessage {
  String toWireStr() {
    switch (this) {
      case TypeMessage.text:
        return 'text';
      case TypeMessage.image:
        return 'image';
    }
  }

  static TypeMessage fromWireStr(String? raw) {
    switch (raw) {
      case 'image':
        return TypeMessage.image;
      case 'text':
      default:
        return TypeMessage.text;
    }
  }
}

enum StatusMessage { sent, delivered, read }

extension StatusMessageX on StatusMessage {
  String toWireStr() {
    switch (this) {
      case StatusMessage.sent:
        return 'sent';
      case StatusMessage.delivered:
        return 'delivered';
      case StatusMessage.read:
        return 'read';
    }
  }

  static StatusMessage fromWireStr(String? raw) {
    switch (raw) {
      case 'delivered':
        return StatusMessage.delivered;
      case 'read':
        return StatusMessage.read;
      case 'sent':
      default:
        return StatusMessage.sent;
    }
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final TypeMessage kind;
  final String? text;
  final String? imgUrl;
  final StatusMessage status;
  final DateTime? createdAt;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.kind,
    this.text,
    this.imgUrl,
    required this.status,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) {
    return MessageModel(
      id: (j['message_id'] ?? j['id']).toString(),
      chatId: (j['chat_id'] ?? '').toString(),
      senderId: (j['sender_id'] ?? '').toString(),
      kind: TypeMessageX.fromWireStr(j['type'] as String?),
      text: j['text_content'] as String?,
      imgUrl: j['img_url'] as String?,
      status: StatusMessageX.fromWireStr(j['status'] as String?),
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message_id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'type': kind.toWireStr(),
      'text_content': text,
      'img_url': imgUrl,
      'status': status.toWireStr(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  MessageModel copyWeird({
    String? id,
    String? chatId,
    String? senderId,
    TypeMessage? kind,
    String? text,
    String? imgUrl,
    StatusMessage? status,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      kind: kind ?? this.kind,
      text: text ?? this.text,
      imgUrl: imgUrl ?? this.imgUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
