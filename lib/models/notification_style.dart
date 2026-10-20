import 'dart:convert';

/// Clase base abstracta para cualquier tipo de estilo visual avanzado.
abstract class NotificationStyle {
  const NotificationStyle();

  Map<String, dynamic> toJson();

  factory NotificationStyle.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'messaging') {
      return MessagingNotificationStyle.fromJson(json);
    }
    throw UnsupportedError('Estilo de notificación no soportado: $type');
  }

  const factory NotificationStyle.messaging({
    required String avatarUrl,
    required String groupKey,
    required String conversationTitle,
    required bool isGroupChat,
    List<ChatMessage> messages,
  }) = MessagingNotificationStyle;
}

/// Estilo especializado para mensajería instantánea (Equivalente a MessagingStyle en Android y Toast con imágenes en Windows)
class MessagingNotificationStyle extends NotificationStyle {
  final String avatarUrl;
  final String groupKey;
  final String conversationTitle;
  final bool isGroupChat;
  final List<ChatMessage> messages;

  const MessagingNotificationStyle({
    required this.avatarUrl,
    required this.groupKey,
    required this.conversationTitle,
    required this.isGroupChat,
    this.messages = const [],
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'messaging',
        'avatarUrl': avatarUrl,
        'groupKey': groupKey,
        'conversationTitle': conversationTitle,
        'isGroupChat': isGroupChat,
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory MessagingNotificationStyle.fromJson(Map<String, dynamic> json) {
    return MessagingNotificationStyle(
      avatarUrl: json['avatarUrl'] ?? '',
      groupKey: json['groupKey'] ?? '',
      conversationTitle: json['conversationTitle'] ?? '',
      isGroupChat: json['isGroupChat'] ?? false,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m))
              .toList() ??
          const [],
    );
  }
}

/// Representa un mensaje individual dentro de la conversación agrupada
class ChatMessage {
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String? avatarUrl;

  const ChatMessage({
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'senderName': senderName,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'avatarUrl': avatarUrl,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderName: json['senderName'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      avatarUrl: json['avatarUrl'],
    );
  }
}