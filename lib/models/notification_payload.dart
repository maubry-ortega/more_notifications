import 'dart:convert';

/// Contenedor principal agnóstico para cualquier notificación entrante.
class NotificationPayload {
  final int id;
  final String title;
  final String body;
  final String? channelId;
  final NotificationStyle? style;
  final List<NotificationAction> actions;
  final Map<String, dynamic>? extras;

  const NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    this.channelId,
    this.style,
    this.actions = const [],
    this.extras,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'channelId': channelId,
        'style': style?.toJson(),
        'actions': actions.map((a) => a.toJson()).toList(),
        'extras': extras,
      };

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      channelId: json['channelId'],
      style: json['style'] != null 
          ? NotificationStyle.fromJson(json['style']) 
          : null,
      actions: (json['actions'] as List<dynamic>?)
              ?.map((a) => NotificationAction.fromJson(a))
              .toList() ?? 
          const [],
      extras: json['extras'] as Map<String, dynamic>?,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  
  factory NotificationPayload.fromJsonString(String source) =>
      NotificationPayload.fromJson(jsonDecode(source));
}

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

class NotificationAction {
  final String id;
  final String label;
  final bool requiresInput;
  final String? iconAsset;
  final String? inputPlaceholder;

  const NotificationAction({
    required this.id,
    required this.label,
    this.requiresInput = false,
    this.iconAsset,
    this.inputPlaceholder = "Escribe una respuesta...",
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'requiresInput': requiresInput,
        'iconAsset': iconAsset,
        'inputPlaceholder': inputPlaceholder,
      };

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      requiresInput: json['requiresInput'] ?? false,
      iconAsset: json['iconAsset'],
      inputPlaceholder: json['inputPlaceholder'] ?? "Escribe una respuesta...",
    );
  }
}