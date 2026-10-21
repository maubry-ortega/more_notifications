# More Notifications

Aplicación Flutter de prueba para mostrar notificaciones locales de Android mediante un `MethodChannel` y una implementación nativa en Kotlin.

## Requisitos

- Flutter y Dart compatibles con las versiones indicadas en `pubspec.yaml`.
- Android Studio o Android SDK con las herramientas de compilación de Android.
- Un teléfono Android o emulador. El puente de notificaciones actual solo está implementado para Android.

## Descargar y ejecutar

Clona el repositorio y entra en la carpeta del proyecto:

```sh
git clone <URL_DEL_REPOSITORIO>
cd more_notifications
flutter pub get
flutter devices
flutter run
```

Selecciona un escenario o pulsa **Enviar todas las pruebas**. En Android 13 o posterior, acepta el permiso de notificaciones cuando aparezca. Si lo denegaste antes, actívalo en los ajustes del sistema: **Ajustes > Aplicaciones > More Notifications > Notificaciones**. El nombre de las opciones puede variar según el fabricante.

Para compilar el APK de depuración:

```sh
flutter build apk --debug
```

## Escenarios incluidos

- Chat de equipo.
- Mensaje directo.
- Recordatorio.
- Aviso importante.
- Novedad.

Los escenarios tienen presentaciones nativas distintas: los chats usan formato de conversación y respuesta rápida; el recordatorio se expande como texto y permite marcarlo como hecho; la alerta usa formato de aviso y abre la app; el boletín muestra una lista expandida de novedades. El interruptor **Fondo personalizado (experimental)** está apagado por defecto. Al activarlo usa vistas nativas `RemoteViews` con fondo de color y texto contrastante, en las áreas de contenido contraída y expandida. Android conserva el control de la carcasa exterior, encabezado, márgenes y presentación de acciones; algunos fabricantes pueden adaptar también el contenido personalizado. No es posible eliminar por completo el diseño del sistema desde una app normal. Son notificaciones locales de prueba, no mensajes push ni avisos programados.

## Permisos y comportamiento

Android 13 y versiones posteriores requieren permiso en tiempo de ejecución para publicar notificaciones. La app lo solicita al intentar enviar la primera. En Android 8 y posteriores se crean canales de notificación. Android conserva la configuración del canal después de crearlo, así que los cambios de importancia o sonido pueden requerir borrar los datos de la app o probar con un identificador de canal nuevo.

La app no recibe mensajes de WhatsApp ni de otro servidor. Para notificaciones remotas hay que integrar un proveedor push, como Firebase Cloud Messaging, configurar sus credenciales y manejar tokens/dispositivos en un backend.

## Estado de Git

El `.gitignore` de la raíz cubre compilaciones, cachés y archivos locales o de firma. En el entorno de desarrollo usado para este proyecto, Git se inicializó dentro de `android/`, no en esta carpeta raíz. En ese estado Git no incluye `lib/`, este README ni el `.gitignore` raíz. Antes de publicar el proyecto, revisa la raíz que muestra `git rev-parse --show-toplevel` y asegúrate de inicializar/versionar el proyecto desde esta carpeta, sin subir claves ni archivos locales. No se modificó la configuración Git existente.

## Mejoras recomendadas

- Mover el permiso de Android a AndroidX Activity Result APIs, para mantener el flujo de permisos moderno y facilitar su prueba.
- Añadir pruebas instrumentadas en dispositivos/emuladores para comprobar las variantes nativas y el comportamiento de sus acciones en distintas versiones de Android.
- Implementar el método del motor en `notification_core.dart` y conectar los modelos de `lib/models/` con el puente nativo; hoy ese motor es una estructura inicial sin despacho real.
- Añadir pruebas unitarias y de widgets para respuestas del canal, denegación del permiso y los escenarios; las pruebas existentes parecen corresponder al contador de la plantilla y necesitan actualizarse.
- Añadir recepción de respuestas rápidas en Dart, además del `Toast` actual, y comprobar compatibilidad y apariencia en varios fabricantes Android.
- Configurar un identificador de aplicación propio antes de distribuir la app y documentar las versiones mínimas de Android que se vayan a soportar.

## Comprobaciones

```sh
flutter analyze
flutter test
```