import 'dart:convert';

import 'notification_action.dart';
import 'notification_style.dart';

class NotificationPayload {
  const NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    this.channelId = 'default_notifications',
    this.channelName = 'Notificaciones',
    this.style = const BasicNotificationStyle(),
    this.actions = const [],
    this.color,
    this.useCustomBackground = false,
    this.extras = const {},
  });

  final int id;
  final String title;
  final String body;
  final String channelId;
  final String channelName;
  final NotificationStyle style;
  final List<NotificationAction> actions;
  final int? color;
  final bool useCustomBackground;
  final Map<String, dynamic> extras;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'channelId': channelId,
        'channelName': channelName,
        'style': style.toJson(),
        'actions': actions.map((action) => action.toJson()).toList(),
        'color': color,
        'useCustomBackground': useCustomBackground,
        'extras': extras,
      };

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      channelId: json['channelId'] as String? ?? 'default_notifications',
      channelName: json['channelName'] as String? ?? 'Notificaciones',
      style: json['style'] is Map<String, dynamic>
          ? NotificationStyle.fromJson(json['style'] as Map<String, dynamic>)
          : const BasicNotificationStyle(),
      actions: (json['actions'] as List<dynamic>? ?? const [])
          .map((action) => NotificationAction.fromJson(action as Map<String, dynamic>))
          .toList(),
      color: (json['color'] as num?)?.toInt(),
      useCustomBackground: json['useCustomBackground'] as bool? ?? false,
      extras: (json['extras'] as Map<dynamic, dynamic>? ?? const {}).cast<String, dynamic>(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory NotificationPayload.fromJsonString(String source) =>
      NotificationPayload.fromJson(jsonDecode(source) as Map<String, dynamic>);
}