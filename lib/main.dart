import 'dart:async';

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:more_notifications/more_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NotificationLibraryDemo());
}

class NotificationLibraryDemo extends StatelessWidget {
  const NotificationLibraryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'More Notifications',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B5B),
          surface: const Color(0xFFF7F8F4),
        ),
        useMaterial3: true,
      ),
      home: const NotificationGalleryScreen(),
    );
  }
}

class NotificationGalleryScreen extends StatefulWidget {
  const NotificationGalleryScreen({super.key});

  @override
  State<NotificationGalleryScreen> createState() => _NotificationGalleryScreenState();
}

class _NotificationGalleryScreenState extends State<NotificationGalleryScreen> {
  final List<String> _events = [];
  bool _initialized = false;
  bool _busy = false;
  bool _customBackground = false;

  static final _examples = <_GalleryExample>[
    _GalleryExample(
      label: 'BÁSICA',
      description: 'Título y mensaje',
      icon: Icons.notifications_none,
      color: Color(0xFF3568A8),
      payload: NotificationPayload(
        id: 101,
        channelId: 'library_basic',
        channelName: 'Básicas',
        title: 'Pedido confirmado',
        body: 'Tu pedido ya está en camino.',
      ),
    ),
    _GalleryExample(
      label: 'TEXTO EXPANDIDO',
      description: 'Cuerpo largo con formato ampliado',
      icon: Icons.notes,
      color: Color(0xFF176B5B),
      payload: NotificationPayload(
        id: 102,
        channelId: 'library_big_text',
        channelName: 'Mensajes extensos',
        title: 'Resumen del día',
        body: 'Terminaste tres tareas, tienes dos pendientes y el informe semanal ya está listo para revisar.',
        style: NotificationStyle.bigText(
          text: 'Terminaste tres tareas, tienes dos pendientes y el informe semanal ya está listo para revisar. Puedes abrir la app para ver cada detalle.',
        ),
        color: 0xFF176B5B,
      ),
    ),
    _GalleryExample(
      label: 'LISTA / INBOX',
      description: 'Varias líneas en una vista expandida',
      icon: Icons.list_alt,
      color: Color(0xFF67549A),
      payload: NotificationPayload(
        id: 103,
        channelId: 'library_inbox',
        channelName: 'Resúmenes',
        title: 'Novedades del proyecto',
        body: 'Tres actualizaciones nuevas',
        style: NotificationStyle.inbox(lines: [
          'Diseño aprobado por el equipo',
          'Se publicó una versión de prueba',
          'La documentación fue actualizada',
        ]),
        color: 0xFF67549A,
      ),
    ),
    _GalleryExample(
      label: 'CONVERSACIÓN',
      description: 'Mensajes agrupados y respuesta en línea',
      icon: Icons.forum_outlined,
      color: Color(0xFF176B5B),
      payload: NotificationPayload(
        id: 104,
        channelId: 'library_messaging',
        channelName: 'Conversaciones',
        title: 'Lucía',
        body: '¿Puedes revisar el prototipo?',
        style: NotificationStyle.messaging(
          conversationTitle: 'Equipo de diseño',
          isGroupChat: true,
          messages: [
            ChatMessage(
              senderName: 'Lucía',
              text: '¿Puedes revisar el prototipo?',
              timestamp: DateTime.utc(2026, 10, 21, 12),
            ),
            ChatMessage(
              senderName: 'Mateo',
              text: 'Lo veo después de la reunión.',
              timestamp: DateTime.utc(2026, 10, 21, 12, 1),
            ),
          ],
        ),
        actions: [
          NotificationAction(
            id: 'reply',
            label: 'Responder',
            requiresInput: true,
            inputPlaceholder: 'Escribe tu respuesta...',
          ),
        ],
        color: 0xFF176B5B,
      ),
    ),
    _GalleryExample(
      label: 'PROGRESO',
      description: 'Actualiza la misma notificación por ID',
      icon: Icons.downloading_outlined,
      color: Color(0xFF8B5B16),
      payload: NotificationPayload(
        id: 105,
        channelId: 'library_progress',
        channelName: 'Procesos',
        title: 'Descargando actualización',
        body: 'Preparando archivo...',
        style: NotificationStyle.progress(progress: 0),
        color: 0xFF8B5B16,
      ),
      animatedProgress: true,
    ),
    _GalleryExample(
      label: 'ACCIONES',
      description: 'Botones definidos por el integrador',
      icon: Icons.touch_app_outlined,
      color: Color(0xFF9C4545),
      payload: NotificationPayload(
        id: 106,
        channelId: 'library_actions',
        channelName: 'Acciones',
        title: 'Recordatorio: enviar el informe',
        body: 'La entrega está prevista para hoy.',
        style: NotificationStyle.bigText(
          text: 'La entrega está prevista para hoy. Marca la tarea como lista o posponla para más tarde.',
        ),
        actions: [
          NotificationAction(id: 'done', label: 'Hecho', cancelNotification: true),
          NotificationAction(id: 'later', label: 'En una hora'),
        ],
        color: 0xFF9C4545,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeLibrary();
  }

  Future<void> _initializeLibrary() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      _log('La implementación nativa de esta versión es Android.');
      return;
    }
    try {
      await NotificationCoreEngine.initialize(onAction: (event) {
        _log('Acción ${event.actionId} · notificación ${event.notificationId}'
            '${event.userResponse == null ? '' : ' · ${event.userResponse}'}');
      });
      if (mounted) setState(() => _initialized = true);
      _log('Biblioteca inicializada.');
    } on PlatformException catch (error) {
      _log('Error al iniciar: ${error.message ?? error.code}');
    } catch (error) {
      _log('No se pudo iniciar la biblioteca: $error');
    }
  }

  void _log(String text) {
    if (!mounted) return;
    setState(() {
      _events.insert(0, '${TimeOfDay.now().format(context)}  $text');
      if (_events.length > 10) _events.removeLast();
    });
  }

  Future<void> _showExample(_GalleryExample example) async {
    if (!_initialized || _busy) return;
    setState(() => _busy = true);
    try {
      if (example.animatedProgress) {
        for (var progress = 0; progress <= 100; progress += 20) {
          final payload = NotificationPayload(
            id: example.payload.id,
            channelId: example.payload.channelId,
            channelName: example.payload.channelName,
            title: example.payload.title,
            body: progress == 100 ? 'Descarga completa' : 'Descargando: $progress%',
            style: NotificationStyle.progress(progress: progress),
            color: example.payload.color,
            useCustomBackground: _customBackground,
          );
          await NotificationCoreEngine.show(payload);
          await Future<void>.delayed(const Duration(milliseconds: 250));
        }
      } else {
        final payload = NotificationPayload(
          id: example.payload.id,
          channelId: example.payload.channelId,
          channelName: example.payload.channelName,
          title: example.payload.title,
          body: example.payload.body,
          style: example.payload.style,
          actions: example.payload.actions,
          color: example.payload.color,
          useCustomBackground: _customBackground,
          extras: example.payload.extras,
        );
        await NotificationCoreEngine.show(payload);
      }
      _log('Enviada: ${example.label.toLowerCase()}.');
    } on PlatformException catch (error) {
      _log('Error nativo: ${error.message ?? error.code}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelAll() async {
    if (!_initialized) return;
    await NotificationCoreEngine.cancelAll();
    _log('Notificaciones canceladas.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Notifications · Gallery'),
        backgroundColor: const Color(0xFFF7F8F4),
        foregroundColor: const Color(0xFF173B34),
        actions: [
          IconButton(
            tooltip: 'Cancelar todas',
            onPressed: _initialized ? _cancelAll : null,
            icon: const Icon(Icons.notifications_off_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text(
            'Notificaciones posibles',
            style: TextStyle(
              color: Color(0xFF173B34),
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _initialized ? 'Biblioteca lista · Android' : 'Conectando con la biblioteca...',
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Diseño de contenido personalizado'),
            subtitle: const Text('Experimental; Android conserva la cabecera y el marco.'),
            value: _customBackground,
            onChanged: _busy ? null : (value) => setState(() => _customBackground = value),
          ),
          const SizedBox(height: 12),
          for (final example in _examples)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.blueGrey.shade100),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
                leading: CircleAvatar(
                  backgroundColor: example.color.withValues(alpha: 0.12),
                  foregroundColor: example.color,
                  child: Icon(example.icon),
                ),
                title: Text(
                  example.label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(example.description),
                trailing: IconButton.filledTonal(
                  tooltip: 'Mostrar ${example.label.toLowerCase()}',
                  onPressed: _initialized && !_busy ? () => _showExample(example) : null,
                  icon: const Icon(Icons.send_outlined),
                ),
              ),
            ),
          const SizedBox(height: 14),
          const Text(
            'EVENTOS DE ACCIONES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF53645F)),
          ),
          const SizedBox(height: 8),
          if (_events.isEmpty)
            Text('Los clics y respuestas aparecerán aquí.', style: TextStyle(color: Colors.blueGrey.shade600))
          else
            for (final event in _events)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(event, style: const TextStyle(fontSize: 13)),
              ),
        ],
      ),
    );
  }
}

class _GalleryExample {
  _GalleryExample({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.payload,
    this.animatedProgress = false,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final NotificationPayload payload;
  final bool animatedProgress;
}