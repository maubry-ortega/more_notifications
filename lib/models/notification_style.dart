abstract class NotificationStyle {
  const NotificationStyle();

  Map<String, dynamic> toJson();

  factory NotificationStyle.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'basic' => const BasicNotificationStyle(),
      'bigText' => BigTextNotificationStyle(text: json['text'] as String? ?? ''),
      'inbox' => InboxNotificationStyle(
          lines: (json['lines'] as List<dynamic>? ?? const []).cast<String>(),
        ),
      'messaging' => MessagingNotificationStyle.fromJson(json),
      'progress' => ProgressNotificationStyle(
          progress: json['progress'] as int? ?? 0,
          max: json['max'] as int? ?? 100,
          indeterminate: json['indeterminate'] as bool? ?? false,
        ),
      final type => throw UnsupportedError('Estilo de notificación no soportado: $type'),
    };
  }

  const factory NotificationStyle.basic() = BasicNotificationStyle;

  const factory NotificationStyle.bigText({required String text}) = BigTextNotificationStyle;

  const factory NotificationStyle.inbox({required List<String> lines}) = InboxNotificationStyle;

  const factory NotificationStyle.messaging({
    required String conversationTitle,
    required bool isGroupChat,
    List<ChatMessage> messages,
    String? groupKey,
  }) = MessagingNotificationStyle;

  const factory NotificationStyle.progress({
    required int progress,
    int max,
    bool indeterminate,
  }) = ProgressNotificationStyle;
}

class BasicNotificationStyle extends NotificationStyle {
  const BasicNotificationStyle();

  @override
  Map<String, dynamic> toJson() => const {'type': 'basic'};
}

class BigTextNotificationStyle extends NotificationStyle {
  const BigTextNotificationStyle({required this.text});

  final String text;

  @override
  Map<String, dynamic> toJson() => {'type': 'bigText', 'text': text};
}

class InboxNotificationStyle extends NotificationStyle {
  const InboxNotificationStyle({required this.lines});

  final List<String> lines;

  @override
  Map<String, dynamic> toJson() => {'type': 'inbox', 'lines': lines};
}

class MessagingNotificationStyle extends NotificationStyle {
  const MessagingNotificationStyle({
    required this.conversationTitle,
    required this.isGroupChat,
    this.messages = const [],
    this.groupKey,
  });

  final String conversationTitle;
  final bool isGroupChat;
  final List<ChatMessage> messages;
  final String? groupKey;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'messaging',
        'conversationTitle': conversationTitle,
        'isGroupChat': isGroupChat,
        'groupKey': groupKey,
        'messages': messages.map((message) => message.toJson()).toList(),
      };

  factory MessagingNotificationStyle.fromJson(Map<String, dynamic> json) {
    return MessagingNotificationStyle(
      conversationTitle: json['conversationTitle'] as String? ?? '',
      isGroupChat: json['isGroupChat'] as bool? ?? false,
      groupKey: json['groupKey'] as String?,
      messages: (json['messages'] as List<dynamic>? ?? const [])
          .map((message) => ChatMessage.fromJson(message as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProgressNotificationStyle extends NotificationStyle {
  const ProgressNotificationStyle({
    required this.progress,
    this.max = 100,
    this.indeterminate = false,
  });

  final int progress;
  final int max;
  final bool indeterminate;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'progress',
        'progress': progress,
        'max': max,
        'indeterminate': indeterminate,
      };
}

class ChatMessage {
  const ChatMessage({
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  final String senderName;
  final String text;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'senderName': senderName,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        senderName: json['senderName'] as String? ?? '',
        text: json['text'] as String? ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}