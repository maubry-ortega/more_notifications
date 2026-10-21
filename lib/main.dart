import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NotificationDemoApp());
}

class NotificationDemoApp extends StatelessWidget {
  const NotificationDemoApp({super.key});

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
      home: const NotificationDemoScreen(),
    );
  }
}

class NotificationDemoScreen extends StatefulWidget {
  const NotificationDemoScreen({super.key});

  @override
  State<NotificationDemoScreen> createState() => _NotificationDemoScreenState();
}

class _NotificationDemoScreenState extends State<NotificationDemoScreen> {
  static const MethodChannel _channel = MethodChannel('com.example.more_notifications/core');

  static const _examples = [
    _NotificationExample(
      channelId: 'demo_equipo',
      category: 'CHAT DE EQUIPO',
      style: 'chat',
      title: 'Lucía · Diseño',
      body: 'Ya dejé lista la nueva propuesta. ¿Le echas un vistazo?',
      lines: [],
      icon: Icons.forum_outlined,
      color: Color(0xFF176B5B),
    ),
    _NotificationExample(
      channelId: 'demo_mensaje_directo',
      category: 'MENSAJE DIRECTO',
      style: 'chat',
      title: 'Mateo',
      body: 'Voy saliendo, llego en unos diez minutos.',
      lines: [],
      icon: Icons.chat_bubble_outline,
      color: Color(0xFF3568A8),
    ),
    _NotificationExample(
      channelId: 'demo_recordatorio',
      category: 'RECORDATORIO',
      style: 'reminder',
      title: 'Agenda',
      body: 'Tu reunión de planificación empieza en 15 minutos.',
      lines: [],
      icon: Icons.event_note_outlined,
      color: Color(0xFF8B5B16),
    ),
    _NotificationExample(
      channelId: 'demo_alerta',
      category: 'AVISO IMPORTANTE',
      style: 'alert',
      title: 'Estado del servicio',
      body: 'La sincronización terminó. Tus archivos están al día.',
      lines: [],
      icon: Icons.notifications_active_outlined,
      color: Color(0xFF9C4545),
    ),
    _NotificationExample(
      channelId: 'demo_novedad',
      category: 'NOVEDAD',
      style: 'digest',
      title: 'Boletín semanal',
      body: 'Ya está disponible el resumen de novedades de esta semana.',
      lines: [
        'Nueva bandeja de entrada',
        'Mejoras en las respuestas rápidas',
        'Actualización de privacidad',
      ],
      icon: Icons.campaign_outlined,
      color: Color(0xFF67549A),
    ),
  ];

  final List<String> _activityLog = [];
  bool _isSending = false;
  bool _useCustomBackground = false;

  void _addLog(String message) {
    if (!mounted) return;
    final time = TimeOfDay.now().format(context);
    setState(() {
      _activityLog.insert(0, '$time  $message');
      if (_activityLog.length > 8) _activityLog.removeLast();
    });
  }

  Future<void> _sendExample(_NotificationExample example) async {
    if (_isSending) return;
    setState(() => _isSending = true);
    await _dispatch(example);
    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _sendAllExamples() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    for (final example in _examples) {
      await _dispatch(example);
    }
    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _dispatch(_NotificationExample example) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      _addLog('No enviado: el puente nativo solo está configurado para Android.');
      return;
    }

    try {
      final success = await _channel.invokeMethod<bool>('showNotification', {
        'channelId': example.channelId,
        'style': example.style,
        'title': example.title,
        'body': example.body,
        'color': example.color.toARGB32(),
        'useCustomBackground': _useCustomBackground,
        'lines': example.lines,
      });
      _addLog(success == true
          ? 'Enviada: ${example.category.toLowerCase()} · ${example.title}'
          : 'No enviada: permiso denegado o notificaciones desactivadas.');
    } on PlatformException catch (error) {
      _addLog('Error Android: ${error.message ?? error.code}');
    } on MissingPluginException {
      _addLog('No se encontró el puente nativo. Reinicia la app con flutter run.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Notifications'),
        backgroundColor: const Color(0xFFF7F8F4),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Color(0xFF173B34),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text(
            'Pruebas locales',
            style: TextStyle(
              color: Color(0xFF173B34),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Elige un escenario y envíalo a la barra de notificaciones.',
            style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 15),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _isSending ? null : _sendAllExamples,
            icon: _isSending
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.notifications_active_outlined),
            label: Text(_isSending ? 'Enviando pruebas...' : 'Enviar todas las pruebas'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF176B5B),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Fondo personalizado (experimental)'),
            subtitle: const Text('Colorea el contenido de la notificación; apagado por defecto.'),
            value: _useCustomBackground,
            onChanged: _isSending
                ? null
                : (value) => setState(() => _useCustomBackground = value),
          ),
          const SizedBox(height: 22),
          const Text(
            'ESCENARIOS',
            style: TextStyle(
              color: Color(0xFF53645F),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          for (final example in _examples)
            Card(
              margin: const EdgeInsets.only(bottom: 9),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.blueGrey.shade100),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(14, 7, 8, 7),
                leading: CircleAvatar(
                  backgroundColor: example.color.withValues(alpha: 0.12),
                  foregroundColor: example.color,
                  child: Icon(example.icon),
                ),
                title: Text(
                  example.category,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${example.title}\n${example.body}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                isThreeLine: true,
                trailing: IconButton.filledTonal(
                  tooltip: 'Enviar ${example.category.toLowerCase()}',
                  onPressed: _isSending ? null : () => _sendExample(example),
                  icon: const Icon(Icons.send_outlined),
                ),
              ),
            ),
          const SizedBox(height: 14),
          const Text(
            'ACTIVIDAD',
            style: TextStyle(
              color: Color(0xFF53645F),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          if (_activityLog.isEmpty)
            Text(
              'Todavía no se han enviado notificaciones.',
              style: TextStyle(color: Colors.blueGrey.shade600),
            )
          else
            for (final event in _activityLog)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(event, style: const TextStyle(fontSize: 13)),
              ),
          const SizedBox(height: 14),
          Text(
            'Los chats incluyen respuesta rápida; recordatorios, alertas y resúmenes usan diseños y acciones propios. Android y el fabricante controlan parte de la apariencia. Son pruebas locales, no notificaciones push.',
            style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _NotificationExample {
  const _NotificationExample({
    required this.channelId,
    required this.category,
    required this.style,
    required this.title,
    required this.body,
    required this.lines,
    required this.icon,
    required this.color,
  });

  final String channelId;
  final String category;
  final String style;
  final String title;
  final String body;
  final List<String> lines;
  final IconData icon;
  final Color color;
}