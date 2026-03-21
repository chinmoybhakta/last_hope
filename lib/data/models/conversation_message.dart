class ConversationMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? modelUsed;

  ConversationMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.modelUsed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'modelUsed': modelUsed,
    };
  }

  factory ConversationMessage.fromMap(Map<String, dynamic> map) {
    return ConversationMessage(
      id: map['id'],
      content: map['content'],
      isUser: map['isUser'],
      timestamp: DateTime.parse(map['timestamp']),
      modelUsed: map['modelUsed'],
    );
  }
}

class Conversation {
  final String id;
  final String title;
  final List<ConversationMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      title: map['title'],
      messages: (map['messages'] as List)
          .map((m) => ConversationMessage.fromMap(m))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Conversation copyWith({
    String? id,
    String? title,
    List<ConversationMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}