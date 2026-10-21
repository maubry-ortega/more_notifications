# More Notifications

Biblioteca Flutter/Dart para construir notificaciones locales Android con payloads tipados, estilos nativos y acciones configurables. La pantalla de la aplicación es una galería de ejemplos de la biblioteca, no el producto de notificaciones en sí.

## Requisitos y estado

- Flutter/Dart según el SDK de `pubspec.yaml`.
- Implementación nativa disponible actualmente: Android.
- En Android 13 o posterior se solicita permiso al mostrar la primera notificación.
- Las notificaciones son locales. Push remoto requiere integrar FCM u otro servicio por separado.

## Integrar desde otro proyecto

Mientras no se publique en pub.dev, agrega el paquete por ruta local:

```yaml
dependencies:
  more_notifications:
    path: ../more_notifications
```

Inicializa el motor una vez y crea notificaciones con los modelos exportados:

```dart
import 'package:more_notifications/more_notifications.dart';

await NotificationCoreEngine.initialize(
  onAction: (event) {
    print('Acción: ${event.actionId}, texto: ${event.userResponse}');
  },
);

await NotificationCoreEngine.show(
  NotificationPayload(
    id: 42,
    channelId: 'messages',
    channelName: 'Mensajes',
    title: 'Ana',
    body: '¿Nos vemos a las 18?',
    style: NotificationStyle.messaging(
      conversationTitle: 'Amigos',
      isGroupChat: true,
      messages: [
        ChatMessage(
          senderName: 'Ana',
          text: '¿Nos vemos a las 18?',
          timestamp: DateTime.now(),
        ),
      ],
    ),
    actions: const [
      NotificationAction(
        id: 'reply',
        label: 'Responder',
        requiresInput: true,
      ),
    ],
    extras: const {'conversationId': 'abc-123'},
  ),
);

await NotificationCoreEngine.cancel(42);
```

Las acciones vuelven por `onAction` como `NotificationActionEvent`, incluyendo el ID, texto opcional y `extras`. `cancelAll()` elimina todas las notificaciones publicadas por la app. Reutilizar un mismo `id` actualiza la notificación, lo cual sirve para progreso.

## Estilos disponibles

- `NotificationStyle.basic()`: título y texto.
- `NotificationStyle.bigText(text: ...)`: texto largo expandible.
- `NotificationStyle.inbox(lines: ...)`: resumen en varias líneas.
- `NotificationStyle.messaging(...)`: conversación con mensajes y respuesta en línea si se declara una acción con `requiresInput: true`.
- `NotificationStyle.progress(progress: ..., max: ..., indeterminate: ...)`: barra de progreso actualizable.

Las acciones aceptan `id`, `label`, `requiresInput`, `inputPlaceholder` y `cancelNotification`. Los datos adicionales del llamador se pasan en `extras` y se devuelven en el evento de acción.

El ejemplo ejecutable está en `lib/main.dart`: presenta cada estilo y permite lanzar una demostración. La opción experimental de fondo usa `RemoteViews`; Android mantiene la cabecera, marco y acciones del sistema. La apariencia final varía por versión y fabricante. No hay una API Flutter o Android compatible que quite esas decoraciones en Android moderno.

## Ejecutar la galería

```sh
flutter pub get
flutter devices
flutter run
```

Conceda el permiso de notificaciones cuando Android lo solicite. Si se denegó, habilítalo en los ajustes de la app. Para compilar:

```sh
flutter build apk --debug
```

## Validar

```sh
flutter analyze
flutter test
```

## Publicación

El `pubspec.yaml` mantiene `publish_to: none`; para publicar en pub.dev habría que revisar el nombre, descripción, licencia, documentación de plataformas y soporte no Android. El contrato nativo actual no implementa iOS, Linux, Windows ni macOS.