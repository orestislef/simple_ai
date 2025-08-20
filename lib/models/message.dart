class Message {
  final String text;
  final MessageRole role;
  final String timestamp;
  final String id;
  final bool isFavorite;
  final List<String> reactions;
  final Map<String, dynamic> metadata;

  const Message({
    required this.text,
    required this.role,
    required this.timestamp,
    required this.id,
    this.isFavorite = false,
    this.reactions = const [],
    this.metadata = const {},
  });

  Message copyWith({
    String? text,
    MessageRole? role,
    String? timestamp,
    String? id,
    bool? isFavorite,
    List<String>? reactions,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      text: text ?? this.text,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
      isFavorite: isFavorite ?? this.isFavorite,
      reactions: reactions ?? this.reactions,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'role': role.value,
      'timestamp': timestamp,
      'id': id,
      'isFavorite': isFavorite,
      'reactions': reactions,
      'metadata': metadata,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      text: map['text'] ?? '',
      role: MessageRole.fromString(map['role'] ?? 'user'),
      timestamp: map['timestamp'] ?? '',
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      isFavorite: map['isFavorite'] ?? false,
      reactions: List<String>.from(map['reactions'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

enum MessageRole {
  user('user'),
  assistant('ai'),
  system('system'),
  error('error');

  const MessageRole(this.value);
  final String value;

  static MessageRole fromString(String value) {
    switch (value) {
      case 'user':
        return MessageRole.user;
      case 'ai':
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      case 'error':
        return MessageRole.error;
      default:
        return MessageRole.user;
    }
  }

  bool get isUser => this == MessageRole.user;
  bool get isAssistant => this == MessageRole.assistant;
  bool get isError => this == MessageRole.error;
}