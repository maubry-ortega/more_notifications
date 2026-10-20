import 'models/notification_payload.dart';
import 'src/notification_platform_contract.dart';

/// Fachada principal (Facade) que expone la API pública de la librería.
/// Mantiene todo el motor desacoplado y ofrece métodos sencillos para el desarrollador.
class NotificationCoreEngine {
  /// Instancia de la plataforma activa inyectada mediante el patrón Bridge / Service Locator
  static late final NotificationPlatformContract _platform;
  static bool _isInitialized = false;

  /// Inicializa el motor de notificaciones conectando la plataforma correspondiente.
  /// [platformImplementation]: La implementación nativa específica (ej: AndroidPlatform()).
  static Future<void> init({
    required NotificationPlatformContract platformImplementation,
  }) async {
    if (_isInitialized) return;
    _platform = platformImplementation;
    await _platform.initialize();
    _isInitialized = true;
  }

  /// Muestra una notificación usando el modelo de datos agnóstico [payload].
  static Future<void> show(NotificationPayload payload) async {
    _ensureInitialized();
    await _platform.showNotification(payload);
  }

  /// Cancela una notificación activa según su identificador único [id].
  static Future<void> cancel(int id) async {
    _ensureInitialized();
    await _platform.cancelNotification(id);
  }

  /// Registra un callback global para escuchar las interacciones del usuario 
  /// (como clics en botones o respuestas rápidas con RemoteInput).
  static void onAction(void Function(String actionId, String? userResponse) callback) {
    _ensureInitialized();
    _platform.registerActionHandler(callback);
  }

  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'NotificationCoreEngine no ha sido inicializado. Llama a NotificationCoreEngine.init() primero.',
      );
    }
  }
}