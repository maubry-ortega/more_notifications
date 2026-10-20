import 'package:flutter_test/flutter_test.dart';
// Asegúrate de importar correctamente tu archivo de modelos
import 'package:more_notifications/models/notification_payload.dart';

void main() {
  group('NotificationPayload Tests', () {
    test('Debe serializar y deserializar un payload con MessagingStyle correctamente', () {
      final original = NotificationPayload(
        id: 101,
        title: "Juan Carlos",
        body: "¿Revisamos el código hoy?",
        channelId: "chat_channel",
        style: NotificationStyle.messaging(
          avatarUrl: "https://example.com/avatar.png",
          groupKey: "dev_team",
          conversationTitle: "Equipo",
          isGroupChat: true,
          messages: [
            ChatMessage(
              senderName: "Juan Carlos",
              text: "¿Revisamos el código hoy?",
              timestamp: DateTime.parse("2026-06-06T12:00:00.000Z"),
            )
          ],
        ),
        actions: [
          const NotificationAction(
            id: "reply",
            label: "Responder",
            requiresInput: true,
          )
        ],
      );

      // Conversión a JSON y reconstrucción
      final jsonString = original.toJsonString();
      final reconstructed = NotificationPayload.fromJsonString(jsonString);

      expect(reconstructed.id, 101);
      expect(reconstructed.title, "Juan Carlos");
      expect(reconstructed.body, "¿Revisamos el código hoy?");
      expect(reconstructed.style, isA<MessagingNotificationStyle>());
      
      final style = reconstructed.style as MessagingNotificationStyle;
      expect(style.groupKey, "dev_team");
      expect(style.messages.length, 1);
      expect(style.messages[0].senderName, "Juan Carlos");
      
      expect(reconstructed.actions.length, 1);
      expect(reconstructed.actions[0].requiresInput, true);
    });
    test('Debe serializar y deserializar MessagingNotificationStyle correctamente', () {
  final style = MessagingNotificationStyle(
    avatarUrl: 'https://example.com/group.png',
    groupKey: 'chat_123',
    conversationTitle: 'Soporte Técnico',
    isGroupChat: true,
    messages: [
      ChatMessage(
        senderName: 'Carlos',
        text: 'Hola, ¿necesitan ayuda?',
        timestamp: DateTime.now(),
      ),
    ],
  );

  final json = style.toJson();
  final reconstructed = MessagingNotificationStyle.fromJson(json);

  expect(reconstructed.conversationTitle, 'Soporte Técnico');
  expect(reconstructed.isGroupChat, true);
  expect(reconstructed.messages.length, 1);
  expect(reconstructed.messages.first.senderName, 'Carlos');
});

test('Debe serializar y deserializar NotificationAction con RemoteInput correctamente', () {
  const action = NotificationAction(
    id: 'quick_reply',
    label: 'Responder',
    requiresInput: true,
    inputPlaceholder: 'Escribe tu mensaje...',
  );

  final jsonMap = action.toJson();
  final reconstructed = NotificationAction.fromJson(jsonMap);

  expect(reconstructed.id, 'quick_reply');
  expect(reconstructed.label, 'Responder');
  expect(reconstructed.requiresInput, isTrue);
  expect(reconstructed.inputPlaceholder, 'Escribe tu mensaje...');
});
  });
}