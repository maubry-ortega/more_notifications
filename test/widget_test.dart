import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:more_notifications/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methods = MethodChannel('com.example.more_notifications/core');
  const events = EventChannel('com.example.more_notifications/actions');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  testWidgets('gallery initializes the library and sends a basic notification', (tester) async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(methods, (call) async {
      calls.add(call);
      if (call.method == 'initialize') return <dynamic>[];
      if (call.method == 'showNotification') return true;
      return null;
    });
    messenger.setMockStreamHandler(
      events,
      MockStreamHandler.inline(
        onListen: (_, _) async {},
        onCancel: (_) {},
      ),
    );

    await tester.pumpWidget(const NotificationLibraryDemo());
    await tester.pumpAndSettle();

    expect(find.text('Notificaciones posibles'), findsOneWidget);
    await tester.tap(find.byTooltip('Mostrar básica'));
    await tester.pumpAndSettle();

    expect(calls.map((call) => call.method), containsAll(['initialize', 'showNotification']));
    final showCall = calls.firstWhere((call) => call.method == 'showNotification');
    expect((showCall.arguments as Map)['id'], 101);

    messenger.setMockMethodCallHandler(methods, null);
    messenger.setMockStreamHandler(events, null);
  });
}