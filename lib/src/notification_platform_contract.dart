import '../models/notification_payload.dart';

/// Contrato universal que toda implementación nativa (Android, Windows, Linux) 
/// debe cumplir para que el core de Dart funcione sin modificaciones.
abstract class NotificationPlatformContract {
  /// Inicializa los canales de comunicación nativos y oyentes de eventos.
  Future<void> initialize();

  /// Despacha y renderiza una notificación usando el payload agnóstico.
  Future<void> showNotification(NotificationPayload payload);

  /// Cancela o elimina una notificación activa según su identificador único.
  Future<void> cancelNotification(int id);

  /// Registra un callback para escuchar cuando el usuario interactúa con la notificación 
  /// (por ejemplo, al hacer clic en un botón o enviar una respuesta con RemoteInput).
  /// [actionId]: Identificador del botón pulsado.
  /// [userResponse]: Texto ingresado por el usuario (si `requiresInput` era true).
  void registerActionHandler(
    void Function(String actionId, String? userResponse) handler,
  );
}