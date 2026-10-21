import 'package:flutter_test/flutter_test.dart';
import 'package:more_notifications/more_notifications.dart';

void main() {
  group('NotificationPayload serialization', () {
    final styles = <NotificationStyle>[
      const BasicNotificationStyle(),
      const BigTextNotificationStyle(text: 'Full text'),
      const InboxNotificationStyle(lines: ['Line one', 'Line two']),
      MessagingNotificationStyle(
        conversationTitle: 'Team',
        isGroupChat: true,
        groupKey: 'team_chat',
        messages: [
          ChatMessage(
            senderName: 'Ari',
            text: 'Hello',
            timestamp: DateTime.utc(2026, 10, 21),
          ),
        ],
      ),
      const ProgressNotificationStyle(progress: 45, max: 100),
    ];

    for (final style in styles) {
      test('round trips ${style.runtimeType}', () {
        final payload = NotificationPayload(
          id: 23,
          title: 'Title',
          body: 'Body',
          channelId: 'channel',
          channelName: 'Channel',
          style: style,
          actions: const [
            NotificationAction(id: 'reply', label: 'Reply', requiresInput: true),
          ],
          color: 0xFFAA2233,
          useCustomBackground: true,
          extras: const {'entityId': 'abc'},
        );

        final decoded = NotificationPayload.fromJsonString(payload.toJsonString());
        expect(decoded.id, payload.id);
        expect(decoded.channelId, payload.channelId);
        expect(decoded.style.runtimeType, style.runtimeType);
        expect(decoded.actions.single.requiresInput, isTrue);
        expect(decoded.color, payload.color);
        expect(decoded.useCustomBackground, isTrue);
        expect(decoded.extras['entityId'], 'abc');
      });
    }
  });
}