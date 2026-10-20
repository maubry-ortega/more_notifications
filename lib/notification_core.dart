import 'package:flutter/services.dart';
import 'models/notification_payload.dart';

class NotificationCoreEngine {
  // Canal de comunicación compartido con la capa nativa (Android / iOS)
  static const MethodChannel _channel = MethodChannel('com.example.more_notifications/core');

  /// Inicializa los canales nativos de la librería
  static Future<void> initialize() async {
    // Aquí puedes configurar escuchas iniciales o estados globales si se requiere
    print("Inicializando NotificationCoreEngine...");
  }

  /// Muestra una notificación usando el payload agnóstico
  static Future<bool> show(NotificationPayload payload) async {
    try {
      // 1. Extraemos los campos principales del payload estructurado
      final channelId = payload.channelId ?? 'chat_channel';
      final title = payload.title;
      final body = payload.body;

      // 2. Invocamos el MethodChannel nativo enviando el mapa de argumentos
      final bool result = await _channel.invokeMethod('showNotification', {
        'channelId': channelId,
        'title': title,
        'body': body,
      });

      print("Notificación ID: ${payload.id} despachada con éxito.");
      return result;
    } on PlatformException catch (e) {
      print("Error al despachar la notificación nativa: ${e.message}");
      return false;
    }
  }
}